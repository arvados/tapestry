class NamedProxiesController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :warn_bad_proxy_email # when they are here, they can see the red mark in the named proxies table
  before_filter :set_named_proxy, :only => [:show, :edit, :update, :destroy]

  def done
     step = EnrollmentStep.find_by_keyword('named_proxies')
     current_user.complete_enrollment_step(step)
     redirect_to root_path
  end

  def index
    @named_proxies = current_user.named_proxies
  end

  def new
    @named_proxy = NamedProxy.new()
  end

  def edit
  end

  def destroy
    @named_proxy.destroy

    redirect_to(named_proxies_url)
  end


  def create
    @named_proxy = NamedProxy.new(params[:named_proxy])

    @named_proxy.user = current_user

    if @named_proxy.save
      flash[:notice] = 'Designated Proxy successfully saved.'
      redirect_to named_proxies_path
    else
      render :action => 'new'
    end
  end

  def update
    if @named_proxy.update_attributes(params[:named_proxy])
      flash[:notice] = 'Designated proxy was successfully updated.'
      if @named_proxy.bad_email
        UserLog.new(:user => current_user,
                    :comment => "Participant updated the email address of named proxy to #{@named_proxy.name} <#{@named_proxy.email}>, bad e-mail address flag reset").save!
        @named_proxy.bad_email = false
        @named_proxy.save!
      end
      redirect_to named_proxies_path
    else
      render :action => "edit"
    end
  end

  private
  def set_named_proxy
    @named_proxy = NamedProxy.find(params[:id])
  end
end
