class Admin::AdminControllerBase < ApplicationController
  before_filter :ensure_admin
  skip_before_filter :ensure_enrolled

end
