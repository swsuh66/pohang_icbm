var dataChart = {
	dataType:null
};

dataChart.make = function(container, data) {
	if(!this.instance)
		this.instance = new BuildStockchart(container, data)
}
dataChart.setDataSource = function(data, dataType) {
	if(this.instance) {
		this.dataType = dataType;
		this.instance.getChart().hideLoading();
		this.instance.setDataSource(data);
	}
}
dataChart.showLoading = function(mesg) {
	if(this.instance) {
		//this.instance.setDataSource([]);
		this.instance.getChart().showLoading(mesg);
	}
}
dataChart.hideLoading = function() {
	if(this.instance)
		this.instance.getChart().hideLoading();
}

/******************************************************************************/
/*
 * 
 */

function BuildStockchart(container, data) 
{
	var _chart;
	var xAxisDate = [];
	var tickInterval;
	var xDateFormat = '%Y-%m-%d';
	var tooltip = {};
	var xAxisConfig = [{
	        crosshair: true,
	        type: 'datetime',
		    labels: {
		    	overflow: 'justify',
	            formatter: function () {
	            	return Highcharts.dateFormat('%y.%b.%d', this.value);
	            	//return Highcharts.dateFormat(xDateFormat, this.value);
	            },
	            dateTimeLabelFormats: {
	                minute: '%H:%M',
	                hour: '%H:%M',
	                //day: xDateFormat,
	                day: '%b.%d',
	                week: '%b.%d',
	                month: '%Y-%m',
	                year: '%Y'
	            },
	            labels: {
	                enabled: true,
	            },
	            minorTickLength: 0,
	            tickLength: 0
		    }
	    }];
	
	/******************************************************/
	
	this.setDataSource = function(data) {
		var seriesData = [[],[],[],[],[]];
		
		for(var ix=0; ix<seriesData.length; ix++)
			_chart.series[ix].setData([]);
		_chart.zoomOut();
		
		if(data) {
			var cnt = data.length;
			for(var ix=cnt-1; ix>=0; ix--) {
				var dateStr = data[ix].measDt;
				const [year, month, day] = dateStr.split('-').map(Number);
				var reDate = Date.UTC(year, month - 1, day);

				seriesData[0].push([reDate, data[ix].totUse]);
				seriesData[1].push([reDate, data[ix].avgUse]);
				/*if(data[ix].minUse != null && data[ix].maxUse != null)
					seriesData[2].push([data[ix].measDt, data[ix].minUse, data[ix].maxUse]);*/
				seriesData[2].push([reDate, data[ix].measCnt]);
				seriesData[3].push([reDate, data[ix].measRat]);
				seriesData[4].push([reDate, data[ix].dayMeasRat]);
				
				/*seriesData[1].push([data[ix].measDt, data[ix].avgUse]);
				seriesData[2].push([data[ix].measDt, data[ix].maxUse]);
				seriesData[3].push([data[ix].measDt, data[ix].minUse]);*/				
			}

			//-------------------------------------------------------
			// added by mona
			// change tick interval, dateformat, tooltip, and data itself for each daily and monthly chart
			/*if (dataChart.dataType === '1') {
				tickInterval = 24*3600*1000 * 30; // monthly
				xDateFormat = '%Y-%m'; 
				
				// for label of xAxis
				for(var ix=cnt-1; ix>=0; ix--) {
					xAxisDate[ix] = Date.parse(data[ix].measDt);
				}

		        xAxisConfig[0].tickPositions = xAxisDate;
		        xAxisConfig[0].tickInterval = tickInterval;
		        xAxisConfig[0].labels.formatter = function () {
	            	return Highcharts.dateFormat(xDateFormat, this.value);
	            }
		        tooltip = {
		                split: false,
		    	        shared: false,
		    	        xDateFormat: '<span style="font-size:12px;color:gray;">' + xDateFormat + '</span>'	
		        };
			} else {
				tickInterval = 24*3600*1000 * 1;  // daily
				xDateFormat = '%Y-%m-%d' 
				
		        xAxisConfig[0].tickInterval = tickInterval;
				xAxisConfig[0].labels.formatter = function () {
	            	return Highcharts.dateFormat(xDateFormat, this.value);
	            }
		        tooltip = {
		                split: false,
		    	        shared: false,
		    	        xDateFormat: '<span style="font-size:12px;color:gray;">' + xDateFormat + '</span>'	
		        };
			}*/
			//-------------------------------------------------------
		}
		for(var ix=0; ix<seriesData.length; ix++) {
			_chart.series[ix].setData(seriesData[ix]);

			//-------------------------------------------------------
			// added by mona
			// change tooltip date format for each daily and monthly chart
			_chart.series[ix].update({
	            tooltip: tooltip
	        });
			//-------------------------------------------------------
		}
		
		_chart.zoomOut();
		//setTimeout(_chart.zoomOut(), 1000);		
	}

	this.getChart = function() {
		return _chart;
	}
	
	var clickDetected = false;
	
	//_chart = Highcharts.stockChart(container, {
	_chart = Highcharts.chart(container, {
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
	    		//stickyTracking: false
	    		marker: {
	                fillColor: '#FFFFFF',
	                lineWidth: 1,
	                lineColor: null,
	                width: 5,
	                height: 5
	            }
	    	},
	    	dataGrouping: {
		        enabled: false
		    },
		    column: {
		        //groupPadding: 0.2,
		        //pointPadding: 0.37,
		        pointWidth: 5,
		    }
	    },
	    scrollbar: {
            enabled: false
        },
        navigator: {
        	enabled: true,
        	xAxis: {
                dateTimeLabelFormats: {
                    minute: '%H:%M',
                    hour: '%H:%M',
                    //day: xDateFormat,
                    day: '%b.%d',
                    week: '%b.%d',
                    month: '\'%y %b',
                    year: '%Y'
                }
            }
        },
	    //tooltip: tooltip,
        tooltip: {
            split: false,
	        shared: true,
	        xDateFormat: '<span style="font-size:12px;color:gray;">%Y.%b.%d</span>'
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
	        /*buttons: [{
	            count: 1,
	            type: 'minute',
	            text: '1M'
	        }, {
	            count: 5,
	            type: 'minute',
	            text: '5M'
	        }, {
	            type: 'all',
	            text: 'All'
	        }],
	        selected: 0,
	        inputEnabled: false*/
	    },
	    
	    //xAxis: xAxisConfig,
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
		            text: '총사용량 (㎥)'
		            //style: {color: Highcharts.getOptions().colors[1]}
					
		        },
		        labels: {
		        	align: 'left',
		        	x: 0,
		            format: '{value} ㎥',
		            //style: {color: Highcharts.getOptions().colors[1]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 2);}
		        },
		        min: 0,
		        opposite: false,
		        height: '60%',
	            lineWidth: 0
		    }, 
	    	{
		        title: {
		            text: '전별사용량 (㎥/전)',
		            //style: {color: Highcharts.getOptions().colors[1]}
		        },
		        labels: {
		        	align: 'right',
		        	x: 0,
		            format: '{value} ㎥/전',
		            //style: {color: Highcharts.getOptions().colors[1]},
		            formatter: function () {return Highcharts.numberFormat(this.value, 2);}
		        },
		        min: 0,
		        opposite: true,
	            height: '60%',
	            lineWidth: 0
		    },
	    	{
		        title: {
		            text: '검침수',
		            //style: {color: Highcharts.getOptions().colors[1]}
			
		        },
		        labels: {
		        	align: 'left',
		            format: '{value}',
		            x: 0,
		            formatter: function () {return Highcharts.numberFormat(this.value, 0);}
		        },
		        min: 0,
		        opposite: false,
		        top: '65%',
	            height: '35%',
	            offset: 0,
	            lineWidth: 0
		    },
	    	{
				
		        title: {
		            text: '시간 <br> 검침율',
				style : {						
						fontSize : '10px',						
					},
				x:-50,
				y:55							           
		        },
				
		        /*labels: {
		        	align: 'right',
		            format: '{value} %',
		            x: 0,
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },*/
		        labels: {
		        	align: 'right',
		            format: '검침율 %',
		            x: 0,				
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },
		        min: 0,
		        opposite: true,
		        top: '65%',
	            height: '35%',		
	            offset: 0,
	            lineWidth: 0
		    },
	    	{
		        title: {
		            text: '일<br>검침율',
						style : {						
						fontSize : '10px',						
						},
						x: -25,
						y:55
		            //style: {color: Highcharts.getOptions().colors[1]}
		        },
		        /*labels: {
		        	align: 'right',
		            format: '{value} %',
		            x: 0,
		            formatter: function () {return Highcharts.numberFormat(this.value, 1);}
		        },*/
		        min: 0,
		        opposite: true,
		        top: '65%',
	            height: '35%',
	            offset: 0,
	            lineWidth: 0
		    }
		],
	    series: [
		    {
		        name: '총 사용량',
		        type: 'area',
		        fillOpacity: 0.2,
		        //type: 'column',
		        //type: 'line',
		        lineWidth: 1,
		        yAxis: 0,
		        //zIndex: 2,
		        //lineWidth: 3,
		        //dashStyle: 'shortdot',
		        //color: Highcharts.getOptions().colors[0],
		        data: [],
		        tooltip: {valueDecimals: 3, valueSuffix: ' ㎥'}
		    },
		    {
		        name: '전별사용량',
		        ///*type: 'line',
		        lineWidth: 1,
		        type: 'area',
		        fillOpacity: 0.2,
		        yAxis: 1,
		        color: Highcharts.getOptions().colors[3],
		        //borderWidth: 2,
		        //borderColor: 'gray',
		        //color: 'orange',
		        data: [],
		        tooltip: {valueDecimals: 3, valueSuffix: ' ㎥/전'}
		    }, 
		    {
		        name: '검침수',
		        type: 'column',
		        //color: 'gray',
		        color: Highcharts.getOptions().colors[9],
		        yAxis: 2,
		        data: [],
		        tooltip: {valueDecimals: 0, valueSuffix: ' 건'}
		    }, 
		    {
		        name: '시간 검침율',
		        type: 'line',
		        color: Highcharts.getOptions().colors[8],
		        //fillOpacity: 0.2,
		        yAxis: 3,
		        //borderWidth: 2,
		        //borderColor: 'gray',
		        data: [],
		        tooltip: {valueDecimals: 1, valueSuffix: ' %'}
		    }, 
		    {
		        name: '일 검침율',
		        type: 'line',
		        color: Highcharts.getOptions().colors[1],
		        //fillOpacity: 0.2,
		        yAxis: 4,
		        //borderWidth: 2,
		        //borderColor: 'gray',
		        data: [],
		        tooltip: {valueDecimals: 1, valueSuffix: ' %'}
		    }
		    /*, 
		    {
		        name: '미터별최고',
		        type: 'line',
		        yAxis: 1,
		        data: [],
		        //color: Highcharts.getOptions().colors[1],
		        tooltip: {valueSuffix: ' ㎥/전'}
		    }, 
		    {
		        name: '미터별최저',
		        type: 'line',
		        yAxis: 1,
		        data: [],
		        //color: Highcharts.getOptions().colors[1],
		        tooltip: {valueSuffix: ' ㎥/전'}
		    }*/
	    ]
	});
	
	if(data) 
		this.setDataSource(data);
		
	return this;
};