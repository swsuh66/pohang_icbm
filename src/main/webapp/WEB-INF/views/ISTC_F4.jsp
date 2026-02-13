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

    <script type="text/javascript">

        var _animate = !AceApp.Util.isReducedMotion();

        var mainGrid;

        var dbParamsTb = 'f4-export';

        var dbParams;


        $(function () {

            /*
            * 페이지 리싸이징
            */
            $(window).resize(function () {

                /* main grid layout */
                layoutSize();

            });

            /* main grid layout */
            layoutSize();

            /* 엑셀다운도르를 위한 db 파람조회  */
            getDbtableInfo();


            $('#baseDate').val(kutil.dateFormat(new Date(Date.now()), 'yyyy-mm'));


            /* grid 초기화 */
            mainGrid = initGrid('mainGrid');

            /* 수용가 조회 */
            mainGrid.search();
            
        });


        function updateColPos(cols, parentElement) {
            var left =
                $(parentElement + " .jsgrid-grid-body").scrollLeft() <
                $(parentElement + " .jsgrid-grid-body .jsgrid-table").width() -
                $(parentElement + " .jsgrid-grid-body").width() +
                16
                    ? $(parentElement + " .jsgrid-grid-body").scrollLeft()
                    : $(parentElement + " .jsgrid-grid-body .jsgrid-table").width() -
                    $(parentElement + " .jsgrid-grid-body").width() +
                    16;
            $(
                parentElement +
                " .jsgrid-header-row th:nth-child(-n+" +
                cols +
                ")," +
                parentElement +
                " .jsgrid-filter-row td:nth-child(-n+" +
                cols +
                ")," +
                parentElement +
                " .jsgrid-insert-row td:nth-child(-n+" +
                cols +
                ")," +
                parentElement +
                " .jsgrid-grid-body tr td:nth-child(-n+" +
                (cols + 1) +
                ")"
            ).css({
                position: "relative",
                left: left,
            });
        }

        /*
        * 리소스 path
         */
        function getContextPath() {

            return "${contextPath}";

        };
        
        function getAbsolutepath(path) {
    		
    		return '${contextPath}/' + path;
    		
    	};	

        /*
        * 레이아웃 사이즈
        */
        function layoutSize() {

            var ht1 = $(window).innerHeight();
            var off = $('#gridContainer').offset();

            if (off) {

                var ht = ht1 - off.top - 36;
                $('#gridContainer').height(ht);

            }

        };


        /*
        * 그리드 갱신
         */
        function refreshGrid(data) {

            mainGrid = initGrid('mainGrid');

            if (data)
                mainGrid.finishLoad(data || []);
            else
                mainGrid.command('refresh');

            $('.bcard.point-grid').aceWidget('stopLoading');

            var jsGrid = document.querySelector("#mainGrid .jsgrid-grid-body");

            console.log(jsGrid);
            $(jsGrid).on("scroll", function (item) {
                //console.log("scroll");
                var element = "#" + $(item.target).parent().attr("id");
                console.log(element);
                updateColPos(3, element);
            });


        };

        /*
        * 그리드 컬럼 요소 리빌딩
         */
        var colfnc = function (value, item, c, d, e) {

            switch (this.name) {

                case 'num':
                    return (item.pageNo - 1) * item.pageSize + (c + 1);


            }

            return (value == 0 || value) ? value : '-';


        };

        /*
        * 그리드 초기화
         */
        function initGrid(container) {

            var fields = [
                {
                    name: "num",
                    title: "순번",
                    type: "text",
                    align: "center",
                    width: 70,
                    itemTemplate: colfnc,
                    sortingDisabled: true
                },
                {
                    name: "adminId",
                    title: "수용가 번호",
                    type: "text",
                    align: "center",
                    width: 100,
                    itemTemplate: colfnc,
                    hasGroup: true,
                    group: groups[0]
                },
                {
                    name: "custName",
                    title: "수용가 명",
                    type: "text",
                    align: "center",
                    width: 70,
                    itemTemplate: colfnc,
                    hasGroup: true
                },
                {
                    name: "addr",
                    title: "주소",
                    type: "text",
                    align: "center",
                    width: 150,
                    itemTemplate: colfnc,
                    hasGroup: true
                },
                {
                    name: "readOpr",
                    title: "검침원",
                    type: "text",
                    align: "center",
                    width: 70,
                    itemTemplate: colfnc,
                    hasGroup: true
                }

            ];


            fields = refactFields(fields);


            var opt = {
                height: "100%",
                width: "100%",
                sorting: true,

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

                fields: fields,

                loadStrategy: function () {

                    return new CustomPageLoadingStrategy(this, loadData);

                },
                rowDoubleClick: function (evt) {
                    parent.loadModalData(false, evt.item);
                    parent.loadChartData(false, evt.item);
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

        var groups = [
            {title: '수용가', columns: 4, align: "center"},
            {title: '일간 검침값 (㎥)', columns: 30, align: "center"}
        ];

        function refactFields(fields) {

            var baseDate = $('#baseDate').val();
            var lastDate = getLastDate(baseDate);

            groups[1].columns = lastDate;

            for (var i = 1; i <= lastDate; i++) {

                var obj = new Object();

                obj.name = 'D' + kutil.lpad('00', i);
                obj.title = i;
                obj.type = 'number';
                obj.align = 'center';
                obj.width = 80;
                if (i == 1)
                    obj.group = groups[1];

                obj.hasGroup = true;

                obj.itemTemplate = colfnc;

                fields.push(obj);

            }

            return fields;

        };

        function getLastDate(baseDate) {

            var dateList = baseDate.split('-');
            var lastDate = (new Date(dateList[0], dateList[1], 0)).getDate();

            return lastDate;
        };

        function makeParams() {
            var params = {};

            $.extend(params, searchComponentes);
            $.extend(params, mainGrid.loadParams());

            var baseDate = $('#baseDate').val();
    		params.baseDate = baseDate;

            params['cust_nm'] = $('#cust_nm').val();
            params['admin_no'] = $('#admin_no').val();
            params['addr'] = $('#addr').val();

            params.useCd = '1';
            return params;
        };

        /* 메인 gird 로드  */
        function loadData() {

            var params = makeParams();

            if (!params.baseDate || params.baseDate.length == 0) {

                jAlert.error('오류', '날짜를 지정하세요');
                return;

            }

            /* 수용가 조회 */
            getAjax('rawDayList_paging', params, function () {

                /* 로딩 시작 */
                $('.bcard.point-grid').aceWidget('startLoading');

            }, refreshGrid, null);

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

                    if (error.status == 401) {

                        parent.document.location.reload();
                        return;
                    }

                    if (errCallback)
                        errCallback(error);

                    refreshGrid([]);

                    var msg = '데이터를 읽을 수 없습니다.<br>';
                    msg += (error.responseText ? error.responseText.trim()
                        : '서버에 오류가 있습니다.');

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


            params.downloadFileName = "RawDayList" + kutil.dateFormat(new Date(), 'yymmddHHMMss');


            var tParams = makeParams();

            var fromDate = $('#fromDate').val();
            if (!fromDate || fromDate.length == 0) {

                /* 날짜 초기화 */
                $('#fromDate').val(kutil.dateFormat(new Date(Date.now()), 'yyyy-mm'));
                fromDate = kutil.dateFormat(new Date(Date.now()), 'yyyy-mm');
            }

            tParams.fromDate = fromDate + '-01';


            $.extend(params, tParams);

            templetDownLoadStream(params, null, null, function () {

                jAlert.error('오류', '다운로드에 실패했습니다.');

            });

        };

        /* 단말번호 검색을 위한 스크립트 */
        function selectChangHandler(el) {

            var searchOption = $(el).val();
            var target = $('#' + $(el).data('target'));
            var plh;

            plh = (searchOption == 0) ? '수용가 번호/이름/주소 ...' : '단말기 번호/미터기 번호 ...';

            target.attr('placeholder', plh);

        };


    </script>

    <style type="text/css">


    </style>


</head>


<body>


<div role="main" class="sub-content">
	<%@ include file="ISTC_F4_CONTENT.jsp" %>
    <div class="sub-cont-header">
       <%--
        <h1>검침내역</h1>
        --%>
        <div class="sub-cont-header-area">
        </div>
    </div>
    <div class="dj-card">
        <div class="bcard card h-100 point-grid">
            <div class="card-body p-0" id="gridContainer">
                <div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
            </div>
    </div>
</div>



<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>


</body>


</html>

