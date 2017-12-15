//删除资源
function resource_delete(resource_id){
    $('#resourceModal').modal('show');
    $('#resourceModal').on('shown.bs.modal',function(){
        $('#del_resource_id').val(resource_id)
    })

}