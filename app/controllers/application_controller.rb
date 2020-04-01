# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  include Userstamp

  layout APP_CONFIG['application_layout']

  # cancan
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.info "Access denied on action #{exception.action} : #{exception.subject.inspect}"
    redirect_to unauthorized_user_url, :alert => exception.message
  end

  rescue_from ActionController::RoutingError, :with => :not_found

  before_filter :login_required
  before_filter :ensure_tos_agreement
  before_filter :ensure_latest_consent
  before_filter :ensure_recent_safety_questionnaire
  before_filter :ensure_enrolled
  before_filter :ensure_active
  before_filter :warn_bad_proxy_email
  before_filter :only_owner_can_change, :only => [:edit, :update, :destroy]
  before_filter :prevent_setting_ownership, :only => [:create, :update]
  before_filter :ensure_dataset_release
  before_filter :set_locale

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '0123456789abcdef0123456789abcdef'
  # but not in test
  skip_before_filter :verify_authenticity_token, :if => lambda{ Rails.env == 'test' }

  respond_to :json, :xml, :html
  class MyResponder < ActionController::Responder
    include PublicApiResponder
    include DatatablesResponder
  end

  # Allow forcing of the locale via URL query parameter 'locale'
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # Pass the locale options through in every request, but only if
  # we're not using the default locale
  def default_url_options(options={})
    if I18n.locale != I18n.default_locale
      options.merge!({ :locale => I18n.locale })
    end
    options.merge!({ :protocol => APP_CONFIG["root_url_scheme"].gsub(/[:\/]*/,'') })
  end

  def self.responder
    MyResponder
  end
  def respond_with(resource, options={})
    def_template = :public
    def_template = :privileged if (current_user and
                                   (current_user.is_admin? or
                                    current_user.is_researcher_onirb?))
    super resource, {
      :for => current_user,
      :api_template => def_template,
      :model => model,
      :model_name => model_name
    }.merge(options)
  end

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

  def page_title
    return @page_title if @page_title
    return controller_name.titleize if action_name == 'index'
    item_name = action_name.titleize
    if (action_name == 'show' or action_name == 'edit')
      if params[:id] and model and (ob = model.find_by_id(params[:id]))
        item_name = nil
        if defined? ob.hex
          item_name = ob.hex
        elsif defined? ob.name and ob.name and model != User
          item_name = ob.name
        end
        item_name = "#{ob.crc_id} #{item_name}" if defined? ob.crc_id and ob.crc_id
        item_name ||= "##{ob.id}"
      end
    end
    "#{controller_name.titleize}: #{item_name}"
  end

  protected

  def model_name
    controller_name.classify
  end

  def model
    model_name.constantize rescue nil
  end

  def include_section?(section)
    Section::include_section?(section)
  end

  def check_section_disabled(section)
    section_disabled unless include_section?(section)
  end

  def section_disabled
    redirect_to unauthorized_user_url
  end

  def only_owner_can_change
    return true if current_user and current_user.is_admin?
    @model = model
    if @model.nil? then
      # This is bad; we've got an unhandled controller -> model translation. E-mail site admins.
      UserMailer.error_notification(current_user,"Unable to translate '#{controller_name}' to model name</p><p>#{request.inspect()}</p>").deliver
      return true
    end
    if (params[:id] and
        (m=@model.exists?(params[:id])) and
        (m=@model.find(params[:id])) and
        (cols=m.class.columns_hash))
      ['user_id', 'owner_id', 'created_by'].each do |col|
        if cols.has_key? col and m.attributes[col] != current_user.id
          current_user.log("SECURITY: Tried to modify #{model_name}: value change for unowned record: id #{params[:id]}; params: #{params.inspect()}") if current_user
          flash[:error] = "You do not have permission to edit #{m.class} ##{m.id} -- it belongs to a different user."
          redirect_to :controller => '/'+controller_path
          return false
        end
      end
    end
    true
  end

  def prevent_setting_ownership
    return true if current_user and current_user.is_admin?
    ['user_id', 'owner_id', 'created_by'].each do |col|
      re = Regexp.new("^#{col}$")
      params.each do |k,v|
        if k == controller_name.singularize.underscore then
          begin
            v.each do |k2,v2|
              if re.match k2 then
                v.delete k2
                current_user.log("SECURITY: Tried to modify #{model_name}: ownership change: #{k2} to #{v2}; params: #{params.inspect()}") if current_user
              end
            end
          rescue
            # Make sure we don't blow up if this object is not a real hash.
            # The common object as of Rails 3.0.9 is ActiveSupport::HashWithIndifferentAccess
            # which is a Hash derivative (but the parent is just 'Object').
            # Ward, 2011-08-02
          end
        elsif re.match k then
          params.delete k
          current_user.log("SECURITY: Tried to modify #{model_name}: ownership change: #{k} to #{v}; params: #{params.inspect()}") if current_user
        end
      end
    end
  end

  def ensure_enrolled
    if not logged_in? or current_user.nil? or not current_user.enrolled
      redirect_to unauthorized_user_url
    end
  end

  def ensure_active
    if not current_user.nil? and current_user.enrolled and not current_user.deactivated_at.nil?
      redirect_to deactivated_user_url
    end
  end

  def warn_bad_proxy_email
    if current_user and current_user.has_bad_proxy_email
      flash[:error] = 'One or more of your named proxies has an invalid e-mail address, please <a href="/named_proxies">correct it</a>'
    end
  end

  def ensure_recent_safety_questionnaire
    if logged_in? and current_user and current_user.enrolled and not current_user.has_recent_safety_questionnaire and (not session[:real_uid] or not session[:switch_back_to])
      flash[:warning] = 'You have been redirected to this page because you are due to complete a quarterly safety questionnaire. You will need to complete this before interacting with your PGP account. Thanks!'
      session[:return_to] = request.protocol + request.host_with_port + request.fullpath
      redirect_to require_safety_questionnaire_url
    end
  end

  def ensure_tos_agreement
    if APP_CONFIG['ensure_tos'] && logged_in? and current_user and current_user.documents.kind(Document::TOS, LATEST_TOS_VERSION).empty? and (not session[:real_uid] or not session[:switch_back_to])
      session[:return_to] = request.protocol + request.host_with_port + request.fullpath
      redirect_to tos_user_url
    end
  end

  def ensure_dataset_release
    if logged_in? and current_user and (not session[:real_uid] or not session[:switch_back_to])
      if current_user.datasets.released_to_participant.size != current_user.datasets.seen_by_participant.size
        flash[:warning] = 'You have been redirected to this page because you have new raw genomic data and a preliminary genome analysis to review. Please do so below. Thanks!'
        session[:return_to] = request.protocol + request.host_with_port + request.fullpath
        redirect_to specimen_analysis_data_index_url
      end
    end
  end

  def ensure_latest_consent
    if logged_in? and current_user and current_user.enrolled and current_user.documents.kind('consent', APP_CONFIG['latest_consent_version']).empty? and current_user.documents.kind('consent', APP_CONFIG['ok_consent_versions']).empty? and (not session[:real_uid] or not session[:switch_back_to])
      session[:return_to] = request.protocol + request.host_with_port + request.fullpath
      redirect_to consent_user_url
    end
  end

  def ensure_researcher
    if not logged_in? or current_user.nil? or (not current_user.is_researcher? and not current_user.is_admin?)
      redirect_to unauthorized_user_url
    end
  end

  def ensure_admin
    if not logged_in? or current_user.nil? or not current_user.is_admin?
      redirect_to unauthorized_user_url
    end
  end

  def add_breadcrumb name, url = ''
    @breadcrumbs ||= []
    url = eval(url) if url =~ /_path|_url|@/
    @breadcrumbs << [name, url]
  end

  def self.add_breadcrumb name, url, options = {}
    before_filter options do |controller|
      controller.send(:add_breadcrumb, name, url)
    end
  end

