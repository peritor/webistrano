class AddRecipeVersion < ActiveRecord::Migration
  def self.up
    add_column :recipes, :version, :integer, :default => 1
  end

  def self.down
    remove_column :recipes, :version
  end
end
