class Deployment < ActiveRecord::Base
end

class AddRealStatusFieldToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :status, :string, :default => "running"
    Deployment.update_all("status = 'failed'", "success = 0")
    Deployment.update_all("status = 'success'", "success = 1")
    remove_column :deployments , :success
  end

  def self.down
    add_column :deployments, :success, :integer, :default => 0
    Deployment.update_all("success = 0", "status = 'failed'")
    Deployment.update_all("success = 1", "status = 'success'")
    remove_column :deployments, :status
  end
end
