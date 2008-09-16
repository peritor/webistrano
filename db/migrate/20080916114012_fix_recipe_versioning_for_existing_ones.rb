class Recipe < ActiveRecord::Base
end

class FixRecipeVersioningForExistingOnes < ActiveRecord::Migration
  def self.up
    Recipe.update_all('version = 1')
  end

  def self.down
  end
end
