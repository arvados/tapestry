class Selection < ActiveRecord::Base
  model_stamper
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  serialize :spec, Hash
  serialize :targets, Array

  scope :visible_to, lambda { |user|
    where('creator_id = ?', user.id)
  }

  def target_ids
    return [] if !targets
    targets.collect { |t|
      if t.class == Fixnum
        t
      elsif t.class == Array
        t[0]
      elsif t.class == Hash
        t[:id]
      end
    }.compact
  end
end
