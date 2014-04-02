class ParticipationConsentsController < ApplicationController
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_active, :only => [ :show, :create ]
  skip_before_filter :ensure_latest_consent, :only => [:show, :create ]
  skip_before_filter :ensure_recent_safety_questionnaire, :only => [:show, :create ]

  def show
    @informed_consent_response = InformedConsentResponse.new( params[:attrs] )
  end

  def create
    icr_params = params[:informed_consent_response]
    icr_params ||= {}
    # whitelist
    new_attrs = icr_params.delete_if{|k,v| !%w(twin recontact).include?(k) }
    new_attrs.merge!({
      :user_id => current_user.id,
      :name => params[:participation_consent][:name],
      :name_confirmation => current_user.full_name,
      :email => params[:participation_consent][:email],
      :email_confirmation => current_user.email
    })

    @informed_consent_response = InformedConsentResponse.create( new_attrs )

    if @informed_consent_response.valid?
      step = EnrollmentStep.find_by_keyword('participation_consent')
      current_user.complete_enrollment_step(step)
      current_user.log('Signed full consent form version ' + LATEST_CONSENT_VERSION,step)
      redirect_to root_path
    else
      flash[:error] = @informed_consent_response.errors.collect{|field,msg| msg}.join('<br/><br/>')
      render :action => 'show', :attrs => new_attrs
    end
  end

end
