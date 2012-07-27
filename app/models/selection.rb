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

  # For a given target id, get an array of the table rows (if
  # available) that caused that target to be included in the
  # selection.  Each element in the returned array is the original
  # table row with an initial 0-based row number prepended.
  def spec_table_rows_for_target(needle)
    return [] if !spec[:table]
    targets.select { |t|
      t.class == Array and t[0] == needle and t[1]
    }.collect { |t|
      [t[1], *spec[:table][t[1]]]
    }
  end

  # Like spec_table_rows_for_target but gets data for all targets.
  # Returns hash where key = target_id, value = array of [row_index,
  # *original_row]
  def spec_table_rows_for_all_targets
    return {} if !spec[:table]
    ret = {}
    targets.each { |t|
      if t.class == Array and t[1]
        ret[t[0]] ||= []
        ret[t[0]] << [t[1], *spec[:table][t[1]]]
      end
    }
    ret
  end
end
