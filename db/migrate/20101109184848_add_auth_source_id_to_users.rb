class AddAuthSourceIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :auth_source_id, :integer
  end

  def self.down
    remove_column :users, :auth_source_id
  end
end
