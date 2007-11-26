class RenameCommentToDescription < ActiveRecord::Migration
  def self.up
    rename_column :deployments, :comment, :description
  end

  def self.down
    rename_column :deployments, :description, :comment
  end
end
