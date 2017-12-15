function deleteProductTag(tagid){
    $('#DeleteproductTagModal').modal('show');
    $('#DeleteproductTagModal').on('shown.bs.modal',function(){
        $('#del_product_tag_id').val(tagid)
    })
}

function updateProductTag(tagid,tagname,sort){
    $('#updateProductTagModal').modal('show');
    $('#updateProductTagModal').on('shown.bs.modal',function(){
        $('#update_product_tag_id').val(tagid)
        $('#update_product_tag').val(tagname)
        $('#update_product_tag_sort').val(sort)
    })
}
