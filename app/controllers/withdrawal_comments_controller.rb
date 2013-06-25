class WithdrawalCommentsController < ApplicationController
  skip_before_filter :ensure_active
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire
  skip_before_filter :ensure_tos_agreement
  before_filter :ensure_admin, :only => [:index]

  # GET /withdrawal_comments
  # GET /withdrawal_comments.xml
  def index
    @withdrawal_comments = WithdrawalComment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @withdrawal_comments }
    end
  end

  # GET /withdrawal_comments/1
  # GET /withdrawal_comments/1.xml
  def show
    @withdrawal_comment = WithdrawalComment.find(params[:id])
    return access_denied unless current_user.is_admin? or @withdrawal_comment.user == current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @withdrawal_comment }
    end
  end

  # GET /withdrawal_comments/new
  # GET /withdrawal_comments/new.xml
  def new
    @withdrawal_comment = WithdrawalComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @withdrawal_comment }
    end
  end

  # POST /withdrawal_comments
  # POST /withdrawal_comments.xml
  def create
    @withdrawal_comment = WithdrawalComment.new(params[:withdrawal_comment])
    @withdrawal_comment.created_at = Time.now
    @withdrawal_comment.user = current_user

    respond_to do |format|
      if @withdrawal_comment.save
        flash[:notice] = 'Your comments have been recorded for our review.  Thank you.'
        format.html { redirect_to @withdrawal_comment }
        format.xml  { render :xml => @withdrawal_comment, :status => :created, :location => @withdrawal_comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @withdrawal_comment.errors, :status => :unprocessable_entity }
      end
    end
  end
end
