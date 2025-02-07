<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>

<head>
    <%@include file="/resources/inc/meta.inc" %>
        <title>스마트수도미터원격검침시스템</title>

    <%@include file="/resources/inc/base.inc" %>
    <%@include file="/resources/inc/tree.inc" %>
    <%@include file="/resources/inc/jsgrid.inc" %>
    <%@include file="/resources/inc/hichart.inc" %>


    <!--

     테스트
    -->
    <script type="text/javascript">
        var _animate = !AceApp.Util.isReducedMotion();
        var _data_groups;
        var componentesIdx = 0;

        /*
         * 현재는 istc_f1 에서 만 사용 추후에 변경예정
         */
        var searchComponentes = {
            statCd: null,
            useType: null,
            blkSq: null,
            readOpr: null,
            setYears: null,
            comSq: null,
            amiType: null,
            pipeDia: null,
            siteSq: null,
            upSiteSq: getSiteSq(),
            lv: 1,
            fullNm: ['전체']
        };

        var change = 0;


        $(function () {

            $(window).resize(function () {

                /* iframe layout */
                layoutSize();

                /* modal layout */
                layoutModalSize('infoModal');

                /* modal usegrid layout */
                layoutSize('infoModal', 'modalGridContainer', 100);

                /* modal useChart layout */
                layoutSize('infoModal', 'useChart', 100);
            });

            /* iframe layout */
            layoutSize();

            /* modal layout */
            layoutModalSize('infoModal');

            /* 사이드 로딩 시작 */
            $('.container[name="nav-bar-search"]').aceWidget('startLoading');

            // 2023-10-16 변경 : 환경별로 페이지로드 되지 않은상태에서 데이터로드가 되어 데이터 싱크가 안맞는 기능수정.
            $('.container[name="nav-bar-search"]').load('ISTC_F0_1', function () {
            });

            //multLanguage();
            menuClose();

        });


        // 다국어처리
        function multLanguage() {
            $.i18n.properties({
                name: 'Language', // 다국어 속성 파일의 이름 (Language_en.properties, Language_ko.properties, 등)
                path:  getContextPath() + '/resources/language/', // 다국어 속성 파일이 있는 경로
                mode: 'map', // 로드된 메시지를 JavaScript 객체로 저장
                language: 'ko', // 기본 언어 설정
                callback: function() {
                    // 다국어 메시지 사용

                    var setting_value = $.i18n.map;

                    for (var key in setting_value) {
                        if (setting_value.hasOwnProperty(key)) {
                            var value = setting_value[key];
                            $('#' + key).empty();
                            $('#' + key).append(value);
                        }
                    }
                }
            });
        };

        function menuClose() {
            $.i18n.properties({
                name: 'menuHide', // 다국어 속성 파일의 이름 (Language_en.properties, Language_ko.properties, 등)
                path:  getContextPath() + '/resources/language/', // 다국어 속성 파일이 있는 경로
                mode: 'map', // 로드된 메시지를 JavaScript 객체로 저장
                language: '', // 기본 언어 설정
                callback: function() {
                    // 다국어 메시지 사용

                    var setting_value = $.i18n.map;
                    var userlv = getUserLv();

                    for (var key in setting_value) {
                        if (setting_value.hasOwnProperty(key)) {
                            var value = setting_value[key];
                            if (!value.includes(userlv)) {
                                $('#' + key).hide();
                            }
                        }
                    }
                }
            });
        };


        /*
        * 레이아웃 사이즈
        */
        function layoutSize(con, target, px) {

            var conEl = con ? $('#' + con) : $(window);
            target = target ? target : 'iframeBody';
            px = px ? px : 10;

            var ht1 = conEl.innerHeight();
            var off = $('#' + target).offset();

            if (off) {
                var top = off.top;
                var src = $('#iframeBody').attr('src');
                    top = 0;
                    px = 0;

                var ht = ht1 - top - 0;
                $('#' + target).height(ht);

            }

        };

        /*
        * 레이아웃 사이즈
        */
        function layoutModalSize(id) {

            var ht1 = $(window).innerHeight();

            $('.modal[id="' + id + '"]').height(ht1);

        };

        /*
         * istc_f1때문에 남김
         */
        function selectChangHandler(el) {
            var component = $(el).data('component');
            var val = $(el).val();
            searchComponentes[component] = val != '-1' ? val : null;

        };

        /*
         * 리소스 path
         */
        function getContextPath() {

            return "${contextPath}";

        };

        function getUserLv() {
            return "${user.getUserRoll()}";
        };

        function getAbsolutepath(path) {

            return '${contextPath}/' + path;

        };

        function getSiteSq() {

            return ${ user.getSiteSq() };

        };

        function getSiteLv() {

            return ${ user.getSiteLv() };

        };

        function getUserRoll() {

            return ${ user.getUserRoll() };

        };

        function getUserNm() {

            return ${ user.getUserNm() };

        };

        /*
         * 슬라이터 onoff
         */
        function sidebarChangeHandler(el) {

            var id = $(el).data('target');
            var clss = 'toggling collapsed';

            if ($('#' + id).hasClass(clss) == true) {
                $('.sidebar[id="' + id + '"]').removeClass(clss);
            } else
                $('.sidebar[id="' + id + '"]').addClass(clss);

        };

        /*
         * 바디 프레임 교체
         */
        function reloadFrame(src, el) {
            $('#iframeBody').attr('src', src);
            
            $('.nav-item').removeClass('active open');

            $(el).parent('.nav-item').addClass('active open');
            layoutSize();

            if (document.getElementById('iframeBody').contentWindow.window.location.href.indexOf('login') > -1) {

                document.location.reload();
                return;
            }
        };

        /*
         * ISTC_F0_1 의 검색에서 사용하는 조회 버튼 기능.
         */
        function searchGrid() {
            if (document.getElementById('iframeBody').contentWindow.loadAll != undefined) { // iframeBody 에 있는 jsp 로직에서  loadAll 이라는 함수가 있을때만.
                document.getElementById('iframeBody').contentWindow.loadAll();
            }
            document.getElementById('iframeBody').contentWindow.mainGrid.search();

        };

        


        function loadAllData() {
            $.extend(searchComponentes, {

                statCd: null,
                useType: null,
                blkSq: null,
                readOpr: null,
                setYears: null,
                comSq: null,
                amiType: null,
                pipeDia: null

            });


            $('.container[name="nav-bar-search"]').empty();
            $('.container[name="nav-bar-search"]').load('ISTC_F0_1', function () {

                setBreadcrumb();

            });

            var childPage = $('#iframeBody').attr('src');

            if (childPage == 'ISTC_F1') {

                document.getElementById('iframeBody').contentWindow.loadAll();

            }

            if (childPage.indexOf('ISTC_F9') > -1) {

                document.getElementById('iframeBody').contentWindow.loadSettingData();

            }

            document.getElementById('iframeBody').contentWindow.loadData();

        };

        /*
         *  Breadcrumb 세팅
         */
        function setBreadcrumb(data) {

            $('.breadcrumb').empty();

            var arr = parent.searchComponentes.fullNm;

            arr.forEach(function (item, idx) {

                var i = $('<i>').addClass('fa fa-angle-right text-80');

                if (idx != 0)
                    $('.breadcrumb').append($('<li>').append(i).append('<a>' + item + '</a>'));
                else
                    $('.breadcrumb').append($('<li>').append('<a>' + item + '</a>'));

            });

        };

        /*
         * 각 요소 초기화
         */
        function resetComponentes() {

            $('.form-control').val('').trigger('chosen:updated');

            $.extend(searchComponentes, {

                statCd: null,
                useType: null,
                blkSq: null,
                readOpr: null,
                setYears: null,
                comSq: null,
                amiType: null,
                pipeDia: null

            });

        };

        function finishLoadedComponentes() {

            componentesIdx++;

            //console.log(componentesIdx);

            if (componentesIdx == 7) {
                //$(".form-control").chosen({ 이걸 왜 바꾼지모르겠음 프론트 기업에서.
                $(".chosen-select").chosen({
                    allow_single_deselect: true
                })

                $('.container[name="nav-bar-search"]').aceWidget('stopLoading');
                var src = $('#iframeBody').attr('src');
                componentesIdx = 0;

            }

        };

        /*
         * 각 요소 조회
         */
        function loadComponentes() {

            loadComponent('selectComponentes', 0, finishLoadedComponentes);

            loadComponent('selectComponentes', 1, finishLoadedComponentes);

            loadComponent('selectComponentes', 2, finishLoadedComponentes);

            loadComponent('selectComponentes', 3, finishLoadedComponentes);

            loadComponent('selectComponentes', 4, finishLoadedComponentes);

            loadComponent('selectComponentes', 5, finishLoadedComponentes);

            loadComponent('selectComponentes', 6, finishLoadedComponentes);

        };

        /*
         * 각 요소 조회
         */
        function loadComponent(qid, key, bCallback) {

            var obj = new Object();
            obj.key = key;

            $.extend(obj, searchComponentes);

            /* 계량기 상태이상 데이터 조회 */
            getAjax(qid, obj, function () {

            }, refreshComponent, null, bCallback);

        };

        function refreshComponent(result, bCallback) {

            if (result.length != 0) {

                var key = result[0].key;

                result.forEach(function (item, idx) {

                    var el = $('<option>').attr('value', item.sq).text(item.val);
                    $('.form-control[name="' + key + '"]').append(el);

                });

            }

            if (bCallback)
                bCallback();

        };

        /*
         * ajax 조회 기본 함수
         */
        function getAjax(qid, params, beforesend, callback, errCallback, bCallback) {

            ajaxSelect({
                sql: qid,
                data: params,
                //async : async ? async : true,
                beforeSend: function () {


                    if (beforesend) {

                        bCallback ? beforesend(bCallback) : beforesend();

                    }

                },
                success: function (result) {
                    if (callback) {

                        bCallback ? callback(result, bCallback) : callback(result);
                    }
                },
                error: function (error) {

                    if (error.status == 401) {

                        parent.document.location.reload();
                        return;
                    }


                    if (errCallback) {

                        bCallback ? errCallback(error, bCallback) : errCallback(error);

                    }

                    var msg = '데이터를 읽을 수 없습니다.<br>';
                    msg += (error.responseText ? error.responseText.trim()
                        : '서버에 오류가 있습니다.');

                    jAlert.error('오류', msg);

                }
            });

        };

         function handleLoginLoad(){
            var iframe = document.getElementById('iframeBody')
            var iframeURL = iframe.contentWindow.location.href;
            if(iframeURL.includes("/login")){
                document.getElementById('iframeBody').parentNode.removeChild(iframe);
                top.location.href = "/login";
            }
        };
    </script>
