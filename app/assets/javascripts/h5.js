// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jsviews
//= require jsviews_helper
//= require h5/base
//= require h5/swiper.jquery.min
//= require sweetalert
//= require h5/iscroll
//= require h5/pullToRefresh
//= require h5/count_down
//= require h5/clipboard.min
//= require jquery-dateFormat.min
//= require h5/highstock
//= require dropload.min
swal.setDefaults({confirmButtonText: "确定"})
function cannot_close_alert(){
  alertTx('此交易为T+1交易规则<br>下一交易日才能交易，谢谢！')
}
function cannot_sell_alert(){
  alertTx('此交易为T+1交易规则<br>下一交易日才能交易，谢谢！')
}
