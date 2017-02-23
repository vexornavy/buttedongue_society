require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @not_activated = users(:malory)
  end
  
  test 'invalid login details' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: {email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
  end
  
  test "login with unactivated account" do
    login_as(@not_activated, remember_me: '1')
    assert_not is_logged_in?
    follow_redirect!
    assert_not flash.empty?
  end
  
  test "login with remembering" do
    login_as(@user, remember_me: '1')
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end
  
   test "login without remembering" do
    # Log in to set the cookie.
    login_as(@user, remember_me: '1')
    # Log in again and verify that the cookie is deleted.
    login_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
  
  test 'valid login details' do
    get login_path
    post login_path, params: { session: {email: @user.email, password: 'password', remember_me: '0' } }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', users_path
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
  end
  
  test 'log user out' do
    get login_path
    post login_path, params: { session: {email: @user.email, password: 'password' } }
    follow_redirect!
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_path
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', users_path, count: 0
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end
end