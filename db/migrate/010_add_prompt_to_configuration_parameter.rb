class AddPromptToConfigurationParameter < ActiveRecord::Migration
  def self.up
    add_column :configuration_parameters, :prompt_on_deploy, :integer, :default => 0
  end

  def self.down
    remove_column :configuration_parameters, :prompt_on_deploy
  end
end
