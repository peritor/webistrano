class AddArchivedFlagToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :archived, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :archived
  end
end