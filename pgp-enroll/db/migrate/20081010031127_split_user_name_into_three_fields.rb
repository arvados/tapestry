class User < ActiveRecord::Base; end

class SplitUserNameIntoThreeFields < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string

    User.all.each do |user|
      names = user.name.split(' ')
      user.first_name = names[0]
      if names.length == 2
        user.last_name = names[1]
      elsif names.length == 3
        user.middle_name = names[1]
        user.last_name = names[2]
      else
        user.middle_name = names[1]
        user.last_name = names[2..-1]
      end
      user.save
    end

    remove_column :users, :name
  end

  def self.down
    add_column :users, :name, :string

    User.all.each do |user|
      user.update_attributes(:name =>
        [user.first_name, user.middle_name, user.last_name].
        join(' ').gsub(/\s+/,' '))
    end
  end
end
