<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<script type="text/javascript">
	var _params;
	var _bfParams;
	var useGrid;
	var useGrid2;
	var useChart;

	var imgContextPath = 'resources/meter_img/';

	$(function () {
		 /* grid 초기화  */
	    useGrid = initGrid('useGrid', rawDefFields);
		 /* 메인 차트 초기화 */
	    useChart = new rawStockchart('useChart');
	    useChart.initChart('useChart');

	    useGrid2 = initGrid2('useGrid2', chAdminFields);

	    /* 날짜 초기화 */
	    var endDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd');
	     $('#toDate').val(endDate);
	    var begDate = kutil.addMonth(endDate, -1);
	    begDate = moment(Date.parse(begDate)).format('YYYY-MM-DD');
	    $('#fromDate').val(begDate);

	    /* 모달 오픈 핸들러 */
	    $("#infoModal").on('shown.bs.modal', function () {

	    });
	});

	/*
	 * 모달창에 정보 넣기
	 */
	function updateValueFields(data) {
	    var fields = $('div[name="pageContainer"]').find('input[type="text"]');

	    for (var ix = 0; ix < fields.length; ix++) {

	        var target = $(fields[ix]);

	        var fid = target.attr('id');
	        var val = data[0][fid];

	        if (fid == 'accuIv')
	            var a = 1;

	        var value = valueFieldFunction(fid, val, data[0]);

	        target.val(value);
	    }
	    document.getElementById('img_src_gum').src = imgContextPath + '' + data[0]['img_src_gum']; // 검침값
	    document.getElementById('img_src_bf').src =  imgContextPath + '' + data[0]['img_src_bf']; // 교체전
	    document.getElementById('img_src_af').src = imgContextPath + '' + data[0]['img_src_af']; // 교체후
	    document.getElementById('img_src_add').src = imgContextPath + '' +data[0]['img_src_add'];  //

	    document.getElementById('remark').value = data[0]['remark'];
		console.log ("remark", data[0]['remark']);
	    if(document.getElementById('remark').value == 'undefined') {
	        document.getElementById('remark').value = '';
	    }

	};

	function valueFieldFunction(id, value, data) {

	    var val = value;

	    switch (id) {

	        case 'useCd':
	            return val == '1' ? '검침중' : '<font style="color:red;font-weight:bold;">검침중지</font>';

	        case 'statCd':
	            val = meterStatCd.getStr(val);
	            if (val.indexOf('장애') > 0)
	                val = '<font style="color:red;font-weight:bold;">' + val + '</font>';

	            return val;

	        case 'accuIv':
	            return kutil.v2n(val, 3);

	        case 'measDt':
	            return (value ? kutil.dateFormat(val, 'yyyy-mm-dd HH:MM:ss') : '-');

	        case 'setDt':
	            return (value ? kutil.dateFormat(val, 'yyyy-mm-dd HH:MM:ss') : '-');

			case 'custPhone':
				return (value ? val : '-');
	    }

	    return (val ? val : '-');
	};

	/* 모달 요소 refresh */
	function refreshModalMain(result) {

		 var preLayoutSetting = function () {

	        /* modal usegrid layout */
	        layoutSize('infoModal', 'modalGridContainer', 100);

	        /* modal useChart layout */
	        layoutSize('infoModal', 'useChart', 100);

	    };


	    var preGridSetting = function (result) {

	        var type = $('#typeSelect').val();

	        if (type == '0') { //수집

	            if (result.length > 0) {

	                var amiType = result[0].amiType;

	                rawField =
	                    (amiType == 'lora') ? rawDefFields :
	                        $.merge($.merge([], rawDefFields), rawSubFields);

	                useGrid = initGrid('useGrid', rawField);

	            }

	        } else
	            //일간
	            useGrid = initGrid('useGrid', dayFields);

	    };

	    var preChartSetting = function (result) {
			// console.log("preChartSetting", result);
	        var type = $('#typeSelect').val();

	        if (type == '0') { //수집

	            useChart = new rawStockchart('useChart');
	            useChart.initChart('useChart');
	        } else {

	            useChart = new dayStockchart('useChart');
	            useChart.initChart('useChart');
	        }
	    };

	    preLayoutSetting();

	    preGridSetting(result);

	    // preChartSetting(result);

	    refreshGrid(result);

		// Brad : 2024.04.30 차트데이터 전체데이터 반영을 위해 주석처리
		//useChart.setDataSource(result);

	};

	//2023.10.25 김용희 : 주-부 수용가
	function refreshChildAdminId(result) {
	    // 2023.10.25 김용희 : 주-부 수용가
	    var preGridSetting2 = function (result) {
	        useGrid2 = initGrid2('useGrid2', chAdminFields);
	    };

	    var refreshGrid2 = function (data) {
	        if (data)
	            useGrid2.finishLoad(data || []);
	        else
	            useGrid2.command('refresh');
	    };
	    layoutSize('infoModal', 'modalGridContainer2', 100);

	    preGridSetting2(result);
	    refreshGrid2(result);
	};

	/*
	 * 그리드 갱신
	 */
	function refreshGrid(data) {

	    if (data)
	        useGrid.finishLoad(data || []);
	    else
	        useGrid.command('refresh');

	    $('#infoModal').aceWidget('stopLoading');
	};

	function dataDownload() {
	    var qType = $('#typeSelect').val(); //0(수집)/1(일간)/2(??)

	    var transforms;

	    if (qType == '0') {
	        transforms = {
	            "measDt": function (value) {
	                if (!value) return;
	                return kutil.dateFormat(value, 'yyyy-mm-dd HH:MM');
	            },
	            "statCd": function (value) {
	                return meterStatCd.getStr(value);
	            },
	            "accuIv": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "termCh": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "termCv": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "rssiV": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "snrV": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "temperature": function (value) {
	                   if (!value) return '';
	                   return value + '℃';
	               },
	            "rsrqV": function (value) {
	                   if (value != 0 && !value) return '-';
	                   return value * -1;
	            },
	            "rsrpV": function (value) {
	                   if (value != 0 && !value) return '-';
	                   return value * -1;
	            }
	        };

	    } else if (qType == '1' || qType == '2') {

	        transforms = {
	            "measDt": function (value) {
	                if (!value) return '-';
	                return kutil.dateFormat(value, 'yyyy-mm-dd');
	            },
	            "statCd": function (value) {
	                return meterStatCd.getStr(value);
	            },
	            "rawCnt": function (value) {
	                if (value != 0 && !value) return '';
	                   return value;
	            },
	            "lastDt": function (value) {
	                if (!value) return '-';
	                return kutil.dateFormat(value, 'yyyy-mm-dd HH:MM');
	            },
	            "accuIv": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "temperature": function (value) {
	                   if (!value) return '';
	                   return value + '℃';
	            },
	            "termCv": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "termCv_1d": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "termCv_7d": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	            },
	            "termCv_30d": function (value) {
	                if (value != 0 && !value) return '-';
	                   return value;
	               }
	        };

	    }

	       getAjax((qType == '0' ? 'pointHisdataRaw' : 'pointHisdata'), _params, function() {
	           $('#infoModal').aceWidget('startLoading');
	       }, function(result) {
	            jgexp.download2(useGrid, transforms, result);   //페이징 기준 없이 그리드 전체 내용 다운로드
	            $('#infoModal').aceWidget('stopLoading');
	       }, function() {
	           $('#infoModal').aceWidget('stopLoading');
	       });

	    //if (transforms)
	    //    jgexp.download(useGrid, transforms);    //페이징 기준으로 현 그리드 내용만 다운로드

	};

	<!-- 그리드 생성 필드 -->
			/*
	         * 그리드 컬럼 요소 리빌딩
	         */
	        var rawColfnc = function (value, item, c, d, e) {

	            switch (this.name) {
	                case 'measDt':
	                    return kutil.dateFormat(value, 'yy-mm-dd HH:MM:ss');
	                case 'statCd':
	                    return meterStatCd.getStr(value);
	                case 'accuIv':
	                    if (value != 0 && !value) return '-';
	                    value = kutil.v2n(value, 3);
	                    if (item.adjstV && Math.abs(item.adjstV) >= 1)
	                        value += '<br><small style="color:red;">'
	                            + kutil.v2n(item.adjstV, 3) + '</small>';
	                    return value;
	                case 'termCh':
	                    if (item.termCv != null && item.intavlH)
	                        return kutil.v2n(item.termCv / item.intavlH, 3);
	                    return '-';
	                case 'termCv':
	                    if (value != 0 && !value) return '-';
	                    return kutil.v2n(value, 3);
	                case 'rssiV':
	                case 'snrV':
	                    if (value != 0 && !value) return '-';
	                    return kutil.v2n(value, 1);
	                case 'rsrqV':
	                case 'rsrpV':
	                    if (value != 0 && !value) return '-';
	                    return kutil.v2n(value, 1) * -1
	                case 'temperature':		   ////////////// 2022-11-30
	                    if (item.temperature != undefined && item.temperature != null) {
	                        return item.temperature + '℃';
	                    }
	                    return '';
	            }
	            return (value == 0 || value) ? value : '-';
	        };

	        /*
	         * 그리드 컬럼 요소 리빌딩
	         */
	        var dayColfnc = function (value, item, c, d, e) {

	            switch (this.name) {
	                case 'measDt':
	                    return (value ? kutil.dateFormat(new Date(item.measDt), 'yy-mm-dd')
	                        : '-');

	                case 'statCd':
	                    return meterStatCd.getStr(value);

	                case 'rawCnt':
	                    return value;

	                case 'lastDt':
						if (!value) return '-';

						// measDt의 년월일 + lastDt의 시분초를 합치기
						//const measDate = kutil.dateFormat(new Date(item.measDt), 'yy-mm-dd');
						const measDate = kutil.dateFormat(new Date(item.measDt), 'yy-mm-dd');
						const lastTime = kutil.dateFormat(new Date(value), "HH:mm");
						return measDate + ' ' + lastTime;

	                case 'accuIv':
	                    value = kutil.v2n(value, 3);
	                    if (item.adjstV && Math.abs(item.adjstV) >= 1)
	                        value += '<br><small style="color:red;">'
	                            + kutil.v2n(item.adjstV, 3) + '</small>';
	                    return value;
	                case 'termCv':
	                case 'termCv_1d':
	                case 'termCv_7d':
	                case 'termCv_30d':
	                    return kutil.v2n(value, 3);
	                case 'temperature':		   ////////////// 2022-11-30
	                    if (item.temperature != undefined && item.temperature != null) {
	                        return item.temperature + '℃';
	                    }
	                    return '';
	            }
	            return (value == 0 || value) ? value : '-';
	        };

	        var groups = [{
	            title: '일간(이동평균) 사용량 (㎥/일)',
	            columns: 3,
	            align: "center"
	        }];

	        var rawField;

	        var rawDefFields = [
	            {name: "measDt", title: "검침일시", type: "text", align: "center", width: 130, itemTemplate: rawColfnc},
	            {name: "statCd", title: "수신상태", type: "text", align: "center", width: 80, itemTemplate: rawColfnc},
	            {name: "accuIv", title: "최종지침<br>(㎥)", type: "number", align: "right", width: 100, itemTemplate: rawColfnc},
	            {
	                name: "termCv",
	                title: "구간사용량<br>(㎥)",
	                type: "number",
	                align: "right",
	                width: 100,
	                itemTemplate: rawColfnc
	            },
	            {
	                name: "termCh",
	                title: "단위사용량<br>(㎥/H)",
	                type: "number",
	                align: "right",
	                width: 100,
	                itemTemplate: rawColfnc
	            },
	            {name: "rssiV", title: "RSSI<br>(dBm)", type: "number", align: "right", width: 60, itemTemplate: rawColfnc},
	            {name: "snrV", title: "SNR<br>(db)", type: "number", align: "right", width: 60, itemTemplate: rawColfnc},
	            {name: "temperature", title: "온도", type: "text", align: "right", width: 60, itemTemplate: rawColfnc},    ////////////// 2022-11-30
	        ];

	        var rawSubFields = [
	            {name: "rsrqV", title: "RSRQ", type: "number", align: "right", width: 60, itemTemplate: rawColfnc},
	            {name: "rsrpV", title: "RSRP", type: "number", align: "right", width: 60, itemTemplate: rawColfnc}
	        ];


	        var dayFields = [
	            {name: "measDt", title: "기준일자", type: "text", align: "center", width: 80, itemTemplate: dayColfnc},
	            {name: "statCd", title: "일간상태", type: "text", align: "center", width: 80, itemTemplate: dayColfnc},
	            {name: "rawCnt", title: "검침회수", type: "number", align: "right", width: 70, itemTemplate: dayColfnc},
	            {name: "lastDt", title: "최종검침일시", type: "text", align: "center", width: 120, itemTemplate: dayColfnc},
	            {name: "accuIv", title: "최종지침(㎥)", type: "number", align: "right", width: 100, itemTemplate: dayColfnc},
	            {name: "temperature", title: "온도", type: "text", align: "right", width: 60, itemTemplate: rawColfnc},     ////////////// 2022-11-30
	            {
	                name: "termCv",
	                title: "당일",
	                type: "number",
	                align: "right",
	                width: 90,
	                itemTemplate: dayColfnc,
	                hasGroup: true,
	                group: groups[0]
	            },
	            {
	                name: "termCv_7d",
	                title: "직전7일",
	                type: "number",
	                align: "right",
	                width: 90,
	                itemTemplate: dayColfnc,
	                hasGroup: true
	            },
	            {
	                name: "termCv_30d",
	                title: "직전30일",
	                type: "number",
	                align: "right",
	                width: 90,
	                itemTemplate: dayColfnc,
	                hasGroup: true
	            }
	        ];

	        var chAdminFields = [
	            {
	                name: "childAdminId",
	                title: "부 수용가",
	                type: "text",
	                align: "center",
	                width: 50,
	            },
	            {
	                name: "childAdminNm",
	                title: "부 수용가 명칭",
	                type: "text",
	                align: "center",
	                width: 50,
	            },
	            {
	                name: "termCh",
	                title: "단위 사용량",
	                type: "text",
	                align: "center",
	                width: 100,
	            },
	        ];

	        /*
	         * 그리드 초기화
	         */
	        function initGrid(container, fields, _extendOpt) {

	            var opt = {

	                height: "100%",
	                width: "100%",
	                //autowidth:true,
	                sorting: true,

	                pageLoading: true,
	                paging: true,
	                //pageIndex: 1,
	                pageSize: 50,
	                pageButtonCount: 5, 	// 페이지 버튼 개수
	                pagerFormat: "{first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}",
	                pagePrevText: "<i class='ico i-prev'></i>", // 이전
	                pageNextText: "<i class='ico i-next'></i>", // 다음
	                pageFirstText: "<i class='ico i-prev-double'></i>", // 처음
	                pageLastText: "<i class='ico i-next-double'></i>", // 마지막

	                fields: fields,
	                rnTop: 50,
	                rnBottom: 0,

	                loadStrategy: function () {

	                    return new CustomPageLoadingStrategy(this, null);

	                },
	                rowDoubleClick: function (evt) {

	                },
	                onPageChanged: function(args){
	                    console.log("onPageChanged:", args.pageIndex, _params);;
	                    args.pointSq = _params.pointSq;
	                    args.siteSq = _params.siteSq;

						loadModalData(false, args);
	                },
	                 onRefreshed: function (args) {
					$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
						$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
					});
					$("table").colResizable({
						onResize: function () {
							$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
								$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
							});
						}
					});
	   			 }

	            };

	            if(_extendOpt){
	                $.extend(opt, _extendOpt);
	            }

	            return new DataGrid(container, opt);
	        };

	        // 2023.10.25 김용희 : 주-부수용가 전용 그리드
	        function initGrid2(container, fields) {

	            var opt = {

	                height: "100%",
	                width: "100%",
	                sorting: false,

	                fields: fields,

	                loadStrategy: function () {
	                    return new CustomPageLoadingStrategy(this, null);
	                },
	                rowDoubleClick: function (evt) {
						_bfParams = _params; // 부 수용가 검색 전 수용가데이터
	                    loadModalData(false, evt.item);
	                },
	                onRefreshed: function (args) {
					$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
						$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
					});
					$("table").colResizable({
						onResize: function () {
							$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
								$(args.grid._bodyGrid[0].rows[0].cells[i]).css("width", $(obj).css("width"));
							});
						}
					});
	   			 }

	            };

	            return new DataGrid(container, opt);
	        };

			// 검색기간 제한한
			function validateDateRange() {
				var begDate = $('#fromDate').val();
				var endDate = $('#toDate').val();

				var today = moment().format('YYYY-MM-DD');
				if (endDate > today) {
					alert("조회 종료일은 오늘을 넘을 수 없습니다.");
					$('#toDate').val(today);
					return false;
				}

				var diff = moment(endDate).diff(moment(begDate), 'days');
				if (diff > 365) {
					alert("조회 기간은 최대 1년 이내여야 합니다.");
					return false;
				}

				return true;
			}

	        function searchModalData(){
				if (!validateDateRange()) {
					return;
				}
				useGrid = initGrid('useGrid', rawField, {pageIndex:1});
				loadModalData(false, _params);
				loadChartData(false, _params);
	        }

			var preChartSetting = function (result) {
				var type = $('#typeSelect').val();

				if (type == '0') { //수집

					useChart = new rawStockchart('useChart');
					useChart.initChart('useChart');

				} else {

					useChart = new dayStockchart('useChart');
					useChart.initChart('useChart');

				}

			};

			/* 수용가 정보, 검침 그래프와  */
	        function loadChartData(useGparams, item) {
				$('#infoModal').modal('show'); //infoModal

				var params = new Object();
	            var type = $('#typeSelect', window.parent.document).val();
				var begDate = $('#fromDate', window.parent.document).val();
	            var endDate = $('#toDate', window.parent.document).val();

				params.endDate = endDate;
	            params.begDate = begDate;

	            $.extend(params, useGrid.loadParams());
	            if (!endDate || endDate.length == 0) {
	                /* 날짜 초기화 */
	                //$('#fromDate', window.parent.document).val(kutil.dateFormat(new Date(), 'yyyy-mm-dd'));
	                //var endDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd');
	            }

	            if (useGparams)
	                params = _params;
	            else {
	                if (item) {
	                    params.pointSq = item.pointSq;
	                    params.siteSq = item.siteSq;
	                }
	            }

	            // 그래프 데이터 생성
				const query_id = type == '0' ? 'pointHisdataRaw' : 'pointHisdata';
				getAjax(query_id, params, function() {
					 $('#infoModal').aceWidget('startLoading');
				}, function(result) {
					layoutSize('infoModal', 'useChart', 100);
					preChartSetting(result);
					if (type == '0') {
						useChart.setDataSourceNew(result, begDate, endDate);
					} else {
						useChart.setDataSource(result);
					}

				}, function() {
					$('#infoModal').aceWidget('stopLoading');
				});
	            _params = params;
			}

	        /* 수용가 정보, 검침 그리드 데이터 로드 */
	        function loadModalData(useGparams, item) {
				console.log("loadModalData", useGparams, item);
	        	$('#infoModal').modal('show'); //infoModal

	            var params = new Object();
	            var type = $('#typeSelect', window.parent.document).val();
				var begDate = $('#fromDate', window.parent.document).val();
	            var endDate = $('#toDate', window.parent.document).val();

	            params.endDate = endDate;
	            params.begDate = begDate;

	            $.extend(params, useGrid.loadParams());
	            if (!endDate || endDate.length == 0) {
	                /* 날짜 초기화 */
	                //$('#fromDate', window.parent.document).val(kutil.dateFormat(new Date(), 'yyyy-mm-dd'));
	                //var endDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd');
	            }

	            if (useGparams)
	                params = _params;
	            else {
	                if (item) {
	                    params.pointSq = item.pointSq;
	                    params.siteSq = item.siteSq;
	                }
	            }

	            loadPointData(params);
	            loadModalChildAdminId(params);

	            type == '0' ? loadRawData('pointHisdataRaw_paging', params) : loadRawData('pointHisdata_paging', params);

	            _params = params;
	        };

	        /* 수용가 검침데이터 이력정보 */
	    	function loadRawData(qid,  params) {
	            /* 검침값 조회 */
	    		getAjax(qid, params, function() {
	    			$('#infoModal').aceWidget('startLoading');
	    		}, function(result) {
					refreshModalMain(result);
	    		}, function() {
	    			$('#infoModal').aceWidget('stopLoading');
	    		});
	       };

	    	/* 수용가 정보 */
	        function loadPointData(params) {
	            /* 수용가 조회 */
	            getAjax('mars.icbm.map1.pointList', params, null, function (result) {

	                parent.updateValueFields(result);

	            }, null);

	        };

	 		/* 부수용가정보 */
	        function loadModalChildAdminId(obj) {
	        	var params = obj;
	        	getAjax('mars.icbm.map1.selectChildAdminId', params, function() {

	        	}, function(result) {
	        			refreshChildAdminId(result);
	        	}, null);

	        };

	        /* 이전 수용가 불러오기 */
	        function beforeData() {
				loadModalData(false, _bfParams);
				loadChartData(false, _bfParams);
	        };

	        // 모달창에서
	        function bigoUpdate() {
	            param = {};
	            param.custSq = document.getElementById('custSq').value;
	            param.remark = document.getElementById('remark').value.trim();
				/*
				if (document.getElementById('remark').value.trim().length == 0)
	            {
	                jAlert.error('경고', '비고를 입력하세요');
	                return;
	            }
				*/
	            if (document.getElementById('remark').value.length > 100)
	            {
	                jAlert.error('경고', '비고는 100자를 넘을수 없습니다');
	                return;
	            }

	            getAjax('mars.icbm.map1.updateRemark', param, false, function (result) {
	                jAlert.info('정보', '저장 완료');    }, null);

	        };
