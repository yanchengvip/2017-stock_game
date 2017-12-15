class Admins::DownloadCsvController < Admins::ApplicationController
  before_action :csv_menus, only: [:index, :show_user_info, :show_remain_balance,
                                   :show_change_balance, :show_month_money, :show_lottery_orders,
                                   :show_channel, :channel_detail]
  before_action :generate_file_name, only: [:user_info_csv, :remain_balance_csv, :change_balance_csv, :month_money_csv, :lottery_orders_csv]

  def index
    @menu_active = '下载记录'
    if params[:statistic_type].to_i == 0
      st = [1, 2, 3, 4, 5, 6]
    else
      st = params[:statistic_type]
    end
    @csv_files = CsvFile.ransack(statistic_type_in: st)
                     .result.order('download_date desc').paginate(:page => params[:page], :per_page => 30)
  end


  def download_csv_file
    csv_file = CsvFile.find(params[:id])
    count = csv_file.count.to_i + 1
    csv_file.update_attributes(count: count)
    file_path = 'public' + params[:file_path]
    filename = params[:filename]
    respond_to do |format|
      format.csv { send_file file_path, filename: filename }
    end
  end

  #用户基本情况统计
  def show_user_info
    @menu_active = '用户基本情况统计'
    #@info_search_time = true
    #user_info_scv_data
    @datas, @users = User.user_info_scv_data params.merge(is_web_table: true)
  end

  #资金余额统计
  def show_remain_balance
    @menu_active = '资金余额统计'
    @remain_search_time = true
    @user_remain_balance = User.remain_balance_data_hash params.merge(is_web_table: true)

  end

  #资金变动统计
  def show_change_balance
    @menu_active = '资金变动统计'
    @change_search_time = true
    if params[:nickname].present?
      @users = User.where('nickname like ?', "%#{params[:nickname]}%").paginate(page: params[:page], per_page: 5)
    else
      @users = User.paginate(page: params[:page], per_page: 5)
    end
    user_ids =@users.pluck(:id)
    @tongji_user_data_change = User.user_change_balance_data_hash params.merge(is_web_table: true, user_ids: user_ids)

  end

  #资金月报统计
  def show_month_money
    @menu_active = '资金月报统计'
    @month_search_time = true
    if params[:nickname].present?
      @users = User.where('nickname like ?', "%#{params[:nickname]}%").paginate(page: params[:page], per_page: 5)
    else
      @users = User.paginate(page: params[:page], per_page: 5)
    end

    user_ids =@users.pluck(:id)
    @user_data_month = User.month_money_scv_data params.merge(is_web_table: true, user_ids: user_ids)

  end


  #中奖订单统计
  def show_lottery_orders
    @menu_active = '中奖订单统计'
    @datas, @lottery_orders = User.user_orders_data params.merge(is_web_table: true)

  end


  #由于清空表导致资金不同，恢复资金余额统计的数据，误差修改--diamond_amount清空了，但是user表的total_diamont_mount没有清空，导致数据不一致
  def show_remain_balance_data_diff
    users = User.remain_balance_data_hash
    @users = []
    users.each do |user|
      if user.ga1_amount.to_f != user.total_gold.to_f || user.da1_amount.to_f != user.total_gold.to_f
        @users << user
      end
    end

  end

  #恢复由于清空表导致资金不同
  def recovery_remain_balance_data_diff
    User.recover_remain_data params[:user_id]
    redirect_to '/admins/download_csv/show_remain_balance_data_diff'
  end


  #用户基本情况统计下载
  def user_info_csv
    header = ['用户ID', '用户名', '手机号', '注册时间', '关注微信公众号', '注册来源', '注册渠道', '成功邀请好友人数', '登录天数(活跃度)', '夺宝次数',
              '中奖次数', '钻币抽奖次数', '钻币中奖金额', '虚拟盘交易次数', '虚拟盘交易金额']
    Thread.new do
      begin
        datas, users = User.user_info_scv_data params
        User.custom_save_csv @file_path_temp, datas, header
        CsvFile.create(url: @file_path, csv_name: @filename,
                                      statistic_type: 1, download_date: Time.now.strftime("%Y%m%d"))
      rescue Exception => e
        ErrorLog.create(title: '用户基本情况统计下载', desc: e.to_s)
      end
    end

    render json: {status: 'ok'}
  end

  #资金余额统计下载
  def remain_balance_csv
    header = ['用户ID', '用户名', '手机号', '注册时间', '注册来源', '虚拟资金余额', '可用于兑换钻石币的资金金额', '钻石币余额']

    Thread.new do
      begin
        datas = User.remain_balance_scv_data params
        User.custom_save_csv @file_path_temp, datas, header
        CsvFile.create(url: @file_path, csv_name: @filename,
                                      statistic_type: 2, download_date: Time.now.strftime("%Y%m%d"))
      rescue Exception => e
        ErrorLog.create(title: '资金余额统计下载', desc: e.to_s)
      end

    end
    render json: {status: 'ok'}
  end

  #资金变动统计下载
  def change_balance_csv
    parent_header = ['用户信息', '', '', '', '', '虚拟资金变化', '', '', '', '', '', '钻石币变化', '', '', '', '']
    sub_header = ['用户ID', '用户名', '手机号', '注册时间', '注册来源', '初始资金', '邀请好友获得虚拟金', '其他方式获得虚拟金',
                  '虚拟盘盈亏', '兑换钻石币消耗的虚拟资金', '其他方式消耗的虚拟资金',
                  '注册获得钻石币', '虚拟金兑换的的钻石币', '其他方式获得的钻石币', '夺宝消耗的钻石币', '其他方式消耗的钻石币']

    Thread.new do
      begin
        datas = User.change_balance_scv_data params
        User.custom_save_csv @file_path_temp, datas, parent_header, sub_header
        CsvFile.create(url: @file_path, csv_name: @filename,
                                      statistic_type: 3, download_date: Time.now.strftime("%Y%m%d"))
      rescue Exception => e
        ErrorLog.create(title: '资金变动统计下载', desc: e.to_s)
      end


    end
    render json: {status: 'ok'}
  end

  #资金月报统计下载
  def month_money_csv
    parent_header = ['用户信息', '', '', '', '', '虚拟资金变化', '', '', '', '', '', '', '', '钻石币变化', '', '', '', '', '', '']
    sub_header = ['用户ID', '用户名', '手机号', '注册时间', '注册来源', '月初资金金额', '注册赠送资金', '邀请好友获得虚拟金',
                  '其他方式获得虚拟金', '虚拟盘盈亏', '兑换钻石币消耗的虚拟资金',
                  '其他方式消耗的虚拟金', '月末资金金额',
                  '月初钻石币余额', '注册获得', '虚拟金兑换的钻石币', '其他方式获得的钻石币', '夺宝消耗的钻石币', '其他方式消耗的钻石币', '月末钻石币余额']

    Thread.new do
      begin
        datas = User.month_money_scv_data params
        User.custom_save_csv @file_path_temp, datas, parent_header, sub_header
        CsvFile.create(url: @file_path, csv_name: @filename,
                                      statistic_type: 4, download_date: Time.now.strftime("%Y%m%d"))
      rescue Exception => e
        ErrorLog.create(title: '资金变动统计下载', desc: e.to_s)
      end

    end

    render json: {status: 'ok'}
  end

  #中奖订单统计
  def lottery_orders_csv
    header = ['揭晓时间', '订单号', '商品名称', '价格', '上线时间', '期号', '幸运号码', '购买时间', '参与人次',
              '支付钻石币', '用户微信', '手机号', '收货姓名', '收货电话', '收货地址', '是否已支付邮费', '支付金额', '发货状态']

    Thread.new do
      begin
        datas, @lottery_orders = User.user_orders_data params
        User.custom_save_csv @file_path_temp, datas, header
        CsvFile.create(url: @file_path, csv_name: @filename,
                                      statistic_type: 6, download_date: Time.now.strftime("%Y%m%d"))
      rescue Exception => e
        ErrorLog.create(title: '中奖订单统计', desc: e.to_s)
      end

    end
  end

  # 渠道统计
  def show_channel
    @menu_active = '渠道统计'
    # joins = ["left join (select qrsr.openid, qrcode_id,qrsr.id from  qrcode_scan_records  as qrsr
    #         left join users on users.openid = qrsr.openid ) as new on qrcodes.id=new.qrcode_id"]
    # qrcodes = Qrcode.select("qrcodes.id, user_name, qrcode_status, qrcodes.created_at,new.qrcode_id,new.openid")
    #                 .joins(joins.join(' '))
    #                 .where("qrcodes.qrcode_status=1")
    #                 .where("user_name like ?", "%#{params[:user_name]}%")
    qrcodes = Qrcode.includes(:qrcode_scan_records).select("id, user_name")
                                                   .where("qrcode_status = 1")
                                                   .where("user_name like ?", "%#{params[:user_name]}%")
    @res = Qrcode.channel_datas qrcodes
  end

  # 渠道明细
  def channel_detail
    @menu_active = '渠道统计'
    @qrcode = Qrcode.where("user_name like ?", "%#{params[:user_name]}%").first
    if params[:occur_date].present?
      @res = Qrcode.channel_details(@qrcode, params[:occur_date], params[:page] || 1)
    else
      @res = Qrcode.channel_details_group(@qrcode, params[:page] || 1)
    end
  end



  private

  def generate_file_name
    if !Dir.exists?('public/uploads/csv/')
      Dir.mkdir('public/uploads/csv/')
    end
    time = Time.now.strftime('%Y%m%d%H%M%S').to_s + Time.now.nsec.to_s[0..3] + rand(10).to_s
    @file_path_temp = 'public/uploads/csv/' + time + '.csv'
    @file_path = '/uploads/csv/' + time + '.csv'
    @filename = time + '.csv'
  end
end
