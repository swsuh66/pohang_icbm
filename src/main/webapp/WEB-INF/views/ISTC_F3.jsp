<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
         contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

    <%@include file="/resources/inc/meta.inc" %>
    <title>스마트수도미터원격검침시스템</title>

    <%@include file="/resources/inc/base.inc" %>
    <%@include file="/resources/inc/jsgrid.inc" %>
    <%@include file="/resources/inc/hichart.inc" %>

    <script type="text/javascript">

        var _animate = !AceApp.Util.isReducedMotion();

        var mainGrid;

        var useGraph;

        var dbParams;

        var dbParamsTb = 'f3-export';

        $(function () {

            /*
            * 페이지 리싸이징
            */
            $(window).resize(function () {
                layoutSize('gridContainer', 50);
                layoutSize('useGraph', 50);
            });
            layoutSize('gridContainer', 50);
            layoutSize('useGraph', 50);


            $('#toDate').val(kutil.dateFormat(new Date(), 'yyyy-mm-dd'));

            /* 엑셀다운도르를 위한 db 파람조회  */
            getDbtableInfo();

            /* grid 초기화  */
            mainGrid = initGrid('mainGrid');

            /* 차트 초기화 */
            dataChart.make('useGraph');

            /* 데이터 조회  */
            mainGrid.search();

        });

        function refreshAll(result) {

            refreshGrid(result);

            dataChart.setDataSource(result, 0);

        };


        function layoutSize(id, px) {

            var ht1 = $(window).innerHeight();
            var off = $("#" + id).offset();

            if (off) {

                var ht = ht1 - off.top - 60;
                $("#" + id).height(ht);

            }

            $("#" + id).width('100%');

        };


        /*
        * 리소스 path
         */
        function getContextPath() {

            return "${contextPath}";

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

        };

        /*
        * 그리드 갱신
         */
        function refreshGrid(data) {

            if (data)
                mainGrid.finishLoad(data || []);
            else
                mainGrid.command('refresh');

            $('.bcard.main-grid').aceWidget('stopLoading');
        };

        /*
        * 그리드 컬럼 요소 리빌딩
         */
        var colfnc = function (value, item, c, d, e) {

            switch (this.name) {
                case 'totUse':
                case 'avgUse':
                case 'maxUse':
                case 'minUse':
                    value = kutil.v2n(value, 3).split('.');
                    return (value && value.length > 1 ? value[0] : '-');
                case 'dayMeasRat':
                case 'measRat':
                    value = kutil.v2n(value, 1).split('.');
                    return (value && value.length > 1 ? value[0] : '-');
                case 'measDt':
                    var dt = new Date(value);
                    return kutil.dateFormat(dt, 'yyyy.mm.dd');
            }

            return (value ? value : '-');
        };


        var groups = [
            {title: '전별 사용량 ', columns: 3, align: "center"}
        ];

        /*
        * 그리드 초기화
         */
        function initGrid(container) {

            var opt = {

                height: "100%",
                width: "100%",
                sorting: false,

                pageLoading: true,
                paging: true,
                pageSize: 50,
                pageButtonCount: 5, 	// 페이지 버튼 개수
                pagerFormat: "{first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}",
                pagePrevText: "<i class='ico i-prev'></i>", // 이전
                pageNextText: "<i class='ico i-next'></i>", // 다음
                pageFirstText: "<i class='ico i-prev-double'></i>", // 처음
                pageLastText: "<i class='ico i-next-double'></i>", // 마지막

                rnTop: 50,
                rnBottom: 0,

                searchContainer: '#searchInput',

                fields: [
                    //{ name: "meas.rowSeq", 	title: "순번", 		type: "number", align:"right", width: 70, itemTemplate:colfnc },
                    {name: "measDt", title: "검침일", type: "text", align: "center", width: '100', itemTemplate: colfnc},

                    {name: "equipCnt", title: "수전수", type: "number", align: "right", width: 200, itemTemplate: colfnc},
                    {name: "measCnt", title: "검침건수", type: "number", align: "right", width: 200, itemTemplate: colfnc},
                    {
                        name: "measRat",
                        title: "시간 검침율(%)",
                        type: "number",
                        align: "right",
                        width: 110,
                        itemTemplate: colfnc
                    },
                    {
                        name: "dayMeasRat",
                        title: "일 검침율(%)",
                        type: "number",
                        align: "right",
                        width: 110,
                        itemTemplate: colfnc
                    },
                    {
                        name: "totUse",
                        title: "총사용량(㎥)",
                        type: "number",
                        align: "right",
                        width: 120,
                        itemTemplate: colfnc
                    },

                    {
                        name: "avgUse",
                        title: "평균(㎥/전)",
                        type: "number",
                        align: "right",
                        width: 120,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[0]
                    },
                    {
                        name: "maxUse",
                        title: "최고(㎥/전)",
                        type: "number",
                        align: "right",
                        width: 120,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "minUse",
                        title: "최저(㎥/전)",
                        type: "number",
                        align: "right",
                        width: 120,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                ],

                loadStrategy: function () {

                    return new CustomPageLoadingStrategy(this, loadData);

                },
                rowDoubleClick: function (evt) {

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

        function makeParams() {

            var params = new Object();

            var toDate = $('#toDate').val();
            params.toDate = toDate;


            var fromDate = kutil.dateFormat(kutil.addMonth(toDate, -1 * $('#daysSelect').val()), 'yyyy-mm-dd');
            params.fromDate = fromDate;

            $.extend(params, searchComponentes);

            return params;
        };

        function loadData() {

            var params = makeParams();

            if (!params.toDate || params.toDate.length == 0) {

                jAlert.error('오류', '날짜를 지정하세요');
                return;

            }


            /* 조회 */
            getAjax('selectAnalyResult', params, function () {

                /* 로딩 시작 */
                $('.bcard.main-grid').aceWidget('startLoading');


            }, refreshAll, null);
            
            loadStat();
        };

        function getAjax(qid, params, beforesend, callback, errCallback, async) {

            ajaxSelect({
                sql: qid,
                data: params,
                async: async ? async : true,
                beforeSend: function () {

                    if (beforesend)
                        beforesend();

                },
                success: function (result) {

                    if (callback)
                        callback(result);

                },
                error: function (error) {

                    if (errCallback)
                        errCallback(error);

                    refreshGrid([]);

                    var msg = '데이터를 읽을 수 없습니다.<br>';
                    msg += (error.responseText ? error.responseText.trim() : '서버에 오류가 있습니다.');

                    jAlert.error('오류', msg);

                }
            });


        };


        /**
         * 미터기 DB 테이블 기본 정보를 가져옵니다.
         */
        function getDbtableInfo() {

            var url = getContextPath() + '/file/dbParams/' + dbParamsTb;

            ajaxSelect({
                url: url,
                success: function (data) {

                    dbParams = data;

                },
                error: function (result) {

                    jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');

                }
            });

        };


        function dataDownload() {


            if (!dbParams) {

                jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
                return;

            }

            var params = new Object();

            params.qid = dbParams[dbParamsTb]['refer-sql'];
            params.colMapping = dbParams[dbParamsTb]['cols'];
            params.length = params.colMapping.length;


            params.downloadFileName = "Aggregation_" + kutil.dateFormat(new Date(), 'yymmddHHMMss');
            var tParams = makeParams();

            if (!tParams.toDate || tParams.toDate.length == 0) {
                /* 날짜 초기화 */
                $('#fromDate').val(kutil.dateFormat(new Date(), 'yyyy-mm-dd'));
                tParams.fromDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd');

            }

            $.extend(params, tParams);

            templetDownLoad(params, null, null, function () {

                jAlert.error('오류', '다운로드에 실패했습니다.');

            });

        };

        /*
        * 계량기 상태 조회
        */
        function loadStat() {
            var obj = {};
            $.extend(obj, makeParams());
            var qid = 'statCdSumarySimple'; 
            /* 계량기 상태이상 데이터 조회 */
            getAjax(qid, obj, startStatLoading, refreshStatCard, stopStatLoading);
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


    </script>

</head>

<body>


<!-- jsgrid-header-cell jsgrid-align-center jsgrid-header-group -->
<!-- jsgrid-header-cell jsgrid-header-sortable  -->


<!--

background-color: transparent;
border-color: #e3eff9 !important;


    padding: 0.75rem 1.25rem;
    margin-bottom: 0;
    background-color: rgba(0, 0, 0, 0.03);
    border-bottom: 1px solid rgba(0, 0, 0, 0.125);

  -->

<div role="main" class="sub-content">
	<%@ include file="ISTC_F3_CONTENT.jsp" %>
    <div class="sub-cont-header">
        <div class="sub-cont-header-area">
        </div>
    </div>
    <div class="dj-card ">
        <div class="bcard card">
            <div class="col-sm-12">
                <div class="row">
                    <div class="col-sm-3">
                        <div class="bcard box-item meter-stat" name="300000000" >
                            <img class="box-icon" src="resources/img/ico/box-icon-05.png" alt="전체">
                            <dl>
                                <dd><span name="text-value">0</span></dd>
                                <dt>원격검침</dt>
                            </dl>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="bcard box-item meter-stat" name="000000000" ondblclick="openPop('0','2');">
                            <img class="box-icon" src="resources/img/ico/box-icon-06.png" alt="정상">
                            <dl>
                                <dd><span name="text-value">0</span></dd>
                                <dt>정상</dt>
                            </dl>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="bcard box-item meter-stat" name="100000000"  ondblclick="openPop('1','2');">
                            <img class="box-icon" src="resources/img/ico/box-icon-07.png" alt="통신 장애">
                            <dl>
                                <dd><span name="text-value">0</span></dd>
                                <dt>통신 장애</dt>
                            </dl>
                        </div>
                    </div>
                    <div class="col-sm-3">
                        <div class="bcard box-item meter-stat" name="010000000"  ondblclick="openPop('2','2');">
                            <img class="box-icon" src="resources/img/ico/box-icon-08.png" alt="계량기 장애">
                            <dl>
                                <dd><span name="text-value">0</span></dd>
                                <dt>계량기 장애</dt>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="dj-card">
        <div class="bcard card">
                <ul class="nav nav-tabs custom-nav-tabs" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link active custom-nav-link" id="home16-tab-btn"
                           data-toggle="tab" href="#home16" role="tab" aria-controls="home16"
                           aria-selected="true">차트
                        </a>
                    </li>

                    <li class="nav-item">
                        <a class="nav-link custom-nav-link"
                           id="profile16-tab-btn" data-toggle="tab" href="#profile16" role="tab"
                           aria-controls="profile16" aria-selected="false">
                            테이블
                        </a>
                    </li>
                </ul>

                <div class="card-body px-0 py-2">
                    <div class="tab-content tab-sliding border-0 px-0">
                        <div class="tab-pane show active text-95 px-25" id="home16" role="tabpanel"
                             aria-labelledby="home16-tab-btn">
                            <div id="useGraph" class="containerBorder" style="width: 100%; height: 100%;"></div>
                        </div>
                        <div class="tab-pane text-95 px-25" id="profile16" role="tabpanel"
                             aria-labelledby="profile16-tab-btn">

                            <div class="" id="gridContainer">
                            <div id="mainGrid" class="data-list containerBorder"></div>
                        </div>
                    </div>
                </div>
            </div>

    </div>
</div>


<%-- <script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script> --%>
<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>
<script type="text/javascript" src="${contextPath}/resources/page/p/js/istc-f3.js"></script>

</body>


</html>
