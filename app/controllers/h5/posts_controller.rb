class H5::PostsController < ApplicationController
  skip_before_action :verify_signature
  skip_before_filter :verify_authenticity_token

  def diamond_account_role
    @title = "钻石币说明"
  end

end
