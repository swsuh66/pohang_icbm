<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
         contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

    <%@include file="/resources/inc/meta.inc" %>
    <title>스마트수도미터원격검침시스템</title>
    <!-- 화면명 : ISTC_F9 -->
    <!-- 화면명 : 수검침 -->

    <%@include file="/resources/inc/base.inc" %>
    <%@include file="/resources/inc/jsgrid.inc" %>

    <script type="text/javascript">

        var _animate = !AceApp.Util.isReducedMotion();

        var mainGrid;

        var dbParamsTb = 'f9-export-deajeon';

        var dbParams;
        var remarkStr = [];

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
                    width: 40,
                    itemTemplate: colfnc,
                    sortingDisabled: true,
                    editing: false
                },
                {
                    name: "bungu_cd",
                    title: "분구코드",
                    type: "text",
                    align: "center",
                    width: 60,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: false
                },
                {
                    name: "cs_no",
                    title: "수용가 번호",
                    type: "text",
                    align: "center",
                    width: 100,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: false
                },
                {
                    name: "cust_name",
                    title: "성명",
                    type: "text",
                    align: "center",
                    width: 70,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: false
                },
                {
                    name: "cust_phone",
                    title: "연락처",
                    type: "text",
                    align: "center",
                    width: 80,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: false
                },
                {
                    name: "addr_new",
                    title: "주소",
                    type: "text",
                    align: "center",
                    width: 200,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: false
                },
                {
                    name: "business_name",
                    title: "업종",
                    type: "text",
                    align: "center",
                    width: 46,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: false
                },
                {
                    name: "pipe_diameter",
                    title: "구경",
                    type: "text",
                    align: "center",
                    width: 46,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: false
                },
                {
                    name: "bf_date",
                    title: "검침일",
                    type: "date",
                    align: "center",
                    width: 60,
                    itemTemplate: colfnc,
                    hasGroup: true,
                    group: groups[0],
                    editing: false
                },
                {
                    name: "bf_iv",
                    title: "검침값",
                    type: "text",
                    align: "center",
                    width: 60,
                    itemTemplate: colfnc,
                    hasGroup: true,
                    editing: false
                },
                {
                    name: "now_date",
                    title: "검침일",
                    type: "date",
                    align: "center",
                    width: 60,
                    itemTemplate: colfnc,
                    hasGroup: true,
                    group: groups[1],
                    editing: false
                },
                {
                    name: "now_iv",
                    title: "검침값",
                    type: "text",
                    align: "center",
                    width: 60,
                    itemTemplate: colfnc,
                    hasGroup: true,
                    editing: true
                },
                {
                    name: "remarkStr",
                    title: "장애상태",
                    items: remarkStr,
                    valueField: "id",
                    textField: "name",
                    type: "select",
                    align: "center",
                    width: 60,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: true
                },
                {
                    name: "flag",
                    title: "검침상태",
                    type: "text",
                    align: "center",
                    width: 46,
                    itemTemplate: colfnc,
                    hasGroup: false,
                    editing: false
                },
                {type: "control", hasGroup: false}
            ];

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
                editing: true,
                searchContainer: '#searchInput',
                fields: fields,

                loadStrategy: function () {
                    return new CustomPageLoadingStrategy(this, loadData);
                },
                rowClick: function (args) {
                },
                rowDoubleClick: function (evt) {

                    $('#infoModal', window.parent.document).modal('show'); //infoModal

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
                },
                updateItem: function (item, editedItem) {
                    var row = this._editingRow.data('JSGridItem');//JSGRID_ROW_DATA_KEY
                    var editRow = this._getValidatedEditedItem();//JSGRID_ROW_DATA_KEY

                    if (!row) {
                        alert('수정 row 에러');
                        return;
                    }

                    if (!editRow) {
                        alert('수정 editRow 에러');
                        return;
                    }
                    $.extend(row, editRow);

                    getAjax('mars.icbm.map1.deleteWriteAccuIv', row, false, function (result) {
                        getAjax('mars.icbm.map1.insertWriteAccuIv', row, false, function () {
                            getAjax('mars.icbm.map1.updateRemark', row, false, function () {
                                mainGrid.search();
                            }, null);
                        }, null);
                    }, null);


                }
            };

            return new DataGrid(container, opt);
        };

        var groups = [
            {title: '전월', columns: 2, align: "center"},
            {title: '금월', columns: 2, align: "center"}
        ];


        /* modal 데이터 로드 */
        function loadModalData(useGparams, item) {


            var params = new Object();
            var type = $('#typeSelect', window.parent.document).val();
            var endDate = $('#fromDate', window.parent.document).val();


            if (!endDate || endDate.length == 0) {

                /* 날짜 초기화 */
                $('#fromDate', window.parent.document).val(kutil.dateFormat(new Date(), 'yyyy-mm-dd'));
                endDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd');

            }


            if (useGparams)
                params = parent._params;
            else {

                if (item) {
                    params.pointSq = item.point_sq;
                    params.siteSq = item.site_sq;
                }

            }

            params.endDate = endDate;

            var begDate = kutil.addMonth(endDate, (type == '0') ? -1 : -12);
            params.begDate = moment(Date.parse(begDate)).format('YYYY-MM-DD');

            loadPointData(params);

            type == '0' ?
                loadRawData('pointHisdataRaw', params) :
                loadRawData('pointHisdata', params);


            parent._params = params;

        };

        function loadRawData(qid, params) {

            /* 검침값 조회 */
            getAjax(qid, params, function () {

                $('#infoModal', window.parent.document).aceWidget('startLoading');

            }, function (result) {

                parent.refreshModalMain(result);

            }, null);

        };

        /* 로드 수용가 정보 */
        function loadPointData(params) {

            /* 수용가 조회 */
            getAjax('mars.icbm.map1.pointList', params, null, function (result) {

                parent.updateValueFields(result);

            }, null);

        };


        function makeParams() {

            var params = {};

            $.extend(params, mainGrid.loadParams());

            params['cs_no'] = $('#cs_no').val();
            params['cust_nm'] = $('#cust_nm').val();
            params['read_responsi'] = $('#read_responsi').val();
            params['remark'] = $('#remark').val();
            params['cust_phone'] = $('#cust_phone').val();
            params['bungu_cd'] = $('#bungu_cd').val();
            params['flag'] = $('#flag').val();

            return params;
        };

        /* 메인 gird 로드  */
        function loadData() {

            var params = makeParams();
            /* 수용가 조회 */
            getAjax('writeAccuIvList_paging', params, function () {

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

        function componentGridItem(url) {
            ajaxSelect({
                sql: url,
                success: function (data) {
                    if (data != 0) {
                        data.forEach(function (item, idx) {
                            if (item != null) {
                                //var el = $('<option>').attr('value', item.val).text(item.name);
                                //$('.componentsSelect[name="' + key + '"]').append(el);

                                var map = {id: item.val, name: item.name};
                                remarkStr.push(map);

                            }
                        });
                    }

                },
                error: function (result) {

                    jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');

                }
            });
        };

        /**
         * 조회조건 조회
         */
        function component(url, key) {
            ajaxSelect({
                sql: url,
                success: function (data) {
                    if (data != 0) {
                        data.forEach(function (item, idx) {
                            if (item != null) {
                                var el = $('<option>').attr('value', item.val).text(item.name);
                                $('.componentsSelect[name="' + key + '"]').append(el);
                            }
                        });
                    }

                },
                error: function (result) {

                    jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');

                }
            });
        };

        function selectChange(url, key) {
            var params = {};

            $('#addr_2 option').remove(); //초기화
            var el = $('<option>').attr('value', "").text("전체");
            $('.componentsSelect[name="' + "addr_2" + '"]').append(el);

            var addr_1 = $('#addr_1').val()
            if (addr_1 == null || addr_1 == "") {
                component('mars.icbm.map1.selecAllSecondSiteComponent', 'addr_2');
                return;
            }

            params['up_site_sq'] = addr_1;

            ajaxSelect({
                sql: url,
                data: params,
                success: function (data) {
                    if (data != 0) {
                        data.forEach(function (item, idx) {
                            if (item != null) {
                                var el = $('<option>').attr('value', item.val).text(item.name);
                                $('.componentsSelect[name="' + key + '"]').append(el);
                            }
                        });
                    }

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


            params.downloadFileName = "writeAccuIv" + kutil.dateFormat(new Date(), 'yymmddHHMMss');


            var tParams = makeParams();

            $.extend(params, tParams);

            templetDownLoad(params, null, null, function () {

                jAlert.error('오류', '다운로드에 실패했습니다.');

            });

        };

    </script>
</head>
<body>
<div role="main" class="sub-content">
    <%@ include file="ISTC_F0_1_9.jsp" %>

    <div class="dj-card">
        <div class="bcard point-grid" id="gridContainer">
            <div id="mainGrid" class="data-list containerBorder"></div>
        </div>
    </div>
</div>
<%--		<div  style="width: 100% !important;  height: 100% !important; padding: 0 !important;">--%>

<%--			<div style="width: 100% !important;  height: 100% !important; padding: 0 !important;">--%>
<%--				<div>--%>
<%--					<div class="bcard card h-100 point-grid">--%>
<%--						<div class="card-body p-0" id="gridContainer"">							--%>
<%--							<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>--%>
<%--						</div>--%>
<%--					</div>--%>
<%--			</div>--%>
<%--			</div>--%>
<%--		</div>--%>


<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>


</body>


</html>

