class ParticipationConsentsController < ApplicationController
  def show
    @informed_consent_response = InformedConsentResponse.new()
  end

  def create
    @informed_consent_response = InformedConsentResponse.new
    if params[:informed_consent_response]
      %w(twin recontact).each do |field|
        @informed_consent_response.send(:"#{field}=", params[:informed_consent_response][field])
      end
    else
      flash[:error] ||= ''
      flash[:error] += 'Please indicate whether you have an identical twin.<br/><br/>Please indicate whether you are willing to be recontacted.<br/><br/>'
    end

    if params[:informed_consent_response] then
      if not params[:informed_consent_response][:twin] then
        flash[:error] ||= ''
        flash[:error] += 'Please indicate whether you have an identical twin.<br/><br/>'
      end
      if not params[:informed_consent_response][:recontact] then
        flash[:error] ||= ''
        flash[:error] += 'Please indicate whether you are willing to be recontacted.<br/><br/>'
      end
    end

    @informed_consent_response.user = current_user

    if ! name_and_email_match
      flash[:error] ||= ''
      flash[:error] += 'Your name and email signature must match the name and email that you signed up with.<br/><br/>'
    end

    if ! @informed_consent_response.valid?
      flash[:error] ||= ''
      flash[:error]  += 'You must answer the questions within the Consent Form.<br/><br/>'
    end

    if name_and_email_match && @informed_consent_response.valid? && @informed_consent_response.save
      step = EnrollmentStep.find_by_keyword('participation_consent')
      current_user.log('Signed full consent form version 20100331',step)
      current_user.complete_enrollment_step(step)
      redirect_to root_path
    else
      #show
      render :action => 'show'
      flash[:error] = ''
    end
  end

  private

  def name_and_email_match
    params[:participation_consent][:name]  == current_user.full_name &&
    params[:participation_consent][:email] == current_user.email
  end
end
