class AddDatesToStudy < ActiveRecord::Migration
  def self.up
    add_column :studies, :date_approved, :datetime
    add_column :studies, :date_opened, :datetime
  end

  def self.down
    remove_column :studies, :date_approved, :datetime
    remove_column :studies, :date_opened, :datetime
  end
end
