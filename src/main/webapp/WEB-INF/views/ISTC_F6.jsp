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

        var dbParams;

        var dbParamsTb = 'f6-export';

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

            /* grid 초기화 */
            mainGrid = initGrid('mainGrid');

            /* 수용가 조회 */
            mainGrid.search();

        });


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

            if (data)
                mainGrid.finishLoad(data || []);
            else
                mainGrid.command('refresh');

            $('.bcard.point-grid').aceWidget('stopLoading');

        };

        /*
        * 그리드 컬럼 요소 리빌딩
         */
        var colfnc = function (value, item, c, d, e) {

            switch (this.name) {
                case 'num':
                    return (item.pageNo - 1) * item.pageSize + (c + 1);
                case 'insDt':
                case 'updDt':
                    if (value == null) return '-';
                    return kutil.dateFormat(new Date(value), 'yyyy-mm-dd');


            }

            return value ? value : '-';
        };

        /*
        * 그리드 초기화
         */
        function initGrid(container) {

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

                fields: [
                    {
                        name: "num",
                        title: "순번",
                        type: "text",
                        align: "center",
                        width: 60,
                        itemTemplate: colfnc,
                        sortingDisabled: true
                    },
                    {
                        name: "siteNm0",
                        title: "지자체",
                        type: "text",
                        width: 100,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[1]
                    },
                    {name: "adminNo", title: "고객 번호", type: "text", width: 160, itemTemplate: colfnc, hasGroup: true},
                    {name: "custNm", title: "이름", type: "text", width: 200, itemTemplate: colfnc, hasGroup: true},
                    {
                        name: "meterNo",
                        title: "계량기 번호",
                        type: "text",
                        width: 140,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[2]
                    },
                    {name: "pipeDia", title: "구경(mm)", type: "text", width: 60, itemTemplate: colfnc, hasGroup: true},
                    {
                        name: "subDevNo",
                        title: "단말 부번호",
                        type: "text",
                        width: 250,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[3]
                    },
                    {name: "devNo", title: "단말 주번호", type: "text", width: 120, itemTemplate: colfnc, hasGroup: true},
                    {
                        name: "insDt",
                        title: "생성일",
                        type: "text",
                        width: 100,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[4]
                    }

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

        var groups = [

            {title: '구분', columns: 1, align: "center"},
            {title: '수용가', columns: 3, align: "center"},
            {title: '계량기', columns: 2, align: "center"},
            {title: '단말기', columns: 2, align: "center"},
            {title: '일시', columns: 1, align: "center"}
        ];


        function selectChangHandler(el) {

            var searchOption = $(el).val();
            var target = $('#' + $(el).data('target'));
            var plh;

            plh = (searchOption == 0) ? '수용가 번호/이름/주소 ...' : '단말기 번호/미터기 번호 ...';

            target.attr('placeholder', plh);

        };

        function makeParams() {

            var params = {};

            $.extend(params, searchComponentes);
            $.extend(params, mainGrid.loadParams());
			
            params['cs_no'] = $('#cs_no').val().replace(/-/g,'');
            params['cust_nm'] = $('#cust_nm').val();
            params['admin_no'] = $('#admin_no').val();
            params['tap_gb'] = $('#tap_gb').val();
            params['tap_cd'] = $('#tap_cd').val();
            params['addr_1'] = $('#addr_1').val();
            if ($('#addr_2').val() != '' && $('#addr_2').val() != null && $('#addr_2').val() != "") {
                params['addr_1'] = $('#addr_2').val(); // 오타아님 addr1 안에 2가있음
            }
            params['addr'] = $('#addr').val();
            params['bungu_cd'] = $('#bungu_cd').val();

            return params;
        };


        /* 메인 gird 로드  */
        function loadData() {

            var params = makeParams();

            /* 수용가 조회 */
            getAjax('importList_paging', params, function () {

                /* 로딩 시작 */
                $('.bcard.point-grid').aceWidget('startLoading');

            }, refreshGrid, null);

        };

        function updateAjax(qid, params, beforesend, callback, errCallback, async) {

            ajaxUpdate({
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
                error: function (result) {

                    if (errCallback)
                        errCallback(error);

                    var msg = '업데이트 오류.<br>';
                    msg += (error.responseText ? error.responseText.trim()
                        : '서버에 오류가 있습니다.');

                    jAlert.error('오류', msg);

                }

            });

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

            params.downloadFileName = "History_" + kutil.dateFormat(new Date(), 'yymmddHHMMss');
            $.extend(params, makeParams());

            templetDownLoad(params, null, null, function () {

                jAlert.error('오류', '다운로드에 실패했습니다.');

            });

        };

    </script>

</head>

<body>

<div role="main" class="sub-content">
	<%@ include file="ISTC_F0_1_2.jsp" %>
	<%--
    <div class="sub-cont-header">
        <h1>이력 관리</h1>
    </div>
	 --%>
    <div class="dj-card">
        <div class="bcard card h-100 point-grid">
            <div class="card-body p-0" id="gridContainer">
                <div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
            </div>
        </div>
    </div>


</div>


<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>


</body>


</html>

