class Recipe < ActiveRecord::Base
  has_and_belongs_to_many :recipes
  has_many :stages
end

class Stage < ActiveRecord::Base
  has_and_belongs_to_many :recipes
  belongs_to :project
end

class Recipe < ActiveRecord::Base
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :stages
end

class MoveRecipesToStages < ActiveRecord::Migration
  def self.up
    
    create_table "recipes_stages", :id => false, :force => true do |t|
      t.integer "recipe_id"
      t.integer "stage_id"
    end
    
    Recipe.find(:all).each do |r|
      r.projects.each do |p|
        p.stages.each do |s|
          s.recipes << r
        end
      end
    end
    
  end

  def self.down
    
    drop_table :recipes_stages
    
  end
end
