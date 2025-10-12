require "test_helper"

class PaymentControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get payment_new_url
    assert_response :success
  end

  test "should get status" do
    get payment_status_url
    assert_response :success
  end

  test "should get checkout" do
    get payment_checkout_url
    assert_response :success
  end
end
