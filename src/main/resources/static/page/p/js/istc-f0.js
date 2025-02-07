
/******************************************************************************/
/*
 * 
 */

var _amiType;
function dayStockchart(container, data) 
{
	var _chart;
	
	/******************************************************/
	
	this.setDataSource = function(data) {
		var seriesData = [[],[],[],[],[],[]];
		
		for(var ix=0; ix<seriesData.length; ix++) {
			_chart.series[ix].setData([]);
		}
		_chart.zoomOut();
		
		if(data) {
			var cnt = data.length;
			for(var ix=data.length-1; ix>=0; ix--) {
				var dateStr = data[ix].measDtStr;
				const [year, month, day] = dateStr.split('-').map(Number);
				var reDate = Date.UTC(year, month - 1, day);
				if(data[ix].pointSq) {
					seriesData[0].push([reDate, data[ix].termCv]);
					//seriesData[1].push([data[ix].measDt, data[ix].termCv_1d]);
					seriesData[1].push([reDate, data[ix].termCv_7d]);
					seriesData[2].push([reDate, data[ix].termCv_30d]);
					seriesData[3].push([reDate, data[ix].accuIv]);
					seriesData[4].push([reDate, data[ix].rawCnt]);
					seriesData[5].push([reDate, Math.round(data[ix].rawCnt/24*1000)/10] );
				}
				else {
					seriesData[0].push([reDate, null] );
					//seriesData[1].push([data[ix].measDt, null] );
					seriesData[1].push([reDate, null] );
					seriesData[2].push([reDate, null] );
					seriesData[3].push([reDate, null] );
					seriesData[4].push([reDate, null] );
					seriesData[5].push([reDate, null] );
				}
			}
		}
		for(var ix=0; ix<seriesData.length; ix++) {
			_chart.series[ix].setData(seriesData[ix]);
			//_chart.series[ix].isDirty = true;
		}
		_chart.zoomOut();
		//_chart.redraw();
		//setTimeout(_chart.zoomOut(), 1000);
	}

	this.getChart = function() {
		return _chart;
	}
	
	var clickDetected = false;
	
    var clr = [
    	Highcharts.getOptions().colors[7],
    	Highcharts.getOptions().colors[2],
    	Highcharts.getOptions().colors[3],
    	Highcharts.getOptions().colors[5]
    ]
    for(var ix=0; ix<clr.length; ix++)
		clr[ix] = (new Highcharts.Color(clr[ix])).setOpacity(1).get();	

	var _config = {
	    chart: {
	    	//renderTo: container, 
	        //zoomType: 'xy'
	    	zoomType: 'x',
	    	events: {
	    		click: function(event) {
	                if(clickDetected) {
	                    //alert ('x: '+ event.xAxis[0].value +', y: '+ event.yAxis[0].value);
	                    this.zoomOut();
	                    clickDetected = false;
	                } else {
	                    clickDetected = true;
	                    setTimeout(function() {
	                        clickDetected = false;
	                    }, 500); 
	                }
	            },
	            load: function(event) {
	            	/*var self = this;
	            	setTimeout(self.zoomOut(), 300);*/
	            	//this.zoomOut();
	            }
	    	}	    	
	    },
	    plotOptions: {
	    	series: {
	    		marker: {
	                fillColor: '#FFFFFF',
	                lineWidth: 1,
	                lineColor: null,
	                width: 5,
	                height: 5
	            }
	    	},	    	
		    dataGrouping: {
		        enabled: false,
		    },
		    column: {
		        //groupPadding: 0.2,
		        //pointPadding: 0.37,
		        pointWidth: 5
		    }
	    },
	    
	    scrollbar: {
            enabled: false
        },
        navigator: {
        	enabled: true,
        	xAxis: {
                type: 'datetime',
    		    labels: {
    		    	overflow: 'justify',
    	            formatter: function () {
    	            	return Highcharts.dateFormat('%y.%b.%d', this.value);
    	            	//return Highcharts.dateFormat('%b.%d %H:%M', this.value);
    	                //return Highcharts.dateFormat('%a %d %b %H:%M', this.value);
    	            },
    	            dateTimeLabelFormats: {
                        //minute: '%H:%M',
                        //hour: '%H:%M',
                        day: '%b.%d',
                        week: '%b.%d',
                        month: '\'%y %b',
                        year: '%Y'
    	            },
    	            labels: {
    	                enabled: true,
    	            },
    		    }
        	},
            series: {
            	dataGrouping: {
            		enabled: false
            	}
            },
            labels: {
		    	overflow: 'justify',
	            formatter: function () {
	            	return Highcharts.dateFormat('%y.%b.%d', this.value);
	            },
	            dateTimeLabelFormats: {
                    //minute: '%H:%M',
                    //hour: '%H:%M',
                    day: '%b.%d',
                    //week: '%b.%d',
                    //month: '\'%y %b',
                    //year: '%Y'
	            },
	            labels: {
	                enabled: true,
	            },
		    }
        },
	    tooltip: {
            split: false,
	        shared: true,
	        xDateFormat: '<span style="font-size:12px;color:gray;">%Y.%b.%d</span>'
	        //xDateFormat: '<span style="font-size:12px;color:gray;">%Y.%b.%d %H:%M</span>'
	        //style: {fontSize: '12pt'} 
	    },
	    legend: {
	    	enabled: true,
	        floating: false,
	    	layout: 'horizontal',
	    	align: 'center',
	        verticalAlign: 'top'
	        //x: 80,
	        //y: 0,
	        //backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
	    },

	    title: {
	        text: null//'24h 저수현황'
	    },
	    /*subtitle: {
	        text: 'Source: WorldClimate.com'
	    },*/
	    
	    rangeSelector: {
	    	enabled: false,
	    },
	    
	    xAxis: [{
            crosshair: true,
            type: 'datetime',
            //ordinal: false,
            //tickInterval: 24*3600*1000,
	        //minorTickLength: 7,
	        tickLength: 0,
		    labels: {
		    	overflow: 'justify',
	            formatter: function () {
	            	return Highcharts.dateFormat('%y.%b.%d', this.value);
	            	//return Highcharts.dateFormat('%b.%d %H:%M', this.value);
	                //return Highcharts.dateFormat('%a %d %b %H:%M', this.value);
	            },
	            dateTimeLabelFormats: {
                    //minute: '%H:%M',
                    //hour: '%H:%M',
                    day: '%b.%d',
                    week: '%b.%d',
                    month: '\'%y %b',
                    year: '%Y'
	            },
	            labels: {
	                enabled: true,
	            },
		    }
	    }],
	    yAxis: [
	    	{
		        title: {
		            text: '일사용량(㎥/일)',
		            //style: {color: Highcharts.getOptions().colors[1]}
		        },
		        labels: {
		        	align: 'left',
		        	x: 3,
		            format: '{value}㎥',
		            //style: {color: Highcharts.getOptions().colors[1]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },
		        opposite: false,
		        height: '65%',
	            lineWidth: 0
		    }, 
		    {
		        gridLineWidth: 0,
		        title: {
		            text: '검침값 (㎥)',
		            //style: {color: Highcharts.getOptions().colors[0]}
		        },
		        labels: {
		        	align: 'right',
		            format: '{value}㎥',
		            x: -3,
		            //style: {color: Highcharts.getOptions().colors[0]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 0);}
		        },
		        opposite: true,
		        height: '65%',
	            lineWidth: 0
		    },
	    	{
		        title: {
		            text: '검침횟수',
		            //style: {color: Highcharts.getOptions().colors[1]}
		        },
		        labels: {
		        	align: 'left',
		        	x: 3,
		            format: '{value}회',
		            //style: {color: Highcharts.getOptions().colors[1]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 0);}
		        },
		        opposite: false,
		        top: '75%',
	            height: '25%',
	            offset: 0,
	            lineWidth: 0
		    },
	    	{
		        title: {
		            text: '검침율',
		            //style: {color: Highcharts.getOptions().colors[1]}
		        },
		        labels: {
		        	align: 'right',
		            format: '{value}%',
		            x: -3,
		            //style: {color: Highcharts.getOptions().colors[1]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },
		        opposite: true,
		        top: '75%',
	            height: '25%',
	            offset: 0,
	            lineWidth: 0
		    }
		],
	    series: [
		    {
		        name: '당일',
		        type: 'column',
		        yAxis: 0,
		        data: [],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 3, valueSuffix: ' ㎥/일'}
		    }, 
		   /* {
		        name: '직전1일',
		        type: 'line',
		        yAxis: 0,
		        data: [],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 3, valueSuffix: ' ㎥/일'}
		    }, */
		    {
		        name: '직전7일간 평균',
		        type: 'line',
		        lineWidth: 1,
		        color: clr[1],
		        yAxis: 0,
		        data: [],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 3, valueSuffix: ' ㎥/일'}
		    }, 
		    {
		        name: '직전30일간 평균',
		        type: 'line',
		        lineWidth: 1,
		        color: clr[2],
		        yAxis: 0,
		        data: [],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 3, valueSuffix: ' ㎥/일'}
		    }, 
		    {
		        name: '검침값',
		        type: 'line',
		        lineWidth: 1,
		        marker : {
		        	symbol : 'circle'
		        },
		        color: clr[8],
		        //type: 'area',
		        //fillOpacity: 0.1,
		        yAxis: 1,
		        //lineWidth: 3,
		        //dashStyle: 'shortdot',
		        //color: Highcharts.getOptions().colors[0],
		        data: [],
		    	//dashStyle: 'Dash',
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 3, valueSuffix: ' ㎥'}
		    },
		    {
		        name: '검침횟수',
		        type: 'column',
		        color: Highcharts.getOptions().colors[9],
		        yAxis: 2,
		        data: [],
		        //color: Highcharts.getOptions().colors[1],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 0, valueSuffix: ''}
		    }, 
		    {
		        name: '검침율',
		        type: 'line',
		        color: Highcharts.getOptions().colors[8],
		        marker : {
		        	symbol : 'circle'
		        },
		        lineWidth: 1,
		        yAxis: 3,
		        data: [],
		        //color: Highcharts.getOptions().colors[1],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 1, valueSuffix: ' %'}
		    } 
		    
	    ]
	};
	
	this.initChart = function(container) {
		var config = $.extend(true, {}, _config);
		//_chart = Highcharts.stockChart(container, config);
		_chart = Highcharts.chart(container, config);
		
		if(data)
			this.setDataSource(data);
	};
	
	return this;
}

