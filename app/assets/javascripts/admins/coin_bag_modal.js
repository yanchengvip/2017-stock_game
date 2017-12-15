/**
 * Created by iuzuan on 2017/3/15.
 */

//删除福袋
function coin_bag_delete(coin_bag_id){
    $('#deleteCoinbagModal').modal('show');
    $('#deleteCoinbagModal').on('shown.bs.modal',function(){
        $('#del_coin_id').val(coin_bag_id)
    })

}