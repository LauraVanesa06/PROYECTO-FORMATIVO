require "test_helper"

class ContactosControllerTest < ActionDispatch::IntegrationTest
  test "should get contacto" do
    get contactos_contacto_url
    assert_response :success
  end
end
