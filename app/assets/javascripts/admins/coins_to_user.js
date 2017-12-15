/**
 * Created by iuzuan on 2017/3/15.
 */


/**
 * Created by iuzuan on 2017/3/8.
 */

//分发福袋给用户
function save_selected_user_coin(coin_bag_id) {
    var lottery_arr = []
    var input_arr = $('#selected_user_ul').children('li').children('input');
    input_arr.each(function () {
        var lottery_attr = {user_id: $(this).attr('user_id'), lottery_num: $(this).val()}
        lottery_arr.push(lottery_attr)
    })
    var data = JSON.stringify({id: coin_bag_id, lottery_arr: lottery_arr})
    if(lottery_arr.length == 0){
        alert('用户不能为空');
        return false;
    }
    $.ajax({
        type: 'post',
        dataType: 'json',
        contentType: "application/json",
        url: '/admins/coin_bags/coins_to_user_save',
        data: data,
        success: function (data) {
            if (data['status'] == '1') {
                alert('分配成功！')
                location.reload()
            } else if (data['status'] == '2') {
                alert(data['message'])
            }
        }


    })
}


// $(function () {
//
//     //创建福袋时的有效期
//     $('#end_time_picker').val(moment().format('YYYY-MM-DD HH:mm'))
//     $('#end_time_picker').datetimepicker({
//         format: 'YYYY-MM-DD HH:mm',
//         locale: 'zh-cn'
//     }).on('dp.change', function (ev) {
//
//     });
//
//
// })

