class User < ActiveRecord::Base
end

class AddTimeZoneToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :time_zone, :string, :default => 'UTC'
    User.reset_column_information 
    User.update_all("time_zone = 'UTC'") # in order to set for PGSQL
  end

  def self.down
    remove_column :users, :time_zone
  end
end
