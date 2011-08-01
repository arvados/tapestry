class Admin::ResearchersController < Admin::AdminControllerBase

  def index 
    @requested_studies = Study.requested
    @approved_studies = Study.approved
    @draft_studies = Study.draft
  end

end
