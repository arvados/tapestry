require 'digest/sha1'
require 'user_eligibility_groupings'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  has_many :enrollment_step_completions
  has_many :completed_enrollment_steps, :through => :enrollment_step_completions, :source => :enrollment_step
  has_many :exam_responses
  has_many :waitlists
  has_many :documents
  has_many :distinctive_traits
  has_one  :screening_survey_response
  has_many :family_relations
  has_many :relatives, :class_name => 'User', :through => :family_relations

  # Next three are legacy and will go away when we drop the code for v1 of the eligibility survey
  has_one  :residency_survey_response
  has_one  :family_survey_response
  has_one  :privacy_survey_response
  # /legacy
  has_many  :named_proxies
  has_one  :informed_consent_response
  has_one  :baseline_traits_survey
  has_and_belongs_to_many :mailing_lists, :join_table => :mailing_list_subscriptions
  has_many :user_logs
  has_many :safety_questionnaires

  has_attached_file :phr

  # temporarily removed requirement
  # attr_accessor :email_confirmation

  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # We allow nil for security_question and security_answer because we have a lot of legacy records
  # for which those fields are still nil
  validates_length_of       :security_question, :minimum => 5, :allow_nil => true
  validates_length_of       :security_answer, :minimum => 2, :allow_nil => true

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => /.+@.+\...+/, :message => MSG_EMAIL_BAD

  # We allow nil because we have lots of legacy records with value nil
  validates_format_of :zip,
                      :with => %r{^(\d{5}|)(-\d{4})?$},
                      :message => "should be in 5 or 5 plus 4 digit format (e.g. 12345 or 12345-1234)",
                      :allow_nil => true

  # temporarily removed requirement
  # validate_on_create :email_confirmed

  named_scope :has_completed, lambda { |keyword|
    {
      :conditions => ["enrollment_steps.keyword = ?", keyword],
      :joins => :completed_enrollment_steps
    }
  }

  named_scope :inactive, { :conditions => "activated_at IS NULL" }
  named_scope :enrolled, { :conditions => "enrolled IS NOT NULL" }

  named_scope :ineligible_for_enrollment, lambda { 
    joins = [:enrollment_step_completions]
    enrollment_application_step_id = EnrollmentStep.find_by_keyword('enrollment_application').id
    conditions_sql = "users.enrolled IS NULL and 
        (users.id in (select user_id from residency_survey_responses where us_resident != 1) or
        users.id in (select user_id from screening_survey_responses where monozygotic_twin != 'no') or
        users.id in (select user_id from screening_survey_responses where us_citizen=0) or
        users.id in (select user_id from screening_survey_responses where us_citizen is null)) and
        enrollment_step_completions.enrollment_step_id=#{enrollment_application_step_id}"
    { 
      :conditions => conditions_sql,
      :order => 'enrollment_step_completions.created_at',
      :joins => joins
    }
  }

  named_scope :eligible_for_enrollment, lambda { 
    joins = [:enrollment_step_completions]
    enrollment_application_step_id = EnrollmentStep.find_by_keyword('enrollment_application').id
    conditions_sql = "users.enrolled IS NULL and 
        users.id not in (select user_id from residency_survey_responses where us_resident != 1) and
        users.id not in (select user_id from screening_survey_responses where monozygotic_twin != 'no') and
        users.id not in (select user_id from screening_survey_responses where us_citizen=0) and
        users.id not in (select user_id from screening_survey_responses where us_citizen is null) and
        enrollment_step_completions.enrollment_step_id=#{enrollment_application_step_id}"
    { 
      :conditions => conditions_sql,
      :order => 'enrollment_step_completions.created_at',
      :joins => joins
    }
  }

  named_scope :in_screening_eligibility_group, lambda { |group|
     joins = [:residency_survey_response, :family_survey_response, :privacy_survey_response, :enrollment_step_completions]
     birth_year = Time.now.year - 21
     # content_areas_enrollment_step_id = EnrollmentStep.find_by_keyword('content_areas').id
     eligibility_step_id = EnrollmentStep.find_by_keyword('screening_submission').id
     promoted_or_waitlisted_ids = User.promoted_ids | User.waitlisted_ids

     conditions_sql = UserEligibilityGroupings.eligibility_group_sql(group)
     conditions_sql += " and users.id not in (:promoted_or_waitlisted_ids)"

     {
       :conditions => [conditions_sql, {
           :birth_year => birth_year,
           :eligibility_step_id => eligibility_step_id,
           :promoted_or_waitlisted_ids => promoted_or_waitlisted_ids
          }],
       :joins => joins
     }
  }

  def self.promoted_ids
    step_id = EnrollmentStep.find_by_keyword('eligibility_screening_results').id
    connection.select_values("select users.id from users
        inner join enrollment_step_completions on enrollment_step_completions.user_id = users.id
        where enrollment_step_completions.enrollment_step_id = #{step_id}")
  end

  def self.waitlisted_ids
    connection.select_values("select users.id from users
        inner join waitlists on waitlists.user_id = users.id
        where waitlists.resubmitted_at is null")
  end

  def email=(email)
    email = email.strip if email
    write_attribute(:email, email)
  end

  def has_completed?(keyword)
    !!completed_enrollment_steps.find_by_keyword(keyword)
  end

  # temporarily removed requirement
  #
  # def email_confirmed
  #   unless email_confirmation == email
  #     errors.add(:email, 'must match confirmation')
  #   end
  # end

  def valid_for_attrs?(attrs)
    valid?
    return !attrs.any? { |attr| errors.on(attr) }
  end

  before_create :make_activation_code
  attr_accessible :email, :email_confirmation,
                  :password, :password_confirmation,
                  :first_name, :middle_name, :last_name,
                  :security_question, :security_answer,
                  :address1, :address2, :city, :state, :zip,
                  :phr_profile_name, :mailing_list_ids, :authsub_token

  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    signup_enrollment_step = EnrollmentStep.find_by_keyword('signup')
    log('Signed mini consent form version 20100315',signup_enrollment_step)
    self.complete_enrollment_step(signup_enrollment_step)
    save(false)
  end

  def log(comment,step=nil,origin=nil)
    UserLog.new(:user => self, :comment => comment, :enrollment_step => step, :origin => origin).save!
  end

  def promote!
    complete_enrollment_step(next_enrollment_step)
  end

  def demote!
    enrollment_step_completions.last.delete
  end

  def next_enrollment_step
    last_step_completed = last_completed_enrollment_step

    if last_step_completed.nil?
      EnrollmentStep.ordered.first
    else
      EnrollmentStep.ordered.find :first, :conditions => ['ordinal > ?', last_step_completed.ordinal]
    end
  end

  def complete_enrollment_step(step)
    raise "Cannot find enrollment step to complete." if step.nil?

    final_pre_enrollment_step = EnrollmentStep.find_by_keyword('enrollment_application_results')
    exam_enrollment_step = EnrollmentStep.find_by_keyword('content_areas')
    consent_enrollment_step = EnrollmentStep.find_by_keyword('participation_consent')
    if ! EnrollmentStepCompletion.find_by_user_id_and_enrollment_step_id(self, step)
      completion = EnrollmentStepCompletion.new :enrollment_step => step
      enrollment_step_completions << completion
      log("Completed enrollment step: #{step.title}", step)
    end

    if (step == final_pre_enrollment_step and self.enrolled.nil?) then
      self.enrolled = Time.now()
      self.hex = self.make_hex_code()
      save
    end
    if (step == exam_enrollment_step) then
      # We're at v2 of the exam currently. Ward, 2010-08-03
      self.exam_version = 'v2'
      save
    end
    if (step == consent_enrollment_step) then
      # We're at v20100331 of the consent currently. Ward, 2010-08-10
      self.consent_version = '20100331'
      save
    end
  end

  def active?
    activation_code.nil?
  end

  def recently_activated?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate email, password
    email = email.strip if email
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def last_completed_enrollment_step
    completed_enrollment_steps.sort_by(&:ordinal).last
  end

  def full_name
    [first_name, middle_name, last_name].join(' ').gsub(/\s+/,' ').strip
  end

  def completed_content_area_count
    ContentArea.all.select { |content_area| content_area.completed_by?(self) }.size
  end

  def last_waitlisted_at
    waitlists.first(:order => 'created_at desc').created_at if waitlists.any?
  end

  def eligibility_screening_passed
    if self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_keyword('screening_survey_results') } then
      return self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_keyword('screening_survey_results') }.created_at.to_s + ' (passed ' + self.eligibility_survey_version + ')'
    elsif self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_keyword('screening_surveys') } then
      # In v1 of the enrollment application, the eligibility questionnaire results step right after taking the eligibility questionnaire did not exist
      # So, we just take the timestamp of the questionnaire itself, which will hold the date it was last taken. 
      return self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_keyword('screening_surveys') }.created_at.to_s + ' (passed ' + self.eligibility_survey_version + ')'
    else
      return 'Not passed yet.'
    end
  end

  def exam_passed
    if self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_title('Entrance Exam') } then
      return self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_title('Entrance Exam') }.created_at.to_s + ' (passed ' + self.exam_version + ')'
    else
      return 'Not passed yet.'
    end
  end

  def consent_passed
    if self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_keyword('participation_consent') } then
      return self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_keyword('participation_consent') }.created_at.to_s + ' (passed v' + self.consent_version + ')'
    else
      return 'Not consented yet.'
    end
  end

  # doctype can be
  #   tos
  #   eligibility_survey
  #   consent
  #   exam
  def latest_doc(doctype)
    self.documents.kind(doctype).first
  end

  def has_recent_safety_questionnaire
    # this only applies to enrolled users; for all others, this function should be a no-op
    return true if self.enrolled.nil?
    if self.safety_questionnaires.empty? and 3.months.ago > self.enrolled then
      # No SQ results, and account older than 3 months. They have to take one
      return false
    elsif self.safety_questionnaires.empty?
      # No SQ results, but account younger than 3 months. They are ok.
      return true
    end
    3.months.ago < self.safety_questionnaires.last.datetime
  end

  def ineligible_for_enrollment
    reasons = Array.new()
    # They are already enrolled
    reasons.push('Already enrolled') if self.enrolled
    # They have not submitted an enrollment application
    reasons.push('Enrollment application not submitted') if not self.has_completed?('enrollment_application') 
    # Not a US resident
    reasons.push('Not a US resident') if not self.residency_survey_response.nil? and not self.residency_survey_response.us_resident
    # They have a twin or are unsure
    reasons.push('There may be a monozygotic twin') if not self.screening_survey_response.nil? and self.screening_survey_response.monozygotic_twin != 'no'
    # Not a US citizen
    reasons.push('Not a US citizen') if not self.screening_survey_response.nil? and not self.screening_survey_response.us_citizen and not self.screening_survey_response.us_citizen.nil?
    # Have not taken eligibility survey v2 or higher
    reasons.push('Not taken eligibility survey v2 or higher') if not self.screening_survey_response.nil? and self.screening_survey_response.us_citizen.nil?
    # Empty array -> eligible
    # Non-empty array -> ineligible
    return reasons
  end

  protected

  def make_hex_code
    code = nil
    while User.find_by_hex(code) or code == nil
      code = "hu" + ("%x%x%x%x%x%x" % [ rand(16), rand(16), rand(16), rand(16), rand(16), rand(16) ]).upcase
    end
    return code
  end

  def make_activation_code
    self.activation_code = self.class.make_token
  end

  def self.pending_family_relations
    return FamilyRelations.find(:all, :conditions => ['relative_id = ? AND NOT is_confirmed', self.id])
  end
end
