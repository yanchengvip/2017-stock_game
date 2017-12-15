function lottery_time(id, lottery_end_time){
    open_times = [360, 660, 960, 1260, 1560, 1860, 2160, 2460, 2760, 3060, 3360, 3660, 3960, 4260, 4560, 4860, 5160, 5460, 5760, 6060, 6360, 6660, 6960, 36060, 36660, 37260, 37860, 38460, 39060, 39660, 40260, 40860, 41460, 42060, 42660, 43260, 43860, 44460, 45060, 45660, 46260, 46860, 47460, 48060, 48660, 49260, 49860, 50460, 51060, 51660, 52260, 52860, 53460, 54060, 54660, 55260, 55860, 56460, 57060, 57660, 58260, 58860, 59460, 60060, 60660, 61260, 61860, 62460, 63060, 63660, 64260, 64860, 65460, 66060, 66660, 67260, 67860, 68460, 69060, 69660, 70260, 70860, 71460, 72060, 72660, 73260, 73860, 74460, 75060, 75660, 76260, 76860, 77460, 78060, 78660, 79260, 79560, 79860, 80160, 80460, 80760, 81060, 81360, 81660, 81960, 82260, 82560, 82860, 83160, 83460, 83760, 84060, 84360, 84660, 84960, 85260, 85560, 85860, 86160, 86460]
    day_begin = Date.parse($.format.date(Date.now(), strftime = "yyyy-MM-dd"))/1000 - 8 * 3600

    lottery_end_time = Date.parse(lottery_end_time)

    if(Date.now() - lottery_end_time > 10 * 60 * 1000){
      console.log(id)
      console.log($.format.date(lottery_end_time, "yyyy/MM/dd HH:mm:ss"))
      Conutdown($.format.date(lottery_end_time, "yyyy/MM/dd HH:mm:ss"), "#" +id)
      return false
    }

    seconds = Date.now()/1000 - day_begin
    $.each(open_times, function(index, x){
      if(x > seconds){
        Conutdown($.format.date((x+day_begin)*1000, "yyyy/MM/dd HH:mm:ss"), "#"+id)
        return false
      }
    })
}

function formatDate(date, strftime) {
  if(!strftime){
    strftime = "yyyy-MM-dd HH:mm:ss"
  }
  return $.format.date(date, strftime);
}

  /*数字用逗号间隔*/
function outputmoney(number) {
  /*number = number.replace(/\,/g, "");*/
  /*if(isNaN(number) || number == "")return "";*/
  number = Math.round(number * 100) / 100;
  if (number < 0)
    return '-' + outputdollars(Math.floor(Math.abs(number) - 0) + '') + outputcents(Math.abs(number) - 0);
  else
    return outputdollars(Math.floor(number - 0) + '') + outputcents(number - 0);
}
//格式化金额
function outputdollars(number) {
  if (number.length <= 3)
    return (number == '' ? '0' : number);
  else {
    var mod = number.length % 3;
    var output = (mod == 0 ? '' : (number.substring(0, mod)));
    for (i = 0; i < Math.floor(number.length / 3); i++) {
      if ((mod == 0) && (i == 0))
        output += number.substring(mod + 3 * i, mod + 3 * i + 3);
      else
        output += ',' + number.substring(mod + 3 * i, mod + 3 * i + 3);
    }
    return (output);
  }
}
function outputcents(amount) {
  amount = Math.round(((amount) - Math.floor(amount)) * 100);
  return (amount < 10 ? '.0' + amount : '.' + amount);
}
 //字符串截取
function filter_String(s){
  console.log(s)

  // s = s.match(/[a-zA-Z0-9\u4e00-\u9fa5]+/)[0]
  var Length = s.length;
  // if(s[0] == "\uD83C" || s[0] == "\uD83D"){
  //   return s.substr(0,2)+"**"
  // }

  // if(typeof(s) !="string"){
  //   s = s.toString(s);
  // }
  // if((Length>0) && (Length<3)){
  //   s = s.substr(0,1) + '**';
  // }
  // else if(Length >= 3){
  //   s = s.substr(0,1) + '**' + s.substr(Length-1,1);
  // }
  // else{
  //   s = "***";
  // }
  if(s.length > 4){
    s = s.substr(0,2)+"*"+s.substr(s.length-2, 2)
  }
  else if(s.length > 2){
    console.log(s.length)
    s = s.substr(0,2)+"**"
  }else{
    s = s + "**"
  }
  return s;
}
//
function to_persent(amount, total_count, sales_count) {
  amount = amount * 100
  res = amount.toFixed(0) + "%";
  if(res == "100%" && total_count - sales_count > 0){
    res = "99%"
  }
  if(amount == 0){
    res = (sales_count * 100.0 / total_count).toFixed(0)+ "%";
  }
  return res
}

function lottery_name(name){
  return name
  if(name.length > 18){
    return name.substr(0,18)+"..."
  }else{
    return name
  }
}

function to_fixed(number, n){
  return parseFloat(number).toFixed(n)
}
$.views.helpers({format: formatDate});
$.views.helpers({outputmoney: outputmoney, filter_string: filter_String, to_persent: to_persent, lottery_name: lottery_name, to_fixed: to_fixed});
