require 'test_helper'

class ShareConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @share_config = share_configs(:one)
  end

  test "should get index" do
    get share_configs_url
    assert_response :success
  end

  test "should get new" do
    get new_share_config_url
    assert_response :success
  end

  test "should create share_config" do
    assert_difference('ShareConfig.count') do
      post share_configs_url, params: { share_config: { desc: @share_config.desc, img_url: @share_config.img_url, link_url: @share_config.link_url, title: @share_config.title, user_id: @share_config.user_id } }
    end

    assert_redirected_to share_config_url(ShareConfig.last)
  end

  test "should show share_config" do
    get share_config_url(@share_config)
    assert_response :success
  end

  test "should get edit" do
    get edit_share_config_url(@share_config)
    assert_response :success
  end

  test "should update share_config" do
    patch share_config_url(@share_config), params: { share_config: { desc: @share_config.desc, img_url: @share_config.img_url, link_url: @share_config.link_url, title: @share_config.title, user_id: @share_config.user_id } }
    assert_redirected_to share_config_url(@share_config)
  end

  test "should destroy share_config" do
    assert_difference('ShareConfig.count', -1) do
      delete share_config_url(@share_config)
    end

    assert_redirected_to share_configs_url
  end
end
