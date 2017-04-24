class ExportsController < ApplicationController
  before_filter      {|c| c.check_section_disabled(Section::PUBLIC_DATA) }
  skip_before_filter :login_required
  skip_before_filter :ensure_enrolled
  skip_before_filter :ensure_latest_consent
  skip_before_filter :ensure_recent_safety_questionnaire

  def users
    export_rows 'users' do |&block|
      block.call %w(human_id real_name enrolled)
      User.publishable.each do |u|
        real_name =
          if include_section?(Section::REAL_NAMES) and u.real_name_public
            u.full_name
          end
        block.call [u.hex, real_name, u.enrolled]
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

  def user_files
    export_rows 'user_files' do |&block|
      block.call %w(human_id data_type date description dataset_file_name dataset_content_type dataset_file_size dataset_updated_at created_at updated_at locator report_url status_url)
      User.publishable.eager_load(:datasets).each do |u|
        u.user_files.each do |uf|
          block.call [u.hex, uf.data_type, uf.date, uf.description, uf.dataset_file_name, uf.dataset_content_type, uf.dataset_file_size, uf.dataset_updated_at, uf.created_at, uf.updated_at, uf.locator, uf.report_url, uf.status_url]
        end
      end
    end
  end

  def phrccr_allergies
    export_rows 'phrccr_allergies' do |&block|
      block.call %w(human_id start_date end_date severity codes status created_at updated_at origin description)
      Allergy.eager_load(:allergy_description, :ccr => :user).where('ccrs.user_id in (?)', User.publishable.select(:id).collect(&:id)).each do |a|
        block.call [a.ccr.user.hex, a.start_date, a.end_date, a.severity, a.codes, a.status, a.ccr.created_at, a.ccr.updated_at, a.ccr.origin, a.description]
      end
    end
  end

  def phrccr_conditions
    export_rows 'phrccr_conditions' do |&block|
      block.call %w(human_id start_date end_date codes status created_at updated_at origin description)
      Condition.eager_load(:condition_description, :ccr => :user).where('ccrs.user_id in (?)', User.publishable.select(:id).collect(&:id)).each do |c|
        block.call [c.ccr.user.hex, c.start_date, c.end_date, c.codes, c.status, c.ccr.created_at, c.ccr.updated_at, c.ccr.origin, c.description]
      end
    end
  end

  def phrccr_demographics
    export_rows 'phrccr_demographics' do |&block|
      block.call %w(human_id dob gender weight_oz height_in blood_type race created_at updated_at origin)
      Ccr.eager_load(:user, :demographic).where('ccrs.user_id in (?)', User.publishable.select(:id).collect(&:id)).each do |c|
        d = c.demographic
        block.call [c.user.hex, d.dob, d.gender, d.weight_oz, d.height_in, d.blood_type, d.race, c.created_at, c.updated_at, c.origin]
      end
    end
  end

  def phrccr_immunizations
    export_rows 'phrccr_immunizations' do |&block|
      block.call %w(human_id start_date codes created_at updated_at origin description)
      Immunization.eager_load(:immunization_name, :ccr => :user).where('ccrs.user_id in (?)', User.publishable.select(:id).collect(&:id)).each do |i|
        block.call [i.ccr.user.hex, i.start_date, i.codes, i.ccr.created_at, i.ccr.updated_at, i.ccr.origin, i.name]
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
      Ccr.eager_load(:user).where('ccrs.user_id in (?)', User.publishable.select(:id).collect(&:id)).each do |ccr|
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

  def phrccr_medications
    export_rows 'phrccr_medications' do |&block|
      block.call %w(human_id start_date end_date codes strength dose frequency route route_codes is_refill created_at updated_at origin description)
      Medication.eager_load(:medication_name, :ccr => :user).where('ccrs.user_id in (?)', User.publishable.select(:id).collect(&:id)).each do |m|
        block.call [m.ccr.user.hex, m.start_date, m.end_date, m.codes, m.strength, m.dose, m.frequency, m.route, m.route_codes, m.is_refill, m.ccr.created_at, m.ccr.updated_at, m.ccr.origin, m.name]
      end
    end
  end

  def phrccr_procedures
    export_rows 'phrccr_procedures' do |&block|
      block.call %w(human_id start_date codes created_at updated_at origin description)
      Procedure.eager_load(:procedure_description, :ccr => :user).where('ccrs.user_id in (?)', User.publishable.select(:id).collect(&:id)).each do |p|
        block.call [p.ccr.user.hex, p.start_date, p.codes, p.ccr.created_at, p.ccr.updated_at, p.ccr.origin, p.description]
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
