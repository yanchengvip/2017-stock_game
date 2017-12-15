50个号 还是 人定义开奖时间

2-28
分时图接口
k线接口

交易宝箱  配置
邀请赚资金配置


模块list

运营配置

rails g scaffold admin_config  name  config_type  value:integer value_name  pre_condition_name pre_condition_value:integer


交易列表

<!-- 挂单：
rails g scaffold booking_trade sale_diamond_id:integer total_count:integer  user_id:integer bussiness_type:integer "booking_price:decimal{10,2}"  status:integer "deposit:decimal{10,2}" -->

<!-- 交易订单

rails g scaffold diamond_trade booking_trade_id:integer user_id:integer  sale_diamond_id:integer business_type:integer total_count:integer "total_price:decimal{10,2}" -->

用户虚拟金明细账目
rails g scaffold gold_item user_id:integer "amount:decimal{10,2}" gold_type:integer remark table_id:integer table_type

每日收益

rails g scaffold gold_gains_history user_id:integer "amount:decimal{10,2}" day


增加用户虚拟金及持仓信息
rails g migration add_total_gold_and_available_gold_and_hold_diamonds_count_and_total_gold_gains_to_users "total_gold:decimal{10,2}" "available_gold:decimal{10,2}" hold_diamonds_count:integer "total_gold_gains:decimal{10,2}"


持有钻石列表
rails g scaffold hold_diamonds  sale_diamond_id:integer   "buy_price:decimal{10,2}"  "sell_price:decimal{10,2}"  sell_time:datetime buy_time:datetime  status:integer  diamond_trade_id:integer user_id:integer  "profit:decimal{10,2}"







钻石列表


钻石历史价格记录
rails g scaffold sale_diamond_history_prices sale_diamond_id:integer  "price:decaima{10,2}" date_time:datetime day



文章

收货地址
rails g scaffold address user_id:integer user_name  phone  postcode  address is_default:boolean

商品

rails g scaffold product name desc:text "price:decimal{10,2}" inventory_count:integer detail_url  head_image  is_published:boolean user_id:integer  product_type:integer award  total_count:integer  end_time:datetime


图片资源
rails g scaffold image url name content_size table_id:integer table_type


0元购活动模块
rails g scaffold lottery product_id:integer pubilshed_at:datetime  product_name sales_count:integer  total_count:integer  "price:decimal{10,2}"  status:integer  lottery_time:datetime   share_code award    end_time:datetime

0元购购买记录

抽奖号码
rails g scaffold lottery_order_item lottery_id:integer lottery_order_id:integer  user_id:integer lottery_code request_ip is_win:boolean

购买订单
rails g scaffold lottery_order  lottery_id:integer user_id:integer request_ip total_count:integer "total_price:decimal{10,2}" is_win:boolean status:integer address_id:integer

快递信息
rails g scaffold courier table_id:integer  table_type courier_no  courier_name





竞赛排名



排名奖励配置

<!--rails  g scaffold  ranking_config  ranking:integer  table_type  table_id  price  prize_type:integer  date_type:integer  ranking_type:integer
-->

rails  g scaffold  ranking_config  ranking:integer     date_type:integer  ranking_type:integer

date_type: 年 月 日 周

ranking_type: 收益 / 收益率

rails  g scaffold  ranking_config_item  ranking_config_id:integer  table_type  table_id  price  prize_type:integer

prize_type: 奖品类型：无/虚拟资金/钻石币/夺宝商品/分享福袋/钻石礼包/现金

排名奖励记录


rails g scaffold ranking_config_win user_id lottery_time:datetime ranking_config_id:integer lottery_order_id:integer lottery_id:integer

rails g scaffold ranking_order ranking_config_id:integer ranking_config_item_id:integer user_id:integer status:integer product_id:integer total_count:integer total_price address_id:integer request_ip

钻币礼包

rails g scaffold coin_bag coin_count:integer person_count:integer remain_coin_count:integer coin_count_groups end_time:datetime is_published:boolean   lock_version:integer

rails g scaffold coin_bag_lottery coin_bag_id:integer user_id:integer  share_code

rails g scaffold coin_bag_lottery_item coin_bag_lottery_id:integer coin_bag_id:integer user_id:integer request_ip coin_count:integer

2017-02-23
梦网短信接口 短信验证码

2017-02-22
用户授权 微信/手机

2017-02-21
wechat 初始化

rails g scaffold charge_order user_id:integer pay_type:integer status:integer "money:decimal{10,2}" micro_diamond:integer
