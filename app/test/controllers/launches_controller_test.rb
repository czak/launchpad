require "test_helper"

class LaunchesControllerTest < ActionDispatch::IntegrationTest
  test "should get next" do
    get launches_next_url
    assert_response :success
  end
end
