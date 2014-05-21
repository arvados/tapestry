class Admin::MailingListsController < Admin::AdminControllerBase

  before_filter :set_mailing_list, :only => [:edit, :update]

  def index
    @mailing_lists = MailingList.all
  end

  def edit
  end

  def new
    @mailing_list = MailingList.new
  end

  def create
    @mailing_list = MailingList.new(params[:mailing_list])

    if @mailing_list.save
      flash[:notice] = 'Mailing list was successfully created.'
      redirect_to admin_mailing_lists_path
    else
      render :action => 'new'
    end
  end

  def update
    if @mailing_list.update_attributes(params[:mailing_list])
      flash[:notice] = 'Mailing list was successfully updated.'
      redirect_to admin_mailing_lists_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @mailing_list = MailingList.find(params[:id])
    @mailing_list.destroy

    redirect_to(admin_mailing_lists_url)
  end

  private
  def set_mailing_list
    @mailing_list = MailingList.find(params[:id])
  end
end
