$(function () {
  $('.tab-box .tab-btn').on('click',function(){
    $(this).addClass('active').siblings(".tab-box .tab-btn").removeClass('active');
    var idx = $(this).index()
    $($(".tab-content .tab-lister")[idx]).show().siblings(".tab-content .tab-lister").hide();
    kLine();
    if (idx==1) {
    	$(".top-btm").hide();
    }else{
    	$(".top-btm").show();
    };
  })
})
