//页面切换 重新加载此js,取消turbolinks
$(document).on('turbolinks:load', function () {

    //统计月份
    $('.csv_datepicker').val(moment().format('YYYY-MM'))
    $('.csv_datepicker').datetimepicker({
        format: 'YYYY-MM',
        locale: 'zh-cn'
    }).on('dp.change', function (ev) {

    });

    //查询注册开始时间
    $('.csv_start_datetimepicker').datetimepicker({
        format: 'YYYY-MM-DD',
        locale: 'zh-cn'
    }).on('dp.change', function (ev) {

    });
    ;

    //查询注册结束时间
    $('.csv_end_datetimepicker').datetimepicker({
        format: 'YYYY-MM-DD',
        locale: 'zh-cn'
    }).on('dp.change', function (ev) {

    });

});

function dowload_csv(type) {
    d1 = {
        'csv_start_datetimepicker': $('.q5').val(),
        'csv_end_datetimepicker': $('.q6').val(),
        'user_source': $('#q9').val(),
        'nickname': $('.q10').val()
    }
    switch (type) {

        case 1:
            url = '/admins/download_csv/user_info_csv';
            d2 = {
                "tongji_start_datetimepicker": $('.q1').val(),
                'tongji_end_datetimepicker': $('.q2').val()
            }
            data = $.extend(d1, d2)
            downlod_csv(url, data)
            break;
        case 2:
            url = '/admins/download_csv/remain_balance_csv';
            d2 = {
                "tongji_end_datetimepicker": $('.q3').val()
            }
            data = $.extend(d1, d2)
            downlod_csv(url, data)
            break;
        case 3:
            url = '/admins/download_csv/change_balance_csv';
            d2 = {
                "tongji_start_datetimepicker": $('.q1').val(),
                'tongji_end_datetimepicker': $('.q2').val()
            }
            data = $.extend(d1, d2)
            downlod_csv(url, data)
            break;
        case 4:
            url = '/admins/download_csv/month_money_csv';
            d2 = {
                "tongji_date": $('.q4').val()
            }
            data = $.extend(d1, d2)
            downlod_csv(url, data)
            break;

        case 6:
            url = '/admins/download_csv/lottery_orders_csv';
            downlod_csv(url, '')
        default:


    }


}

function downlod_csv(url, data) {
    $.ajax({
        type: 'get',
        dataType: 'json',
        contentType: "application/json",
        url: url,
        data: data,
        success: function (data) {
            alert('下载成功后,请移步到【下载记录】拷贝文件')
        }
    })
}

