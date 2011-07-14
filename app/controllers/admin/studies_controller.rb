class Admin::StudiesController < Admin::AdminControllerBase

  def index
    respond_to do |format|
      format.html
      format.csv { send_data csv_for_studies(@unpaginated_studies), {
                     :filename    => 'PGP Application Studies.csv',
                     :type        => 'application/csv',
                     :disposition => 'attachment' } }
    end
  end

  def edit
    @study = Study.find(params[:id])
  end

  def update
    @study = Study.find(params[:id])
    @study.irb_associate = params[:study].delete(:irb_associate)
    @study.approved = params[:study].delete(:approved)
    @study.requested = false if @study.approved

    if @study.update_attributes(params[:study])
      flash[:notice] = 'Study updated.'
      redirect_to admin_researchers_url
    else
      render :action => 'edit' 
    end
  end

  def destroy
    @study = Study.find params[:id]

    if @study.destroy
      flash[:notice] = 'Study deleted.'
      redirect_to admin_studies_url
    else
      render :action => 'index'
    end
  end

end