</head>

<body>
<div class="wrap">
    <!-- 사이드 메뉴 -->
    <aside class="custom-sidebar" id="side-bar">
        <button class="btn-toggle-sidebar"><i class="ico i-toggle-sidebar"></i></button>
        <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F1', this);" class="custom-sidebar-logo">
            <img alt="" src="${contextPath}/resources/img/ISTEC-LOGO-L.png">
        </a>
        <ul class="nav custom-nav">
            <li class="nav-item" id="ISTC_F1">
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F1', this);" class="nav-link">
                    <i class="ico i-home"></i>
                    <span id="istc_f0_menu0">HOME</span>
                </a>
            </li>

            <li class="nav-item" id="ISTC_F8">
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F8', this);" class="nav-link">
                    <i class="ico i-history-management"></i>
                    <span id="istc_f0_menu1">수용가정보</span>
                </a>
            </li>

            <li class="nav-item"  id="ISTC_F9" hidden>
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F9', this);"
                   class="nav-link">
                    <i class="ico i_writeaccu"></i>
                    <span >수검침</span>
                </a>
            </li>

            <li class="nav-item" id="ISTC_F2">
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F2', this);" class="nav-link">
                    <i class="ico i-meter-reading"></i>
                    <span id="istc_f0_menu2">원격검침현황</span>
                </a>
            </li>

            <li class="nav-item" id="ISTC_F3">
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F3', this);" class="nav-link">
                    <i class="ico i-remote-meter-reading"></i>
                    <span id="istc_f0_menu3">원격검침집계</span>
                </a>
            </li>

            <li class="nav-item" id="ISTC_F4">
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F4', this);" class="nav-link">
                    <i class="ico i-meter-reading-list"></i>
                    <span id="istc_f0_menu4">원격검침내역</span>
                </a>
            </li>

            <li class="nav-item" id="ISTC_F6" hidden>
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F6', this);" class="nav-link">
                    <i class="ico i-history-management"></i>
                    <span id="istc_f0_menu6">등록이력관리</span>
                </a>

            </li>
            <li class="nav-item" id="ISTC_F10">
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F10', this);" class="nav-link">
                    <i class="ico i_imposition"></i>
                    <span id="istc_f0_menu5">부과조회</span>
                </a>

            </li>
            <li class="nav-item" id="ISTC_F13">
                <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F13', this);" class="nav-link">
                    <i class="ico i-meter-reading"></i>
                    <span>시간대별 검침값 검출</span>
                </a>

            </li>
			<li class="nav-item " id="ISTC_WATERWEEK_GRP">
               <a href="javascript:void(0);" onclick="" class="nav-link">
                   <i class="ico i_leak"></i>
                   <span id="istc_f0_menu6">누수검출기능</span>
                       <b class="ico i-arrow-down"></b>
               </a>
               <ul class="nav custom-nav custom-nav-navbar" >
                   <li class="nav-item" id="ISTC_F11_1">
                       <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F11_1', this);"
                          class="nav-link">누수검출</span>
                       </a>
                   </li>

                    <li class="nav-item" id="ISTC_F11_3">
                        <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F11_3', this);"
                           class="nav-link">누수검출-설정</a>
                        </li>
                    </ul>
            </li>
                <li class="nav-item " id="SETTING_GRP">
                    <a href="#" class="nav-link">
                        <i class="ico i-set"></i>
                        <span>설정</span>
                        <b class="ico i-arrow-down"></b>
                    </a>
                    <ul class="nav custom-nav custom-nav-navbar">

                        <li class="nav-item" id="ISTC_F5_4" hidden>
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_4', this);"
                               class="nav-link">단말등록 관리</a>
                        </li>
                        
                        <li class="nav-item"  id="ISTC_F5_5" hidden>
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_5', this);"
                               class="nav-link">단말설치 관리</a>
                        </li>

                        <li class="nav-item" id="ISTC_F5_2" >
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_2', this);"
                               class="nav-link">종합등록 관리</a>
                        </li>
                        <li class="nav-item" id="ISTC_F5_1_1">
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_1_1', this);"
                               class="nav-link">사용자 관리</span>
                            </a>
                        </li>
                        <li class="nav-item" id="ISTC_F5_SVC_LIST" >
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_SVC_LIST', this);"
                               class="nav-link">LG 서비스코드 관리</a>
                        </li>

                        <li class="nav-item" id="ISTC_F5_6" >
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_6', this);"
                               class="nav-link">부수용가 등록</a>
                        </li>
                    </ul>
                </li>

                <li class="nav-item " id="SM_GRP">
                    <a href="#" class="nav-link">
                        <i class="ico i_writeaccu"></i>
                        <span>유지보수</span>
                        <b class="ico i-arrow-down"></b>
                    </a>
                    <ul class="nav custom-nav custom-nav-navbar">
                        <li class="nav-item" id="ISTC_F5_1">
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_1', this);"
                               class="nav-link">사용자 관리 - 마스터</span>
                            </a>
                        </li>
                        <li class="nav-item" id="ISTC_F12" >
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F12', this);"
                               class="nav-link">DB 에러로그</a>
                        </li>
                        <!-- 2022-11-28 -->
                        <li class="nav-item" id="ISTC_F5_URL_RTS" >
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_URL_RTS', this);"
                               class="nav-link">하향URL 관리</a>
                        </li>

                        <!-- 2022-11-28 -->
                        <li class="nav-item" id="ISTC_F5_SEND_RTS" >
                            <a href="javascript:void(0);" onclick="reloadFrame('ISTC_F5_SEND_RTS', this);"
                               class="nav-link">장비 설정
                            </a>
                        </li>
                        <!-- 2022-11-28 -->
                        <li class="nav-item" id="ISTC_F5_SEND_RTS_HISTORY" >
                            <a href="javascript:void(0);"
                               onclick="reloadFrame('ISTC_F5_SEND_RTS_HISTORY', this);" class="nav-link">명령
                                이력</a>
                        </li>
                    </ul>
                </li>
            
        </ul>

    </aside>
    <!-- 페이지 헤더 -->
    <div class="main-wrap">
        <header class="custom-header">
            <ul>
                <li>${user.getUserNm()}님</li>
                <li><a href="logout">로그아웃</a></li>
            </ul>
            <h6 class="header-user-name"></h6>
        </header>

        <div class="main-container" id="main-container">
            <div role="main" class="main-content">
                <!-- 주요 프레임 -->
                <iframe id="iframeBody" src="ISTC_F1" frameborder="0" scrolling="no" onload="handleLoginLoad()"></iframe>
            </div>
            <div class="footer-tools" hidden>
                <a href="#"
                   class="btn-scroll-up btn btn-green px-25 py-2 text-95 radius-1 mb-2 mr-2 scroll-btn-visible">
                    <i class="fa fa-angle-double-up w-2 h-2"></i>
                </a>
            </div>
        </div>
    </div>
    
    <!-- 수용가 종합정보 MODAL -->
    <%@ include file="ISTC_F0_MODAL.jsp" %>
    <!-- 수용가 종합정보 MODAL END-->
    
</div>

<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
<script type="text/javascript" src="${contextPath}/resources/page/p/js/istc-f0.js"></script>
</body>

</html>
