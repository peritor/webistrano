class CreateStageConfigurations < ActiveRecord::Migration
  def self.up
    create_table :stage_configurations do |t|
    end
  end

  def self.down
    drop_table :stage_configurations
  end
end
