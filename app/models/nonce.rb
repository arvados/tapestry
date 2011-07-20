class Nonce < ActiveRecord::Base
  validates_uniqueness_of :nonce

  attr_protected :created_at, :used_at, :nonce

  def after_initialize
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

  def before_destroy
    return false
  end
end
