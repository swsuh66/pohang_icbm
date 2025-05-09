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

        Date.prototype.yyyymmdd = function (type) {
            if (this == "Invalid Date") {
                return "";
            }
            var mm = this.getMonth() + 1;
            var dd = this.getDate();
            if (type != null) {
                return [this.getFullYear(), (mm > 9 ? '' : '0') + mm, (dd > 9 ? '' : '0') + dd].join(type);
            }
            return [this.getFullYear(), (mm > 9 ? '' : '0') + mm, (dd > 9 ? '' : '0') + dd].join('-');
        };

        Date.prototype.yymmdd = function (type) {
            if (this == "Invalid Date") {
                return "";
            }
            var mm = this.getMonth() + 1;
            var dd = this.getDate();
            var yy = this.getYear() - 100;
            if (type != null) {
                return [yy, (mm > 9 ? '' : '0') + mm, (dd > 9 ? '' : '0') + dd].join(type);
            }
            return [yy, (mm > 9 ? '' : '0') + mm, (dd > 9 ? '' : '0') + dd].join('-');
        };

        Date.prototype.hhmmss = function () {
            var hh = this.getHours();
            var mm = this.getMinutes();
            var ss = this.getSeconds();
            return [(hh > 9 ? '' : '0') + hh, (mm > 9 ? '' : '0') + mm, (ss > 9 ? '' : '0') + ss].join(':');
        };
        Date.prototype.yyyymmddhhmmss = function () {
            return this.yyyymmdd() + " " + this.hhmmss();
        };

        var _animate = !AceApp.Util.isReducedMotion();

        var mainGrid;

        var dbParams;

        var dbParams2; //

        var dbParams3;

        var dbParams4;

        var dbParamsTb = 'f2-export';

        var dbParamsTb2 = 'f1-export';

        var dbParamsTb3 = 'f11-export';

        var dbParamsTb4 = 'f12-export'


        $(function () {

            /*
            * 페이지 리싸이징
            */
            $(window).resize(function () {

                /* main grid layout */
                layoutSize();

            }).off('resize');

            /* main grid layout */
            layoutSize();

            /* 엑셀다운도르를 위한 db 파람조회  */
            getDbtableInfo();

            /* grid 초기화 */
            mainGrid = initGrid('mainGrid');

            /* 수용가 조회 */
            mainGrid.search();

            /* dat다운로드를 위한 db 파람조회  */
            getDbtableInfo2();

            /* 푸른물 엑셀 다운로드 */
            getPurenMulInfo();

            /* 수자원 엑셀 다운로드 */
            getSujaWonInfo();
            
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
                case 'blkNm':
                    value = item.blkNm2;
                    if (value && value.indexOf(':') >= 0)
                        value = value.substr(value.indexOf(':') + 1);
                    return value;

                case 'statCd':
                    if (!item.statCd)
                        return '-';

                    return '<img style="width:24px;height:24px; margin: 0 4px 0 0" src="' + meterStatCd.getImage(item.statCd) + '"/><span style="font-size:12px;">' + meterStatCd.getStr(item.statCd) + '</span>';
                    break;
                case 'deviceStatCd':
                    if (!item.statCd)
                        return '-';

                    return '<img style="width:24px;height:24px; margin: 0 4px 0 0" src="' + deviceStatCd.getImage(item.statCd) + '"/><span style="font-size:12px;">' + deviceStatCd.getStr(item.statCd) + '</span>';
                    break;
                case 'custNm':
                    //value = item.custNm.substring(0,3);
                    return value;

                case 'accuIv':
                    if (value != 0 && !value) return '-';
                    return value;
                case 'termCv_0d':
                case 'termCv_1d':
                case 'termCv_7d':
                case 'termCv_30d':
                    if (value != 0 && !value) return '-';
                    value = kutil.v2n(value, 3).split('.');
                    return value[0] + '<small>.' + value[1];
                case 'rawCnt_0d':
                case 'rawCnt_1d':
                case 'rawCnt_7d':
                case 'rawCnt_30d':
                    if (!value) return '-';
                    value = kutil.v2n(value, 1).split('.');
                    return value[0] + '<small>.' + value[1];

                case 'measDt':
                    if (!value)
                        return '-';
                    var dt = new Date(value);
                    return '' + kutil.dateFormat(dt, 'yy.mm.dd') + ' ' +
                        kutil.dateFormat(dt, 'HH:MM');

                case 'instlDay':
                    if (!value)
                        return '-';
                    var dt = new Date(value);
                    return '<small>' + kutil.dateFormat(dt, 'yy.mm.dd') + ' </small> ';

                case 'bat2Stat':
                    if (!item.bat2Stat)
                        return '-';
                    if (item.bat2Stat == '장애') {
                        return '<img style="width:16px;height:16px;" src="resources/img/marker/i-bat-red.png"/>&nbsp;' + item.bat2Stat;
                        break;
                    } else {
                        return '<img style="width:16px;height:16px;" src="resources/img/marker/i-bat-green.png"/>&nbsp;' + item.bat2Stat;
                        break;
                    }
                    return '-';
                case 'temperature':		   ////////////// 2022-11-30
                    if (item.temperature != undefined && item.temperature != null) {
                        return item.temperature + '℃';
                    }
                    return '';
            }

            return (value == 0 || value) ? value : '-';
        };

        /*
        * 그리드 초기화
         */
        function initGrid(container) {

            var opt = {

                height: "100%",
                width: "100%",
                //autowidth:true,
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
                        width: 46,
                        itemTemplate: colfnc,
                        sortingDisabled: true
                    },
                    {
                        name: "custNm",
                        title: "수용가 명",
                        type: "text",
                        align: "center",
                        width: 100,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[1]
                    },
                    {
                        name: "adminId",
                        title: "수용가번호",
                        type: "text",
                        type: "text",
                        align: "center",
                        width: 160,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "addrOld",
                        title: "구 주소",
                        type: "text",
                        align: "center",
                        width: 200,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "addrNew",
                        title: "도로명 주소",
                        type: "text",
                        align: "center",
                        width: 400,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "custPhone",
                        title: "전화번호",
                        type: "text",
                        align: "center",
                        width: 140,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "readOpr",
                        title: "검침원",
                        type: "text",
                        align: "center",
                        width: 60,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    
                    {
                        name: "statCd",
                        title: "계량기 상태",
                        type: "text",
                        align: "center",
                        width: 100,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[2]
                    },
                    {
                        name: "deviceStatCd",
                        title: "단말기 상태",
                        type: "text",
                        align: "center",
                        width: 100,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "measDt",
                        title: "검침일시",
                        type: "text",
                        align: "center",
                        width: 100,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "accuIv",
                        title: "검침값(㎥)",
                        type: "number",
                        align: "center",
                        width: 90,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    /*Brad : 필요없는 정보 제거
                    {
                        name: "termCv_0d",
                        title: "당일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[3]
                    },
                    {
                        name: "termCv_1d",
                        title: "전일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "termCv_7d",
                        title: "직전7일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "termCv_30d",
                        title: "직전30일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "termCv_90d",
                        title: "직전90일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "rawCnt_0d",
                        title: "당일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[4]
                    },
                    {
                        name: "rawCnt_1d",
                        title: "전일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "rawCnt_7d",
                        title: "직전7일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "rawCnt_30d",
                        title: "직전30일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "rawCnt_90d",
                        title: "직전90일",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    },
                    {
                        name: "bat2Iv",
                        title: "전압(v)",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true,
                        group: groups[5]
                    },
                    {
                        name: "bat2Stat",
                        title: "상태",
                        type: "number",
                        align: "center",
                        width: 80,
                        itemTemplate: colfnc,
                        hasGroup: true
                    }*/
                ],

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
            {title: '구분', columns: 1, align: "center"},
            {title: '수용가', columns: 6, align: "center"},            
            {title: '최종 검침', columns: 4, align: "center"},
            /* Brad : 필요없는 정보 제거
            {title: '일간(이동평균) 사용량 (㎥/일)', columns: 5, align: "center"},
            {title: '일간(이동평균) 검침수 (건/일)', columns: 5, align: "center"},
            {title: '단말기 배터리', columns: 2, align: "center"}
            */
            /* {title : '기온', columns : 1, align : "center"}, */  ////////////// 2022-11-30
        ];

        function makeParams() {

            var params = {};

            $.extend(params, searchComponentes);
            $.extend(params, mainGrid.loadParams());

            params['cust_nm']  = $('#cust_nm').val();
            params['admin_no'] = $('#admin_no').val();
            params['addr']	   = $('#addr').val();
            params['meter_no'] = $('#meter_no').val();

            //base
            params.useCd = '1';

            return params;

        };

        /* 메인 gird 로드  */
        function loadData(qid) {

            var params = makeParams();

            /* 수용가 조회 */
            getAjax('newPointList_paging', params, function () {

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

        /**
         * 미터기 DB 테이블 기본 정보를 가져옵니다. 2번
         */
        function getDbtableInfo2() {

            var url = getContextPath() + '/file/dbParams/' + dbParamsTb2;

            ajaxSelect({
                url: url,
                success: function (data) {

                    dbParams2 = data;

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


            params.downloadFileName = "AccuNow_" + kutil.dateFormat(new Date(), 'yymmddHHMMss');
            $.extend(params, makeParams());

            templetDownLoad(params, null, null, function () {

                jAlert.error('오류', '다운로드에 실패했습니다.');

            });

        };


        function downloadDat() {
            var params = new Object();

            params.qid = dbParams2[dbParamsTb2]['refer-sql'];
            params.colMapping = dbParams2[dbParamsTb2]['cols'];
            params.length = params.colMapping.length;
            console.log(params)

            params.downloadFileName = "result_dat" + kutil.dateFormat(new Date(), 'yymm');
            $.extend(params, makeParams());

            templetDownLoadDat(params, null, null, function () {

                jAlert.error('오류', '다운로드에 실패했습니다.');

            });
        }



        /* 단말번호 검색을 위한 스크립트 */
        function selectChangHandler(el) {

            var searchOption = $(el).val();
            var target = $('#' + $(el).data('target'));
            var plh;

            plh = (searchOption == 0) ? '수용가 번호/이름/주소 ...' : '단말기 번호/미터기 번호 ...';

            target.attr('placeholder', plh);

        };


        function modalDate() {
            $('#toDate').val(kutil.dateFormat(new Date(Date.now()), 'yyyy-mm-dd'));
            $('#fromDate').val(kutil.addMonth(new Date(), -1).yyyymmdd());


        }

        function pmDownload(el) {


            var fromDt = $('#fromDate').val();

            var toDt = $('#toDate').val();


            if (!fromDt || !toDt) {
                jAlert.error('오류', '날짜를 선택해주세요');
                return;
            } else if (fromDt > toDt) {
                jAlert.error('오류', '시작 날짜가 종료 날짜를 넘을 수 없습니다.');
                return;
            } else {

                if (!dbParams) {

                    jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
                    return;

                }

                var params = new Object();

                params.fromDt = fromDt;
                params.toDt = toDt;
                params.qid = dbParams3[dbParamsTb3]['refer-sql'];
                params.colMapping = dbParams3[dbParamsTb3]['cols'];
                params.length = params.colMapping.length;
                params.downloadFileName = "PurenMul_" + kutil.dateFormat(new Date(), 'yymmddHHMMss');

                pmReportDateSearch(params);

            }
        }

        function pmReportDateSearch(params) {

            getAjax('mars.icbm.map1.purenMul', params, function () {

            }, function (result) {

                if (result.length == 0) {
                    jAlert.error('오류', '해당 날짜에 데이터가 존재하지 않습니다.');
                    return;

                } else {
                    templetDownLoad(params, null, null, function () {

                        jAlert.error('오류', '다운로드에 실패했습니다.');

                    });
                    $('#pmModal').modal('hide');
                }

            }, null);

        }

        function getPurenMulInfo() {

            var url = getContextPath() + '/file/dbParams/' + dbParamsTb3;

            ajaxSelect({
                url: url,
                success: function (data) {

                    dbParams3 = data;

                },
                error: function (result) {

                    jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');

                }
            });

        };


        function getSujaWonInfo() {

            var url = getContextPath() + '/file/dbParams/' + dbParamsTb4;

            ajaxSelect({
                url: url,
                success: function (data) {

                    dbParams4 = data;

                },
                error: function (result) {

                    jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');

                }
            });

        };

        function sjDownload(evt) {

            var fromDt = $('#fromDate').val();

            var toDt = $('#toDate').val();


            if (!fromDt || !toDt) {
                jAlert.error('오류', '날짜를 선택해주세요');
                return;
            } else if (fromDt > toDt) {
                jAlert.error('오류', '시작 날짜가 종료 날짜를 넘을 수 없습니다.');
                return;
            } else {

                if (!dbParams) {

                    jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
                    return;

                }

                var params = new Object();

                params.fromDt = fromDt;
                params.toDt = toDt;
                params.qid = dbParams4[dbParamsTb4]['refer-sql'];
                params.colMapping = dbParams4[dbParamsTb4]['cols'];
                params.length = params.colMapping.length;
                params.downloadFileName = "SuJaWon_" + kutil.dateFormat(new Date(), 'yymmddHHMMss');

                sjReportDateSearch(params);

            }
        }

        function sjReportDateSearch(params) {

            getAjax('mars.icbm.map1.suJaWon', params, function () {

            }, function (result) {

                if (result.length == 0) {
                    jAlert.error('오류', '해당 날짜에 데이터가 존재하지 않습니다.');
                    return;

                } else {
                    templetDownLoad(params, null, null, function () {

                        jAlert.error('오류', '다운로드에 실패했습니다.');

                    });
                    $('#pmModal').modal('hide');
                }

            }, null);

        }

    </script>

    <style type="text/css">
        #devContainer .form-control {
            width: 30% !important;
        }

        #pmModal .modal-dialog {
            max-width: 600px !important;
        }

    </style>


</head>


<body>


<!-- # start of modal : dat download modal -->
<div class="modal fade" id="dat-download-modal" role="dialog">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <!-- modal : header -->
            <div class="modal-header">
                <h4 class="modal-title">.dat 파일 다운로드</h4>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <!-- modal : body -->
            <div class="modal-body">
                <div class="modal-body-content">
                    <div class="ist-flex">
                        <div class="input-group">
                            <input id="rs-sunshine-calendar-day"
                                   class="digital-calendar-input form-control form-control-sm" type="text" readonly/>
                            <div class="input-group-append">
                                <button class="digital-calendar-button form-control form-control-sm btn btn-outline-primary"
                                        type="button"><i class="far fa-calendar-alt"></i></button>
                            </div>
                        </div>
                        <button id="dat-download-btn" type="button" class="btn btn-outline-primary btn-sm">다운로드</button>
                    </div>
                </div>
            </div>
            <!-- modal : footer -->
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary btn-sm" data-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>
<!-- end of modal : dat file download-->


<div role="main" class="sub-content">
    <%@ include file="ISTC_F0_1_2.jsp" %>

    <div class="dj-card">
        <div class="bcard point-grid" id="gridContainer">
            <div id="mainGrid" class="data-list containerBorder"></div>
        </div>
    </div>
</div>


</div>

<div class="modal fade dialog-30" id="pmModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-dialog-scrollable" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    요금연동 Export
                </h5>

                <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="closeReportModal"
                        onclick="closeDevModal();">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>


            <div class="modal-body">
                <div id="devContainer" class="d-flex align-items-center">
                    <input type="date" class="form-control search-param" id="fromDate"/>
                    <input type="date" class="form-control search-param" id="toDate"/>
                    <button type="button" class="btn btn-primary ml-3" id='pmDownload' onclick='pmDownload(this);'>푸른물
                        <i class="fa fa-download ml-1 text-90"></i>
                    </button>
                    <button type="button" class="btn btn-primary ml-3" id='sjDownload' onclick='sjDownload(this);'>수자원
                        <i class="fa fa-download ml-1 text-90"></i>
                    </button>
                </div>
            </div>

        </div>
    </div>
</div>


<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>


</body>


</html>

