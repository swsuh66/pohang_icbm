<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
         contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

    <%@include file="/resources/inc/meta.inc" %>
    <title>스마트수도미터원격검침시스템</title>
    <!-- 화면명 : ISTC_F5_SVC_LIST -->
    <!-- 화면명 : LG 서비스코드 관리 -->

    <%@include file="/resources/inc/base.inc" %>
    <%@include file="/resources/inc/jsgrid.inc" %>

    <script type="text/javascript">

        var _animate = !AceApp.Util.isReducedMotion();

        var mainGrid;

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

            /* grid 초기화 */
            mainGrid = initGrid('mainGrid');

            /* 수용가 조회 */
            mainGrid.search();

            blankbase();
            $('#excelbtn').hide();
            $('#clearbtn').hide();

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

        /*
        * 레이아웃 사이즈
        */
        function layoutSize() {

            var ht1 = $(window).innerHeight();
            var off = $('#gridContainer').offset();

            if (off) {
                var ht = ht1 - off.top - 36;
                // var ht = ht1 - off.top - 66;
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
                updateColPos(5, element);
            });


        };

        /*
        * 그리드 컬럼 요소 리빌딩
         */
        var colfnc = function (value, item, c, d, e) {

            switch (this.name) {

                case 'num':
                    return (item.pageNo - 1) * item.pageSize + (c + 1);
                default :
                    return (value == 0 || value) ? value : '-';

            }

            return (value == 0 || value) ? value : '-';


        };

        /*
        * 그리드 초기화
         */
        function initGrid(container) {

            var fields = [
                {
                    name: "rownum",
                    title: "순번",
                    type: "text",
                    align: "center",
                    width: 46,
                    itemTemplate: colfnc,
                    sortingDisabled: true
                },
                {
                    name: "svc_cd",
                    title: "서비스코드",
                    type: "text",
                    align: "center",
                    width: 50,
                    itemTemplate: colfnc,
                    hasGroup: false,
                },
                {
                    name: "entityid",
                    title: "entity id",
                    type: "text",
                    align: "center",
                    width: 140,
                    itemTemplate: colfnc,
                    hasGroup: false
                },
                {
                    name: "token_id",
                    title: "TOKEN",
                    type: "text",
                    align: "center",
                    width: 140,
                    itemTemplate: colfnc,
                    hasGroup: false
                },
                {
                    name: "eki",
                    title: "EKI",
                    type: "text",
                    align: "center",
                    width: 140,
                    itemTemplate: colfnc,
                    hasGroup: false
                },
                {
                    name: "response_binary_mode",
                    title: "바이너리모드\r\n (true, false)",
                    type: "text",
                    align: "center",
                    width: 140,
                    itemTemplate: colfnc,
                    hasGroup: false
                },
                {type: "control", editButton: false, modeSwitchButton: false}
            ];


            //fields = refactFields(fields);


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
                inserting : true,
                editing: true,

                rnTop: 50,
                rnBottom: 0,

                searchContainer: '#searchInput',

                fields: fields,

                loadStrategy: function () {

                    return new CustomPageLoadingStrategy(this, loadData);

                },
                rowDoubleClick: function (evt) {

                },
                insertItem: function(item) {
                    var insertingItem = item || this._getValidatedInsertItem();

                    if(!insertingItem) {
                        return alert('insert row 이상');
                    }

                    getAjax('mars.icbm.devSqlMapper.insertServiceCd', insertingItem, function () {
                    }, function() {alert('입력 성공'); mainGrid.search();}, function() {alert('입력 실패'); mainGrid.search();});
                },
                deleteItem: function(item) {
                    var delRow = this.rowByItem(item);
                    if(!delRow.length){
                        return;
                    }
                    var param = delRow.data('JSGridItem');

                    if (confirm("삭제하시겠습니까?") == false ) {
                        return;
                    }
                    
                    getAjax('mars.icbm.devSqlMapper.deleteServiceCd', param, function () {
                    }, function() {alert('삭제 성공'); mainGrid.search();}, function() {alert('삭제 실패'); mainGrid.search();});
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
            var params = {};

            $.extend(params, mainGrid.loadParams());

            return params;
        };

        /* 메인 gird 로드  */
        function loadData() {

            var params = makeParams();
            /* 수용가 조회 */
            getAjax('mars.icbm.devSqlMapper.selectServiceCdPage', params, function () {
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



    </script>




</head>


<body>


<div role="main" class="sub-content">
    <%@ include file="ISTC_F0_1_BASE.jsp" %>

    <div class="dj-card">
        <div class="bcard point-grid" id="gridContainer">
            <div id="mainGrid" class="data-list containerBorder"></div>
        </div>
    </div>
</div>


<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>


</body>


</html>

