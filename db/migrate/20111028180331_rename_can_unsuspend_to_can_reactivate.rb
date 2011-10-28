class RenameCanUnsuspendToCanReactivate < ActiveRecord::Migration
  def self.up
    rename_column :users, :can_unsuspend_self, :can_reactivate_self
    User.where(:can_reactivate_self => true, :deactivated_at => nil).each { |u|
      if u.suspended_at
        u.deactivated_at = u.suspended_at
        u.suspended_at = nil
        warn "User ##{u.id} has been deactivated and unsuspended"
        u.save
      else
        warn "User ##{u.id} was not suspended, but had can_unsuspend_self set"
      end
    }
  end

  def self.down
    rename_column :users, :can_reactivate_self, :can_unsuspend_self
    User.where(:can_unsuspend_self => true, :suspended_at => nil).each { |u|
      if u.deactivated_at
        u.suspended_at = u.deactivated_at
        u.deactivated_at = nil
        warn "User ##{u.id} has been suspended and reactivated"
        u.save
      else
        warn "User ##{u.id} was not deactivated, but had can_reactivate_self set"
      end
    }
  end
end
