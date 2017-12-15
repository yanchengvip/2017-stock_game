namespace :db  do
  task admin_seeds:  :environment do
    products_seed
    lotteries_seed
    admin_seed


    #ranking_data
    ranking_award_seed
    ranking_rate_seed
    ranking_config_items_seed
    ranking_config_win_seeds #需要先注释modle中的alfter方法

    #竞赛排名
    ranking_config_win_order_seed
  end
end

def admin_seed
  #Role.delete_all
  User.create(
           id: 100,
           nickname: 'zuanlian',
           phone: '110',
           encrypted_password: '123'
  )

  User.create(
      id: 200,
      nickname: 'zuanlian4',
      phone: '115',
      encrypted_password: '123'
  )

  User.create(
      nickname: 'zuanlian2',
      phone: '112',
      encrypted_password: '123'
  )

  User.create(
      nickname: 'zuanlian3',
      phone: '114',
      encrypted_password: '123'
  )

  Role.create(
          user_id: 100,
          name: 'admin'
  )
end

def products_seed

  # Product.delete_all

  Product.create(
             id: 1,
             name: '夺宝1-Burberry黑色真皮拼接格纹装饰女士斜挎包',
             desc: '就是好，高大上档次！',
             price: 99999,
             inventory_count: 100,
             head_image: 'http://www.ihaveu.com/index.html#subapp=productGrid&keyword=钻石专属',
             is_published: true,
             product_type: 1

  )

  Product.create(
      id: 2,
      name: '夺宝2-Burberry黑色真皮拼接格纹装饰女士斜挎包',
      desc: '就是好，高大上档次！',
      price: 99999,
      inventory_count: 100,
      head_image: 'http://www.ihaveu.com/index.html#subapp=productGrid&keyword=钻石专属',
      is_published: true,
      product_type: 1

  )

  Product.create(
      id: 3,
      name: '夺宝3-Burberry黑色真皮拼接格纹装饰女士斜挎包1',
      desc: '就是好，高大上档次！',
      price: 99999,
      inventory_count: 100,
      head_image: 'http://www.ihaveu.com/index.html#subapp=productGrid&keyword=钻石专属',
      is_published: true,
      product_type: 1

  )


  Product.create(
      id: 4,
      name: '福袋1-钻石礼包',
      desc: '就是好，高大上档次！',
      price: 99999,
      inventory_count: 100,
      total_count: 30,
      end_time: Time.new,
      award: '送一克拉钻石',
      head_image: 'http://www.ihaveu.com/index.html#subapp=productGrid&keyword=钻石专属',
      is_published: true,
      product_type: 2

  )

  Product.create(
      id: 5,
      name: '福袋2-钻石礼包',
      desc: '就是好，高大上档次！',
      price: 99999,
      inventory_count: 100,
      total_count: 30,
      end_time: Time.new,
      award: '送一克拉钻石',
      head_image: 'http://www.ihaveu.com/index.html#subapp=productGrid&keyword=钻石专属',
      is_published: true,
      product_type: 2

  )
end


def lotteries_seed
    # Lottery.delete_all
    # LotteryOrder.delete_all
    # LotteryOrderItem.delete_all
    #夺宝
   Lottery.create(
      id: 1,
      product_id: 1,
      published_at: Time.new,
      lottery_time: Time.new,
      end_time: Time.new,
      status: 0,
      product_name: '夺宝1-Burberry黑色真皮拼接格纹装饰女士斜挎包',
      sales_count: 0,
      total_count: 100,
      price: 10,
      lottery_code: '20170313123456'

   )

    Lottery.create(
        id: 2,
        product_id: 1,
        published_at: Time.new,
        lottery_time: Time.new,
        end_time: Time.new,
        status: 0,
        product_name: '夺宝1-Burberry黑色真皮拼接格纹装饰女士斜挎包',
        sales_count: 0,
        total_count: 100,
        price: 10,
        lottery_code: '20170313123457'

    )

  #福袋

    Lottery.create(
        id: 3,
        product_id: 4,
        published_at: Time.new,
        lottery_time: Time.new,
        end_time: Time.new,
        status: 0,
        user_id: 100,
        product_name: '夺宝1-钻石礼包',
        sales_count: 0,
        total_count: 100,
        price: 10,
        award: '送一克拉钻石',
        lottery_code: '20170313123459'

    )


    Lottery.create(
        id: 4,
        product_id: 4,
        published_at: Time.new,
        lottery_time: Time.new,
        end_time: Time.new,
        status: 0,
        user_id: 100,
        product_name: '夺宝2-钻石礼包',
        sales_count: 0,
        total_count: 100,
        price: 10,
        award: '送一克拉钻石',
        lottery_code: '20170313123458'

    )


      LotteryOrder.create(
                      id: 1,
                      lottery_id: 1,
                      user_id: 200,
                      request_ip: '127.0.0.1',
                      total_count: 10,
                      status: 0,
      )


    LotteryOrder.create(
        id: 2,
        lottery_id: 3,
        user_id: 200,
        request_ip: '127.0.0.1',
        total_count: 10,
        status: 0,
    )


    LotteryOrderItem.create(
          lottery_id: 3,
          lottery_order_id: 2,
          user_id: 200,
          request_ip: '127.0.0.1',
          is_win: true,
          lottery_code: '20170313123654'
    )
end




