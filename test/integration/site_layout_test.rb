require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  
  
  test "full title helper" do
    assert_equal full_title, "The 21st Century Buttedongue Society"
    assert_equal full_title("Contact"), "Contact | The 21st Century Buttedongue Society"
  end
  
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
  end
end
