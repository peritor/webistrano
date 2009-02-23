class AddLockingToStage < ActiveRecord::Migration
  def self.up
    add_column :stages, :locked_by_deployment_id, :integer
    add_column :stages, :locked, :integer, :default => 0
  end

  def self.down
    remove_column :stages, :locked_by_deployment_id
    remove_column :stages, :locked
  end
end
