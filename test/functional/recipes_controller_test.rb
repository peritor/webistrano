require File.dirname(__FILE__) + '/../test_helper'
require 'recipes_controller'

# Re-raise errors caught by the controller.
class RecipesController; def rescue_action(e) raise e end; end

class RecipesControllerTest < Test::Unit::TestCase

  def setup
    @controller = RecipesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @recipe = create_new_recipe
    @user = login
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:recipes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_recipe
    old_count = Recipe.count
    post :create, :recipe => { :name => 'Copy Config files', :body => 'foobarr'}
    assert_equal old_count+1, Recipe.count
    
    assert_redirected_to recipe_path(assigns(:recipe))
  end

  def test_should_show_recipe
    get :show, :id => @recipe.id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => @recipe.id
    assert_response :success
  end
  
  def test_should_update_recipe
    put :update, :id => @recipe.id, :recipe => {:name => 'foobarr 22'}
    assert_redirected_to recipe_path(assigns(:recipe))
    @recipe.reload 
    
    assert_equal 'foobarr 22', @recipe.name
  end
  
  def test_should_destroy_recipe
    old_count = Recipe.count
    delete :destroy, :id => @recipe
    assert_equal old_count-1, Recipe.count
    
    assert_redirected_to recipes_path
  end
end
