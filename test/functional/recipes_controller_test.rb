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
  end

  def test_should_get_index
    @user = login
    
    get :index
    assert_response :success
    assert assigns(:recipes)
  end

  def test_non_admin_should_not_get_new
    @user = login
    assert !@user.admin?
    
    get :new
    assert_response :redirect
  end
  
  def test_admin_should_not_new
    @user = admin_login
    assert @user.admin?
    
    get :new
    assert_response :success
  end
  
  def test_non_admin_should_not_create_recipe
    @user = login
    
    old_count = Recipe.count
    post :create, :recipe => { :name => 'Copy Config files', :body => 'foobarr'}
    assert_equal old_count, Recipe.count
    
    assert_response :redirect
  end
  
  def test_admin_should_create_recipe
    @user = admin_login
    
    old_count = Recipe.count
    post :create, :recipe => { :name => 'Copy Config files', :body => 'foobarr'}
    assert_equal old_count+1, Recipe.count
    
    assert_redirected_to recipe_path(assigns(:recipe))
  end

  def test_should_show_recipe
    @user = login
    
    get :show, :id => @recipe.id
    assert_response :success
  end

  def test_non_admin_should_not_get_edit
    @user = login
    
    get :edit, :id => @recipe.id
    assert_response :redirect
  end
  
  def test_admin_should_get_edit
    @user = admin_login
    
    get :edit, :id => @recipe.id
    assert_response :success
  end
  
  def test_non_admin_should_not_update_recipe
    @user = login
    
    put :update, :id => @recipe.id, :recipe => {:name => 'foobarr 22'}
    assert_response :redirect
    @recipe.reload 
    
    assert_not_equal 'foobarr 22', @recipe.name
  end
  
  def test_admin_should_update_recipe
    @user = admin_login
    
    put :update, :id => @recipe.id, :recipe => {:name => 'foobarr 22'}
    assert_redirected_to recipe_path(assigns(:recipe))
    @recipe.reload 
    
    assert_equal 'foobarr 22', @recipe.name
  end
  
  def test_non_admin_should_not_destroy_recipe
    @user = login
    
    old_count = Recipe.count
    delete :destroy, :id => @recipe
    assert_equal old_count, Recipe.count
    
    assert_response :redirect
  end
  
  def test_admin_should_destroy_recipe
    @user = admin_login
    
    old_count = Recipe.count
    delete :destroy, :id => @recipe
    assert_equal old_count-1, Recipe.count
    
    assert_redirected_to recipes_path
  end
  
  def test_should_preview_the_recipe
    @user = admin_login
    
    xhr :get, :preview, :recipe => {:body => @recipe.body}
    assert_select_rjs :replace_html, "preview"
  end
  
end
