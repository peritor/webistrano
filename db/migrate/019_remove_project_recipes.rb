class RemoveProjectRecipes < ActiveRecord::Migration
  def self.up
    drop_table :projects_recipes
    
  end

  def self.down
    
    create_table "projects_recipes", :id => false, :force => true do |t|
      t.integer "recipe_id"
      t.integer "project_id"
    end
    
  end
end
