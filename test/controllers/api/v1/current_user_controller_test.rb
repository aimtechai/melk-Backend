require "test_helper"

class Api::V1::CurrentUserControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_current_user_index_url
    assert_response :success
  end
end
