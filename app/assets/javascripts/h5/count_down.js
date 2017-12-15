function count_down(){
  $('.prize_count_time').each(function(index, item){
    item_count_down($(item), parseInt($(item).children('.seconds').text()));
  });
}

function item_count_down(timer_item, seconds){

  var pathname = window.location.pathname;

    if(seconds <= 0 ){
      // 页面刷新
      timer_item.children('.time_str').text('已开奖......').addClass('already_prize');;
      // if (!timer_item.children('.time_str').hasClass('already_prize')) { 
      //   timer_item.children('.time_str').addClass('already_prize');
      //   if(seconds < 0 ){ return false; };
      if(seconds < 0 ){ return false;}
      window.location.reload(); 
      // }
      // window.location.reload();
    }else{
      seconds -= 1;
      timer_item.children('.time_str').html( get_time_str(seconds));
      setTimeout(function(){item_count_down(timer_item, seconds)}, 1000);
    }
  }

// 把时间转换成时分秒格式
function get_time_str(intDiff){
  msg = ''
  if(intDiff > 0){
    days = Math.floor(intDiff / (60 * 60 * 24));
    // hours = Math.floor(intDiff / (60 * 60)) - (days * 24);
    hours1 = Math.floor(intDiff / (60 * 60)) - (days * 24);
    hours = Math.floor(intDiff / (60 * 60));
    // minutes = Math.floor(intDiff / 60) - (days * 24 * 60) - (hours * 60);
    minutes = Math.floor(intDiff / 60) - (days * 24 * 60) - (hours1 * 60);
    seconds = Math.floor(intDiff) - (days * 24 * 60 * 60) - (hours1 * 60 * 60) - (minutes * 60);

    if (minutes <= 9) minutes = '0' + minutes;
    if (seconds <= 9) seconds = '0' + seconds;

    //  var days = Math.floor((time_value / 3600)/ 24);
    // if(days > 0){
    //   msg += days + '天:';
    // }
    // msg += hours + '时:' + minutes + '分:' + seconds + '秒';
    msg += hours + ':' + minutes + ':' + seconds + '';
  }
  return msg
}