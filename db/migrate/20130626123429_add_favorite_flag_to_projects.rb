class AddFavoriteFlagToProjects < ActiveRecord::Migration
  def self.up
	add_column :projects, :favorite, :integer
  end

  def self.down
  end
end
