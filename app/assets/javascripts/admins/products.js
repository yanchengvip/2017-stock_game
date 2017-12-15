/**
 * Created by iuzuan on 2017/3/1.
 */


function product_delete(product_id,product_name){

    $('#deleteProductModal').modal('show');
    $('#deleteProductModal').on('shown.bs.modal',function(){
        $('#del_product_name').html(product_name)
        $('#del_product_id').val(product_id)
    })

}


//增加一期夺宝modal-js
function show_add_lottery_modal(product_id,product_price,product_name){
    $('#addLotteryModal').modal('show')
    $('#addLotteryModal').on('shown.bs.modal',function (){
        $('#product_id_l').val(product_id)
        $('#product_name_l').val(product_name)
        $('.current_pro_price_modal').html(product_price)
        $('#total_count_input').val(Math.floor(product_price))
        //发布时间默认值
        $('#published_at_picker').val(moment().format('YYYY-MM-DD HH:mm'))
        $('#published_at_radio').val(moment().format('YYYY-MM-DD HH:mm'))
        $('#published_at_radio2').val(moment().format('YYYY-MM-DD HH:mm'))
    })
}

//验证增加一期夺宝是否允许发布
function validate_add_lottery_form(form_data){
    var total_count = $('#total_count_input').val()
    var single_price = $('#single_price_input').val()
    var current_pro_price =  $('.current_pro_price_modal').val()

    //参与人数×参与单价×钻石币汇率>商品价格，才能进行商品抽奖发布
    if (total_count*single_price > current_pro_price) {
        return true;
    }else{
        alert('参与人数×参与单价×钻石币汇率>商品价格，才能进行商品抽奖发布')
        return false;
    }


}


//限制输入框的字数

function validate_words_length(max_num,type){
    if (type == 1){
        //添加时，验证产品名字的长度
       var  current_num = $('#add_product_name_input').val().length

        if (current_num<= 30){
            $('#apn_last_num').html('还能输入' + (30 - current_num) + '字')
        }else{
            $('#apn_last_num').html('还能输入0字')
        }

        var text_num = $('#add_product_name_input').val().substr(0,30)
        $('#add_product_name_input').val(text_num)
    }else if (type == 2){
        //添加时，验证商品描述的长度
        var  current_num = $('#add_product_desc_input').val().length

        if (current_num<= 60){
            $('#apd_last_num').html('还能输入' + (60 - current_num) + '字')
        }else{
            $('#apd_last_num').html('还能输入0字')
        }

        var text_num = $('#add_product_desc_input').val().substr(0,60)
        $('#add_product_desc_input').val(text_num)

    }else if (type == 3){

        //修改时，验证产品名字的长度
        var  current_num = $('#upni').val().length
        if (current_num<= 30){
            $('#epn_last_num').html('还能输入' + (30 - current_num) + '字')
        }else{
            $('#epn_last_num').html('还能输入0字')
        }

        var text_num = $('#upni').val().substr(0,30)
        $('#upni').val(text_num)
    }else if (type == 4){

        //修改时，验证商品描述的长度
        var  current_num = $('#update_product_desc_input').val().length

        if (current_num<= 60){
            $('#epd_last_num').html('还能输入' + (60 - current_num) + '字')
        }else{
            $('#epd_last_num').html('还能输入0字')
        }

        var text_num = $('#update_product_desc_input').val().substr(0,60)
        $('#update_product_desc_input').val(text_num)
    }

}


$(function () {

    // 一期夺宝发布时间
    $('#published_at_picker').datetimepicker({
        format: 'YYYY-MM-DD HH:mm',
        locale: 'zh-cn'
    }).on('dp.change',function (ev) {
        $('#published_at_radio').val(moment(ev.date).format('YYYY-MM-DD HH:mm'))
    });




});



