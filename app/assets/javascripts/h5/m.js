function mData() {

  //模拟当日数据
  var demoData = dataTestOut();
  var minData = [] //分时图数据
  var averageData = [] //分时图均线数据
  var columnData = [] //分时图成交量数据
  for (var i = 0; i < demoData.length; i++) {
    minData.push([demoData[i][0], demoData[i][1]])
    averageData.push([demoData[i][0], demoData[i][2]])
    columnData.push([demoData[i][0], demoData[i][3]])
  }
  // 生成模拟数据函数
  function dataTestOut() {
    var dataTest = [];
    var dataBranch1 = [];

    var a = 1489023000000;
    var b = 300;
    var c = 0;
    for (var i = 0; i < 330; i++) {
      a = a + 60000;
      if (i < 50) {
        b -= 0.03
      } else {
        b += 0.06
      }
      if (i <= 150) {
        var randomNum = Math.random();
        dataBranch1.push(a)
        dataBranch1.push(b + Math.random() * 2 - Math.random() * 2)
        dataBranch1.push(b + Math.random() - Math.random())
        dataBranch1.push(c + Math.random())
      } else {
        var randomNum = Math.random();
        dataBranch1.push(a)
        dataBranch1.push(null)
      }
      dataTest.push(dataBranch1)
      dataBranch1 = [];
    }
    // console.log(dataTest)

    return dataTest
  }


  var todayDate = demoData[0];
  var day = Highcharts.dateFormat('%Y/%m/%d', todayDate),
    breaks = [{
      from: new Date(day + ' 11:30').getTime(),
      to: new Date(day + ' 13:00').getTime(),
      breakSize: 0 * 60
    }]

  var crrentData = [];
  var retTrade = [minData, averageData, columnData];
  // console.log(retTrade)
  return retTrade
}


