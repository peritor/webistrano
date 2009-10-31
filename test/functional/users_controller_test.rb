require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase

  def test_should_not_allow_for_non_admins_to_create_users
    login
    
    assert_no_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  def test_should_allow_for_admins_to_create_users
    admin_login
    
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    admin_login
    
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    admin_login
    
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    admin_login
    
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    admin_login
    
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end
  
  def test_non_admins_can_not_delete_users
    User.delete_all
    user_1 = create_new_user(:login => 'user_1')
    user_2 = create_new_user(:login => 'user_2')
    user_3 = create_new_user(:login => 'user_3')
    admin = create_new_user(:login => 'admin')
    admin.make_admin!
    
    # login as non-admin
    assert !user_1.admin?
    login(user_1)
    delete :destroy, :id => user_2.id
    assert_equal 4, User.count
    assert_match 'Action not allowed', flash[:notice]
    
  end
  
  def test_admins_can_delete_users
    User.delete_all
    user_1 = create_new_user
    user_2 = create_new_user
    user_3 = create_new_user
    admin = create_new_user
    admin.make_admin!
    
    assert admin.admin?
    login(admin)
    delete :destroy, :id => user_2.id
    assert_equal 3, User.enabled.count
  end
  
  def test_admin_status_can_not_be_set_by_non_admins
    user_1 = create_new_user
    user_2 = create_new_user
    
    assert !user_1.admin?
    assert !user_2.admin?
    
    login(user_1)
    put :update, :id => user_2.id, :user => { :admin => '1'}
    
    user_2.reload
    
    assert !user_2.admin?
  end
  
  def test_admin_status_can_be_set_by_non_admins
    admin = create_new_user
    admin.make_admin!
    user_2 = create_new_user
    
    assert admin.admin?
    assert !user_2.admin?
    
    login(admin)
    put :update, :id => user_2.id, :user => { :admin => '1'}
    
    user_2.reload
    
    assert user_2.admin?
  end
  
  def test_always_one_admin_left
    User.delete_all
    admin = create_new_user
    admin.make_admin!
    admin_2 = create_new_user
    admin_2.make_admin!
    user = create_new_user
    
    assert_equal 3, User.count
    
    login(admin)
    
    # delete the user
    delete :destroy, :id => user.id
    assert_equal 2, User.enabled.count
    
    # delete the other admin
    delete :destroy, :id => admin_2.id
    assert_equal 1, User.enabled.count
    
    # last admin can not be deleted
    delete :destroy, :id => admin.id
    assert_equal 1, User.enabled.count
  end
  
  # basic non-exception test
  def test_deployments    
    user = login
    
    assert_nothing_raised{
      get :deployments, :id => user  
    }
    
  end
  
  def test_user_can_edit_themselfs
    user = login
    
    get :edit, :id => user.id
    assert_response :success
    
    post :update, :id => user.id, :user => {:login => 'foobarrr'}
    user.reload
    assert_equal 'foobarrr', user.login
  end
  
  def test_user_not_can_edit_other
    user = login
    other = create_new_user
    
    get :edit, :id => other.id
    assert_response :redirect
    
    post :update, :id => other.id, :user => {:login => 'foobarrr'}
    other.reload
    assert_not_equal 'foobarrr', other.login
  end
  
  def test_destroy_should_only_mark_as_disabled
    user = admin_login
    other = create_new_user
    assert !other.disabled?
    
    assert_difference "User.disabled.count" do
      assert_no_difference "User.count" do
        post :destroy, :id => other.id
        assert_response :redirect
      end
    end
    
  end
  
  def test_enable
    user = admin_login
    other = create_new_user
    other.disable
    
    post :enable, :id => other.id
    assert_response :redirect
    
    other.reload
    assert !other.disabled?
  end
  
  def test_enable_only_admin
    user = login
    other = create_new_user
    other.disable
    
    post :enable, :id => other.id
    assert_response :redirect
    
    other.reload
    assert other.disabled?
  end
  
  def test_should_logout_if_disabled_after_login
    user = login
    
    user.disable
    
    get :index
    assert_response :redirect
    assert_redirected_to home_path
  end
  

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
