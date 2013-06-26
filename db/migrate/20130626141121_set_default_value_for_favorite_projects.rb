class SetDefaultValueForFavoriteProjects < ActiveRecord::Migration
  def self.up
    change_column :projects, :favorite, :integer, :default => 0, :null => false
    add_index     :projects, :favorite
  end

  def self.down
  end
end
