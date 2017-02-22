require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @archer = users(:archer)
  end
  
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect edit when logged in as wrong user" do
    login_as(@archer)
    get edit_user_path(@user)
    assert_redirected_to root_url
  end
  
  test "should redirect update when logged in as wrong user" do
    login_as(@archer)
    patch user_path(@user), params: { user: { name: @archer.name,
                                              email: @archer.email } }
    assert_redirected_to root_url
  end
    
  test "unsuccessful edit" do
    login_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    assert_template 'users/edit'
    assert_select 'div.alert', regex: 'The form contains 4 errors'
  end
  
  test "shouldn't edit admin" do
    login_as(@archer)
    get edit_user_path(@archer)
    assert_not @archer.admin?
    patch user_path(@archer), params: {user: {
                                            password:              "password",
                                            password_confirmation: "password",
                                            admin: true } } 
    assert_not @archer.reload.admin?
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    login_as(@archer)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    login_as(@user)
    assert_redirected_to edit_user_url(@user)
    assert session[:forwarding_url].nil?
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
