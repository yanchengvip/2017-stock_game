/**
 * Created by iuzuan on 2017/3/9.
 */
function lucky_bag_delete(product_id,product_name){

    $('#deleteBagsModal').modal('show');
    $('#deleteBagsModal').on('shown.bs.modal',function(){
        $('#del_bag_name').html(product_name)
        $('#del_bag_id').val(product_id)
    })

}