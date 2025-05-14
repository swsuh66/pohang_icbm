<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %> <%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
	<head>
		<%@include file="/resources/inc/meta.inc" %>
		<title>스마트수도미터원격검침시스템</title>

		<%@include file="/resources/inc/base.inc" %> <%@include file="/resources/inc/jsgrid.inc"%> <%@include file="/resources/inc/ol.inc" %> <%@include
		file="/resources/inc/hichart.inc"%>

		<script type="text/javascript">
			        var statChart;
			        var tRatioChart;
			        var dRatioChart;
			        var mainGrid;

			        var dashSearchComponentes = {
			            //meterStat: 'statCdSumarySimple',
			            meterStat: 'statCdSumarySimple',
			            timeRatio: 1,
			            dayRatio: 1,
			            used: 1,
			            ratioGraph: 1
			        };

			        var currentSiteSq = ${user.getSiteSq()};

			        function getContextPath() {

			            return '${contextPath}';

			        };

			        function getAbsolutepath(path) {

			            return '${contextPath}/' + path;

			        };

			        var gis = {
			            mapLy: {},
			            mapDS: {}
			        };


			        var olMap;

			        $(function () {

			            initOlMap();

			            initChartes();

			            /* grid 초기화 */
			            //parent.mainGrid = parent.initGrid('mainGrid');
			            mainGrid = initGrid('mainGrid');
			            parent.errGrid = parent.initErrGrid('errGrid');

			            /* 수용가 조회 */
			            mainGrid.search();

			            /* 모든 차트 초기화*/
			            //parent.initChartes();
			            /* 모든 데이터 로드 */
			            parent.loadAll();

			            parent.getDbtableInfo();

			        });

			        function startStatLoading() {
			            /* 상태 카드 로딩 시작 */
			            $('.bcard.meter-stat').aceWidget('startLoading');
			            /* 상태 차트 로딩 시작 */
			            $('.bcard.meter-stat-chart').aceWidget('startLoading');
			            /* 세팅 로딩 시작 */
			            $('.dropdown-menu[id="settingForm"]').aceWidget('startLoading');
			        }

			        function stopStatLoading() {
			            /* 상태 카드 로딩 시작 */
			            $('.bcard.meter-stat').aceWidget('stopLoading');
			            /* 상태 차트 로딩 시작 */
			            $('.bcard.meter-stat-chart').aceWidget('stopLoading');
			            /* 세팅 로딩 시작 */
			            $('.dropdown-menu[id="settingForm"]').aceWidget('stopLoading');
			        }

			        function startTimeRatioLoading() {
			            $('.bcard.time-ratio-chart').aceWidget('startLoading');
			        }

			        function stopTimeRatioLoading() {
			            $('.bcard.time-ratio-chart').aceWidget('stopLoading');
			        }

			        function startDayRatioLoading() {
			            $('.bcard.day-ratio-chart').aceWidget('startLoading');
			        }

			        function stopDayRatioLoading() {
			            $('.bcard.day-ratio-chart').aceWidget('stopLoading');
			        }

			        function startGrid() {
			            $('.bcard.point-grid').aceWidget('startLoading');
			        }

			        function stopGrid() {
			            $('.bcard.point-grid').aceWidget('stopLoading');
			        }

			        /*
			        * 차트 초기화
			         */
			        function initChartes() {
			            statChart = new Chart(document.getElementById('statChart'), statChartOpt);
			            tRatioChart = new Chart(document.getElementById('tRatioChart'), tRatioChartOpt);
			            dRatioChart = new Chart(document.getElementById('dRatioChart'), dRatioChartOpt);
			            useGraph.make('useGraph_gis');
			            ratioGraph.make('ratioGraph_gis');
			        };


			        function getMapCfg() {
			            var _zoomResetControl = function (opt_options) {

			                var options = opt_options || {};

			                var button = document.createElement('button');
			                button.innerHTML = '<span style="font-size:12px;">□</span>';
			                button.addEventListener('click', function (e) {
			                    mapResetZoom();
			                }, false);
			                button.title = 'Reset zoom';

			                var element = document.createElement('div');
			                element.className = 'zoom-reset ol-unselectable ol-control';
			                element.appendChild(button);

			                ol.control.Control.call(this, {
			                    element: element,
			                    target: options.target
			                });

			            };
			            ol.inherits(_zoomResetControl, ol.control.Control);

			            var _expandControl = function (opt_options) {

			                var options = opt_options || {};
			                var _collapsed = false;

			                var button = document.createElement('button');
			                button.innerHTML = '<span style="font-size:10px;">&gt;</span>';
			                button.title = 'Collapse';
			                button.addEventListener(
			                    'click',
			                    function (e) {
			                        var wd = $('#mapContainer').width();
			                        if (_collapsed) {

			                            button.innerHTML = '<span style="font-size:10px;">&gt;</span>';
			                            button.title = 'Collapse';
			                            //$('#mapContainer').width(wd-320);
			                            document.getElementById('mapContainer').style.right = '480px';
			                            document.getElementById('listContainer').style.width = '480px';
			                        } else {
			                            button.innerHTML = '<span style="font-size:10px;">&lt;</span>';
			                            button.title = 'Expend';
			                            //var wd = parseFloat(document.getElementById('mapContainer').style.right);
			                            //$('#mapContainer').width(wd+320);
			                            document.getElementById('mapContainer').style.right = '0px';
			                            document.getElementById('listContainer').style.width = '0px';
			                        }
			                        _collapsed = !_collapsed;
			                        olMap.updateSize();
			                    },
			                    false
			                );

			                var element = document.createElement('div');
			                element.className = 'xctn-expand ol-unselectable ol-control';
			                element.appendChild(button);

			                ol.control.Control.call(this, {
			                    element: element,
			                    target: options.target
			                });

			            };
			            ol.inherits(_expandControl, ol.control.Control);

			            var olmapDefCfg = {
			                controls: ol.control.defaults({
			                    attributionOptions: /** @type {olx.control.AttributionOptions} */ ({
			                        collapsible: true
			                    })
			                }).extend([
			                    new _zoomResetControl(),
			                    new _expandControl()
			                ]),
			                //한국
			                defult_center: ol.proj.transform([127, 36], 'EPSG:4326', 'EPSG:3857'),
			                //베트남
			                //defult_center: ol.proj.transform([106.388, 21.032], 'EPSG:4326', 'EPSG:3857'),
			                //인도네시아
			                //defult_center: ol.proj.transform([114.368, -5.648], 'EPSG:4326', 'EPSG:3857'),
			                defult_zoom: 12,
			                projection: 'EPSG:3857'
			            };

			            return olmapDefCfg;
			        }

			        /**********************************************************************/
			        // Map Initialize


			        function initOlMap() {
			            olMap = new OLMap(document.getElementById('mapContainer'), getMapCfg());

			            var mousePositionControl = new ol.control.MousePosition({
			                //className: 'mouse-position1',
			                target: document.getElementById('mapinfo1'),
			                undefinedHTML: '',
			                projection: 'EPSG:4326',
			                coordinateFormat: function (coordinate) {
			                    return ol.coordinate.format(coordinate, '{x}, {y}', 7);
			                }
			            });
			            olMap.getMap().addControl(mousePositionControl);

			            //--------------------------------------

			            gis.mapLy['map_base'] = new OLlayerBase(olMap);
			            gis.mapLy['map_point'] = new OLlayerEquip(olMap);
			            gis.mapLy['map_point'].addDagController();

			            //--------------------------------------

			            loadBaseData();

			        }

			        function loadBaseData() {

			            var baseLoadEndhandler = function (id, data, isLast) {

			                if (data && data.features && data.features.length) {
			                    data = data.features;
			                } else
			                    data = null;

			                gis.mapLy['map_base'].setBoundaryData(data);

			            };

			            dLoader.multiLoad([
			                {
			                    id: 'base_boundary',
			                    //'http://localhost:8080/demo/geojson/base?code=46150',
			                    //url: 'http://localhost:8080/m1/geojson/boundary',
			                    url: getAbsolutepath('geojson/boundary'),
			                    success: baseLoadEndhandler,
			                }
			            ]);
			        };


			        function saveFeatureModify(data) {
			            var result = ajaxUpdate({
			                sql: 'mars.icbm.map1.updateLocation',
			                data: data
			            });

			            console.log('saveFeatureModify', JSON.stringify(result));

			            if (!result.success) {
			                jAlert.error('저장 오류', '위치정보 저장과정에 오류가 발생하였습니다.<br>정보 저장에 실패하였습니다.');
			                return false;
			            } else {
			                jAlert.success('저장 완료', '위치정보 저장이 완료되었습니다.');
			                return true;
			            }
			        };

			        function mapCenterToPoint(pointSq) {
			            if (pointSq)
			                gis.mapLy['map_point'].centerToPoint(pointSq, 18);

			        };

			        function mapResetZoom() {
			            olMap.resetCenter();
			        };

			        function mapMoveEndHandler(center, zoom, resolution, maxResolution) {
			            var cen = ol.proj.transform(center, 'EPSG:3857', 'EPSG:4326');
			            document.getElementById('mapinfo2').innerHTML =
			                'zoom: [' + zoom + '] center: [' + cen[0].toFixed(3) + ' ' + cen[1].toFixed(3) + ']' +
			                ' resolution: [' + resolution.toFixed(3) + '/' + maxResolution.toFixed(3) + ']';
			        };

			        function mapMoveHandlerForAddress(center,zoom){
			            if(center[0] && center[1]){
			                getAddressText(center, zoom, 0);
			            }
			        }

			        function getAddressText (center, zoom, cnt){
			            const address = document.getElementById("box-address");
			            $.ajax({url:'https://nominatim.openstreetmap.org/reverse?format=json&lat=' + center[1].toFixed(3) + '&lon=' + center[0].toFixed(3) + '&zoom='+ zoom.toFixed(0) + '&addressdetails=1'
			                , dataType: 'json'
			                , async: false
			                , success:function(data){
			                    console.log(data);
			                    var add = data.address;
			                    var cityName = add.city || add.town || add.village || add.county || add.state;

			                    address.innerText = add.country + '[' + cityName + ']';
			                }
			                , error:function(error){
			                    console.log(error);
			                }
			            })
			        }

			        /**************************
			         여기부터 신규로직 2023.11.30 김용희
			         **************************/
			        /*
			        * 계량기 상태 카드/차트 갱신
			         */
			        function refreshStat(result) {
			            refreshStatCard(result);
			            refreshStatChart(result);
			            /* 로딩 제거 */
			            $('.dropdown-menu[id="settingForm"]').aceWidget('stopLoading');
			        };

			        /*
			        * 미터기 상태 카드 갱신
			         */
			        function refreshStatCard(result) {
			            /* 모든 상태 0개로 세팅 */
			            $('.bcard.meter-stat span[name="text-value"]').text(0);
			            /* 각 상태에 숫자 세팅 */
			            result.forEach(function (item, idx) {
			                $('.bcard.meter-stat[name="' + item.statCd + '"] span[name="text-value"]').text(item.cnt.toLocaleString());
			            });
			            /* 로딩 제거 */
			            $('.bcard.meter-stat').aceWidget('stopLoading');
			        };

			        /*
			        * 미터기 상태 차트 갱신
			         */
			        function refreshStatChart(result) {
			            var dataOrder = new Object();
			            var chked = $('#showStatInput').is(':checked');
			            if (chked) {
			                dataOrder[-1] = {order: 0}; //정상
			                dataOrder[0] = {order: 1}; //통신 장애
			                dataOrder[1] = {order: 2}; //계량기 장애
			                dataOrder[2] = {order: 3}; //Q3초과
			                dataOrder[3] = {order: 4}; //역류
			                dataOrder[4] = {order: 5}; //누수
			                dataOrder[7] = {order: 6}; //베터리
			                tData = [0, 0, 0, 0, 0, 0, 0];
			                labels = ['정상', '통신장애', '계량기 장애', 'Q3 초과', '역류', '누수', '배터리 장애'];
			            } else {
			                dataOrder[-1] = {order: 0}; //정상
			                dataOrder[0] = {order: 1}; //통신 장애
			                dataOrder[1] = {order: 2}; //계량기 장애
			                tData = [0, 0, 0];
			                labels = ['정상', '통신장애', '계량기 장애'];
			            }
			            /* 각 상태에 세팅 */
			            var cnt = 0;

			            result.forEach(function (item, idx) {
			                /*
			                if (item.statCd == '109990090') {
			                    cnt -= item.cnt;
			                }
			                else if (item.statCd == '108880080') {
			                    cnt -= item.cnt;
			                }
			                else if (item.statCd == '200000000') {
			                    cnt += item.cnt;
			                }
			                else {
			                    var statAllIdx = item.statCd.indexOf('2');
			                    if(
			                       statAllIdx != 0 && 			//전체가 아니고
			                       dataOrder[item.statCd.indexOf('1')] //계량기 상태상에 있으면
			                    ) {
			                        var order = dataOrder[item.statCd.indexOf('1')].order;
			                        labels[order] = item.statCdStr;
			                        tData[order] = item.cnt;
			                    }
			                }
			                */
			                if (item.statCd == '100000000' || item.statCd == '010000000' || item.statCd == '000000000') {
			                    var statAllIdx = item.statCd.indexOf('2');
			                    if (
			                        statAllIdx != 0 && 			//전체가 아니고
			                        dataOrder[item.statCd.indexOf('1')] //계량기 상태상에 있으면
			                    ) {
			                        var order = dataOrder[item.statCd.indexOf('1')].order;
			                        labels[order] = item.statCdStr;
			                        tData[order] = item.cnt;
			                    }
			                } else if (item.statCd == '300000000') {
			                    cnt += item.cnt;
			                }
			            });
			            $('.bcard.meter-stat-chart div[name="text-value"]').text(cnt.toLocaleString());

			            /* 차트 갱신 */
			            statChartOpt.data.datasets[0].data = tData;
			            statChartOpt.data.labels = labels;
			            statChart.update();
			            /* 기존 라벨 삭제 */
			            $('.piechart-legends[id="statChart"]').remove();
			            /* label 출력 */
			            var sourceCanvas = document.getElementById('statChart');
			            $(sourceCanvas).parent().before("<div id='statChart' class='piechart-legends chart-legend'>"
			                + statChart.generateLegend() + "</div>")
			            $('.bcard.meter-stat-chart').aceWidget('stopLoading');
			        };

			        /*
			        * 일 검침률 차트 갱신
			         */
			        function refreshDayRatioChart(result) {
			            var labels = ['100%', '90%', '80%', '80% 미만'];
			            var data = setRatioData(result);
			            //$('.bcard.time-ratio-chart div[name="text-value"]').text(100 + '%');
			            /* 차트 갱신 */
			            dRatioChartOpt.data.datasets[0].data = data;
			            dRatioChartOpt.data.labels = labels;
			            dRatioChart.update();
			            /* 기존 라벨 삭제 */
			            $('.piechart-legends[id="dRatioChart"]').remove();
			            /* label 출력 */
			            var sourceCanvas = document.getElementById('dRatioChart');
			            $(sourceCanvas).parent().before("<div id='dRatioChart' class='piechart-legends chart-legend'>"
			                + dRatioChart.generateLegend() + "</div>")
			            $('.bcard.day-ratio-chart').aceWidget('stopLoading');
			            /* total 0 세팅 */
			            $('.bcard.day-ratio-chart div[name="text-value"]').text(0);
			            /* total 세팅 */
			            if (result && result.length > 0) {
			                result.forEach(function (item, idx) {
			                    if (item.type == '0') {
			                        //var cnt = item.cnt >= 10000 ? Math.floor(item.cnt/1000) + 'K' : item.cnt;
			                        var cnt = item.cnt;
			                        $('.bcard.day-ratio-chart div[name="text-value"]').text(cnt.toLocaleString());
			                    }
			                });
			            }
			        };

			        /*
			        * 검침률 요소 갱신
			         */
			        function setRatioData(result) {
			            var dataOrder = new Object();
			            dataOrder[100] = {order: 0}; //100%
			            dataOrder[90] = {order: 1}; //90%
			            dataOrder[80] = {order: 2}; //80%
			            dataOrder[0] = {order: 3}; //80%미만
			            var data = [0, 0, 0, 0];
			            if (result && result.length > 0) {
			                /* 각 상태에 세팅 */
			                result.forEach(function (item, idx) {
			                    if (dataOrder[item.ratio]) {
			                        var order = dataOrder[item.ratio].order;
			                        data[order] = item.cnt;
			                    }
			                });
			            }
			            return data;
			        };

			        /*
			        * 시간 검침률 차트 갱신
			         */
			        function refreshTimeRatioChart(result) {
			            var labels = ['100%', '90%', '80%', '80% 미만'];
			            var data = setRatioData(result);
			            //$('.bcard.time-ratio-chart div[name="text-value"]').text(100 + '%');
			            /* 차트 갱신 */
			            tRatioChartOpt.data.datasets[0].data = data;
			            tRatioChartOpt.data.labels = labels;
			            tRatioChart.update();
			            /* 기존 라벨 삭제 */
			            $('.piechart-legends[id="tRatioChart"]').remove();
			            /* label 출력 */
			            var sourceCanvas = document.getElementById('tRatioChart');
			            $(sourceCanvas).parent().before("<div id='tRatioChart' class='piechart-legends chart-legend'>"
			                + tRatioChart.generateLegend() + "</div>")
			            $('.bcard.time-ratio-chart').aceWidget('stopLoading');
			            /* total 0 세팅 */
			            $('.bcard.time-ratio-chart div[name="text-value"]').text(0);
			            /* total 세팅 */
			            if (result && result.length > 0) {
			                result.forEach(function (item, idx) {
			                    if (item.type == '0') {
			//						var cnt = item.cnt >= 10000 ? Math.floor(item.cnt/1000) + 'K' : item.cnt;
			                        var cnt = item.cnt;
			                        $('.bcard.time-ratio-chart div[name="text-value"]').text(cnt.toLocaleString());
			                    }
			                });
			            }
			        };


			        /*
			        * 드롭 다운 선택 셀렉트 박스 갱신 핸들러
			         */
			        function toolBarChangHandler(el) {
			            var nm = $(el).data('target-nm');
			            var txt = $(el).text();
			            /* 버튼 active */
			            $('div[name="' + nm + '"] .dropdown-item').removeClass('active btn-a-bold');
			            $(el).addClass('active btn-a-bold');
			            /* 표시 세팅 */
			            $('div[name="' + nm + '"] a.dropdown-toggle').text(txt);
			            /* 대쉬보드 컴포넌트 세팅 */
			            var component = $(el).data('component');
			            var val = $(el).data('component-value');
			            dashSearchComponentes[component] = val;
			        };

			        function makeParams() {
			            var params = {};
			            var val = $('#searchInputP').val();
			            params.searchParam = val;
			            return $.extend(params, parent.searchComponentes());
			        };

			        function openPop(val,filter){
			        	$('#cdParam').attr("value", val);
			        	$('#fliterType').attr("value", filter);
			    		var pop_title = "popupOpener" ;

			    		window.open("", pop_title , "width=1000,height=900,left=200,top=200,menubar=no,status=no") ;

			    		document.getElementById('popupForm').submit();
			    	}

			        /*
			         * 2024.06.18 그래프 추가.
			         */

			        function refreshUsed(result) {
			            useGraph.setDataSource(result, 0);
			        };

			        function refreshRaioGraph(result) {
			            ratioGraph.setDataSource(result, 0);
			        };


			        /*
			         * 그리드 추가.
			         */

			        /*
			        * 그리드 컬럼 요소 리빌딩
			        */
			        var colfnc = function(value, item, c, d, e) {
			            switch (this.name) {
			            case 'adminId':
			                value = '<span style="font-size:11px;" id="' + item.adminId + '">'+ item.adminId + '</span>'//'</span><br>' //+ (item.custNm?item.custNm:'&nbsp;');
			                return value;
			            case 'blkNm':
			                var ix = -1;
			                if(value) {
			                    ix = value.indexOf(':');
			                    if(ix >= 0){
			                        value = value.substr(ix+1);
			                    }
			                }
			                var useType = item.useType ? item.useType : '미지정';
			                var pipeDia = item.pipeDia ? item.pipeDia : '미지정';
			                value = (value ? value : '&nbsp;') +'<br>'+ useType +'&nbsp;'+ item.pipeDia +'<small>mm</small>';
			                return value;
			            case 'statCd':
			                if(!item.statCd) {
			                    return '-';
			                }
			                //return '<img style="width:30px;height:30px; "src="'+ meterStatCd.getImage(item.statCd) +'"/><br><small>' + meterStatCd.getStr(item.statCd) + '</small>';
			                return   '<span style="font-size:11px;">'+ meterStatCd.getStr(item.statCd) + '</span>';
			            case 'rawCnt_0d':
			                return kutil.v2n(item.rawCnt_0d, 1) +'<br>'+ kutil.v2n(item.rawCnt_30d, 1);
			            case 'measDt':
			                if(!item.measDt) {
			                    return '-';
			                }
			                var v1 = kutil.v2n(item.accuIv, 3) +'<span style="font-size:11px;"> ㎥</span>';
			                var v2 = '<span style="font-size:11px;">'+ kutil.dateFormat(new Date(item.measDt), 'yy.mm.dd HH:MM')
			                +'</span>'
			                return v2 +'<br>'+ v1;
			            }
			            return (value ? value : '-');
			        };

			        /*
			        * 그리드 초기화
			        */
			        function initGrid(container) {
			            var opt = {
			                height: "300px",
			                width: "100%",
			                sorting: true,
			                pageLoading: true,
			                paging: true,
			                pageSize: 50,
			                pageButtonCount: 3, 	// 페이지 버튼 개수
			                //pagerFormat: "{first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}",
			                pagerFormat: "{first} {prev} {pages} {next} {last}",
			                pagePrevText: "<",
			                pageNextText: ">",
			                pageFirstText: "<<",
			                pageLastText: ">>",
			                rnTop: 50,
			                rnBottom: 0,
			                searchContainer: '#searchInput',
			                fields:  [
			                    { name: "statCd", 	title: "상태", 					type: "text", 	align:"center", width: 60, 	itemTemplate:colfnc},
			                    //{ name: "adminId",	title: "수용가 번호<br>수용가명", 	type: "text", 	align:"left", 	width: 'auto', 	itemTemplate:colfnc},
			                    { name: "adminId",	title: "수용가 번호", 	type: "text", 	align:"left", 	width: 'auto', 	itemTemplate:colfnc},
			                    //{ name: "blkNm",	title: "블록<br>구분", 			type: "text", 	align:"left", 	width: 120, 	itemTemplate:colfnc},
			                    //{ name: "rawCnt_0d",title: "일간검침수<br>당일 | 30일", 	type: "text", 	align:"right", 	width: 100, 	itemTemplate:colfnc},
			                    //{ name: "measDt", 	title: "최종검침일시<br>최종검침값", 	type: "text", 	align:"right", 	width: 110, 	itemTemplate:colfnc}
			                    //{ name: "meas.obsDate", 	title: "검침일시", 	type: "text", 	align:"center", width: 70, itemTemplate:colfnc }
			                ],
			                loadStrategy: function() {
			                    return new CustomPageLoadingStrategy(this, parent.loadData);
			                },
			                rowClick: function(evt) {
			                    var pointSq = evt.item.pointSq;
			                    mapCenterToPoint(pointSq);
			                },
			                rowDoubleClick: function(evt) {
			                    parent.parent.loadModalData(false, evt.item);
								parent.parent.loadChartData(false, evt.item);
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

			        function refreshGrid(data) {
			            if(data) {
			                mainGrid.finishLoad(data||[]);
			            } else {
			                mainGrid.command('refresh');
			            }
			            refreshMap(data);
			        };

			        function refreshMap(result) {
			            if(result) {
			                gis.mapLy['map_point'].createFeatures(result);
			                gis.mapLy['map_point'].updateFeature(result, 'meas_meter');
			            }
			            stopGrid();
			            //gisFrame.mainGrid.finishLoad(result||[]);
			            //$('.bcard.point-grid').aceWidget('stopLoading');
			        };
		</script>

		<style type="text/css">
			.mapContainer {
				/* left: 0px; */
				width: 100%;
				/* right: 480px; */
				height: 100%;
				overflow: hidden;
				position: absolute;
			}

			.listContainer {
				right: 0px;
				width: 480px;
				height: 100%;
				position: absolute;
			}

			.leftContainer {
				position: absolute;
				background-color: #f8f7fe;
				z-index: 2;
				border-radius: 12px;
				padding: 10px 5px;
				top: 3%;
				left: 3%;
				box-shadow: 0 3px 6px #00000036;
			}

			.leftContainer2 {
				position: absolute;
				background-color: #f8f7fe;
				z-index: 2;
				border-radius: 12px;
				padding: 10px 5px;
				top: 35%;
				left: 3%;
				box-shadow: 0 3px 6px #00000036;
			}

			.leftContainer3 {
				position: absolute;
				background-color: #f8f7fe;
				z-index: 2;
				border-radius: 12px;
				padding: 10px 5px;
				top: 68%;
				left: 3%;
				box-shadow: 0 3px 6px #00000036;
			}

			.rightContainer {
				position: absolute;
				background-color: #f8f7fe;
				z-index: 2;
				border-radius: 12px;
				padding: 10px 5px;
				top: 15%;
				right: 3%;
				box-shadow: 0 3px 6px #00000036;
			}

			.rightSearchContainer {
				position: absolute;
				background-color: #f8f7fe;
				z-index: 2;
				border-radius: 12px;
				padding: 10px 5px;
				top: 3%;
				right: 3%;
				width: 320px;
				box-shadow: 0 3px 6px #00000036;
			}
		</style>
	</head>

	<body>
		<div id="mapContainer" class="map-container">
			<div class="box-list-wrap left">
				<!-- 상태 창 -->
				<div class="box-list" hidden>
					<ul>
						<li>
							<div class="bcard box-item meter-stat" name="200000000">
								<img class="box-icon" src="resources/img/ico/box-icon-01.png" alt="전체" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>전체</dt>
								</dl>
							</div>
						</li>
						<li>
							<div class="bcard box-item meter-stat" name="408880080" ondblclick="openPop('0100','1');">
								<img class="box-icon" src="resources/img/ico/box-icon-02.png" alt="상수도" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>상수도</dt>
								</dl>
							</div>
						</li>
						<li>
							<div class="bcard box-item meter-stat" name="308880080" ondblclick="openPop('0300','1');">
								<img class="box-icon" src="resources/img/ico/box-icon-03.png" alt="중수도" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>중수도</dt>
								</dl>
							</div>
						</li>
						<li>
							<div class="bcard box-item meter-stat" name="208880080" ondblclick="openPop('0200','1');">
								<img class="box-icon" src="resources/img/ico/box-icon-04.png" alt="지하수" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>지하수</dt>
								</dl>
							</div>
						</li>
					</ul>
				</div>

				<div class="box-list">
					<ul>
						<li>
							<div class="bcard box-item meter-stat" name="300000000">
								<img class="box-icon" src="resources/img/ico/box-icon-05.png" alt="전체" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>원격검침</dt>
								</dl>
							</div>
						</li>
						<li>
							<div class="bcard box-item meter-stat" name="000000000" ondblclick="openPop('0','2');">
								<img class="box-icon" src="resources/img/ico/box-icon-06.png" alt="정상" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>정상</dt>
								</dl>
							</div>
						</li>
						<li>
							<div class="bcard box-item meter-stat" name="100000000" ondblclick="openPop('1','2');">
								<img class="box-icon" src="resources/img/ico/box-icon-07.png" alt="통신 장애" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>통신 장애</dt>
								</dl>
							</div>
						</li>
						<li>
							<div class="bcard box-item meter-stat" name="010000000" ondblclick="openPop('2','2');">
								<img class="box-icon" src="resources/img/ico/box-icon-08.png" alt="계량기 장애" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>계량기 장애</dt>
								</dl>
							</div>
						</li>
						<!--
                 <li>
                    <div class="bcard box-item meter-stat" name="001000000"  ondblclick="openPop('3','2');">
                        <img class="box-icon" src="resources/img/ico/box-icon-11.png" alt="Q3 초과">
                        <dl>
                            <dd><span name="text-value">0</span></dd>
                            <dt>Q3 초과</dt>
                        </dl>
                    </div>
                </li>
                 <li>
                    <div class="bcard box-item meter-stat" name="000100000"  ondblclick="openPop('4','2');">
                        <img class="box-icon" src="resources/img/ico/box-icon-03.png" alt="역류">
                        <dl>
                            <dd><span name="text-value">0</span></dd>
                            <dt>역류</dt>
                        </dl>
                    </div>
                </li>
                 <li>
                    <div class="bcard box-item meter-stat" name="000010000"  ondblclick="openPop('5','2');">
                        <img class="box-icon" src="resources/img/ico/box-icon-12.png" alt="누수">
                        <dl>
                            <dd><span name="text-value">0</span></dd>
                            <dt>누수</dt>
                        </dl>
                    </div>
                </li>
                 <li>
                    <div class="bcard box-item meter-stat" name="000001000"  ondblclick="openPop('6','2');">
                        <img class="box-icon" src="resources/img/ico/box-icon-10.png" alt="배터리 장애">
                        <dl>
                            <dd><span name="text-value">0</span></dd>
                            <dt>배터리 장애</dt>
                        </dl>
                    </div>
                </li>
            -->
					</ul>
				</div>

				<div class="box-list" hidden>
					<ul>
						<li>
							<div class="bcard box-item meter-stat" name="400000000">
								<img class="box-icon" src="resources/img/ico/box-icon-09.png" alt="수검침" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>수검침</dt>
								</dl>
							</div>
						</li>
						<li>
							<div class="bcard box-item meter-stat" name="410000000">
								<img class="box-icon" src="resources/img/ico/box-icon-06.png" alt="정상" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>정상</dt>
								</dl>
							</div>
						</li>
						<li>
							<div class="bcard box-item meter-stat" name="420000000">
								<img class="box-icon" src="resources/img/ico/box-icon-08.png" alt="계량기 장애" />
								<dl>
									<dd><span name="text-value">0</span></dd>
									<dt>계량기 장애</dt>
								</dl>
							</div>
						</li>
					</ul>
				</div>
			</div>

			<div class="box-list-wrap center">
				<div style="position: absolute; width: 100%; text-align: center">
					<div class="box-address" style="display: inline-block; font-weight: bold" id="box-address"></div>
				</div>
			</div>

			<div class="box-list-wrap right">
				<div class="search-group">
					<input
						type="text"
						placeholder="특정 수용가 데이터 검색"
						id="searchInputP"
						onKeypress="javascript:if(event.keyCode == 13) { parent.loadPointSearch( makeParams() ); parent.loadData();}"
					/>
					<button type="button" onclick="parent.loadPointSearch( makeParams() ); parent.loadData();"><i class="ico i-primary-search"></i></button>
				</div>

				<div class="box-list chart-group">
					<div class="accordion-item">
						<h6 class="accordion-header">계량기 상태</h6>
						<div class="accordion-content">
							<div class="bcard meter-stat-chart chart-area">
								<dl>
									<dt>전체</dt>
									<dd><div name="text-value">0</div></dd>
								</dl>
								<canvas id="statChart" width="140" height="140"></canvas>
							</div>
						</div>
					</div>
					<div class="accordion-item">
						<h6 class="accordion-header">시간 검침률</h6>
						<div class="accordion-content">
							<div class="bcard time-ratio-chart chart-area">
								<dl>
									<dt>전체</dt>
									<dd><div name="text-value">0</div></dd>
								</dl>
								<!-- 해당 차트 데이터가 기존에도 나오지 않았는지, 확인부탁드립니다. -->
								<canvas id="tRatioChart" width="140" height="140"></canvas>
							</div>
						</div>
					</div>
					<div class="accordion-item">
						<h6 class="accordion-header">일 검침률</h6>
						<div class="accordion-content">
							<div class="bcard day-ratio-chart chart-area">
								<dl>
									<dt>전체</dt>
									<dd><div name="text-value">0</div></dd>
								</dl>
								<canvas id="dRatioChart" width="140" height="140"></canvas>
							</div>
						</div>
					</div>
					<div class="accordion-item">
						<h6 class="accordion-header">검침률 추이</h6>
						<div class="accordion-content">
							<div class="bcard meter-stat-chart chart-area">
								<div id="ratioGraph_gis" class="mt-lg-4 chartjs-render-monitor"></div>
							</div>
						</div>
					</div>
					<div class="accordion-item" hidden>
						<h6 class="accordion-header">사용량 추이</h6>
						<div class="accordion-content">
							<div class="bcard meter-stat-chart chart-area">
								<div id="useGraph_gis" class="mt-lg-4 chartjs-render-monitor"></div>
							</div>
						</div>
					</div>
				</div>

				<!-- 그래프 일단 지움-->
				<div class="box-list graph-group" hidden>
					<div class="accordion-item">
						<h6 class="accordion-header">검침률 추이</h6>
						<div class="accordion-content">
							<div class="bcard meter-stat-chart chart-area">
								<div id="ratioGraph_gis" class="mt-lg-4 chartjs-render-monitor"></div>
							</div>
						</div>
					</div>
					<div class="accordion-item">
						<h6 class="accordion-header">사용량 추이</h6>
						<div class="accordion-content">
							<div class="bcard meter-stat-chart chart-area">
								<div id="useGraph_gis" class="mt-lg-4 chartjs-render-monitor"></div>
							</div>
						</div>
					</div>
				</div>

				<div class="box-list chart-group" hidden>
					<div class="accordion-item">
						<h6 class="accordion-header">수용가</h6>
						<div class="accordion-content">
							<div class="bcard point-grid" id="gridContainer">
								<div id="mainGrid" class="data-list containerBorder"></div>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div id="mapinfo1" style="color: #242424; z-index: 2; position: absolute; bottom: 9px; height: 20px; width: 180px"></div>
			<div id="mapinfo2" style="color: #242424; z-index: 2; position: absolute; bottom: 2px; right: 40px"></div>
		</div>
		<!-- 팝업창 폼 -->
		<form action="popup/ISTC_POPUP" id="popupForm" method="post" target="popupOpener" hidden>
			<input type="text" hidden="hidden" id="cdParam" name="cdParam" value="" />
			<input type="text" hidden="hidden" id="fliterType" name="fliterType" value="" />
		</form>
		<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
		<script type="text/javascript" src="${contextPath}/resources/page/p/js/istc-f1.js?v=1.0"></script>
	</body>
</html>
