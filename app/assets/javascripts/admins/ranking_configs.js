/**
 * Created by iuzuan on 2017/3/10.
 */

function add_ranking_modal() {
    $('#addRankingModal').modal('show')
}

function add_ranking_modal2() {
    $('#addRankingModal2').modal('show')
}


//收益-日排行奖品设置
$(function(){
    //奖品选中为无的checkbox触发的事件
    $('#empty_award').change(function(){
        if ($("#empty_award").is(":checked")){

            $(".o-checkbox").attr("disabled","disabled");
            $('.o-checkbox').prop('checked', false);
        }else{
            $('.o-checkbox').removeAttr('disabled')

        }

    })
})
