class ExportsController < ApplicationController
  before_filter      {|c| c.check_section_disabled(Section::PUBLIC_DATA) }
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  def users
    export_rows 'users' do |&block|
      block.call %w(human_id sha1 download_url get_evidence_genome_id report_url location  name created_at updated_at locator published_at status_url  download_url report_metadata)
      User.publishable.each do |u|
        block.call [u.hex, u.real_name_public]
      end
    end
  end

  def datasets
    export_rows 'datasets' do |&block|
      block.call %w(human_id sha1 download_url get_evidence_genome_id report_url location  name created_at updated_at locator published_at status_url  download_url report_metadata)
      User.publishable.eager_load(:datasets).each do |u|
        u.datasets.published_or_published_anonymously.each do |d|
          hex = d.published_at ? u.hex : ''
          published_at = d.published_anonymously_at || d.published_at
          block.call [hex, d.sha1, d.download_url, d.get_evidence_genome_id, d.report_url, d.location, d.name, d.created_at, d.updated_at, d.locator, published_at, d.status_url, d.download_url, d.report_metadata]
        end
      end
    end
  end

  def phrccr_lab_test_results
    export_rows 'phrccr_lab_test_results' do |&block|
      block.call %w(human_id start_date codes value units created_at updated_at origin description)

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
        block.call [u.hex, ltr.start_date, ltr.codes, ltr.value, ltr.units, ccr.created_at, ccr.updated_at, ltrd.description]
      end
    end
  end

  protected

  # Export a table as CSV or (in the future) other formats.
  #
  # The given block will be called once: it should yield one header
  # array and any number of content rows.
  #
  # The exported filename will be the given basename, plus a timestamp
  # and a suitable format extension.
  def export_rows basename, &block
    respond_to do |format|
      format.csv do
        buf = FasterCSV.generate(String.new, :force_quotes => true) do |csv|
          block.call do |row|
            csv << row
          end
        end
        send_data buf, {
          :filename    => basename + "-#{Time.now.utc.strftime '%Y%m%d%H%M%S'}.csv",
          :type        => 'application/csv',
          :disposition => 'attachment'
        }
      end
    end
  end
end
