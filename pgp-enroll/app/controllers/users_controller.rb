class UsersController < ApplicationController
  before_filter :ensure_current_user_may_edit_this_user, :except => [ :new, :new2, :create, :activate ]
  skip_before_filter :login_required, :only => [:new, :new2, :create, :activate]

  def new
    @user = User.new(params[:user])
  end

  def new2
    @user = User.new(params[:user])

    if @user.valid_for_attrs?(params[:user].keys)
      @user.errors.clear
    else
      render :template => 'users/new'
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User updated.'
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    success = @user && verify_recaptcha(@user) && @user.save

    if success && @user.errors.empty?
      redirect_to root_url
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "Please double-check your signup information below."
      render :action => 'new2'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:code]) unless params[:code].blank?
    case
    when (!params[:code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  private

  def ensure_current_user_may_edit_this_user
    redirect_to root_url unless current_user && ( current_user.id == params[:id].to_i ) # || curren_user.admin?
  end
end
