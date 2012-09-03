class Sample < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version
  acts_as_api

  serialize :qc_result

  belongs_to :study
  belongs_to :kit
  belongs_to :original_kit_design_sample, :class_name => "KitDesignSample"
  belongs_to :kit_design_sample

  belongs_to :participant, :class_name => "User"
  belongs_to :owner, :class_name => "User"

  has_many :sample_logs, :dependent => :destroy
  has_many :parent_sample_origins, :foreign_key => :child_sample_id, :class_name => 'SampleOrigin'
  has_many :parent_samples, {
    :class_name => 'Sample',
    :through => :parent_sample_origins,
    :source => :parent_sample
  }
  has_many :child_sample_origins, :foreign_key => :parent_sample_id, :class_name => 'SampleOrigin'
  has_many :child_samples, {
    :class_name => 'Sample',
    :through => :child_sample_origins,
    :source => :child_sample
  }

  validates_uniqueness_of :crc_id
  validates_uniqueness_of :url_code
  validates_presence_of :study_id

  scope :real, where('samples.is_destroyed is ?',nil)
  scope :destroyed, where('samples.is_destroyed is not ?',nil)
  scope :visible_to, lambda { |user|
    if user and user.is_admin?
      unscoped.scoped(:include => [:study, :participant, :owner])
    else
      real.scoped(:include => [:study, :participant, :owner],
                  :conditions => ['? in (samples.participant_id, samples.owner_id, studies.creator_id) or (samples.participant_id is not ? and samples.owner_id is not ? and samples.owner_id <> samples.participant_id)',
                                  (user ? user.id : -1), nil, nil])
    end
  }

  def receive!(current_user)
    SampleLog.new(:actor => current_user, :comment => "Sample received by researcher", :sample_id => self.id).save!
    self.last_received = Time.now
    self.owner = current_user
    save

    # If the researcher has the sample, they have the kit
    if self.kit and self.kit.owner != current_user

      # Notify the participant if this is the first time we've seen the
      # kit since it was claimed/returned
      if self.kit and
          self.kit.participant and
          (self.kit.owner.nil? or # kit has been marked "returned"
           self.kit.owner == self.kit.participant) and # claimed, not returned
          !self.kit.kit_logs.collect(&:comment).index('Kit received')
        UserMailer.kit_received_notification(self.kit.participant,
                                             current_user,
                                             self.kit).deliver
      end

      KitLog.new(:actor => current_user, :comment => "Kit received", :kit_id => self.kit.id).save!
      self.kit.last_received = Time.now
      self.kit.owner = current_user
      self.kit.lost_at = nil
      self.kit.save!
    end
  end

  def crc_id_s
    "%08d" % crc_id
  end

  def dup(options)
    s = Sample.new
    s.update_attributes({
                          :participant_id => self.participant_id,
                          :study_id => self.study_id,
                          :owner_id => self.owner_id,
                          :crc_id => Kit.generate_verhoeff_number(s),
                          :url_code => Kit.generate_url_code(s),
                          :when_originated => Time.now,
                          :material => self.material,
                          :kit_design_sample_id => self.kit_design_sample_id,
                          :original_kit_design_sample_id => self.original_kit_design_sample_id,
                          :name => (options[:name] or 'derived'),
                          :creator => options[:actor]
                        })
    s.save!
    SampleOrigin.new({
                       :parent_sample => self,
                       :child_sample => s,
                       :derivation_method => options[:derivation_method],
                       :creator => options[:actor]
                     }).save!
    # make sure self.child_samples gets updated
    reload
    sample_logs << SampleLog.new(:actor => options[:actor],
                                 :comment => "A new sample #{s.crc_id_s} was derived from this sample")
    s.sample_logs << SampleLog.new(:actor => options[:actor],
                                   :comment => "Sample created; derived from sample #{self.crc_id_s}")
    s
  end

  api_accessible :id do |t|
    t.add :crc_id_s, :as => :crc_id
    t.add :material
    t.add :amount
    t.add :unit
  end

  api_accessible :public do |t|
    t.add :study, :template => :public
    t.add :participant, :template => :id
    t.add :owner, :template => :id
    t.add :crc_id_s, :as => :crc_id
    t.add :material
    t.add :amount
    t.add :unit
  end

  api_accessible :researcher, :extend => :public do |t|
    t.add :id
    t.add :study, :template => :researcher
    t.add :kit, :template => :id
    t.add :qc_result
  end

  api_accessible :privileged, :extend => :researcher do |t|
    t.add :url_code
  end

  def self.help_datatables_sort_by(sortkey, options={})
    sortkey = sortkey.to_s.gsub(/^sample\./, '')
    case sortkey
    when 'id', 'crc_id'
      "#{table_name}.#{sortkey}"
    when 'material'
      "#{table_name}.#{sortkey} #{options[:sql_direction]}, #{table_name}.amount"
    when 'owner'
      'owners_samples.researcher_affiliation'
    when 'study.name'
      ['studies.name', { :study => {} }]
    when 'participant.hex'
      ['users.hex', { :participant => {} }]
    when 'kit.name'
      ['kits.name', { :kit => {} }]
    when 'url_code'
      (options[:for] and options[:for].is_admin?) ? 'samples.url_code' : 'sample.id'
    when 'qc_result.QC Status'
      ['#{table_name}.qc_result like "%QC Status%" desc, #{table_name}.qc_result like "%QC Status%Passed%"']
    else
      'samples.crc_id'
    end
  end

  def self.help_datatables_search(options)
    s = "#{table_name}.id like :search or #{table_name}.crc_id like :search"
    if options[:for] and options[:for].is_admin?
      s << " or #{table_name}.url_code like :search"
    end
    s << " or users.hex like :search"
    s << " or owners_samples.researcher_affiliation like :search"
    s << " or studies.name like :search"
    if options[:for] and (options[:for].is_researcher? or options[:for].is_admin?)
      s << " or kits.name like :search" 
      s << " or ((:search like '_passed_' or :search like '_failed_') and #{table_name}.qc_result like concat('%QC Status',:search))"
    end
    [s, { :kit => {}, :participant => {}, :owner => {} }]
  end

  def self.normalize_url_code(s)
    s.sub(/^.*\//) do |prefix|
      prefix == 'http://myp.gp/hu/' ? '' : MD5.hexdigest(prefix).to_i(16).to_s(36)[0..5]
    end
  end
end
