class GoogleSpreadsheetsController < ApplicationController

  before_filter :ensure_researcher

  def index
    if current_user.is_admin?
      @google_spreadsheets = GoogleSpreadsheet.all
    else
      @google_spreadsheets = GoogleSpreadsheet.where(:user_id => current_user.id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @google_spreadsheets }
    end
  end

  def show
    find_mine

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @google_spreadsheet }
    end
  end

  def new
    @google_spreadsheet = GoogleSpreadsheet.new(:user => current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @google_spreadsheet }
    end
  end

  def edit
    find_mine
  end

  def create
    @google_spreadsheet = GoogleSpreadsheet.new(params[:google_spreadsheet])
    @google_spreadsheet.user_id = current_user.id
    @google_spreadsheet.guess_fields_from_feed

    respond_to do |format|
      if @google_spreadsheet.save
        format.html { redirect_to(@google_spreadsheet, :notice => 'Google spreadsheet was successfully created.') }
        format.xml  { render :xml => @google_spreadsheet, :status => :created, :location => @google_spreadsheet }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @google_spreadsheet.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    find_mine

    respond_to do |format|
      if @google_spreadsheet.update_attributes(params[:google_spreadsheet])
        @google_spreadsheet.guess_fields_from_feed
        format.html { redirect_to(@google_spreadsheet, :notice => 'Google spreadsheet was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @google_spreadsheet.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    find_mine
    @google_spreadsheet.destroy

    respond_to do |format|
      format.html { redirect_to(google_spreadsheets_url) }
      format.xml  { head :ok }
    end
  end

  def synchronize
    find_mine
    ok, error_message = @google_spreadsheet.synchronize!
    if ok
      flash[:notice] = 'Spreadsheet data downloaded at ' + @google_spreadsheet.last_downloaded_at.to_s
    else
      flash[:error] = error_message
    end
    redirect_to google_spreadsheet_path(@google_spreadsheet)
  end

  def find_mine
    if current_user.is_admin?
      @google_spreadsheet = GoogleSpreadsheet.
        find(params[:id])
    else
      @google_spreadsheet = GoogleSpreadsheet.
        where(:user_id => current_user.id).
        find(params[:id])
    end
  end

end
