require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get home_index_url
    assert_response :success
  end

  test "should get home" do
    get home_home_url
    assert_response :success
  end

  test "should get producto" do
    get home_producto_url
    assert_response :success
  end

  test "should get contacto" do
    get home_contacto_url
    assert_response :success
  end
end
