class Admin::ResearchersController < Admin::AdminControllerBase

  def index 
    @requested_studies = Study.where('requested = ?',true)
    @approved_studies = Study.where('approved = ?',true)
    @draft_studies = Study.where('requested = ? and approved != ?',false,true)
  end

end
