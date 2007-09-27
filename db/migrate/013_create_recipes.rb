class CreateRecipes < ActiveRecord::Migration
  def self.up
    create_table :recipes do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    create_table :projects_recipes, :id => false do |t|
      t.column :recipe_id, :integer
      t.column :project_id, :integer
    end
  end

  def self.down
    drop_table :recipes
    drop_table :projects_recipes
  end
end
