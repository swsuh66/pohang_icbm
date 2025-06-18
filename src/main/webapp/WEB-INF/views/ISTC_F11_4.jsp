<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<%@include file="/resources/inc/meta.inc" %>
		<title>스마트수도미터원격검침시스템</title>
		<!-- 화면명 : ISTC_F11_4-->
		<!-- 화면명 : 누수알림톡송신조회 -->

		<%@include file="/resources/inc/base.inc" %> <%@include file="/resources/inc/jsgrid.inc" %>

		<script type="text/javascript">
			var _animate = !AceApp.Util.isReducedMotion();

			var mainGrid;

			var dbParamsTb = 'f11-4';

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

				/* 날짜 초기 설정 */
				setInitDate();

				/* 엑셀다운도르를 위한 db 파람조회  */
				getDbtableInfo();

				/* grid 초기화 */
				mainGrid = initGrid('mainGrid');

				/* 수용가 조회 */
				mainGrid.search();
			});

			function updateColPos(cols, parentElement) {
				var left =
					$(parentElement + ' .jsgrid-grid-body').scrollLeft() <
					$(parentElement + ' .jsgrid-grid-body .jsgrid-table').width() - $(parentElement + ' .jsgrid-grid-body').width() + 16
						? $(parentElement + ' .jsgrid-grid-body').scrollLeft()
						: $(parentElement + ' .jsgrid-grid-body .jsgrid-table').width() - $(parentElement + ' .jsgrid-grid-body').width() + 16;
				$(
					parentElement +
						' .jsgrid-header-row th:nth-child(-n+' +
						cols +
						'),' +
						parentElement +
						' .jsgrid-filter-row td:nth-child(-n+' +
						cols +
						'),' +
						parentElement +
						' .jsgrid-insert-row td:nth-child(-n+' +
						cols +
						'),' +
						parentElement +
						' .jsgrid-grid-body tr td:nth-child(-n+' +
						(cols + 1) +
						')'
				).css({
					position: 'relative',
					left: left,
				});
			}

			/*
			 * 리소스 path
			 */
			function getContextPath() {
				return '${contextPath}';
			}

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
			}

			function setInitDate() {
				var dt = new Date(); // 오늘 날짜

				// 오늘 날짜를 yyyy-mm-dd 형식으로
				var endDate = kutil.dateFormat(dt, 'yyyy-mm-dd');

				// 한 달 전 날짜 계산
				dt.setMonth(dt.getMonth() - 1);
				var startDate = kutil.dateFormat(dt, 'yyyy-mm-dd');

				// DOM에 값 설정
				$('#startDate').val(startDate);
				$('#endDate').val(endDate);
			}

			/*
			 * 그리드 갱신
			 */
			function refreshGrid(data) {
				//mainGrid = initGrid('mainGrid');

				if (data) {
					mainGrid.finishLoad(data || []);
				} else {
					mainGrid.command('refresh');
				}

				$('.bcard.point-grid').aceWidget('stopLoading');

				var jsGrid = document.querySelector('#mainGrid .jsgrid-grid-body');

				// console.log(jsGrid);
				$(jsGrid).on('scroll', function (item) {
					//console.log("scroll");
					var element = '#' + $(item.target).parent().attr('id');
					// console.log(element);
					updateColPos(5, element);
				});
			}

			/*
			 * 그리드 컬럼 요소 리빌딩
			 */
			var fotmatDateTime = function (value) {
				if (!value || value.length < 14) return value;

				// 14자리 숫자면 yyyy-mm-dd hh:mm:ss 형식으로 변환
				return (
					value.substring(0, 4) +
					'-' +
					value.substring(4, 6) +
					'-' +
					value.substring(6, 8) +
					' ' +
					value.substring(8, 10) +
					':' +
					value.substring(10, 12) +
					':' +
					value.substring(12, 14)
				);
			};
			var colfnc = function (value, item, c, d, e) {
				switch (this.name) {
					case 'reg_dttm':
						return fotmatDateTime(value);
					case 'phone_num':
						return value && value.length > 0 ? value.replace(/(\d{3})(\d{3,4})(\d{4})/, '$1-$2-$3') : value;
				}

				return value == 0 || value ? value : '-';
			};

			/*
			 * 그리드 초기화
			 */
			function initGrid(container) {
				var fields = [
					{
						name: 'rownum',
						title: '순번',
						type: 'text',
						align: 'center',
						width: 46,
						itemTemplate: colfnc,
						sortingDisabled: true,
					},
					{
						name: 'tgt_nm',
						title: '수신자',
						type: 'text',
						align: 'left',
						width: 100,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'phone_num',
						title: '수신번호',
						type: 'text',
						align: 'left',
						width: 100,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'title',
						title: '제목',
						type: 'text',
						align: 'left',
						width: 160,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'msg_content',
						title: '내용',
						type: 'text',
						align: 'left',
						width: 250,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'reg_dttm',
						title: '발신일',
						type: 'text',
						align: 'left',
						width: 100,
						itemTemplate: colfnc,
						hasGroup: false,
					},
					{
						name: 'state_msg',
						title: '상태',
						type: 'text',
						align: 'left',
						width: 100,
						itemTemplate: colfnc,
						hasGroup: false,
					},
				];

				//fields = refactFields(fields);

				var opt = {
					height: '100%',
					width: '100%',
					sorting: true,

					pageLoading: true,
					paging: true,
					pageSize: 50,
					pageButtonCount: 5, // 페이지 버튼 개수
					pagerFormat: '{first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}',
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
						/*
						$('#infoModal', window.parent.document).modal('show'); //infoModal

						parent.loadModalData(false, evt.item);
						parent.loadChartData(false, evt.item);
						*/
					},
					onRefreshed: function (args) {
						$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
							$(args.grid._bodyGrid[0].rows[0].cells[i]).css('width', $(obj).css('width'));
						});
						$('table').colResizable({
							onResize: function () {
								$.each(args.grid._headerGrid[0].rows[0].cells, function (i, obj) {
									$(args.grid._bodyGrid[0].rows[0].cells[i]).css('width', $(obj).css('width'));
								});
							},
						});
					},
				};

				return new DataGrid(container, opt);
			}

			var groups = [
				{ title: '수전', columns: 3, align: 'center' },
				//	{title:'일간 검침값 (㎥)', 	columns: 30, align:"center"}
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

				if (useGparams) params = parent._params;
				else {
					if (item) {
						params.pointSq = item.pointSq;
						params.siteSq = item.siteSq;
					}
				}

				params.endDate = endDate;

				var begDate = kutil.addMonth(endDate, type == '0' ? -1 : -12);
				params.begDate = moment(Date.parse(begDate)).format('YYYY-MM-DD');

				loadPointData(params);

				type == '0' ? loadRawData('pointHisdataRaw', params) : loadRawData('pointHisdata', params);

				parent._params = params;
			}

			function loadRawData(qid, params) {
				/* 검침값 조회 */
				getAjax(
					qid,
					params,
					function () {
						$('#infoModal', window.parent.document).aceWidget('startLoading');
					},
					function (result) {
						parent.refreshModalMain(result);
					},
					null
				);
			}

			/* 로드 수용가 정보 */
			function loadPointData(params) {
				/* 수용가 조회 */
				getAjax(
					'mars.icbm.map1.pointList',
					params,
					null,
					function (result) {
						parent.updateValueFields(result);
					},
					null
				);
			}

			function makeParams() {
				var params = {};

				$.extend(params, mainGrid.loadParams());

				params.tgt_nm = $('#tgt_nm').val();
				params.phone_num = $('#phone_num').val();

				params.startDate = $('#startDate').val();
				params.endDate = $('#endDate').val();

				return params;
			}

			/* 메인 gird 로드  */
			function loadData() {
				const params = makeParams();
				//const queryString = new URLSearchParams(params).toString();
				const url = 'http://localhost:8088/api/v1/message/history';
				/* 알림톡 발신 리스트 조회 */
				getAjax(
					url,
					params,
					function () {
						/* 로딩 시작 */
						$('.bcard.point-grid').aceWidget('startLoading');
					},
					refreshGrid,
					null
				);
			}

			function getAjax(url, params, beforesend, callback, errCallback, async) {
				// console.log('getAjax', url);
				$.ajax({
					url: url,
					type: 'GET', // 또는 POST, PUT 등
					data: params, // POST일 경우엔 contentType에 따라 JSON.stringify(params)
					async: async !== undefined ? async : true,
					beforeSend: function () {
						if (beforesend) beforesend();
					},
					success: function (result) {
						//console.log('getAjax result', result);
						if (callback) callback(result);
					},
					error: function (error) {
						if (errCallback) errCallback(error);

						const msg = '외부 API 호출 실패<br>' + (error.responseText ? error.responseText.trim() : '서버 오류');
						jAlert.error('오류', msg);
					},
				});
			}

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
					},
				});
			}

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
					},
				});
			}

			function selectChange(url, key) {
				var params = {};

				$('#addr_2 option').remove(); //초기화
				var el = $('<option>').attr('value', '').text('전체');
				$('.componentsSelect[name="' + 'addr_2' + '"]').append(el);

				var addr_1 = $('#addr_1').val();
				if (addr_1 == null || addr_1 == '') {
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
					},
				});
			}

			function dataDownload() {
				if (!dbParams) {
					jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
					return;
				}

				var params = new Object();

				params.qid = null; // dbParams[dbParamsTb]['refer-sql'];
				params.url = 'http://localhost:8088/api/v1/message/history';
				params.colMapping = dbParams[dbParamsTb]['cols'];
				params.length = params.colMapping.length;

				params.downloadFileName = 'AlimTok_' + kutil.dateFormat(new Date(), 'yymmddHHMMss');

				var tParams = makeParams();
				tParams.pageIndex = null;
				tParams.pageSize = null;

				$.extend(params, tParams);

				alrimtokDownLoad(params, null, null, function () {
					jAlert.error('오류', '다운로드에 실패했습니다.');
				});
			}
		</script>
	</head>

	<body>
		<div role="main" class="sub-content">
			<%@ include file="ISTC_F11_4_CONTENT.jsp" %>

			<div class="dj-card">
				<div class="bcard point-grid" id="gridContainer">
					<div id="mainGrid" class="data-list containerBorder"></div>
				</div>
			</div>
		</div>

		<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
		<%--
		<script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script>
		--%>
	</body>
</html>
