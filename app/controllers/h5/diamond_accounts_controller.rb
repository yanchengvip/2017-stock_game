class H5::DiamondAccountsController < ApplicationController
  skip_before_action :verify_signature
  skip_before_action :verify_authenticity_token


  def index

  end
  def my_diamond_account_record
    @title = '钻币账单'
    @diamond_accounts = DiamondAccount.my_diamond_account_record({current_user: current_user})
  end

  def my_diamond_account_record_page
    @diamond_accounts = DiamondAccount.my_diamond_account_record({current_user: current_user,page: params[:page]})
    render json: {status: 200,msg: '操作成功',data: {diamond_accounts: @diamond_accounts.as_json}}
  end
end
