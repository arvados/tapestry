# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  include HoptoadNotifier::Catcher

  filter_parameter_logging "password"
  before_filter :login_required
  before_filter :ensure_tos_agreement


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '0123456789abcdef0123456789abcdef'

  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  protected

  def ensure_tos_agreement
  STDERR.puts self.controller_name
  STDERR.puts self.action_name
    if logged_in? and current_user and current_user.documents.kind('tos', 'v1').empty?
      redirect_to tos_user_url
#      redirect_to url_for(:controller => 'users', :action => 'tos')
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

end
