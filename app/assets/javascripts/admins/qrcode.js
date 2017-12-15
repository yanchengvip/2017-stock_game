//删除福袋
function qrcode_delete(qrcode_id){
    $('#deleteqrcodeModal').modal('show');
    $('#deleteqrcodeModal').on('shown.bs.modal',function(){
        $('#del_qrcode_id').val(qrcode_id)
    })

}