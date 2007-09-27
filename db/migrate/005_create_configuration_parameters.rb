class CreateConfigurationParameters < ActiveRecord::Migration
  def self.up
    create_table :configuration_parameters do |t|
      t.column :name, :string
      t.column :value, :string
      t.column :project_id, :integer
      t.column :stage_id, :integer
      t.column :type, :string
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :configuration_parameters
  end
end
