class LinkUsersAndDeployments < ActiveRecord::Migration
  def self.up
    add_column :deployments, :user_id, :integer
  end

  def self.down
    remove_column :deployments, :user_id
  end
end
