require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @not_activated = users(:malory)
  end
  
  test "redirected when not logged in" do
    get users_path
    assert_redirected_to login_path
  end
  
  test "index as admin including pagination and delete links" do
    login_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_select 'a[href=?]', user_path(@not_activated), text: @not_activated.name, count: 0
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    login_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end