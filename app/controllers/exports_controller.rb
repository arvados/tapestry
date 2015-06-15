class ExportsController < ApplicationController
  before_filter      {|c| c.check_section_disabled(Section::PUBLIC_DATA) }
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  def phrccr_lab_test_results
    respond_to do |format|
      format.csv do
        buf = FasterCSV.generate(String.new, :force_quotes => true) do |csv|
          csv << %w(human_id start_date codes value units created_at updated_at origin description)
          # Unfortunately, ActiveRecord model instantiation is too
          # slow to handle this whole query as one big eager_load.
          # Instead we pre-fetch the ccr and description rows, and do
          # the join ourselves.
          ccrs = {}
          Ccr.eager_load(:user).where('users.id in (?)', User.publishable.select(:id).collect(&:id)).each do |ccr|
            ccrs[ccr.id]=ccr
          end
          ltrds = {}
          LabTestResultDescription.all.each do |ltrd|
            ltrds[ltrd.id] = ltrd
          end
          LabTestResult.find_each(:batch_size => 10000) do |ltr|
            ccr = ccrs[ltr.ccr_id]
            next unless ccr
            u = ccr.user
            ltrd = ltrds[ltr.lab_test_result_description_id]
            csv << [u.hex, ltr.start_date, ltr.codes, ltr.value, ltr.units, ccr.created_at, ccr.updated_at, ltrd.description]
          end
        end
        send_data buf, {
          :filename    => "phrccr_lab_test_results-#{Time.now.strftime '%Y%m%d%H%M%S'}.csv",
          :type        => 'application/csv',
          :disposition => 'attachment'
        }
      end
    end
  end
end
