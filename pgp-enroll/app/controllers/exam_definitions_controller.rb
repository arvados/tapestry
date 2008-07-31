class ExamDefinitionsController < ApplicationController
  # GET /exam_definitions
  # GET /exam_definitions.xml
  def index
    @exam_definitions = ExamDefinition.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exam_definitions }
    end
  end

  # GET /exam_definitions/1
  # GET /exam_definitions/1.xml
  def show
    @exam_definition = ExamDefinition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @exam_definition }
    end
  end

  # GET /exam_definitions/new
  # GET /exam_definitions/new.xml
  def new
    @exam_definition = ExamDefinition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @exam_definition }
    end
  end

  # GET /exam_definitions/1/edit
  def edit
    @exam_definition = ExamDefinition.find(params[:id])
  end

  # POST /exam_definitions
  # POST /exam_definitions.xml
  def create
    @exam_definition = ExamDefinition.new(params[:exam_definition])

    respond_to do |format|
      if @exam_definition.save
        flash[:notice] = 'ExamDefinition was successfully created.'
        format.html { redirect_to(@exam_definition) }
        format.xml  { render :xml => @exam_definition, :status => :created, :location => @exam_definition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @exam_definition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /exam_definitions/1
  # PUT /exam_definitions/1.xml
  def update
    @exam_definition = ExamDefinition.find(params[:id])

    respond_to do |format|
      if @exam_definition.update_attributes(params[:exam_definition])
        flash[:notice] = 'ExamDefinition was successfully updated.'
        format.html { redirect_to(@exam_definition) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @exam_definition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /exam_definitions/1
  # DELETE /exam_definitions/1.xml
  def destroy
    @exam_definition = ExamDefinition.find(params[:id])
    @exam_definition.destroy

    respond_to do |format|
      format.html { redirect_to(exam_definitions_url) }
      format.xml  { head :ok }
    end
  end
end
