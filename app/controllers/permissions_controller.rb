class PermissionsController < ApplicationController
  load_and_authorize_resource

  skip_before_filter :ensure_enrolled
  before_filter :ensure_researcher

  # GET /permissions
  # GET /permissions.xml
  def index
    @permissions_granted_to = Permission.find_all_by_granted_to_id(current_user.id)
    @permissions_granted_by = Permission.find_all_by_granted_by_id(current_user.id)
  end

  # POST /permissions
  # POST /permissions.xml
  def create
    @permission.granted_by = current_user
    @permission.subject_id = nil if @permission.subject_id == 0
    respond_to do |format|
      if @permission.save
        format.html { redirect_to(permissions_url, :notice => 'Permission was successfully granted.') }
        format.xml  { render :xml => @permission, :status => :created, :location => @permission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /permissions/1
  # DELETE /permissions/1.xml
  def destroy
    @permission.destroy
    respond_to do |format|
      format.html { redirect_to(permissions_url) }
      format.xml  { head :ok }
    end
  end

  def edit
  end

  def update
    params[:permission]['subject_id'] = nil if params[:permission]['subject_id'] == "0"
    respond_to do |format|
      if @permission.update_attributes(params[:permission])
        format.html { redirect_to(permissions_url, :notice => 'Permission was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @permission.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_subject_select
    @subject_id = nil
    if params.has_key?(:id) then
      permission = Permission.find(params[:id])
      if permission.subject_class == params[:subject_class] then
        @subject_id = permission.subject_id
      end
    end
    if params[:subject_class] == 'Kit' then
      objects = Kit.where(:owner_id=>current_user.id)
      @o2 = [ ["All", 0] ].concat(objects.collect { |o| [o.name, o.id] })
    elsif params[:subject_class] == 'Plate' then
      objects = Plate.where(:creator_id=>current_user.id)
      @o2 = [ ["All", 0] ].concat(objects.collect { |o| [o.description, o.id] })
    elsif params[:subject_class] == 'Sample' then
      objects = Sample.where(:owner_id=>current_user.id)
      @o2 = [ ["All", 0] ].concat(objects.collect { |o| [o.name, o.id] })
    end 
    respond_to do |format|
      format.js
    end
  end


end
