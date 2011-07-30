# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  include Userstamp  

  before_filter :login_required
  before_filter :ensure_tos_agreement
  before_filter :ensure_latest_consent
  before_filter :ensure_recent_safety_questionnaire
  before_filter :ensure_enrolled
  before_filter :only_owner_can_change, :only => [:edit, :update, :destroy]
  before_filter :prevent_setting_ownership, :only => [:create, :update]

  around_filter :profile


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '0123456789abcdef0123456789abcdef'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  protected

  def model_name
    controller_name.classify
  end

  def model
    model_name.constantize
  end

  def only_owner_can_change
    return true if current_user.is_admin?
    if (params[:id] and
        (m=model.find(params[:id])) and
        (cols=m.class.columns_hash))
      ['user_id', 'owner_id', 'created_by'].each do |col|
        if cols.has_key? col and m.attributes[col] != current_user.id
          current_user.log("SECURITY: Tried to modify #{model_name}: value change for unowned record: id #{params[:id]}; params: #{params.inspect()}")
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
                current_user.log("SECURITY: Tried to modify #{model_name}: ownership change: #{k2} to #{v2}; params: #{params.inspect()}")
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
          current_user.log("SECURITY: Tried to modify #{model_name}: ownership change: #{k} to #{v}; params: #{params.inspect()}")
        end
      end
    end
  end

  def ensure_enrolled
    if not logged_in? or current_user.nil? or not current_user.enrolled
      redirect_to unauthorized_user_url
    end
  end

  def ensure_recent_safety_questionnaire
    if logged_in? and current_user and current_user.enrolled and not current_user.has_recent_safety_questionnaire
      redirect_to require_safety_questionnaire_url
    end
  end

  def ensure_tos_agreement
    if logged_in? and current_user and current_user.documents.kind('tos', 'v1').empty?
      redirect_to tos_user_url
    end
  end

  def ensure_latest_consent
    if logged_in? and current_user and current_user.enrolled and current_user.documents.kind('consent', LATEST_CONSENT_VERSION).empty?
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

  # See http://www.dcmanges.com/blog/rails-performance-tuning-workflow
  # and http://ruby-prof.rubyforge.org/files/examples/graph_txt.html
  # and http://ruby-prof.rubyforge.org/
  # Usage: add ?profile=true to your url to get the ruby-prof output.
  # This is not permitted on the production url, for obvious reasons.
  def profile
    return yield if params[:profile].nil? or ROOT_URL == 'my.personalgenomes.org'
    result = RubyProf.profile { yield }
    printer = RubyProf::GraphPrinter.new(result)
    out = StringIO.new
    printer.print(out, 0)
    response.body.replace out.string
    response.content_type = "text/plain"
  end

#  def template_exists?(path)
#    self.view_paths.find_template(path, response.template.template_format)
#    rescue ActionView::MissingTemplate
#      false
#  end

  protect_from_forgery

  # TODO: Move to a separate presenter class instead of a helper.
  def csv_for_study(study,type)

    user_fields = %w(hex e-mail name gh_profile genotype_uploaded address_line_1 address_line_2 address_line_3 city state zip).freeze

    header_row = user_fields.map(&:humanize)
    buf = ''

    CSV.generate_row(header_row, header_row.size, buf)

    study.study_participants.real.send(type).each do |u|
      row = []

      row.push u.hex
      row.push u.email
      row.push u.ccrs.count > 0 ? 'y' : 'n'
      row.push u.genetic_data.count > 0 ? 'y' : 'n'
      row.push u.shipping_address.address_line_1
      row.push u.shipping_address.address_line_2
      row.push u.shipping_address.address_line_3
      row.push u.shipping_address.city
      row.push u.shipping_address.state
      row.push u.shipping_address.zip

      CSV.generate_row(row, row.size, buf)
    end
    buf
  end

private
end
