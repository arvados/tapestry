# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem

  filter_parameter_logging "password"
  before_filter :login_required
  before_filter :ensure_tos_agreement
  before_filter :ensure_latest_consent
  before_filter :ensure_recent_safety_questionnaire
  before_filter :ensure_enrolled

  around_filter :profile


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '0123456789abcdef0123456789abcdef'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  protected

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

  def template_exists?(path)
    self.view_paths.find_template(path, response.template.template_format)
    rescue ActionView::MissingTemplate
      false
  end

end
