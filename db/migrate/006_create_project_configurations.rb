class CreateProjectConfigurations < ActiveRecord::Migration
  def self.up
    create_table :project_configurations do |t|
    end
  end

  def self.down
    drop_table :project_configurations
  end
end
