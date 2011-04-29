class NamedProxiesController < ApplicationController
  skip_before_filter :ensure_enrolled
  before_filter :set_named_proxy, :only => [:show, :edit, :update]

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
    @named_proxy = NamedProxy.find(params[:id])
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
      redirect_to named_proxies_path
    else
      render :action => "edit"
    end
  end


#    puts params.inspect()
#    if params[:proxy1_name] != '' then
#      np = NamedProxy.new(:name => params[:proxy1_name], :email => params[:proxy1_email], :user => current_user)
#      #current_user.named_proxies << np
#      #np.save
#      #np.errors.each_full { |msg| flash[:error] += msg + "<br/>" }
#    end
#    if params[:proxy2_name] != '' then
#      np = NamedProxy.new(:name => params[:proxy2_name], :email => params[:proxy2_email])
#      current_user.named_proxies << np
#    end
#    if current_user.save then
#      puts "OK"
#      show
#      render :action => 'show'
#    else
#      flash[:error] = ''
#      puts "NOK"
#      show
#      render :action => 'show'
#    end
  #  if params[:pledge] =~ /[0-9\.]+/ && params[:pledge].to_f >= 0 && current_user.update_attribute(:pledge, params[:pledge])
  #    step = EnrollmentStep.find_by_keyword('pledge')
  #    current_user.complete_enrollment_step(step)
  #    redirect_to root_path
  #  else
  #    flash[:error] = 'You should make a pledge in number of US dollars.'
  #    show
#      render :action => 'show'
  #  end
#  end
  private
  def set_named_proxy
    @named_proxy = NamedProxy.find(params[:id])
  end
end
