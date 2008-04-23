class AddExcludeHostsToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :excluded_host_ids, :string
  end

  def self.down
    remove_column :deployments, :excluded_host_ids
  end
end
