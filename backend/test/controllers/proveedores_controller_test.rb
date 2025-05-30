require "test_helper"

class ProveedoresControllerTest < ActionDispatch::IntegrationTest
  test "should get proveedor" do
    get proveedores_proveedor_url
    assert_response :success
  end
end
