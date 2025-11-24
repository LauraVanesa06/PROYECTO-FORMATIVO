require "test_helper"

class Api::V1::WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get receive" do
    get api_v1_webhooks_receive_url
    assert_response :success
  end
end
