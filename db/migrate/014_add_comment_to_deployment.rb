class AddCommentToDeployment < ActiveRecord::Migration
  def self.up
    add_column :deployments, :comment, :text
  end

  def self.down
    remove_column :deployments, :comment
  end
end
