class PlatesController < ApplicationController
  load_and_authorize_resource :except => [:mobile, :mobile_assign_position, :mobile_destroy_position, :destroy_sample]

  skip_before_filter :ensure_enrolled
  before_filter :ensure_researcher

  # GET /plates/1
  # GET /plates/1.xml
  def show
    prepare_layout_grid
  end

  # POST /plates
  # POST /plates.xml
  def create
    respond_to do |format|
      if @plate.save
        format.html { redirect_to(@plate, :notice => 'Plate was successfully created.') }
        format.xml  { render :xml => @plate, :status => :created, :location => @plate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @plate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /plates/1
  # PUT /plates/1.xml
  def update
    respond_to do |format|
      if @plate.update_attributes(params[:plate])
        format.html { redirect_to(@plate, :notice => 'Plate was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @plate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /plates/1
  # DELETE /plates/1.xml
  def destroy
    @plate.destroy

    respond_to do |format|
      format.html { redirect_to(plates_url) }
      format.xml  { head :ok }
    end
  end

  def prepare_layout_grid
    @current_mask = nil if !defined? @current_mask

    @positions = @plate.plate_layout.plate_layout_positions

    # Draw the current plate layout, marking each position as empty/full/unusable/masked/next
    @xpositions = @positions.collect { |pos| pos.xpos }.sort.uniq
    @ypositions = @positions.collect { |pos| pos.ypos }.sort.uniq
    @grid = []
    @positions.each { |pos|
      @grid[pos.ypos] = [] unless @grid[pos.ypos]
      @grid[pos.ypos][pos.xpos] = { :position => pos, :class => "empty" }
    }
    @plate.plate_samples.each { |ps|
      pos = ps.plate_layout_position
      @grid[pos.ypos][pos.xpos][:sample] = ps.sample if ps.sample
      if ps.is_unusable
        @grid[pos.ypos][pos.xpos][:class] = "unusable"
      elsif ps.sample
        @grid[pos.ypos][pos.xpos][:class] = "has_sample"
      end
    }

    # Apply the mask to the CSS classes
    @positions.each { |pos|
      unless @current_mask.nil? or @current_mask.exposed? pos
        c = @grid[pos.ypos][pos.xpos][:class].concat(' masked')
        @grid[pos.ypos][pos.xpos][:class] = c
      end
    }
  end

  def mobile
    @plate = Plate.find_by_url_code(params[:url_code])
    authorize! :update, @plate
    if not @plate then
      # They mistyped a url
      redirect_to page_url('researcher_tools')
      return
    end
    @page_title = "Plate #{@plate.crc_id}"

    # Determine the currently selected mask
    @current_mask = nil
    if session[:plate_layout_mask_id]
      @current_mask = PlateLayoutMask.find(session[:plate_layout_mask_id])
    end
    @current_mask = PlateLayoutMask.all[0] unless @current_mask

    # Tell the "scan sample bar code" handler to come back here
    session[:scan_context_timestamp] = Time.now.to_i
    session[:scan_context_path] = mobile_plate_path(@plate.url_code)
    session[:scan_context_gerund] = "transferring samples to plate #{@plate.crc_id}"

    prepare_layout_grid

    # Determine the next available position (if any) in this plate, subject to mask
    @next_pos = nil
    @ypositions.each { |y|
      @xpositions.each { |x|
        if @grid[y][x][:class] == "empty"
          @next_pos = @grid[y][x][:position]
          @grid[y][x][:class] = "next_available"
          break
        end
      }
      break if @next_pos
    }

    if params[:s] and (s=Sample.find_by_crc_id(params[:s].to_i))
      session[:scan_sample_url_code] = s.url_code
    end

    # Look up last sample scanned
    if session[:scan_sample_url_code]
      @scanned_sample = Sample.find_by_url_code(session[:scan_sample_url_code])
    else
      @scanned_sample = nil
    end

    # Choices of masks
    @masks = PlateLayoutMask.all.sort

    render :layout => 'mobile'
  end

  def mobile_select_layout_mask
    session[:plate_layout_mask_id] = params[:plate_layout_mask_id]
    redirect_to mobile_plate_path(params[:url_code])
  end

  def mobile_assign_position
    # Assign a sample to a well
    @plate = Plate.find(params[:plate_id])
    authorize! :update, @plate
    @sample = Sample.find(params[:sample_id])
    @next_pos = PlateLayoutPosition.find(params[:plate_layout_position_id])
    @ps = PlateSample.new(:plate => @plate, :sample => @sample, :plate_layout_position => @next_pos)
    @ps.save!
    SampleLog.new(:actor => current_user,
                  :comment => "Sample transferred to plate #{@plate.crc_id} (id=#{@plate.id}) well #{@next_pos.name} (id=#{@next_pos.id})",
                  :sample_id => @sample.id).save
    session[:scan_sample_url_code] = nil
    redirect_to mobile_plate_path(@plate.url_code)
  end

  def mobile_destroy_position
    # Mark an empty well as destroyed/unusable
    @plate = Plate.find(params[:plate_id])
    authorize! :update, @plate
    @next_pos = PlateLayoutPosition.find(params[:plate_layout_position_id])
    @ps = PlateSample.new(:plate => @plate, :is_unusable => true, :plate_layout_position => @next_pos)
    @ps.save!
    redirect_to mobile_plate_path(@plate.url_code)
  end

  def mobile_stop
    session.delete :scan_context_path
    session.delete :scan_context_timestamp
    session.delete :scan_context_gerund
    if params[:id] and (p=Plate.find(params[:id]))
      redirect_to p
    else
      redirect_to page_url('researcher_tools')
    end
  end

  def destroy_sample
    @plate = Plate.find(params[:plate_id])
    authorize! :update, @plate
    # Mark an already-filled well as destroyed/unusable
    @ps = PlateSample.find_by_plate_id_and_plate_layout_position_id(params[:plate_id], params[:plate_layout_position_id])
    @pos = @ps.plate_layout_position
    SampleLog.new(:actor => current_user,
                  :comment => "Plate #{@ps.plate.crc_id} (id=#{@ps.plate.id}) well #{@pos.name} (id=#{@pos.id}) destroyed",
                  :sample_id => @ps.sample.id).save if @ps.sample and !@ps.is_unusable
    @ps.is_unusable = true
    @ps.save!
    redirect_to plate_path(@ps.plate.id)
  end

end
