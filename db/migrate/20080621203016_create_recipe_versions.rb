class CreateRecipeVersions < ActiveRecord::Migration
  def self.up
    create_table :recipe_versions do |t|
      t.integer :recipe_id, :version, :user_id
      t.string  :name
      t.text    :body
      t.text    :description
      t.timestamps
    end
  end

  def self.down
    drop_table :recipe_versions
  end
end
