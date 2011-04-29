class Admin::AdminControllerBase < ApplicationController
  before_filter :admin_required
  skip_before_filter :ensure_enrolled

  private

  def admin_required
    redirect_to login_url unless current_user && current_user.is_admin?
  end
end
