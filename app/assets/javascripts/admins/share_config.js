//删除福袋
function share_config_delete(share_config_id){
    $('#shareconfigModal').modal('show');
    $('#shareconfigModal').on('shown.bs.modal',function(){
        $('#del_share_id').val(share_config_id)
    })

}