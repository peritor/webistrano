class User < ActiveRecord::Base
end

class Migrate < ActiveRecord::Migration
  def self.up
    User.update_all("time_zone = 'UTC'")
  end

  def self.down
  end
end