function mLine(divId) {

  Highcharts.setOptions({
    global: {
      timezoneOffset: -8*60
    }
  });
  var result = mData();
  var $reporting = $("#report");
  var mouseX;
  var open = 300  //开盘价
  var minTime,midTime,maxTime; //每日分时图起始时间、中点、终止时间

  minTime=1489023000000;
  midTime=1489030200000;
  maxTime=1489042800000;


  var openPrice,closePrice,minPrice,maxPrice; //开盘价、收盘价、最低价、最高价

  openPrice = 290;
  closePrice = 310;
  minPrice = 290;
  maxPrice = 310;

  var mychart = Highcharts.StockChart({
    chart: {
      renderTo: divId,
      events: {
        load: function () {
          // set up the updating of the chart each second
          var series0 = this.series[0];
          var series1 = this.series[1];

          var idx = 150;
          setInterval(function () {
            var x = result[0][idx - 1][0] + 60000;
            y0 = Math.random() - Math.random() + 300;
            y1 = Math.random() - Math.random() + 300;
            series0.addPoint([x, y0], true, false);
            series1.addPoint([x, y1], true, false);
            idx++;
            mychart.redraw();
          }, 1000);
        }
      }
    },
    plotOptions: {
      series: {
        states: {
          hover: {
            enabled: false,
            lineWidth: 0
          }
        }
      }
    },
    rangeSelector: {
      enabled: false  //隐藏左上角范围选择器
    },
    scrollbar: {
      enabled: false  //隐藏滚动条
    },
    navigation: {
      buttonOptions: {
        enabled: false  //隐藏顶部导航条
      }
    },
    navigator: {
      enabled: false    //隐藏底部范围选择
    },
    credits: {
      enabled: false //隐藏highchart.com字样
    },
    xAxis: {
      crosshair: {     //鼠标经过出现十字线
        dashStyle: 'dash',   //十字线样式
      },
      min: minTime, //1489023000000,
      max: maxTime, //1489042800000,
      type: 'datetime',
      labels: {
        x: 0,
        y: 15,
        formatter: function () {
          if (this.value === midTime) {  //11:30 -- 1489030200000
            return '11:30/13:00';
          }
          return Highcharts.dateFormat("%H:%M", this.value);
        },
      },
      tickPositioner: function () {
        return [minTime, midTime, maxTime]  //9:30,11:30,13:00
      },
      
    },
    yAxis: [{
      title: {
        enable: false
      },
      lineWidth: 1,//Y轴边缘线条粗细
      gridLineColor: '#346691',
      gridLineWidth: 0.1,
      // gridLineDashStyle: 'longdash',
      opposite: false,
      labels: {
        align: "left",
        x: 10
      }
    }, {
      title: {
        text: ''    //右侧Y轴名字
      },
      lineWidth: 1,//Y轴边缘线条粗细
      gridLineColor: '#eee', //横线颜色
      minorGridLineWidth: 0,
      // data:demoData,
      opposite: true,
      gridLineWidth: 0,
      tickInterval: 8,  //刻度比例
      max: maxPrice + 10,  // 定义Y轴 最大值
      min: minPrice - 5,  // 定义最小值
      labels: {
        align: "right",
        x: -10,
        // y: 0,
        formatter: function () {
          var a = ( this.value - open ) / this.value
          if (this.value > open) {
            return '<span style="color: red">' + (Math.floor(a * 1000) / 100).toFixed(2) + '% </span>';
          } else if (this.value < open) {
            return '<span style="color: green">' + (Math.floor(a * 1000) / 100).toFixed(2) + '% </span>';
          } else if (this.value = open) {
            return '<span style="color: gray">' + (Math.floor(a * 1000) / 100).toFixed(2) + '% </span>';
          }
          
          
          // return (this.value > 0 ? ' <span style="color: red"> + ' : '<span style="color: green">') + this.value + '% </span>';
        }
        
      }
    }],
    
    series: [{
      name: 'GOOGL',
      data: result[0],
      lineWidth: 1, //曲线线条粗细
      yAxis: 0,
      marker: {
        enabled: false,  //是否在点出突出画一个圆点
        states: {
          hover: {
            enabled: false
          }
        }
      }
    }, {
      name: 'GOOGL',
      data: result[1],
      color: '#E1B91B', //线条颜色
      lineWidth: 1, //曲线线条粗细
      yAxis: 0,
      marker: {
        enabled: false,  //是否在点出突出画一个圆点
        states: {
          hover: {
            enabled: false
          }
        }
      }
    }],
    tooltip: {
      positioner: function () { //设置tips显示的相对位置
        var halfWidth = this.chart.chartWidth / 2;//chart宽度
        var width = this.chart.chartWidth - 155;
        var height = this.chart.chartHeight / 5 - 50;//chart高度
        if (mouseX < halfWidth) {
          return {x: width, y: height};
        } else {
          return {x: 30, y: height};
        }
      },
      shared: true,
      useHTML: true,
      shadow: false,
      // borderColor: "rgba(255, 255, 255, 0)",
      // backgroundColor: "rgba(255, 255, 255, 0)",
      borderColor: '#666',
      valueDecimals: 2,
      formatter: function () {
        mouseX = this.points[0].point.plotX
        console.log(mouseX)
        var time, cprice,aprice,Range, z, o = this;
        //当前时间，当前价，均价，涨幅
        return $.each(this.points, function () {
          var n = this.point.index;
          var a = Highcharts.numberFormat(o.y, 2);
          var b = Highcharts.numberFormat(o.y, 3);
          time = Highcharts.dateFormat("20%y-%m-%d %H:%M", this.x),   //当前点的时间
            cprice = "价:" + '<span style="color:red;">' + Highcharts.numberFormat(o.y, 2) + '</span>',
            z = "价：" + Highcharts.numberFormat(o.y, 3)
          aprice = "均：" + Highcharts.numberFormat(o.y, 2)
          
          
          if (a > open) {
            cprice = "价:" + '<span style="color:red;">' + a + '</span>';
            aprice = "均:" + '<span style="color:red;">' + b + '</span>';
            Range = "幅:" + '<span style="color:red;">' + (Math.floor((a - open) / a * 1000) / 100).toFixed(2) + '% </span>';
          } else if (a < open) {
            cprice = "价:" + '<span style="color:green;">' + a + '</span>';
            aprice = "均:" + '<span style="color:green;">' + b + ' </span>';
            Range = "幅:" + '<span style="color:green;">' + (Math.floor((a - open) / a * 1000) / 100).toFixed(2) + '% </span>';
          } else if (a = open) {
            cprice = "价:" + '<span style="color:gray;">' + a + '</span>';
            aprice = "均:" + '<span style="color:gray;">' + b + ' </span>';
            Range = "幅:" + '<span style="color:gray;">' + (Math.floor((a - open) / a * 1000) / 100).toFixed(2) + '% </span>';
          }

          $reporting.html("时间：" + time + ' ' + cprice + ' ' + aprice + '' + Range);
        }),
        time + '<br>' + cprice + '<br>' + aprice + '<br>' +Range;

      }
    }
  });


}


