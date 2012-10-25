class Nonce < ActiveRecord::Base
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  validates_uniqueness_of :nonce

  default_scope where(:deleted => nil)

  scope :deleted, unscoped.where('deleted is not null')

  after_initialize :calculate_nonce
  before_destroy :do_not_destroy

  def calculate_nonce
    return if self.nonce
    self.nonce = rand(2**256-1).to_s(36)
    self.created_at = Time.now
    self.used_at = nil
    save!
  end

  def use!
    raise "Nonce #{self.nonce} already used." if self.used_at
    self.used_at = Time.now
    save!
  end

  def do_not_destroy
    return false
  end
end
