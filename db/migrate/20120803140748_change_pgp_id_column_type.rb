class ChangePgpIdColumnType < ActiveRecord::Migration
  def self.up
    User.where('pgp_id is not null').each do |u|
      id = /^PGP(\d)/.match(u.pgp_id)
      u.pgp_id = id[1]
      u.save!
    end
    change_table :users do |t|
      t.change :pgp_id, :integer
    end
  end

  def self.down
    change_table :users do |t|
      t.change :pgp_id, :string
    end
  end
end
