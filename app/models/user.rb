require 'digest/sha1'
require 'user_eligibility_groupings'

class User < ActiveRecord::Base
  model_stamper
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  attr_accessor :controlling_user

  has_many :enrollment_step_completions, :dependent => :destroy
  has_many :completed_enrollment_steps, :through => :enrollment_step_completions, :source => :enrollment_step, :dependent => :destroy
  has_many :exam_responses, :dependent => :destroy
  has_many :waitlists, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_many :distinctive_traits, :dependent => :destroy
  has_one  :screening_survey_response, :dependent => :destroy
  has_many :family_relations, :dependent => :destroy
  has_many :confirmed_family_relations, :class_name => "FamilyRelation", :conditions => {:is_confirmed => true}
  has_many :relatives, :class_name => 'User', :through => :family_relations
  has_many :genetic_data, :dependent => :destroy
  has_many :removal_requests, :dependent => :destroy
  has_many :samples, :foreign_key => 'participant_id'
  has_many :datasets, :foreign_key => 'participant_id'

  has_one  :shipping_address, :dependent => :destroy

  scope :shipping_address, joins(:shipping_addresses)

  # Next three are legacy and will go away when we drop the code for v1 of the eligibility survey
  has_one  :residency_survey_response, :dependent => :destroy
  has_one  :family_survey_response, :dependent => :destroy
  has_one  :privacy_survey_response, :dependent => :destroy
  # /legacy
  has_many  :named_proxies, :dependent => :destroy
  has_one  :informed_consent_response, :dependent => :destroy
  has_one  :baseline_traits_survey, :dependent => :destroy
  # TODO: habtm does not take :dependent => :destroy. But we want that in the event a user is deleted.
  # We should probably convert this to has_many, see http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many
  # see also #363. ward, 2010-10-13
  has_and_belongs_to_many :mailing_lists, :join_table => :mailing_list_subscriptions
  has_many :user_logs, :dependent => :destroy
  has_many :safety_questionnaires, :dependent => :destroy
  has_many :ccrs, :dependent => :destroy
  has_many :survey_answers, :dependent => :destroy

  # Researchers only
  has_many :kit_designs, :foreign_key => "owner_id"
  has_many :study_participants, :dependent => :destroy
  has_many :studies, :through => :study_participants

  has_attached_file :phr

  # temporarily removed requirement
  # attr_accessor :email_confirmation

  validates_length_of :researcher_affiliation, :within => 6..100, :if => :is_researcher?

  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # We allow nil for security_question and security_answer because we have a lot of legacy records
  # for which those fields are still nil
  validates_length_of       :security_question, :minimum => 5, :allow_nil => true
  validates_length_of       :security_answer, :minimum => 2, :allow_nil => true

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_uniqueness_of   :pgp_id,   :case_sensitive => false, :allow_nil => true

  validates_format_of :pgp_id,
                      :with => %r{^PGP(\d+)$},
                      :message => "must be of the format PGPXXX with XXX a number",
                      :allow_nil => true

  # this comes from the alexdunae-validates_email_format_of gem, see http://code.dunae.ca/validates_email_format_of.html
  # ward, 2010-10-13
  validates_email_format_of :email, :message => MSG_EMAIL_BAD

  # We allow nil because we have lots of legacy records with value nil
  validates_format_of :zip,
                      :with => %r{^(\d{5}|)(-\d{4})?$},
                      :message => "should be in 5 or 5 plus 4 digit format (e.g. 12345 or 12345-1234)",
                      :allow_nil => true

  # temporarily removed requirement
  # validate_on_create :email_confirmed

  scope :has_completed, lambda { |keyword|
    {
      :conditions => ["enrollment_steps.keyword = ?", keyword],
      :joins => :completed_enrollment_steps
    }
  }

  scope :inactive, { :conditions => "activated_at IS NULL and NOT (is_test <=> 1)" }
  scope :enrolled, { :conditions => "enrolled IS NOT NULL and NOT (is_test <=> 1)" }
  scope :pgp_ids, { :conditions => "enrolled IS NOT NULL and pgp_id IS NOT NULL and NOT (is_test <=> 1)" }
  # User.test is a built-in method, so we have to call our scope something else
  scope :is_test, { :conditions => "is_test = 1" }
  scope :real, { :conditions => "NOT (is_test <=> 1)" }
  scope :researcher, { :conditions => "researcher = 1" }
  scope :publishable, where("enrolled IS NOT NULL AND suspended_at IS NULL").real
  scope :visible_to, lambda { |current_user|
    if current_user and current_user.is_admin?
      unscoped
    elsif current_user and current_user.is_researcher_onirb?
      real
    else
      publishable
    end
  }


  # Beware of NULL: "screening_survey_responses.us_citizen_or_resident!=1"
  # does not match rows that have us_citizen_or_resident set to NULL.
  scope :ineligible_for_enrollment, lambda { 
    joins = [:enrollment_step_completions, :screening_survey_response]
    enrollment_application_step_id = EnrollmentStep.find_by_keyword('enrollment_application').id
    conditions_sql = "users.is_test = 'f' and users.enrolled IS NULL and 
        (screening_survey_responses.monozygotic_twin != 'no' or 
         screening_survey_responses.us_citizen_or_resident is null or 
         screening_survey_responses.us_citizen_or_resident!=1) and
        enrollment_step_completions.enrollment_step_id=#{enrollment_application_step_id}"
    { 
      :conditions => conditions_sql,
      :order => 'enrollment_step_completions.created_at',
      :joins => joins,
      # TODO: when we upgrade rails to 2.3 and 3.0, the next line may no longer be needed. 
      # Cf. http://stackoverflow.com/questions/639171/what-is-causing-this-activerecordreadonlyrecord-error
      # Ward, 2010-10-09.
      :readonly => false
    }
  }

  scope :waitlisted, lambda { 
    joins = [ :waitlists ]
    conditions_sql = "users.is_test = 'f' and users.id = waitlists.user_id"
    {
      :conditions => conditions_sql,
      :order => 'users.created_at',
      :group => 'users.id',
      :joins => joins,
      # TODO: when we upgrade rails to 2.3 and 3.0, the next line may no longer be needed. 
      # Cf. http://stackoverflow.com/questions/639171/what-is-causing-this-activerecordreadonlyrecord-error
      # Ward, 2010-10-09.
      :readonly => false
    }
  }

  scope :eligible_for_enrollment, lambda { 
    joins = [:enrollment_step_completions, :screening_survey_response]
    enrollment_application_step_id = EnrollmentStep.find_by_keyword('enrollment_application').id
    conditions_sql = "users.is_test = 'f' and users.enrolled IS NULL and 
        screening_survey_responses.monozygotic_twin = 'no' and
        screening_survey_responses.us_citizen_or_resident = 1 and
        enrollment_step_completions.enrollment_step_id=#{enrollment_application_step_id} and users.id not in (select user_id from waitlists group by user_id)"
    { 
      :conditions => conditions_sql,
      :order => 'enrollment_step_completions.created_at',
      :joins => joins,
      # TODO: when we upgrade rails to 2.3 and 3.0, the next line may no longer be needed. 
      # Cf. http://stackoverflow.com/questions/639171/what-is-causing-this-activerecordreadonlyrecord-error
      # Ward, 2010-10-09.
      :readonly => false
    }
  }

  scope :trios, lambda {
    joins = [:family_relations]
    conditions_sql = "relation = 'parent'"
    group_by = "user_id having count(*) = 2"
    {
      :conditions => conditions_sql,
      :group => group_by,
      :joins => joins
    }
  }

  # For mislav-will_paginate (WillPaginate), which we use in the admin interface
  cattr_reader :per_page
  @@per_page = 30

  def is_unprivileged?
    not self.researcher and not self.researcher_onirb and not self.is_admin?
  end

  def is_researcher?
    self.researcher
  end

  def is_researcher_onirb?
    self.researcher_onirb
  end

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

  def has_completed?(keyword,include_test_users=true)
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
    return !attrs.any? { |attr| errors[attr].empty? ? false : true }
  end

  before_create :make_activation_code
  attr_accessible :email, :email_confirmation,
                  :password, :password_confirmation,
                  :first_name, :middle_name, :last_name, :pgp_id,
                  :security_question, :security_answer,
                  :address1, :address2, :city, :state, :zip,
                  :phr_profile_name, :mailing_list_ids, :authsub_token, :researcher_affiliation

  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    signup_enrollment_step = EnrollmentStep.find_by_keyword('signup')
    log('Account was activated (e-mail address verified)',signup_enrollment_step)
    # Researchers have a separate signup procedure
    unless self.is_researcher?
      self.complete_enrollment_step(signup_enrollment_step)
    end
    save(:validate => false)
  end

  def log(comment,step=nil,origin=nil,user_comment=nil)
    UserLog.new(:user => self, :comment => comment, :user_comment => user_comment, :enrollment_step => step, :origin => origin, :controlling_user => self.controlling_user).save!
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
      es = EnrollmentStep.ordered - completed_enrollment_steps
      es.sort { |a,b| a.ordinal <=> b.ordinal }.first
    end
  end

  def complete_enrollment_step(step)
    raise Exceptions::MissingStep.new("No enrollment step to complete.") if step.nil?

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
      consent_version = LATEST_CONSENT_VERSION
      self.consent_version = consent_version
      self.documents << Document.new(:keyword => 'consent', :version => consent_version, :timestamp => Time.now())
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
    # In v1 of the enrollment application, the eligibility questionnaire results step right after taking the eligibility questionnaire did not exist
    # So, we just take the timestamp of the questionnaire itself, which will hold the date it was last taken. 
    @step_v1 = self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_keyword('screening_surveys') }
    @step_v2 = self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_keyword('screening_survey_results') }
    if self.screening_survey_response.nil? or not self.screening_survey_response.passed?
      return 'Not passed yet.'
    end
    if not @step_v2.nil? then
      @step = @step_v2
    elsif @step_v1 then
      @step = @step_v1
    else
      return 'Not passed yet.'
    end
    return @step.created_at.to_s + " (passed " + self.eligibility_survey_version + ')'
  end

  def exam_passed
    if self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_title('Entrance Exam') } then
      return self.enrollment_step_completions.detect {|c| c.enrollment_step == EnrollmentStep.find_by_title('Entrance Exam') }.created_at.to_s + ' (passed ' + self.exam_version + ')'
    else
      return 'Not passed yet.'
    end
  end

  def consent_passed
    if !self.latest_doc('consent').nil? then
      c = self.latest_doc('consent')
      return "#{c.created_at.to_s} (passed #{c.version})"
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
    self.documents.kind_any_version(doctype).first
  end

  def has_recent_safety_questionnaire(howrecent=3)
    # this only applies to enrolled users; for all others, this function should be a no-op
    return true if self.enrolled.nil?
    if self.safety_questionnaires.empty? and howrecent.months.ago > self.enrolled then
      # No SQ results, and account older than N months. They have to take one
      return false
    elsif self.safety_questionnaires.empty?
      # No SQ results, but account younger than N months. They are ok.
      return true
    end
    howrecent.months.ago < self.safety_questionnaires.find(:all, :order => 'datetime').last.datetime
  end

  def auto_suspend_if_necessary
    if !self.suspended_at and !has_recent_safety_questionnaire(4)
      self.suspended_at = Time.now
      self.can_unsuspend_self = true
      save
      log("Account automatically suspended")
    end
  end

  def auto_unsuspend_if_possible
    if self.suspended_at and self.can_unsuspend_self and has_recent_safety_questionnaire
      self.suspended_at = nil
      self.can_unsuspend_self = false
      save
      log("Account automatically unsuspended")
    end
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
    # Not a US citizen or permanent resident
    reasons.push('Not a US citizen or permanent resident') if not self.screening_survey_response.nil? and not self.screening_survey_response.us_citizen_or_resident and not self.screening_survey_response.us_citizen_or_resident.nil?
    # Have not taken eligibility survey v2 or higher
    reasons.push('Not taken eligibility survey v2 or higher') if not self.screening_survey_response.nil? and self.screening_survey_response.us_citizen_or_resident.nil?
    # Empty array -> eligible
    # Non-empty array -> ineligible
    return reasons
  end

  def <=> other
    if (pgp_id.nil? && other.pgp_id.nil?) then
      return full_name <=> other.full_name
    elsif (pgp_id.nil?)
      return 1
    elsif (other.pgp_id.nil?)
      return -1
    else
      return pgp_id.sub(/PGP/,'').to_i <=> other.pgp_id.sub(/PGP/,'').to_i
    end
  end

  # Generate a cookie that can be used to grant access to the specified account.
  def create_userswitch_cookie
    r = rand(2**64).to_s(36)
    t = Time.now.to_i
    secret = Tapestry::Application.config.secret_token
    raise "Installation problem: Application.config.secret_token not properly defined" if secret.length < 16
    h = Digest::SHA1.hexdigest("#{secret}#{r}#{t}#{self.id}")
    "#{r},#{t},#{self.id},#{h}"
  end

  # Verify that the cookie is legitimate.  If so, return the target UID.
  def verify_userswitch_cookie(cookie)
    r, t, uid, hash = cookie.split ',' rescue return nil
    t, uid = t.to_i, uid.to_i
    secret = Tapestry::Application.config.secret_token
    raise "Installation problem: Application.config.secret_token not properly defined" if secret.length < 16
    if uid == self.id and t >= Time.now.to_i - 86400 and hash == Digest::SHA1.hexdigest("#{secret}#{r}#{t}#{uid}")
      return uid
    end
    return nil
  end

  def as_json(options={})
    j = {}
    if self.is_researcher? or (options[:for] and options[:for].is_admin?)
      j['full_name'] = self.full_name
    end
    j['hex'] = self.hex unless self.is_researcher?
    j['pgp_id'] = self.pgp_id
    j['enrolled'] = self.enrolled
    j['received_sample_materials'] = self.samples.find_all { |s| s.last_received }.collect { |s| s.material }.uniq
    j['has_ccrs'] = self.ccrs.size
    j['has_relatives_enrolled'] = self.confirmed_family_relations.size
    j['has_whole_genome_data'] = self.datasets.size
    j['has_other_genetic_data'] = self.genetic_data.size
    { self.class.to_s.underscore => j }
  end

  # A unique hash for each user
  # This is used in the place of the hex id, if the user has not been enrolled yet. See
  # export_log in app/controllers/admin/users_controller.rb
  def hash
    secret = Tapestry::Application.config.secret_token
    raise "Installation problem: Application.config.secret_token not properly defined" if secret.length < 16
    Digest::SHA1.hexdigest("#{secret}---#{self.id}")
  end

  protected

  def make_hex_code
    begin code = "hu%06X" % rand(2**24) end while User.unscoped.find_by_hex(code)
    return code
  end

  def make_activation_code
    self.activation_code = self.class.make_token
  end

  def self.pending_family_relations
    return FamilyRelations.find(:all, :conditions => ['relative_id = ? AND NOT is_confirmed', self.id])
  end

  def self.help_datatables_sort_by(sortkey, options={})
    sortkey = sortkey.to_s.gsub(/^user\./,'').to_sym
    case sortkey
    when :pgp_id
      "pgp_id is null, 0+replace(pgp_id,'PGP','')"
    when :hex, :enrolled
      sortkey
    when :received_sample_materials
      ['count(distinct samples.id)>0', { :samples => {} }]
    when :has_ccrs
      ['count(distinct ccrs.id)>0', { :ccrs => {} }]
    when :has_relatives_enrolled
      ['count(distinct family_relations.id)', { :confirmed_family_relations => {} }]
    when :has_whole_genome_data
      ['count(distinct datasets.id)', { :datasets => {} }]
    when :has_other_genetic_data
      ['count(distinct genetic_data.id)', { :genetic_data => {} }]
    else
      :hex
    end
  end

  def self.help_datatables_search(options={})
    current_user = options[:for]
    sql_search = "hex LIKE :search"
    if current_user and (current_user.is_admin? or
                         current_user.is_researcher_onirb?)
      sql_search << " OR concat(first_name,' ',if(middle_name='','',concat(middle_name,' ')),last_name) LIKE :search"
    end
    sql_search
  end

  def self.include_for_json
    [:ccrs, :genetic_data, :datasets, :samples, :confirmed_family_relations]
  end

end
