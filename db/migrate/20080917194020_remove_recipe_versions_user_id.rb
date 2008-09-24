class RemoveRecipeVersionsUserId < ActiveRecord::Migration
  def self.up
    remove_column :recipe_versions, :user_id
  end

  def self.down
    add_column :recipe_versions, :user_id, :integer
  end
end