#  def template_exists?(path)
#    self.view_paths.find_template(path, response.template.template_format)
#    rescue ActionView::MissingTemplate
#      false
#  end

  # TODO: Move to a separate presenter class instead of a helper.
  def csv_for_study(study,type)
    @participants = study.study_participants.real.send(type)
    @participants = StudyParticipant.
      includes({:user => [:shipping_address,
                          :user_files,
                          :ccrs,
                          {:kits => :kit_logs}]}).
      where('study_participants.id in (?)', @participants.collect(&:id))
    csv_for_study_worker(study,@participants)
  end

  def csv_for_study_worker(study,participants)

    if not @study.is_third_party or current_user.is_admin? or current_user.researcher_onirb
      user_fields = %w(hex token e-mail name gh_profile genotype_uploaded address_line_1 address_line_2 address_line_3 city state zip phone_number kit_last_sent_at kit_name kit_status kit_status_changed other_kits).freeze
    else
      user_fields = %w(token).freeze
    end

    FasterCSV.generate(String.new, :force_quotes => true) do |csv|

      csv << user_fields.map(&:humanize)

      participants.each do |u|
        row = []

        if study.is_third_party and not current_user.is_admin? and not current_user.researcher_onirb
          csv << [u.user.app_token("Study##{study.id}")]
          next
        end

        row.push u.user.hex
        row.push u.user.app_token("Study##{study.id}")
        row.push u.user.email
        row.push u.user.full_name
        row.push u.user.ccrs.size > 0 ? 'y' : 'n'
        row.push u.user.user_files.size > 0 ? 'y' : 'n'
        if include_section?(Section::SHIPPING_ADDRESS) && u.user.shipping_address then
          row.push u.user.shipping_address.address_line_1
          row.push u.user.shipping_address.address_line_2
          row.push u.user.shipping_address.address_line_3
          row.push u.user.shipping_address.city
          row.push u.user.shipping_address.state
          row.push u.user.shipping_address.zip
          if not study.shipping_address_required and
              study.phone_number_required and
              u.user.phone_number then
            # user has phone number listed with shipping address, but
            # was reminded to update the "account" phone number when
            # signing up, so we should use the latter.
            row.push u.user.phone_number
          else
            row.push u.user.shipping_address.phone
          end
        else
          6.times do
            row.push ''
          end
          row.push u.user.phone_number
        end

        row.push u.kit_last_sent_at
        claimed_kit, claimed_kit_at = u.claimed_kit_sent_at(u.kit_last_sent_at)
        if claimed_kit
          row.push claimed_kit.name
          row.push claimed_kit.short_status
          row.push claimed_kit.status_changed_at
        else
          3.times { row.push '' }
        end
        row.push u.user.kits.
          select { |k| k != claimed_kit and k.study_id==study.id }.
          collect(&:name).
          join(' ')

        csv << row
      end
    end
  end

  def not_found
    respond_to do |f|
      f.json do
        render(:status => 404,
               :json => {:errors => ['Page not found']})
      end
      f.html do
        render(:status => 404,
               :layout => false,
               :file => Rails.root.join('public', '404.html'))
      end
    end
  end

  def load_selection
    if params[:selection_id]
      if params[:selection_id].to_s.index('_')
        (s_id, s_tok) = params[:selection_id].to_s.split('_')
        @selection ||= Selection.where('id=? and unguessable=?', s_id, s_tok).first
      else
        @selection ||= Selection.visible_to(current_user).where('id=?', params[:selection_id]).first
      end
    end
  end

end
