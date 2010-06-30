class CreateInternationalParticipants < ActiveRecord::Migration
  def self.up
    create_table :international_participants do |t|
      t.string :email
      t.string :country

      t.timestamps
    end
  end

  def self.down
    drop_table :international_participants
  end
end
