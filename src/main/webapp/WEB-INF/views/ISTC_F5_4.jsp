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

        var errGrid;

        var dbParams;

        var dbImportParams;

        var dbParamsTb = 'f5-ctnExport';

        var dbImportTb = 'f5-ctnImport';

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

            /* err grid 초기화 */
            errGrid = initGrid('errGrid', errFields);

            /* grid 초기화 */
            mainGrid = initGrid('mainGrid', mainFields);


            /* 수용가 조회 */
            mainGrid.search();

            $('#statCd_Grp').hide();
            $('#useType_Grp').hide();
            $('#blkSq_Grp').hide();
            $('#readOpr_Grp').hide();
            $('#setYears_Grp').hide();
            $('#amiType_Grp').hide();
            $('#pipeDia_Grp').hide();

        });


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

            $('#errGridContainer').height(480);

        };

        function setSubmitValidation() {

            //var _form = $('#adminIdForm');

            var _form = $('#' + id);

            _form.validate({
                focusCleanup: false,
                onfocusout: false,
                onkeyup: false,
                focusInvalid: false,
                showErrors: function (errorMap, errorList) {
                    validate_util.setError(this, errorList);
                },
                onfocusin: function (element) {
                    validate_util.setValid(this, element);
                },
                submitHandler: function () {
                    updateAdminId(this.currentForm);
                },
                rules: validate_util.rules,
                messages: validate_util.messages
            });

            _form.submit(function () {
                _form.valid();
            })
        };


        function modalGridLayout(modal, height) {

            modal.find('.jsgrid-grid-body').css('height', height + 'px');

            $(window).resize(function () {

                modal.find('.jsgrid-grid-body').css('height', height + 'px');

            });

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

        function refreshErrGrid(data) {

            if (data)
                errGrid.finishLoad(data || []);
            else
                errGrid.command('refresh');


            $('#errGridContainer .jsgrid-grid-body').height(400);

        };

        function clearForm(id) {

            $('#' + id).find('input').val('');

        };

        function closeDevModal() {

            devGrid.finishLoad([]);

            $('#searchInputD').val('');

        };

        /*
        * 그리드 컬럼 요소 리빌딩
         */
        var colfnc = function (value, item, c, d, e) {

            switch (this.name) {
                case 'num':
                    return (item.pageNo - 1) * item.pageSize + (c + 1);
                case 'instlDay':
                    return kutil.dateFormat(new Date(value), 'yyyy');

            }


            return value ? value : '-';
        };


        var errFields = [
            {name: "dataSq", title: "엑셀 순번", type: "text", align: "center", width: 80, sortingDisabled: true},
            {name: "msg", title: "엑셀 오류 내용", type: "text", width: 'auto', sortingDisabled: true}
        ];

        var mainFields = [
            {
                name: "num",
                title: "순번",
                type: "text",
                align: "center",
                width: 60,
                itemTemplate: colfnc,
                sortingDisabled: true,
                hasGroup: true
            },
            {name: "amiType", title: "amiType", type: "text", width: 140, itemTemplate: colfnc, hasGroup: true},
            {name: "ctn", title: "CTN", type: "text", width: 140, itemTemplate: colfnc, hasGroup: true},
            {name: "cseId", title: "CSE_ID", type: "text", width: 140, itemTemplate: colfnc, hasGroup: true},
            {name: "comNm", title: "제조회사", type: "text", width: 100, itemTemplate: colfnc, hasGroup: true},
            {name: "setDt", title: "등록일", type: "text", width: 100, itemTemplate: colfnc, hasGroup: true},
            {name: "updDt", title: "수정일", type: "text", width: 100, itemTemplate: colfnc, hasGroup: true},
            {
                itemTemplate: function (_, item) {

                    if (item.adminId)
                        return;

                    var iEl = $("<i>")
                        .attr("data-ctn", item.ctn)
                        .attr("data-cse-id", item.cseId)
                        .attr("data-ami-type", item.amiType)
                        // .append("단말삭제")
                        .addClass("ico i-trash-red");


                    var aEl = $("<button>").attr("type", "button")
                        .addClass("btn dj-btn-outline-red btn-sm")
                        .append(iEl)
                        .append("단말삭제")
                        .attr("data-ctn", item.ctn)
                        .attr("data-cse-id", item.cseId)
                        .attr("data-ami-type", item.amiType)
                        .on("click", function (evt) {


                            var el = $(evt.target);
                            var devNo = el.data('ctn');
                            var subDevNo = el.data('cse-id');
                            var amiType = el.data('ami-type');

                            var params = new Object();
                            params.ctn = item.ctn;
                            params.cseId = item.cseId


                            jAlert.confirm('알림', '단말을 삭제합니까?', function () {

                                deleteAjax('mars.icbm.map1.deleteCtn', params, function () {

                                    $('.bcard.point-grid').aceWidget('startLoading');

                                }, function (result) {

                                    $('.bcard.point-grid').aceWidget('stopLoading');

                                    mainGrid.search();

                                    jAlert.info('알림', '삭제에 성공했습니다.');

                                }, null);

                            });


                        });


                    return aEl;

                },
                align: "center",
                width: 100,
                title: '단말삭제',
                hasGroup: true,

                sortingDisabled: true
            }
        ];

        /*
        * 그리드 초기화
         */
        function initGrid(container, field) {

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

                fields: field,

                loadStrategy: function () {

                    return new CustomPageLoadingStrategy(this, loadData);

                },
                rowDoubleClick: function (evt) {
                    // 2023. 10. 13 추가. 종합등록관리도 더블클릭 이벤트 추가
                    //$('#infoModal', window.parent.document).modal('show'); //infoModal

                    loadModalPointData(false, evt.item);

                    loadModalRawData(evt.item);
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

            $.extend(params, searchComponentes);
            $.extend(params, mainGrid.loadParams());

            params.searchParam = $('#searchInputCtn').val();

            return params;
        };


        /* 메인 gird 로드  */
        function loadData() {

            var params = makeParams();

            /* 수용가 조회 */
            getAjax('ctnList_paging', params, function () {

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

                    jAlert.error('오류', '서버에 오류가 있습니다.');

                }

            });

        };

        function insertAjax(qid, params, beforesend, callback, errCallback, async) {

            ajaxInsert({
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

                    jAlert.error('오류', '서버에 오류가 있습니다.');

                }

            });

        };

        function deleteAjax(qid, params, beforesend, callback, errCallback, async) {

            ajaxDelete({
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

                    var msg = '삭제 오류.<br>';
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


            var url = getContextPath() + '/file/dbParams/' + dbImportTb;

            ajaxSelect({
                url: url,
                success: function (data) {

                    dbImportParams = data;

                    fileUp.setIsModal('importContainer');
                    fileUp.initStepWizard('fileUp');

                    fileUp.initFileGrid('file_grid_container', data);

                },
                error: function (result) {

                    jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');

                }
            });


        };

        function openModal() {

            $('#importContainer').modal({backdrop: 'static', keyboard: false});

        };

        /**
         * 임포트할 예시 파일을 다운로드 합니다.
         */
        function exFileDownload() {

            window.location = getContextPath() + '/resources/excel/ctnImport.xlsx';

        };

        /**
         * 임포트 끝날시 로직 정의
         */
        function doCreateCompleteLogic(result) {

            if (result.length > 0) {

                jAlert.error('오류', '엑셀에 오류가 있습니다.');

                $('#errModal').modal({backdrop: 'static', keyboard: false});

                refreshErrGrid(result);


            } else
                jAlert.info('성공', '저장되었습니다.');

            mainGrid.search();


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

            params.downloadFileName = "Setting_" + kutil.dateFormat(new Date(), 'yymmddHHMMss');
            $.extend(params, makeParams());

            templetDownLoadStream(params, null, null, function () {

                jAlert.error('오류', '다운로드에 실패했습니다.');

            });

        };


    </script>

    <style type="text/css">


        .table-item {
            width: 100%;
            border: none;
            background: transparent;
        }

        .company-footer {
            display: flex;
            background-color: #eff3f8;
            border-top: 1px solid #dee2e6;
        }

        .mg {
            margin: 0.25rem;
        }


    </style>


</head>


<body>
<div role="main" class="sub-content">
	<%@ include file="ISTC_F5_4_CONTENT.jsp" %>
    <div class="sub-cont-header">
        <div class="sub-cont-header-area">
        </div>
    </div>
    <div class="dj-card">
        <div class="bcard card point-grid">
            <div class="card-body p-0" id="gridContainer">
                <div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
            </div>
        </div>
    </div>
</div>



<div class="modal fade" id="errModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-scrollable" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="">오류 항목</h5>

                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="card-body p-0" id="errGridContainer"></div>
                <div id="errGrid" class="data-list containerBorder grid-mobile"></div>
            </div>
        </div>

    </div>
</div>



<div id="importContainer" class="modal fade" role="dialog">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <!-- <div class="panel-heading" style="height:32px;"> -->
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel2">
                    파일 임포트
                </h5>
            </div>
            <div class="modal-body" id="fileUpload" align="center">
                <%@include file="ISTC_FILE_UPLOAD.jsp" %>
            </div>
        </div>
    </div>
</div>


<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>


</body>


</html>

