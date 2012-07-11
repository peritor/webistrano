class AddPromptFeaturesToConfigurationParameters < ActiveRecord::Migration
  def self.up
    add_column :configuration_parameters, :prompt_default, :string
    add_column :configuration_parameters, :prompt_description, :string
  end

  def self.down
    remove_column :configuration_parameters, :prompt_default
    remove_column :configuration_parameters, :prompt_description
  end
end
