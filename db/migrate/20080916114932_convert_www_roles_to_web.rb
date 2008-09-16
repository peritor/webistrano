class Role < ActiveRecord::Base
end

class ConvertWwwRolesToWeb < ActiveRecord::Migration
  def self.up
    Role.update_all("name = 'web'", "name = 'www'")
  end

  def self.down
  end
end
