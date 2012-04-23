class AddOriginToCcr < ActiveRecord::Migration
  def self.up
    add_column :ccrs, :origin, :string
    update "update ccrs set origin='gh'";
  end

  def self.down
    remove_column :ccrs, :origin
  end
end
