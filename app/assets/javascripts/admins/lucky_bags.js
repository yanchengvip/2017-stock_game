/**
 * Created by iuzuan on 2017/3/8.
 */
function reduce_num(bag_num_input_id) {
    var current_num = parseInt($('#' + bag_num_input_id).val())
    num = --current_num
    if (num < 1) {
        $('#' + bag_num_input_id).val(1);
        return
    }
    //预计分发数量
    $('#pre_send_num').text(parseInt($('#pre_send_num').text()) - 1)
    $('#' + bag_num_input_id).val(num)
}

function add_num(bag_num_input_id) {
    var current_num = parseInt($('#' + bag_num_input_id).val());
    num = ++current_num;
    //预计分发数量
    $('#pre_send_num').text(parseInt($('#pre_send_num').text()) + 1)
    $('#' + bag_num_input_id).val(num)
}


//分发福袋给用户

function show_selected_user(unselect_li_id, user_id, user_name, phone) {

    selected_user = '<li class="list-group-item list-group-item-success" id="selected_user_li' + user_id + '"' + '>' + user_name + '&nbsp&nbsp' + phone + '&nbsp&nbsp' +

        '<span class="glyphicon glyphicon-minus badge_cursor"  id="bag_reduce_num' + user_id + '"' + ' aria-hidden="true"></span>' +
        '&nbsp<input type="number" value="1" user_id="' + user_id + '"' + 'id="bag_num_input' + user_id + '"' + ' class="bags_to_user_input">&nbsp' +

        '<span class="glyphicon glyphicon-plus badge_cursor" id="bag_add_num' + user_id + '"' + '  aria-hidden="true"></span>' +
        '<button   class="badge badge_cursor" id="bag_bt' + user_id + '"' + '>删除</button>' +
        '</li>'


    is_selected = is_selected_user('selected_user_li' + user_id);

    if (is_selected) {
        alert('此用户已被选中，不能重复')
        return false;
    }

    $('#selected_user_ul').append(selected_user);
    //$('#bag_add_num'+user_id).attr("onclick","add_num("+user_id+")")
    document.getElementById('bag_reduce_num' + user_id).onclick = function () {
        reduce_num('bag_num_input' + user_id)
    }
    document.getElementById('bag_add_num' + user_id).onclick = function () {
        add_num('bag_num_input' + user_id)
    }
    document.getElementById('bag_bt' + user_id).onclick = function () {
        hide_selected_user('selected_user_li' + user_id, unselect_li_id)
    }

    //已选择的用户数量
    $('#show_selected_num').text(parseInt($('#show_selected_num').text()) + 1)
    //预计分发数量
    $('#pre_send_num').text(parseInt($('#pre_send_num').text()) + 1)
    $("#" + unselect_li_id).hide();
}

//取消 分发福袋用户
function hide_selected_user(selected_user_li_id, unselect_li_id) {
    //已选择的用户数量
    $('#show_selected_num').text(parseInt($('#show_selected_num').text()) - 1)
    //预计分发数量
    var num = parseInt($("#" + selected_user_li_id).children('input').val()) //已分发的数量
    $('#pre_send_num').text(parseInt($('#pre_send_num').text()) - num)
    $("#" + selected_user_li_id).remove();
    $("#" + unselect_li_id).show();
}


function save_selected_user(product_id) {
    var lottery_arr = []
    var input_arr = $('#selected_user_ul').children('li').children('input');
    input_arr.each(function () {
        var lottery_attr = {user_id: $(this).attr('user_id'), lottery_num: $(this).val()}
        lottery_arr.push(lottery_attr)
    })
    var data = JSON.stringify({id: product_id, lottery_arr: lottery_arr})

    if (lottery_arr.length == 0) {
        alert('用户不能为空');
        return false;
    }

    $.ajax({
        type: 'post',
        dataType: 'json',
        contentType: "application/json",
        url: '/admins/lucky_bags/bag_selected_user',
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

//判断是否已经选择用户，右面已选择用户列表中是否存在
function is_selected_user(selected_li_id) {
    flag = false
    $('#selected_user_ul li').each(function (index, li) {
        if (li.id == selected_li_id) {
            //说明此用户已经被选中，不能重复选
            flag = true;
            return;
        }

    });

    return flag;

}


$(function () {
    //创建福袋时的有效期
    $('#end_time_picker').val(moment().add(1,'month').format('YYYY-MM-DD HH:mm'))
    $('#end_time_picker').datetimepicker({
        format: 'YYYY-MM-DD HH:mm',
        locale: 'zh-cn'
    }).on('dp.change', function (ev) {

    });


})

