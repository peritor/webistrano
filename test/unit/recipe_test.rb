require File.dirname(__FILE__) + '/../test_helper'

class RecipeTest < ActiveSupport::TestCase

  def test_create
    assert_nothing_raised{
      recipe = Recipe.create!(
        :name => 'Copy Config files',
        :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
        :body => "set :config_files, 'database.yml' "
      )
    }
  end
  
  def test_validation
    
    # missing name
    recipe = Recipe.new(
      :name => nil,
      :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
      :body => "set :config_files, 'database.yml' "
    )
    assert !recipe.valid?
    
    # missing body
    recipe = Recipe.new(
      :name => 'Copy Tasks',
      :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
      :body => nil
    )
    assert !recipe.valid?
    
    # name too long
    recipe = Recipe.new(
      :name => 'Copy Config files' * 100,
      :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
      :body => "set :config_files, 'database.yml' "
    )
    assert !recipe.valid?
    
    # fix name and save
    recipe.name = 'Copy'
    recipe.save!
    
    # name not unique
    recipe = Recipe.new(
      :name => 'Copy',
      :description => 'Copies config files from #{deploy_to}/config/ to #{current_path}/config',
      :body => "set :config_files, 'database.yml' "
    )
    assert !recipe.valid?
  end

  def test_validate_invalid_syntax_on_create
    recipe = Recipe.create(:name => "Copy Config files",
                           :description => "Recipe body intentionally erronous",
                           :body => "set config_files, database.yml'")
    assert !recipe.valid?
    assert_equal "syntax error at line: 1", recipe.errors.on(:body)
  end
  
  def test_validate_valid_syntax_on_create
    recipe = Recipe.create(:name => "Copy Config files",
                           :description => "Recipe body intentionally erronous",
                           :body => "set :config_files, 'database.yml'")
    assert !recipe.errors.on(:body)
  end
  
  def test_validate_with_open4_error
    Open4.expects(:popen4).raises(RuntimeError)
    recipe = Recipe.create(:name => "Copy Config files",
                           :description => "Recipe body intentionally erronous",
                           :body => "set :config_files, 'database.yml'")
    assert !recipe.errors.on(:body)
  end
end
