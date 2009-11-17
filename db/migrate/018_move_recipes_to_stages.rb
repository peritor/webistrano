class MoveRecipesToStages < ActiveRecord::Migration
  def self.up
    
    create_table "recipes_stages", :id => false, :force => true do |t|
      t.integer "recipe_id"
      t.integer "stage_id"
    end
        
  end

  def self.down
    
    drop_table :recipes_stages
    
  end
end
