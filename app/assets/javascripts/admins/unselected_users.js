/**
 * Created by iuzuan on 2017/3/23.
 */

function get_unselected_users_remote(){
    $.ajax({
        type: 'post',
        datatype: 'json',
        url: '',
        success: function(data){
                $('#unselected_users_partial').html(data)
        }

    })
}

//钻币礼包选择用户
function search_unselected_users(){
    var name_or_phone = $('#coin_to_user_search').val()
    var product_id = $('#coin_bag_product_id').val()

    var data = {id: product_id, name_or_phone: name_or_phone}
    $.ajax({
        type: 'get',
        datatype: 'json',
        contentType: "application/json",
        url: '/admins/coin_bags/search_unselected_users',
        data: data,
        success: function(data){
            $('#unselected_users_partial').html(data)
            //console.log(55)
        }

    })
}

//分享福袋选择用户
function search_unselected_users_bag(){
    var name_or_phone = $('#bag_to_user_search').val()
    var product_id = $('#bag_product_id').val()

    var data = {id: product_id, name_or_phone: name_or_phone}
    $.ajax({
        type: 'get',
        datatype: 'json',
        contentType: "application/json",
        url: '/admins/lucky_bags/search_unselected_users',
        data: data,
        success: function(data){
            $('#unselected_users_partial').html(data)
        }

    })
}