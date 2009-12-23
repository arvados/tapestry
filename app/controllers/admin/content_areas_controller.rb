class Admin::ContentAreasController < Admin::AdminControllerBase
  add_breadcrumb 'Content Areas', '/admin/content_areas'

  before_filter :set_content_area, :only => [:show, :edit, :update]

  def index
    @content_areas = ContentArea.find(:all)
  end

  def show
    redirect_to admin_content_area_exams_url(@content_area)
  end

  def new
    @content_area = ContentArea.new
  end

  def edit
  end

  def create
    @content_area = ContentArea.new(params[:content_area])

    if @content_area.save
      flash[:notice] = 'ContentArea was successfully created.'
      redirect_to admin_content_areas_path
    else
      render :action => 'new'
    end
  end

  def update
    if @content_area.update_attributes(params[:content_area])
      flash[:notice] = 'Content area was successfully updated.'
      redirect_to admin_content_areas_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @content_area = ContentArea.find(params[:id])
    @content_area.destroy

    redirect_to(admin_content_areas_url)
  end

  private
  def set_content_area
    @content_area = ContentArea.find(params[:id])
    add_breadcrumb @content_area.title
  end
end
