require "test_helper"

class Api::V1::PaymentsCheckoutControllerTest < ActionDispatch::IntegrationTest
  test "should get create_checkout" do
    get api_v1_payments_checkout_create_checkout_url
    assert_response :success
  end
end
