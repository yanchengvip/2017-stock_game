module Admins
  module DownloadCsv
    extend ActiveSupport::Concern

    module ClassMethods
      def to_csv
        CSV.generate do |csv|
          csv << column_names
          all.each do |product|
            csv << product.attributes.values_at(*column_names)
          end
        end
      end


      def custom_save_csv file_path,datas, *headers
        csv_string = CSV.generate do |csv|
          headers.each do |h|
            csv << h
          end
          datas.each do |data|
            csv << data
          end
        end.encode('gb2312', :invalid => :replace, :undef => :replace, :replace => "?")

        File.open(file_path, "w") do |file|
          file.syswrite csv_string
        end

      end


      # def custom_save_csv file_path,datas,*headers
      #   csv_file = CSV.open(file_path,'wb',encoding: 'gb2312') do |csv|
      #     headers.each do |h|
      #       csv << h
      #     end
      #     datas.each do |data|
      #       csv << data
      #     end
      #   end
      #   #csv_file.close()
      # end


      #每天用户关注和取消关注以及每天金额变化的统计
      def user_wechat_subscribe_csv

        datas = User.users_everyday_subscribe_data

        if !Dir.exists?('public/uploads/csv/')
          Dir.mkdir('public/uploads/csv/')
        end

        if !File.file?('public/uploads/csv/2017_everyday_wechat_subscribe.csv')
          csv_string = CSV.generate do |csv|
            csv << ['日期', '新关注人数', '取消关注人数', '净增关注人数', '累积关注人数', '当日累计注册用户', '当日开奖期数',
                    '当日上架数量', '当日剩余商品数', '当日登录人数', '当日参与人数', '当日关注微信获取钻币数', '当日注册获得钻币总数',
                    '当日邀请好友获得钻币数', '当日虚拟资金兑换获得钻币数', '当日消耗钻币', '当日可用钻币总额']

          end.encode('gb2312', :invalid => :replace, :undef => :replace, :replace => "?")

          File.open('public/uploads/csv/2017_everyday_wechat_subscribe.csv', "a") do |file|
            file.syswrite csv_string
          end
          #生成一条记录
          CsvFile.create(url: '/uploads/csv/2017_everyday_wechat_subscribe.csv',
                         csv_name: '2017_everyday_wechat_subscribe.csv', statistic_type: 5, download_date: Time.now.strftime("%Y%m%d"))
        end


        csv_string = CSV.generate do |csv|
          csv << datas

        end.encode('gb2312', :invalid => :replace, :undef => :replace, :replace => "?")

        File.open('public/uploads/csv/2017_everyday_wechat_subscribe.csv', "a") do |file|
          file.syswrite csv_string
        end

      end

    end

    module InstanceMethods
    end

  end
end