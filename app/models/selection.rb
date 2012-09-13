class Selection < ActiveRecord::Base
  model_stamper
  stampable
  acts_as_paranoid_versioned :version_column => :lock_version

  serialize :spec, Hash
  serialize :targets, Array

  scope :visible_to, lambda { |user|
    if user
      where('creator_id = ?', user.id)
    else
      where('1=0')
    end
  }

  before_save :assign_unguessable

  def assign_unguessable
    self.unguessable ||= rand(2**36).to_s(36)
  end

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

  # Return a list of table rows (if available) that did not match any
  # targets.
  def notfound_rows
    return nil if !spec[:table]
    notfound_row_indices = (0..spec[:table].size).to_a
    targets.each do |t|
      if t.class == Array and t[0] and t[1]
        notfound_row_indices[t[1]] = nil
      end
    end
    notfound_row_indices.compact.collect do |i|
      spec[:table][i]
    end
  end

  # Return a list of keys (i.e., values in the attr_column of table
  # rows, if available) that did not match any targets.
  def notfound_keys
    return nil if !spec[:table]
    notfound_rows.collect { |r|
      r and r[spec[:attr_column]]
    }.uniq
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
    return @spec_table_rows_for_all_targets if @spec_table_rows_for_all_targets
    return {} if !spec[:table]
    ret = {}
    targets.each { |t|
      if t.class == Array and t[1]
        ret[t[0]] ||= []
        ret[t[0]] << [t[1], *spec[:table][t[1]]]
      end
    }
    @spec_table_rows_for_all_targets = ret
  end

  # Find the column in spec[:table] that is most responsive to the
  # supplied block.
  def spec_table_column_with_most
    return nil if !spec[:table]
    score = []
    spec[:table].each do |row|
      row.each_index do |colnum|
        if block_given?
          next unless yield row[colnum]
        else
          next unless row[colnum]
        end
        score[colnum] = 1 + (score[colnum] || 0)
      end
    end
    if score.select { |x| x && x == score.compact.max }.count == 1
      # One column is more responsive to supplied block than all others
      score.index(score.compact.max)
    else
      # Ambiguous result
      nil
    end
  end
end