/******************************************************************************/
/*
 * 
 */


function rawStockchart(container, data) 
{
	var _chart;
	
	/******************************************************/
	
	this.setDataSource = function(data) {
		var seriesData = [[],[],[],[]];
		
		for(var ix=0; ix<seriesData.length; ix++) {
			_chart.series[ix].setData([]);
		}
		_chart.zoomOut();
		
		if(data) {
			var cnt = data.length;
			//for(var ix=0; ix<data.length; ix++) {
			for(var ix=data.length-1; ix>=0; ix--) {
				var dateStr = data[ix].measDtStr;
				const [year, month, day, hour, min, sec] = dateStr.split('-').map(Number);
				var reDate = Date.UTC(year, month - 1, day, hour, min, sec);
				//var reDate = data[ix].measDtStr;
				if(data[ix].pointSq) {
					seriesData[0].push([reDate, data[ix].termCv / data[ix].intavlH]);
					seriesData[1].push([reDate, data[ix].accuIv]);
					
					if(_amiType && _amiType == 'lora') {
						seriesData[2].push([reDate, data[ix].rssiV]);
						seriesData[3].push([reDate, data[ix].snrV]);
					} else {
						seriesData[2].push([reDate, data[ix].rsrpV]);
						seriesData[3].push([reDate, data[ix].rsrqV]);
					}
					
				}
				else {
					seriesData[0].push([reDate, null] );
					seriesData[1].push([reDate, null] );
					seriesData[2].push([reDate, null] );
					seriesData[3].push([reDate, null] );
					/*seriesData[4].push([data[ix].measDt, null] );
					seriesData[5].push([data[ix].measDt, null] );*/
				}
			}
		}
		for(var ix=0; ix<seriesData.length; ix++) {
			_chart.series[ix].setData(seriesData[ix]);
			//_chart.series[ix].isDirty = true;
		}
		_chart.zoomOut();
		
	
	}

	this.getChart = function() {
		return _chart;
	}
	
	this.getConfig = function() {
		return _config;
	}
	
	var clickDetected = false;
	
    var clr = [
    	Highcharts.getOptions().colors[0],
    	Highcharts.getOptions().colors[1],
    	Highcharts.getOptions().colors[2],
    	Highcharts.getOptions().colors[3]
    ]
    for(var ix=0; ix<clr.length; ix++)
		clr[ix] = (new Highcharts.Color(clr[ix])).setOpacity(1).get();	

	var _config = {
	    chart: {
	    	//renderTo: container, 
	        //zoomType: 'xy'
	    	zoomType: 'x',
	    	events: {
	    		click: function(event) {
	                if(clickDetected) {
	                    //alert ('x: '+ event.xAxis[0].value +', y: '+ event.yAxis[0].value);
	                    this.zoomOut();
	                    clickDetected = false;
	                } else {
	                    clickDetected = true;
	                    setTimeout(function() {
	                        clickDetected = false;
	                    }, 500); 
	                }
	            },
	            load: function(event) {
	            	/*var self = this;
	            	setTimeout(self.zoomOut(), 300);*/
	            	//this.zoomOut();
	            }
	    	}	    	
	    },
	    plotOptions: {
	    	/*series: {
	    		marker: {
	                fillColor: '#FFFFFF',
	                lineWidth: 1,
	                lineColor: null,
	                width: 5,
	                height: 5
	            }
	    	},*/
		    dataGrouping: {
		        enabled: false
		    }	    
	    },
	    scrollbar: {
            enabled: false
        },
	    tooltip: {
            split: false,
	        shared: true,
	        //xDateFormat: '<span style="font-size:12px;color:gray;">%Y.%b.%d %H:%M:%S</span>' // 원하는 형식으로 포맷
			formatter: function () {
				const kstValue = this.x - (9 * 60 * 60 * 1000);
				let date = Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', kstValue);
				let points = this.points; // 여러 시리즈의 포인트 정보
		
				let tooltipContent = `<span style="font-size:12px;color:gray;">${date}</span><br/>`;
		
				points.forEach(point => {
					tooltipContent += `<span style="color:${point.color};">${point.series.name}: <b>${point.y}</b></span><br/>`;
				});
		
				return tooltipContent;
			}
	        //xDateFormat: '<span style="font-size:12px;color:gray;">%Y.%b.%d %H:%M</span>'
	        //style: {fontSize: '12pt'} 
	    },
	    legend: {
	    	enabled: true,
	        floating: false,
	    	layout: 'horizontal',
	    	align: 'center',
	        verticalAlign: 'top'
	    },

	    title: {
	        text: null//'24h 저수현황'
	    },
	    /*subtitle: {
	        text: 'Source: WorldClimate.com'
	    },*/
	    
	    rangeSelector: {
	    	enabled: false,
	    },
		xAxis: {
			crosshair: true,
			type: 'datetime', // X축을 날짜 시간 타입으로 설정
			tickLength: 0,
			labels: {
				overflow: 'justify',
				formatter: function () {
					const kstValue = this.value - (9 * 60 * 60 * 1000);
					//return Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', kstValue); // 원하는 형식으로 포맷
					return Highcharts.dateFormat('%Y-%m-%d', kstValue); // 원하는 형식으로 포맷
				}
			}
		},
	    yAxis: [
	    	{
		        title: {
		            text: '단위사용량(㎥/H)',
		            //style: {color: Highcharts.getOptions().colors[1]}
		        },
		        labels: {
		        	align: 'left',
		        	x: 3,
		            format: '{value}㎥',
		            //style: {color: Highcharts.getOptions().colors[1]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },
		        opposite: false,
		        height: '70%',
	            lineWidth: 0
		    }, 
		    {
		        gridLineWidth: 0,
		        title: {
		            text: '검침값 (㎥)',
		            //style: {color: Highcharts.getOptions().colors[0]}
		        },
		        labels: {
		            format: '{value}㎥',
		            x: -3,
		            //style: {color: Highcharts.getOptions().colors[0]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },
		        opposite: true,
		        height: '70%',
	            lineWidth: 0
		    },
		    {
		        title: {
		            //text: _amiType == 'lora' ? 'RSSI' : 'RSRP',
		        	text: '-',
		            //style: {color: Highcharts.getOptions().colors[1]}
		        },
		        labels: {
		        	align: 'left',
		        	x: 3,
		            format: '{value}dB',
		            //style: {color: Highcharts.getOptions().colors[1]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },
		        opposite: false,
		        top: '75%',
	            height: '25%',
	            offset: 0,
	            lineWidth: 0
		    },
	    	{
		        title: {
		        	
		            //text: _amiType == 'lora' ? 'SNR' : 'RSRQ',
		        	text: '-',
		            //style: {color: Highcharts.getOptions().colors[1]}
		        },
		        labels: {
		            format: '{value}dB',
		            x: -3,
		            //style: {color: Highcharts.getOptions().colors[1]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },
		        opposite: true,
		        top: '75%',
	            height: '25%',
	            offset: 0,
	            lineWidth: 0
		    }
		],
	    series: [
		    {
		        name: '단위사용량',
		        type: 'column',
		        yAxis: 0,
		        data: [],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 3, valueSuffix: ' ㎥/H'}
		    }, 
		    {
		        name: '검침값',
		        type: 'line',
		        lineWidth: 1,
		        color: clr[3],
		        yAxis: 1,
		        data: [],
		    	dashStyle: 'Dash',
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 3, valueSuffix: ' ㎥'}
		    },
		    {
		        name: 'RSRP',
		        type: 'line',
		        lineWidth: 1,
		        color: Highcharts.getOptions().colors[9],
		        yAxis: 2,
		        data: [],
		        //color: Highcharts.getOptions().colors[1],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 0, valueSuffix: ' dB'}
		    }, 
		    {
		        name: 'RSRQ',
		        type: 'line',
		        lineWidth: 1,
		        color: Highcharts.getOptions().colors[8],
		        yAxis: 3,
		        data: [],
		        //color: Highcharts.getOptions().colors[1],
			    dataGrouping: {
			        enabled: false
			    },
			    tooltip: {valueDecimals: 1, valueSuffix: ' db'}
		    }
		    
	    ]
	};
	
	this.initChart = function(container, data) {
		var config = $.extend(true, {}, _config);
		_chart = Highcharts.stockChart(container, config);

		if(data)
			this.setDataSource(data);
	};
	
	return this;
}

/******************************************************************************/
/*
 * 
 */

function subStockchart(container, data, callback) 
{
	var _chart;
	
	/******************************************************/
	
	this.setDataSource = function(data, callback) {
		var seriesData = [];
		_chart.series[0].setData(seriesData);
		
		if(data && data.length) {			
			data = data[0];		
			if(!data) {
				if(callback)
					callback();
				return;
			}
			seriesData = [
				['당월', Math.round(data.accuCv0 / data.dayCnt0 * 1000)/1000 ],
		    	['직전1개월', Math.round(data.accuCv1 / data.dayCnt1 * 1000)/1000 ],
		    	['직전3개월', Math.round(data.accuCv3 / data.dayCnt3 * 1000)/1000 ]
			];
			_chart.series[0].setData(seriesData);
		}
		
		if(callback)
			callback();
	}

	this.getChart = function() {
		return _chart;
	}
	
	var clickDetected = false;
	
	_chart = Highcharts.chart(container, {
		chart: {
	        type: 'column',
	        marginBottom: 26,
	        marginTop: 26
	    },
	    title: {
	        text: '일평균 사용량 (㎥/일)',	//'24h 저수현황'
	        style: {'font-size': '12px', 'color': 'gray'},
	        align: 'center',
	        //x: 0,
	        y: 4
	    },
	    tooltip: {
	    	headerFormat: null,//'<span style="font-size:13px">{series.name}</span><br>',
	        //pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y:.0f}%</b> ㎥/월<br/>'	    	
	    	pointFormatter: function () {
	    		var str = '<span>'+ this.name +'</span>: <b>'+ Highcharts.numberFormat(this.y, 3) +'</b> ㎥/일<br/>'; 
	    		return str;
	        }
	    },
	    legend: {
	    	enabled: false
	    },
	    plotOptions: {
	        series: {
	            borderWidth: 0,
	            marker: {
	                fillColor: '#FFFFFF',
	                lineWidth: 1,
	                lineColor: null,
	                width: 5,
	                height: 5
	            }
	            //allowPointSelect: true
			    /*dataLabels: {
		            enabled: true,
		            //format: '{point.y:.0f}',
		            formatter: function () {return Highcharts.numberFormat(this.point.y, 0);},
		            rotation: -90,
		            //color: '#FFF',
		            //align: 'center',
		            //allowOverlap: true,
		            //y: 4,
		            //x: 0,
		            style: {
		                fontSize: '12px',
		                //fontFamily: 'Verdana, sans-serif'
		            }
		        }*/
	        }
	    },	    
	    xAxis: {
            type: 'category',
	    },
	    yAxis:{
	    	min: 0,
	        title: {
	            text: null
	        },
	        labels: {
	        	enabled: false
	        }
	    }, 

	    series: [{
	        name: '일평균사용량: ',
	        colorByPoint: true,
	        /*data: [
	        	['당월', 1375],
	        	['전월', 1244],
	        	['직전3월', 1528]
	        ],
	        tooltip: {
	        	//valueSuffix: ' ㎥/월'
	        	pointFormat: '{point.y:.0f} ㎥/월'
	        }*/
	    }]
	});
	
	if(data)
		this.setDataSource(data);
	
	return this;
}    
