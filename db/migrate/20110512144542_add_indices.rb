class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :deployments, :stage_id
    add_index :deployments, :user_id
    add_index :stages, :project_id
    add_index :roles, :stage_id
    add_index :roles, :host_id
  end

  def self.down
    remove_index :deployments, :stage_id
    remove_index :deployments, :user_id
    remove_index :stages, :project_id
    remove_index :roles, :stage_id
    remove_index :roles, :host_id
  end
end
