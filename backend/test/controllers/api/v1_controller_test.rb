require "test_helper"

class Api::V1ControllerTest < ActionDispatch::IntegrationTest
  test "should get webhooks_controller" do
    get api_v1_webhooks_controller_url
    assert_response :success
  end
end
