class AddRevisionToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :revision, :string
  end

  def self.down
    remove_column :deployments, :revision
  end
end