</script>

<div class="modal fade modal-fs" id="infoModal" tabindex="-1" role="dialog">
	<div class="modal-dialog modal-dialog-scrollable" role="document">
		<div class="modal-content jMsgbox-wrap">
			<div class="modal-header">
				<h5 class="modal-title" id="exampleModalLabel2">수용가 종합정보</h5>

				<button type="button" class="close" data-dismiss="modal" aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>

			<div class="modal-body">
				<div class="row" id="infoContainer" name="pageContainer">
					<div class="col-md-6 col-md-no-padding filedBlock">
						<div class="row">
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="adminId">수용가 번호</label>
								<input type="text" class="form-control" id="adminId" disabled />
							</div>
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="custNm">수용가이름</label>
								<input type="text" class="form-control" id="custNm" disabled />
							</div>
							<div class="col-md-no-padding col-md-6" hidden>
								<input type="text" class="form-control" id="pointSq" hidden />
								<input type="text" class="form-control" id="custSq" hidden />
							</div>
						</div>
						<div class="row">
							<div class="col-md-no-padding col-md-3">
								<!--
                                        <label class="labelItem" for="custNm">수용가이름</label>
                                        <input type="text" class="form-control" id="custNm" disabled>
                                        -->
								<label class="labelItem" for="siteNm">소속명</label>
								<input type="text" class="form-control" id="siteNm" disabled />
							</div>
							<div class="col-md-no-padding col-md-3">
								<label class="labelItem" for="useCdStr">운용상태</label>
								<input type="text" class="form-control" id="useCdStr" disabled />
							</div>
							<div class="col-md-no-padding col-md-3">
								<label class="labelItem" for="useType">업종</label>
								<input type="text" class="form-control" id="useType" disabled />
							</div>
							<div class="col-md-no-padding col-md-3">
								<label class="labelItem" for="pipeDia">관경(mm)</label>
								<input type="text" class="form-control" id="pipeDia" disabled />
							</div>
						</div>
						<div class="row">
							<div class="col-md-no-padding col-md-12">
								<label class="labelItem" for="addrNew">주소</label>
								<input type="text" class="form-control" id="addrNew" disabled />
							</div>
						</div>
						<div class="row">
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="setDt">최초설치일</label>
								<input type="text" class="form-control" id="setDt" disabled />
							</div>
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="accuIv">최종검침값(㎥)</label>
								<input type="text" class="form-control" id="accuIv" disabled />
							</div>
						</div>
						<div class="row">
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="statCdStr">최종검침상태</label>
								<input type="text" class="form-control" id="statCdStr" disabled />
							</div>
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="modemId">지시부번호</label>
								<input type="text" class="form-control" id="modemId" disabled />
							</div>
						</div>
					</div>
					<div class="col-md-no-padding col-md-6 filedBlock">
						<div class="row">
							<div class="col-md-no-padding col-md-4">
								<!--
                                        <label class="labelItem" for="siteNm1">사업소</label>
                                        <input type="text" class="form-control" id="siteNm1" disabled>
                                        -->
								<label class="labelItem" for="custPhone">전화번호</label>
								<input type="text" class="form-control" id="custPhone" disabled />
							</div>
							<div class="col-md-no-padding col-md-4">
								<!--
                                        <label class="labelItem" for="siteNm2">구</label>
                                        <input type="text" class="form-control" id="siteNm2" disabled>
                                        -->
								<label class="labelItem" for="blkNm">블럭</label>
								<input type="text" class="form-control" id="blkNm" disabled />
							</div>
							<div class="col-md-no-padding col-md-4">
								<!--
                                        <label class="labelItem" for="siteNm">소속명</label>
                                        <input type="text" class="form-control" id="siteNm" disabled>
                                        -->
							</div>
						</div>
						<div class="row">
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="amiType">통신망</label>
								<input type="text" class="form-control" id="amiType" disabled />
							</div>
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="meterId">미터기번호</label>
								<input type="text" class="form-control" id="meterNo" disabled />
							</div>
						</div>
						<div class="row">
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="devNo">단말기번호</label>
								<input type="text" class="form-control" id="devNo" disabled />
							</div>
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="compNm">단말기업체</label>
								<input type="text" class="form-control" id="comNm" disabled />
							</div>
						</div>
						<div class="row">
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="measDt">최종검침일시</label>
								<input type="text" class="form-control" id="measDt" disabled />
							</div>
							<div class="col-md-no-padding col-md-6">
								<label class="labelItem" for="readOpr">담당검침원</label>
								<input type="text" class="form-control" id="readOpr" disabled />
							</div>
						</div>
					</div>
				</div>

				<div class="row filedBlock" name="pageContainer">
					<div class="col-md-no-padding col-md-12" style="padding: 0 5px 0 5px">
						<div class="card ccard no-border">
							<ul class="nav nav-tabs nav-tabs-simple nav-tabs-scroll border-b-1 brc-dark-l3 mx-0 mx-md-0 px-3 px-md-1 pt-2px" role="tablist">
								<li class="nav-item mr-1">
									<a
										class="nav-link active p-3 bgc-h-primary-l4 radius-0"
										id="home16-tab-btn"
										data-toggle="tab"
										href="#home16"
										role="tab"
										aria-controls="home16"
										aria-selected="true"
									>
										<i class="fa fa-table text-success mr-3px"></i>
										데이터
									</a>
								</li>
								<!--
                                    
                                    <li class="nav-item mr-1">
                                        <a class="nav-link brc-purple-m1 d-style p-3 bgc-h-purple-l4 radius-0"
                                           id="profile16-tab-btn" data-toggle="tab" href="#profile16"
                                           role="tab" aria-controls="profile16" aria-selected="false">
                                            <i class="fa fa-chart-bar text-purple mr-3px"></i>

                                            <span class="d-n-active">
                                                            챠트
                                                        </span>
                                            <span class="d-active text-purple-d1">
                                                            챠트
                                                        </span>
                                        </a>
                                    </li>
                                    -->
								<li class="nav-item mr-1">
									<a
										class="nav-link brc-purple-m1 d-style p-3 bgc-h-purple-l4 radius-0"
										id="profile18-tab-btn"
										data-toggle="tab"
										href="#profile18"
										role="tab"
										aria-controls="profile18"
										aria-selected="false"
									>
										<i class="fa text-purple mr-3px"></i>
										현장 사진
									</a>
								</li>
								<li class="nav-item mr-1">
									<a
										class="nav-link brc-purple-m1 d-style p-3 bgc-h-purple-l4 radius-0"
										id="profile17-tab-btn"
										data-toggle="tab"
										href="#profile17"
										role="tab"
										aria-controls="profile17"
										aria-selected="false"
									>
										<i class="fa text-purple mr-3px"></i>
										부수용가
									</a>
								</li>
								<li class="nav-item mr-1">
									<a
										class="nav-link brc-purple-m1 d-style p-3 bgc-h-purple-l4 radius-0"
										id="profile19-tab-btn"
										data-toggle="tab"
										href="#profile19"
										role="tab"
										aria-controls="profile19"
										aria-selected="false"
									>
										<i class="fa text-purple mr-3px"></i>
										비고
									</a>
								</li>

								<li class="full-width item-vertical-center">
									<div class="dj-btn-group">
										<div class="d-flex align-items-center px-lg-0">
											<a href="#none" title="이전 수용가" class="btn dj-btn-outline-gray btn-sm" onclick="beforeData();">이전 수용가</a>
										</div>
										<div class="d-flex align-items-center px-lg-0">
											<div class="card-toolbar align-self-center no-border">
												<div class="dropdown dd-backdrop dd-backdrop-none-md">
													<a
														class="btn btn-light-green text-600 btn-xs mr-1"
														href="#"
														role="button"
														data-toggle="dropdown"
														data-display="static"
														aria-haspopup="true"
														aria-expanded="false"
														onclick="dataDownload();"
													>
														Export
														<i class="fa fa-download ml-1 text-90"></i>
													</a>
												</div>
											</div>
										</div>
									</div>
								</li>
							</ul>

							<div class="card-body px-0 py-2">
								<div class="tab-content border-0 px-0 no-border" style="min-height: 160px; max-height: 700px">
									<div class="tab-pane show active text-95 px-25" id="home16" role="tabpanel" aria-labelledby="home16-tab-btn">
										<div class="dj-card" id="filter">
											<div class="row">
												<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
													<div class="dj-input-group">
														<span class="info componentsFont">구분</span>
														<select data-placeholder="선택" id="typeSelect" class="form-control border-1p" style="width: 200px">
															<option value="0">수집</option>
															<option value="1">일간</option>
														</select>
													</div>
												</div>
												<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
													<div class="dj-input-group">
														<span class="info componentsFont">시작일</span>
														<input type="date" class="form-control border-1p" id="fromDate" />
													</div>
												</div>
												<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
													<div class="dj-input-group">
														<span class="info componentsFont">종료일</span>
														<input type="date" class="form-control border-1p" id="toDate" />
													</div>
												</div>
												<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
													<div style="display: flex; gap: 8px">
														<a href="#none" title="검색" class="btn dj-btn-primary btn-sm" onclick="searchModalData();">검색</a>
													</div>
												</div>
											</div>
										</div>
										<div class="bcard card point-grid" style="">
											<ul class="nav nav-tabs custom-nav-tabs" role="tablist">
												<li class="nav-item">
													<a
														class="nav-link active custom-nav-link"
														id="datatable-tab-btn"
														data-toggle="tab"
														href="#datatable"
														role="tab"
														aria-controls="datatable"
														aria-selected="true"
														>테이블
													</a>
												</li>
												<li class="nav-item">
													<a
														class="nav-link custom-nav-link"
														id="datachart-tab-btn"
														data-toggle="tab"
														href="#datachart"
														role="tab"
														aria-controls="datachart"
														aria-selected="true"
														>차트
													</a>
												</li>
											</ul>
											<div class="tab-content tab-sliding border-0 px-0">
												<div class="tab-pane show active text-95 px-25" id="datatable" role="tabpanel" aria-labelledby="datatable-tab-btn">
													<div class="" id="modalGridContainer">
														<div id="useGrid" class="data-list containerBorder" style="min-height: 160px; max-height: 650px"></div>
													</div>
												</div>
												<div class="tab-pane show active text-95 px-25" id="datachart" role="tabpanel" aria-labelledby="datachart-tab-btn">
													<div id="useChart" class="containerBorder" style="min-height: 160px; max-height: 650px"></div>
												</div>
											</div>
										</div>
									</div>

									<div class="tab-pane text-95 px-25" id="profile17" role="tabpanel" aria-labelledby="profile17-tab-btn">
										<div class="" id="modalGridContainer2">
											<div id="useGrid2" class="data-list containerBorder" style="width: 100%; height: 100%"></div>
										</div>
									</div>
									<div class="tab-pane text-95 px-25" id="profile19" role="tabpanel" aria-labelledby="profile19-tab-btn">
										<div class="">
											<div class="data-list containerBorder" style="width: 100%; height: 100%">
												<textarea id="remark" style="width: 100%; height: 100%"></textarea>
											</div>
											<div class="dj-btn-group">
												<a class="btn dj-btn-primary btn-sm" onclick="bigoUpdate();"> 저장 </a>
											</div>
										</div>
									</div>

									<!-- 2023.11.13 김용희 : 증빙자료 추가 -->
									<div class="tab-pane text-95 px-25" id="profile18" role="tabpanel" aria-labelledby="profile18-tab-btn" style="overflow: scroll">
										<table class="table table-bordered table-hover table-sm" align="center">
											<tbody>
												<tr>
													<th>전경</th>
													<th>단말기 사진</th>
												</tr>
												<tr>
													<td>
														<img id="img_src_gum" alt="" src="" style="width: 100%; height: 100%; object-fit: contain" />
													</td>

													<td>
														<img id="img_src_af" alt="" src="" style="width: 100%; height: 100%; object-fit: contain" />
													</td>
												</tr>
												<tr>
													<th>계량기 사진</th>
													<th>설치후 사진</th>
												</tr>
												<tr>
													<td>
														<img id="img_src_bf" alt="" src="" style="width: 100%; height: 100%; object-fit: contain" />
													</td>

													<td>
														<img id="img_src_add" alt="" src="" style="width: 100%; height: 100%; object-fit: contain" />
													</td>
												</tr>
											</tbody>
										</table>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
