class Admin::ResearchersController < Admin::AdminControllerBase

  # researchers and admins only
  before_filter :ensure_researcher

  def index
    @requested_studies = Study.requested
    @approved_studies = Study.approved
    @draft_studies = Study.draft
  end

  def study_filter_results
    if not params.has_key?('object') then
      raise 'No object defined'
    end

    if params['object'] == 'User' then
      if params['f'].include?('study') then
        @study = Study.find(params['v']['study'])

        @statuses = params['v']['study_status']
        @statuses.reject! { |s| s.empty? }

        @study_participants = []

        @statuses.each do |s|
          @study_participants = @study_participants | @study.study_participants.send(s)
        end

        if params['f'].include?('kits_sent') then
          # Ruby 1.9.2 introduces Array.keep_if
          @study_participants.delete_if { |p|
            ! Kit.study(@study.id).participant(p.user.id).size.send(params['op']['kits_sent'],params['v']['kits_sent'].to_i) ||
            ! @study.study_participants.where('user_id=? and kit_last_sent_at', p.user.id).size.send(params['op']['kits_sent'],params['v']['kits_sent'].to_i)
           }
        end
        respond_to do |format|
          format.csv { send_data csv_for_study_worker(@study,@study_participants), {
                     :filename    => 'StudyUsers.csv',
                     :type        => 'application/csv',
                     :disposition => 'attachment' } }
        end
        return
      end
    end

  end

end
