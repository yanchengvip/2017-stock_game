require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "should get wx_auth" do
    get api_wx_auth_url
    assert_response :success
  end

end
