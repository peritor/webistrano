class CreateDeployments < ActiveRecord::Migration
  def self.up
    create_table :deployments do |t|
      t.column :task, :string
      t.column :log, :text
      t.column :success, :integer, :default => 0
      t.column :stage_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :completed_at, :datetime
    end
    
    create_table :deployments_roles, :id => false do |t|
      t.column :deployment_id, :integer
      t.column :role_id, :integer
    end
  end

  def self.down
    drop_table :deployments
    drop_table :deployments_roles
  end
end
