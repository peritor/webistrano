class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.column :name, :string
      t.column :stage_id, :integer
      t.column :host_id, :integer
      t.column :primary, :integer, :default => 0
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :roles
  end
end
