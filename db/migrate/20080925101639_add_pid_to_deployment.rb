class AddPidToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :pid, :integer
  end

  def self.down
    remove_column :deployments, :pid
  end
end
