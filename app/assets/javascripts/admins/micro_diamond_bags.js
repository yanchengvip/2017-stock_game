$(function () {

    //创建红包开奖时间
    var buy_date = moment().startOf('day').add(32,'hour').format('YYYY-MM-DD HH:mm');
    var enabled_date = moment().startOf('day').add(32,'hour').format('YYYY-MM-DD HH:mm');

    $('#micro_published_picker').datetimepicker({
        defaultDate: buy_date,
        format: 'YYYY-MM-DD HH:mm',
        locale: 'zh-cn'
    }).on('dp.change',function(e){
        buy_date =  moment($('#micro_published_picker').val()).add(1,'hour').format("YYYY-MM-DD HH:mm");
        enabled_date = moment($('#micro_published_picker').val()).format("YYYY-MM-DD");
        $('#micro_buy_date_picker').data("DateTimePicker").enabledDates([buy_date]);
        $('#micro_buy_date_picker').data('DateTimePicker').date(buy_date)
     });

    $('#micro_buy_date_picker').datetimepicker({
        defaultDate: moment(buy_date).add(1,'hour').format("YYYY-MM-DD HH:mm"),
        enabledDates: [enabled_date],
        format: 'YYYY-MM-DD HH:mm',
        locale: 'zh-cn'
    })

});


function micro_bag_delete(micro_bag_id){

    $('#deleteMicroModal').modal('show');
    $('#deleteMicroModal').on('shown.bs.modal',function(){
        $('#del_micro_id').val(micro_bag_id)
    })

}
