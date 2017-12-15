/**
 * Created by iuzuan on 2017/3/6.
 */

//顶置抽奖
function topLottery (lottery_id,code){
     $('#topLotteryModal').modal('show');
     $('#topLotteryModal').on('shown.bs.modal',function(){
        $('#top_lottery_code').html(code)
        $('#top_lottery_id').val(lottery_id)
    })
}


function autoPublishLottery(lottery){
    lottery = JSON.parse(lottery)
    $('#autoPublishLotteryModal').modal('show');
    $('#autoPublishLotteryModal').on('shown.bs.modal',function(){

        $('#lottery_id').val(lottery.id)
        if (lottery.auto_extension_status == '2'){
            $('#auto').attr("checked",true)

        }else{
            $('#not_auto').attr("checked",true)
        }
        $('#auto_extension_start_time').val(lottery.auto_extension_start_time)
        $('#auto_extension_end_time').val(lottery.auto_extension_end_time)
        $('#auto_extension_interval').val(lottery.auto_extension_interval)

    })
}