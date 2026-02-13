<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<%@include file="/resources/inc/meta.inc"%>
		<title>스마트수도미터원격검침시스템</title>

		<%@include file="/resources/inc/base.inc"%> <%@include file="/resources/inc/jsgrid.inc"%> <%@include file="/resources/inc/hichart.inc"%> <%@include
		file="/resources/inc/validation.inc"%>

		<!-- 미량누수검출 ISTC_F11_3 -->
		<script type="text/javascript">
			var _animate = !AceApp.Util.isReducedMotion();

			var mainGrid;

			// 누수설정 모달 그리드
			var settingGrid;

			// 누수설정 수용가 제외 모달 그리드.
			var hideSettingGrid;

			// 누수 규칙 모달 그리드
			var ruleGrid;

			// 알림톡 전송 결과 그리드
			var alrimTokResultGrid;

			var dbParams;

			var dbParamsTb = 'f11-5-export';

			var pointListData;

		var alrimtokListData;

		var leakSetting;

		var stringByteLength;

		// 라벨 프린터 출력 관련 전역 변수
		var labelPrintDataWithHistory = [];
		var labelHistoryGrid;

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

				/*
				 * cookie manager 초기화
				 */
				cookie = new CookieManager();
				$('#stdDate').val(kutil.dateFormat(new Date(), 'yyyy-mm-dd'));
				$('#stdTime').val(kutil.dateFormat(new Date(), 'HH:MM:00'));

				settingGrid = initGrid('settingGrid', settingFields);
				hideSettingGrid = initGrid('hideSettingGrid', hideSettingFields);
				ruleGrid = initGrid('ruleGrid', ruleFields);

				mainGrid = initGrid('mainGrid', mainFields);

				// 발신 필드 헤더에 체크박스 추가 (전체 선택/해제)
				setupSendStatusHeaderCheckbox();

				// 알림톡 전송 결과 그리드 초기화
				alrimTokResultGrid = initAlrimTokResultGrid('alrimTokResultGrid', alrimTokResultFields);

				loadSettingData();

				loadHideSettingData();

				setSubmitValidation('settingForm', updateLeakSetting);

				setSubmitValidation('hideSettingForm', updateLeakHideSetting);

				loadComponent('select_pipe_diameter');

				loadComponent('select_business_name');

				mainGrid.search();

				/* 체크박스 클릭 이벤트 */
				$(document).on('click', 'input[name=receive_consent]', function () {
					var custSq = $(this).attr('data-custSq');
					var receive_consent = $(this).is(':checked') ? '1' : '0';

					var receive_consent_bool = receive_consent == '1' ? true : false;

					// pointListData에서 해당 항목 찾아서 receive_consent 업데이트
					if (pointListData && pointListData.length > 0) {
						var dataItem = pointListData.find(function (d) {
							return d.cust_sq == custSq || d.custSq == custSq;
						});
						if (dataItem) {
							dataItem.receive_consent = receive_consent_bool;
						}
					}

					var params = {};

					params['custSq'] = custSq;
					params['receive_consent'] = receive_consent_bool;

					getAjax(
						'mars.icbm.map1.updateReceiveConsent',
						params,
						false,
						function (result) {
							jAlert.info('정보', '저장 완료');
						},
						null
					);
				});
			});

			/*
			 * 리소스 path
			 */
			function getContextPath() {
				return '${contextPath}';
			}

			function getAbsolutepath(path) {
				return '${contextPath}/' + path;
			}

			function getUserRoll() {
				return '${user.getUserRoll()}';
			}

			/*
			 * 레이아웃 사이즈
			 */
			function layoutSize() {
				var ht1 = $(window).innerHeight();
				var off = $('#gridContainer').offset();

				if (off) {
					var ht = ht1 - off.top - 10;
					$('#gridContainer').height(ht);
				}
			}

			function modalGridLayout(modal, height) {
				modal.find('.jsgrid-grid-body').css('height', height + 'px');

				$(window).resize(function () {
					modal.find('.jsgrid-grid-body').css('height', height + 'px');
				});
			}

			function loadData(qid, params, callback) {
				var qid = qid ? qid : 'mars.icbm.map1.select_waterLeakList_page3';
				var params = params ? params : makeParams();

				/* 수용가 조회 */
				getAjax(
					qid,
					params,
					function () {
						/* 로딩 시작 */
						$('.bcard.point-grid').aceWidget('startLoading');
					},
					function (result) {
						if (callback) {
							$('.bcard.point-grid').aceWidget('stopLoading');
							callback(result);
							return;
						}

						pointListData = result;

						refreshGrid(mainGrid, result);

						// 그리드 새로고침 후 발신 헤더 체크박스 다시 설정
						setTimeout(function () {
							setupSendStatusHeaderCheckbox();
							updateSendStatusHeaderCheckbox();
						}, 100);

						$('.bcard.point-grid').aceWidget('stopLoading');
					},
					null
				);

				return false;
			}

			function loadRawData() {}

			function loadSites() {
				var obj = new Object();
				obj.upSiteSq = parent.getSiteSq();
				obj.noMaster = true;
				obj.lv = 1; //지자체 까지만

				/* 계량기 상태이상 데이터 조회 */
				getAjax(
					'mars.icbm.map1.sitesList',
					obj,
					function () {},
					function () {},
					null
				);
			}

			function loadSettingData(callback) {
				var params = new Object();
				$.extend(params, parent.searchComponentes);
				params.limit = 1;

				getAjax(
					'mars.icbm.map1.leakSetting2',
					params,
					null,
					function (result) {
						if (result.length > 0) {
							leakSetting = result[0];
							pushData(leakSetting);
							refreshGrid(settingGrid, result);
						} else {
							refreshGrid(settingGrid, []);
						}

						//if(result.length > 0) {
						//chartPriod = leakSetting.daysBefore;
						//}

						if (callback) callback();
					},
					null
				);

				return false;
			}

			function loadHideSettingData(callback) {
				var params = new Object();
				$.extend(params, parent.searchComponentes);

				getAjax(
					'mars.icbm.map1.leakHideSetting_List',
					params,
					null,
					function (result) {
						if (result.length > 0) {
							refreshGrid(hideSettingGrid, result);
						} else {
							refreshGrid(hideSettingGrid, []);
						}

						if (callback) callback();
					},
					null
				);
				return false;
			}

			function loadRuleData(callback) {
				var params = new Object();

				getAjax(
					'mars.icbm.map1.select_rule_waterleak',
					params,
					function () {
						$('.bcard .ruleGrid').aceWidget('startLoading');
					},
					function (result) {
						if (result.length > 0) {
							refreshGrid(ruleGrid, result);
						} else {
							refreshGrid(ruleGrid, []);
						}
						$('.bcard .ruleGrid').aceWidget('stopLoading');
						if (callback) callback();
					},
					null
				);
				return false;
			}

			function pushData(data) {
				var elList = $('#settingForm').find('input');

				$.each(elList, function (i, item) {
					var id = $(item).attr('id');
					if (id) {
						var value = data[id];
						$(item).val(value);
					}
				});
			}

			/*
			 * 그리드 갱신
			 */
			function refreshGrid(grid, data) {
				if (data) grid.finishLoad(data || []);
				//grid.command('refresh');
				else grid.command('refresh');
			}

			var colfnc = function (value, item, c, d, e) {
				switch (this.name) {
					case 'num':
						return (item.pageNo - 1) * item.pageSize + (c + 1);
					case 'blkNm':
						value = item.blkNm2;
						if (value && value.indexOf(':') >= 0) value = value.substr(value.indexOf(':') + 1);
						return value;
					case 'sendDt':
					case 'leakMeasDt':
					/*
			                 case 'measDt':
			                     if(!value)
			                         return '-';
			                     var dt = new Date(value);
			                     return '<small>' + kutil.dateFormat(dt, 'yy.mm.dd') +' </small> ' + kutil.dateFormat(dt, 'HH:MM');
			                 */
					case 'max_date':
					case 'min_date':
					case 'last_send_date':
					case 'leak_start_date':
					case 'max_term_cv_date':
					case 'min_term_cv_date':
						if (!value) return '-';
						var dt = new Date(value);
						return '' + kutil.dateFormat(dt, 'yyyy.mm.dd') + ' ' + kutil.dateFormat(dt, 'HH:MM');
					case 'stat_yn':
						if (value == 'Y') {
							return '계량기누수';
						} else {
							return '정상';
						}
					case 'remark':
						return callCheckTemplate(value, item, c);
					case 'receive_consent':
						var selected = item.receive_consent;
						var text = selected ? '동의' : '미동의';
						var color = selected ? 'blue' : 'red';
						return "<span style='color: " + color + "; font-weight: bold;'>" + text + '</span>';
					case 'send_status':
						// 기본으로 발신 체크박스는 선택되지 않음
						var checked = false;
						return (
							"<input type='checkbox' name='send_status' " + (checked ? 'checked' : '') + " class='cbox' data-custSq='" + (item.cust_sq || item.custSq || '') + "'/>"
						);
				}

				return value || value == 0 ? value : '-';
			};

			//통화여부
			function callCheckTemplate(value, item, c) {
				var $_returnData = $('<div>');
				var $_spanTxt = $('<span>').text(value);
				var $_inputTxt = $('<input>').attr('type', 'text').attr('maxlength', '100').css('width', '85%').val(value);
				var $_editBtn = $('<button>').addClass('jsgrid-button jsgrid-edit-button');
				var $_saveBtn = $('<button>').addClass('jsgrid-button jsgrid-update-button');
				var $_cancelBtn = $('<button>').addClass('jsgrid-button jsgrid-cancel-button');

				$_editBtn.on('click', function () {
					//수정 버튼 클릭
					return $_returnData.empty().append($_inputTxt, $_saveBtn, $_cancelBtn);
				});
				$_saveBtn.on('click', function () {
					//저장 버튼 클릭
					var params = {};
					params['custSq'] = item.cust_sq;
					params['remark'] = $_inputTxt.val();
					getAjax(
						'mars.icbm.map1.updateRemark',
						params,
						false,
						function (result) {
							mainGrid.search();
						},
						null
					);
				});
				$_cancelBtn.on('click', function () {
					//취소 버튼 클릭
					mainGrid.search();
				});

				return $_returnData.empty().append($_editBtn, $_spanTxt); //default
			}

			var colfncSMS = function (value, item, c, d, e) {
				switch (this.name) {
					case 'num':
						value = c + 1;
						break;
					case 'sendDt':
						if (!value) {
							value = '-';
							break;
						}

						var dt = new Date(value);
						value = '<small>' + kutil.dateFormat(dt, 'yy.mm.dd') + ' </small> ' + kutil.dateFormat(dt, 'HH:MM');
						break;
				}

				value = value ? value : '-';

				if (!item.custPhone) {
					value = '<span style="color:#ccc">' + value + '</span>';
				}

				return value;
			};

			var groups = [
				{ title: '구분', columns: 2, align: 'center' },
				{ title: '수용가', columns: 3, align: 'center' },
				{ title: '검침상태', columns: 2, align: 'center' },
				{ title: 'SMS', columns: 4, align: 'center' },
			];

			var smsFields = [
				{ name: 'num', title: '순번', type: 'text', align: 'center', width: 20, itemTemplate: colfncSMS, sortingDisabled: true },
				{ name: 'adminId', title: '수용가 번호', type: 'text', width: 50, itemTemplate: colfncSMS, sortingDisabled: true },
				{ name: 'custNm', title: '이름', type: 'text', width: 40, itemTemplate: colfncSMS, sortingDisabled: true },
				{ name: 'custPhone', title: '전화번호', type: 'text', width: 40, itemTemplate: colfncSMS, sortingDisabled: true },
				{ name: 'sendDt', title: '전송일', type: 'text', width: 40, itemTemplate: colfncSMS, sortingDisabled: true },
			];

			var rawFields = [
				{ name: 'measDt', title: '검침일시', type: 'text', align: 'center', width: 40, itemTemplate: colfnc, sortingDisabled: true },
				{ name: 'termCh', title: '사용량(㎥/h)', type: 'number', width: 50, itemTemplate: colfnc, sortingDisabled: true },
				{ name: 'accuIv', title: '최종지침(㎥)', type: 'number', align: 'right', width: 60, itemTemplate: colfnc, sortingDisabled: true },
			];

			var settingFields = [
				{ name: 'rownum', title: '순번', type: 'text', align: 'center', width: 60, sortingDisabled: true },
				{ name: 'pipe_diameter', title: '구경', type: 'text', align: 'center', width: 60, sortingDisabled: true },
				{ name: 'business_name', title: '업종', type: 'text', align: 'center', width: 60, sortingDisabled: true },
				{ name: 'compare_term_cv', title: '최소사용량', type: 'text', align: 'center', width: 60, sortingDisabled: true },
				{
					itemTemplate: function (_, item) {
						if (item.adminId) return;
						var iEl = $('<i>')
							.attr('data-site_sq', item.site_sq)
							.attr('data-business_name', item.business_name)
							.attr('data-pipe_diameter', item.pipe_diameter)
							.addClass('fa fa-trash');
						var aEl = $('<a>')
							.attr('href', '#none')
							.addClass('btn btn-outline-red btn-brc-tp radius-3px py-2')
							.append(iEl)
							.attr('data-site_sq', item.site_sq)
							.attr('data-business_name', item.business_name)
							.attr('data-pipe_diameter', item.pipe_diameter)
							.on('click', function (evt) {
								var el = $(evt.target);
								var site_sq = el.data('site_sq');
								var business_name = el.data('business_name');
								var pipe_diameter = el.data('pipe_diameter');
								var qid = 'mars.icbm.map1.deleteWaterLeak_List';

								var params = new Object();
								params.site_sq = String(site_sq);
								params.business_name = String(business_name);
								params.pipe_diameter = String(pipe_diameter);

								jAlert.confirm('알림', '단말을 삭제합니까?', function () {
									deleteAjax(
										qid,
										params,
										function () {
											$('.bcard .settingGrid').aceWidget('startLoading');
										},
										function (result) {
											jAlert.info('삭제', '삭제에 성공했습니다.');
											$('.bcard .settingGrid ').aceWidget('stopLoading');
											loadSettingData();
											//settingGrid.search();

											//$('button[name="closeBtn"]').click();
											var modal = $('#settingModal');

											modal.modal({ backdrop: 'static' });

											modalGridLayout(modal, 289);
										},
										null
									);
								});
							});

						return aEl;
					},
					align: 'center',
					width: 50,
					title: '단말삭제',
					hasGroup: false,
					//sortingDisabled:true
				},
			];

			var hideSettingFields = [
				{ name: 'rownum', title: '순번', type: 'text', align: 'center', width: 60, sortingDisabled: true },
				{ name: 'admin_no', title: '수용가번호', type: 'text', align: 'center', width: 60, sortingDisabled: true },
				{ name: 'ins_dt', title: '입력날짜', type: 'text', align: 'center', width: 60, sortingDisabled: true },
				{
					itemTemplate: function (_, item) {
						if (item.adminId) return;
						var iEl = $('<i>').attr('data-point_sq', item.point_sq).addClass('fa fa-trash');
						var aEl = $('<a>')
							.attr('href', '#none')
							.addClass('btn btn-outline-red btn-brc-tp radius-3px py-2')
							.append(iEl)
							.attr('data-point_sq', item.point_sq)
							.on('click', function (evt) {
								var el = $(evt.target);
								var point_sq = el.data('point_sq');
								var qid = 'mars.icbm.map1.deleteWaterLeak_Hide_List';

								var params = new Object();
								params.point_sq = String(point_sq);

								jAlert.confirm('알림', '수용가를 삭제합니까?', function () {
									deleteAjax(
										qid,
										params,
										function () {
											$('.bcard .settingGrid').aceWidget('startLoading');
										},
										function (result) {
											jAlert.info('삭제', '삭제에 성공했습니다.');
											$('.bcard .settingGrid ').aceWidget('stopLoading');
											loadHideSettingData();

											var modal = $('#hideSettingModal');

											modal.modal({ backdrop: 'static' });

											modalGridLayout(modal, 289);
										},
										null
									);
								});
							});
						return aEl;
					},
					align: 'center',
					width: 50,
					title: '수용가삭제',
					hasGroup: false,
					//sortingDisabled:true
				},
			];

			var ruleColfnc = function (value, item, c, d, e) {
				switch (this.name) {
					case 'rownum':
						return c + 1;
				}
				return value || value == 0 ? value : '-';
			};

			var ruleFields = [
				{ name: 'rownum', title: '순번', type: 'text', align: 'center', width: 60, itemTemplate: ruleColfnc, sortingDisabled: true },
				{ name: 'businessName', title: '업종', type: 'text', align: 'center', width: 120, sortingDisabled: true },
				{ name: 'pipeDiameter', title: '구경', type: 'text', align: 'center', width: 100, sortingDisabled: true },
				{ name: 'leakRule', title: '누수 규칙', type: 'text', align: 'right', width: 120, sortingDisabled: true },
			];

			var mainFields = [
				{ name: 'send_status', title: '발신', type: 'text', align: 'center', width: 40, itemTemplate: colfnc, hasGroup: false, sortingDisabled: true },
				{ name: 'num', title: '순번', type: 'text', align: 'center', width: 20, sortingDisabled: true },
				{ name: 'receive_consent', title: '수신동의', type: 'text', width: 30, itemTemplate: colfnc, hasGroup: false, sortingDisabled: true },
				{ name: 'last_send_date', title: '최종발신일', type: 'text', width: 60, itemTemplate: colfnc, hasGroup: false },
				{ name: 'admin_id', title: '수용가번호', type: 'text', width: 75, itemTemplate: colfnc, hasGroup: false },
				{ name: 'cust_nm', title: '수용가명', type: 'text', align: 'left', width: 40, itemTemplate: colfnc, hasGroup: false, group: groups[0] },
				{ name: 'leak_start_date', title: '누수시작일', type: 'text', width: 70, itemTemplate: colfnc, hasGroup: false },
				{ name: 'read_responsi', title: '검침원', type: 'text', width: 35, itemTemplate: colfnc, hasGroup: false },
				{ name: 'use_type', title: '업종', type: 'text', width: 40, itemTemplate: colfnc, hasGroup: false },
				{ name: 'pipe_dia', title: '구경', type: 'text', width: 20, itemTemplate: colfnc, hasGroup: false },
				{ name: 'leak_threshold', title: '기준값', type: 'text', width: 35, itemTemplate: colfnc, hasGroup: false },
				{ name: 'max_term_cv_date', title: '최고시간', type: 'text', width: 70, itemTemplate: colfnc, hasGroup: false },
				{ name: 'max_term_cv', title: '최고사용량', type: 'text', width: 45, itemTemplate: colfnc, hasGroup: false },
				{ name: 'min_term_cv_date', title: '최소시간', type: 'text', width: 70, itemTemplate: colfnc, hasGroup: false },
				{ name: 'min_term_cv', title: '최소사용량', type: 'text', width: 45, itemTemplate: colfnc, hasGroup: false },
				{ name: 'stat_yn', title: '누수여부', type: 'text', width: 40, itemTemplate: colfnc, hasGroup: false },
				{ name: 'cust_phone', title: '전화번호', type: 'text', width: 65, itemTemplate: colfnc, hasGroup: false },
				{ name: 'remark', title: '비고', type: 'text', width: 50, itemTemplate: colfnc, hasGroup: false },
			];

			// 알림톡 전송 결과 그리드 필드
			var alrimTokResultFields = [
				{ name: 'admin_id', title: '수용가번호', type: 'text', align: 'center', width: 100, itemTemplate: colfnc, sortingDisabled: true },
				{ name: 'cust_nm', title: '이름', type: 'text', align: 'center', width: 100, itemTemplate: colfnc, sortingDisabled: true },
				{ name: 'cust_phone', title: '전화번호', type: 'text', align: 'center', width: 100, itemTemplate: colfnc, sortingDisabled: true },
			];

			function initGrid(container, fields) {
				var opt = {
					height: '100%',
					width: '100%',
					sorting: true,

					pageLoading: true,
					paging: true,
					pageSize: 50,
					pageButtonCount: 5, // 페이지 버튼 개수
					pagerFormat: '{first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}',
					pagePrevText: '이전',
					pageNextText: '다음',
					pageFirstText: '처음',
					pageLastText: '마지막',

					rnTop: 50,
					rnBottom: 0,

					searchContainer: '#searchInput',

					fields: fields,

					loadStrategy: function () {
						if (container === 'ruleGrid') {
							return new CustomPageLoadingStrategy(this, loadRuleData);
						}
						return new CustomPageLoadingStrategy(this, loadData);
					},
					rowDoubleClick: function (evt) {
						if (container !== 'ruleGrid') {
							parent.loadModalData(false, evt.item);
							parent.loadChartData(false, evt.item);
						}
					},
				};

				return new DataGrid(container, opt);
			}

			// 알림톡 전송 결과 그리드 초기화 함수
			function initAlrimTokResultGrid(container, fields) {
				var opt = {
					height: '400px',
					width: '100%',
					sorting: false,
					pageLoading: false,
					paging: false,
					fields: fields,
					rowDoubleClick: function (evt) {},
					scrollBar: true, // 스크롤바 표시
				};

				return new DataGrid(container, opt);
			}

			// 발신 필드 헤더에 체크박스 추가 (전체 선택/해제)
			function setupSendStatusHeaderCheckbox() {
				// 그리드 헤더에서 발신 필드 찾기
				var $sendStatusHeader = $('#mainGrid th[name="send_status"]');

				if ($sendStatusHeader.length > 0) {
					// 기존 체크박스가 이미 있으면 제거하지 않고 이벤트만 재설정
					var $existingCheckbox = $sendStatusHeader.find('.send-status-header-checkbox');
					if ($existingCheckbox.length > 0) {
						$existingCheckbox.off('click'); // 기존 이벤트 제거
					} else {
						// 체크박스 생성
						var $checkbox = $('<input>').attr('type', 'checkbox').addClass('send-status-header-checkbox').css('cursor', 'pointer').css('margin-right', '5px');

						// 헤더 컨테이너를 중앙 정렬로 생성
						var $wrapper = $('<div>').css({
							'display': 'flex',
							'align-items': 'center',
							'justify-content': 'center',
							'width': '100%'
						}).append($checkbox).append('발신');

						// 헤더에 체크박스가 먼저, 그 다음 타이틀 표시
						$sendStatusHeader.empty().append($wrapper);
					}

					// 체크박스 참조 (기존 것이 있으면 그것을 사용)
					var $checkbox = $sendStatusHeader.find('.send-status-header-checkbox');

					// 클릭 이벤트 (정렬 방지)
					$checkbox.on('click', function (e) {
						e.stopPropagation(); // 정렬 이벤트 방지
						var isChecked = $(this).is(':checked');

						// 현재 페이지의 모든 발신 체크박스 선택/해제
						$('#mainGrid input[name="send_status"]').prop('checked', isChecked);

						// pointListData도 업데이트
						if (pointListData && pointListData.length > 0) {
							for (var i = 0; i < pointListData.length; i++) {
								pointListData[i].send_status = isChecked;
							}
						}
					});

					// 개별 체크박스 변경 시 헤더 체크박스 상태 업데이트
					$(document).on('change', '#mainGrid input[name="send_status"]', function () {
						updateSendStatusHeaderCheckbox();
					});
				}
			}

			// 발신 헤더 체크박스 상태 업데이트 (전체 선택 여부 확인)
			function updateSendStatusHeaderCheckbox() {
				var $headerCheckbox = $('#mainGrid .send-status-header-checkbox');
				var $allCheckboxes = $('#mainGrid input[name="send_status"]');
				var $checkedCheckboxes = $('#mainGrid input[name="send_status"]:checked');

				if ($allCheckboxes.length > 0) {
					// 모두 선택되어 있으면 체크, 아니면 해제
					$headerCheckbox.prop('checked', $allCheckboxes.length === $checkedCheckboxes.length);
				}
			}

			function openSettingModal() {
				var modal = $('#settingModal');

				modal.modal({ backdrop: 'static', keyboard: false });

				modalGridLayout(modal, 250);
			}

			function openHideSettingModal() {
				var modal = $('#hideSettingModal');

				modal.modal({ backdrop: 'static', keyboard: false });

				modalGridLayout(modal, 250);
			}

			function openRuleModal() {
				var modal = $('#ruleModal');

				modal.modal({ backdrop: 'static', keyboard: false });

				loadRuleData();

				modalGridLayout(modal, 289);
			}

			function openSMSModal(seq) {
				var display = function (data) {
					var modal = $('#smsModal');

					refreshGrid(smsGrid, data);

					$('#adminPhone').val(cookie.getCookie('callback_no'));

					$('#content').text(cookie.getCookie('content'));

					modal.modal({ backdrop: 'static', keyboard: false });

					smsTargetes = data;

					modalGridLayout(modal, 50);
				};

				if (seq == 0 || seq) {
					//특정 수용가 선택

					var data = [findObject(pointListData, 'pointSq', seq)];
					display(data);
				} else {
					// SMS일괄 전송

					var params = new Object();
					params.sendCd = '1';
					params.leakFg = '1';

					loadData('mars.icbm.map1.pointList', params, function (data) {
						if (data.length == 0) {
							jAlert.error('오류', '전송을 허용한 수용가가 없습니다.');
							return;
						}

						display(data);
					});
				}
			}

			function sendResult(data, status, xhr) {
				// console.log('sendResult', data, status, xhr);

				if (xhr.status == 200) {
					jAlert.info('알림', '누수알림톡 전송이 완료되었습니다.');
				} else {
					jAlert.error('오류', '누수알림톡 전송에 실패하였습니다.<br><br>' + (data.error ? data.error.statusText : '서버에서 오류가 발생하였습니다.'));
				}
			}
			/*
			let message =
				'귀댁의 수도 계량기 원격검침 데이터상, 72시간(3일) 동안 지속적인 물 사용량으로 누수가 의심되오니 아래 링크를 참조하여 자가진단 및 누수탐지 바랍니다.\n' +
				'누수가 맞다면 누수공사 완료 후, 감면대상 여부를 확인하고 공사일로부터 60일 이내에 누수감면 신청 바랍니다.\n\n' +
				'★ 자가진단 방법 및 옥내누수감면 안내 ★\n' +
				'https://www.pohang.go.kr/water/contents.do?mid=0302040000\n\n' +
				'수도요금안내>요금납부방법안내>요금감면맟할인제도>옥내누수요금감면(누수자가진단)\n\n' +
				'▶ 관련문의 : 054-270-5331 (평일 9시 ~ 18시)\n\n' +
				'- 포항시 상하수도행정과 요금팀 -';
			*/
			function sendAlrimTok(items) {
				const API_SEND = '<c:url value="/api/alrimtok/send"/>';

				// items가 전달되지 않은 경우 그리드에서 데이터 가져오기
				if (!items || items.length === 0) {
					// 그리드에서 데이터 가져오기
					var gridData = alrimTokResultGrid.jsGrid('option', 'data') || [];

					// 전화번호 형식
					const PHONE_RE = /^010-\d{4}-\d{4}$/;
					const hyphenize = (s) => {
						const digits = String(s || '').replace(/\D/g, '');
						if (digits.length === 11 && digits.startsWith('010')) {
							return digits.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
						}
						return s || '';
					};

					items = [];

					for (let i = 0; i < gridData.length; i++) {
						const row = gridData[i];

						const name = String(row.cust_nm || '').trim();
						let phone = String(row.cust_phone || '').trim();
						phone = PHONE_RE.test(phone) ? phone : hyphenize(phone);
						if (!PHONE_RE.test(phone)) continue; // 형식 불일치 스킵

						items.push({
							tgtNm: name,
							phoneNum: phone,
						});
					}
				}

				if (items.length === 0) {
					alert('전송할 대상이 없습니다. (전화번호 형식 확인)');
					return;
				}

				const sent_count = items.length;
				const success_message = '전송 대상 ' + sent_count + '건 전송 성공';
				// 컨트롤러 프록시를 통해 Node로 배열 그대로 전송
				ajaxPost(
					API_SEND,
					items,
					function (data, status, xhr) {
						if (xhr.status === 200) {
							const insertedList = data.insertIds || [];
							const normalizedItems = items.map((item) => ({
								...item,
								phoneNumNorm: item.phoneNum.replace(/-/g, ''),
							}));
							// console.log('Normalized sent data:', normalizedItems);
							const merged = normalizedItems.map((item) => {
								const match = insertedList.find((x) => x.phoneNum === item.phoneNumNorm && x.tgtNm === item.tgtNm);
								return {
									...item,
									insertId: match ? match.insertId : null,
								};
							});
							// console.log('Merged items with insertIds:', merged); -->

							saveAlrimTok(merged);
							alert(success_message);
						} else {
							alert('전송 실패: ' + (data.message || '알 수 없는 오류'));
						}
					},
					function (data, status, xhr) {
						if (xhr.status === 200) {
							alert(success_message);
						} else {
							alert('전송 실패: ' + (data.message || '알 수 없는 오류'));
						}
					}
				);
			}

			function saveAlrimTok(items) {
				if (!items || items.length === 0) {
					return;
				}

				// ajaxInsert를 사용하여 MyBatis insert 호출
				ajaxInsert({
					sql: 'mars.icbm.map1.insertAlrimtokHistory',
					data: items,
					async: true,
					success: function (result) {
						if (result && result.success) {
							return result;
						}
					},
					error: function (result) {
						// 저장 오류
					},
				});
			}

			function openAlrimTokPopup() {
				// 메인 그리드에서 발신 체크박스가 체크된 항목의 cust_sq 수집
				var checkedCustSqs = [];
				$('#mainGrid input[name="send_status"]:checked').each(function () {
					var custSq = $(this).data('custsq') || $(this).attr('data-custSq');
					if (custSq) {
						checkedCustSqs.push(String(custSq));
					}
				});

				// 발신 체크박스가 체크된 데이터만 필터링
				var filteredData = pointListData.filter(function (item) {
					var custSq = String(item.cust_sq || item.custSq || '');
					return checkedCustSqs.indexOf(custSq) !== -1;
				});

				// 알림톡 결과 그리드에 표시할 데이터 형식으로 변환
				alrimtokListData = filteredData.map(function (item, index) {
					return {
						admin_id: item.admin_id || '',
						cust_nm: item.cust_nm || '',
						cust_phone: item.cust_phone || '',
						send_status: item.receive_consent, // 수신동의 값 (boolean)
					};
				});

				// 그리드에 데이터 로드
				alrimTokResultGrid.finishLoad(alrimtokListData);

				// 전체 대상 개수 업데이트
				document.getElementById('alrimTokTotalCount').textContent = alrimtokListData.length;

				// 체크박스 클릭 이벤트 바인딩 (이벤트 위임)
				$('#alrimTokResultGrid')
					.off('change', '.alrimtok-send-checkbox')
					.on('change', '.alrimtok-send-checkbox', function () {
						var adminId = $(this).data('admin-id');
						var isChecked = $(this).is(':checked');

						// alrimtokListData에서 해당 항목 찾아서 send_status 업데이트
						var dataItem = alrimtokListData.find(function (d) {
							return d.admin_id === adminId;
						});
						if (dataItem) {
							dataItem.send_status = isChecked;
						}
					});

				// 팝업 표시
				document.getElementById('alrimTokPopup').style.display = 'block';
			}

			// 팝업 닫기
			function closeAlrimTokPopup() {
				document.getElementById('alrimTokPopup').style.display = 'none';
			}

			// 알림톡 전송 버튼 클릭 시 그리드 데이터를 가져와서 전송
			function handleSendAlrimTok() {
				// 전화번호 형식
				const PHONE_RE = /^010-\d{4}-\d{4}$/;
				const hyphenize = (s) => {
					const digits = String(s || '').replace(/\D/g, '');
					if (digits.length === 11 && digits.startsWith('010')) {
						return digits.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
					}
					return s || '';
				};

				var items = [];

				for (let i = 0; i < alrimtokListData.length; i++) {
					const row = alrimtokListData[i];

					// send_status가 true인 항목만 전송 대상에 포함
					if (!row.send_status) continue;

					const admin_id = String(row.admin_id || '').trim();
					const name = String(row.cust_nm || '').trim();
					let phone = String(row.cust_phone || '').trim(); // '010-5538-0452';
					phone = PHONE_RE.test(phone) ? phone : hyphenize(phone);
					if (!PHONE_RE.test(phone)) continue; // 형식 불일치 스킵

					items.push({
						admin_id: admin_id,
						tgtNm: name,
						phoneNum: phone,
					});
				}

				// alrimtokListData를 기반으로 변환된 items를 파라미터로 전달
				sendAlrimTok(items);
				closeAlrimTokPopup();
			}

			function confirmSendAlrimTok() {
				const name = document.getElementById('popupUserName').value.trim();
				const phone = document.getElementById('popupPhoneNum').value.trim();
				const phoneRegex = /^010-\d{4}-\d{4}$/; // 010-1234-5678 형식

				if (!name) {
					alert('사용자명을 입력하세요.');
					return;
				}
				if (!phoneRegex.test(phone)) {
					alert('전화번호는 010-1234-5678 형식으로 입력하세요.');
					return;
				}

				sendTestAlrimTok(name, phone);
				closeAlrimTokPopup();
			}

			function sendTestAlrimTok(name, phone) {
				const base = getContextPath();
				if (base && base.endsWith('/')) base = base.slice(0, -1);
				const url = base + '/api/alrimtok/test';

				ajaxPost(
					url,
					{ phoneNum: phone, tgtNm: name },
					function (data, status, xhr) {
						if (xhr.status === 200) {
							alert('테스트 전송 성공');
						} else {
							alert('전송 실패: ' + (data.message || '알 수 없는 오류'));
						}
					},
					function (data, status, xhr) {
						if (xhr.status === 200) {
							alert('테스트 전송 성공');
						} else {
							alert('전송 실패: ' + (data.message || '알 수 없는 오류'));
						}
					}
				);
			}

			function ajaxPost(url, params, callback) {
				//return;
				$.ajax({
					url: url,
					data: JSON.stringify(params),
					type: 'POST',
					contentType: 'application/json;charset=UTF-8',
					dataType: 'json',
					async: true,
					success: function (data, status, xhr) {
						if (callback) callback(data, status, xhr);
					},
					error: function (data, status, xhr) {
						if (callback) callback(data, status, xhr);
					},
				});
			}

			function makeParams() {
				var params = {};

				$.extend(params, mainGrid.loadParams());

				params['stdDate'] = $('#stdDate').val() + ' ' + $('#stdTime').val(); // 기준 일자.
				params['stdTime'] = $('#stdTime').val(); // 기준 일자.
				params['cust_sq'] = $('#cust_sq').val();
				params['cust_nm'] = $('#cust_nm').val();
				params['admin_no'] = $('#admin_no').val();
				params['pipe_diameter'] = $('#pipe_diameter').val();
				params['business_name'] = $('#business_name').val();
				params['compare_term_cv'] = $('#compare_term_cv').val();
				params['read_responsi'] = $('#read_responsi').val();
				params['cust_phone'] = $('#cust_phone').val();
				params['startDt'] = $('#startDt').val(); // 제외기간 시작일
				params['endDt'] = $('#endDt').val(); // 제외기간 종료일
				/*
				params['stdDate'] = '2025-07-28 00:00:00';
				params['stdTime'] = '00:00:00';
				params['cust_sq'] = $('#cust_sq').val();
				params['cust_nm'] = $('#cust_nm').val();
				params['admin_no'] = $('#admin_no').val();
				params['calc_hour'] = '72';
				params['pipe_diameter'] = $('#pipe_diameter').val();
				params['business_name'] = $('#business_name').val();
				params['compare_term_cv'] = '0.05'; //$('#compare_term_cv').val();
				params['read_responsi'] = $('#read_responsi').val();
				params['cust_phone'] = $('#cust_phone').val();
				*/
				return params;
			}

			function setSubmitValidation(id, fn) {
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
					submitHandler: function (e) {
						if (fn) fn(e);
					},
					rules: validate_util.rules,
					messages: validate_util.messages,
				});

				_form.submit(function () {
					_form.valid();
				});
			}

			function updateLeakSetting(e) {
				var params = new Object();
				//var inList = $(e).find('input');
				/*
			$.each(inList, function(i, item) {

				var id = $(item).attr('id');
				params[id] = Number($(item).val());

			});
			*/

				$.extend(params, parent.searchComponentes);
				params.pipe_diameter = $('#pipe_diameter').val();
				params.business_name = $('#business_name').val();
				params.calc_hour = $('#calc_hour').val();
				params.compare_term_cv = $('#compare_term_cv').val();

				var result = ajaxUpdate({ sql: 'mars.icbm.map1.insertWaterLeak_List', data: params });
				if (!result.success) {
					jAlert.error('저장', '정보를 저장하지 못하였습니다.<br><br>' + (result.error ? result.error.statusText : '서버에서 오류가 발생하였습니다.'));
					return false;
				}

				jAlert.info('저장', '수정한 정보를 저장 완료하였습니다.');

				loadSettingData(function () {
					mainGrid.search();
				});

				var modal = $('#settingModal');

				modal.modal({ backdrop: 'static' });

				modalGridLayout(modal, 289);

				//$('button[name="closeBtn"]').click();

				return true;
			}

			// 수용가 제외 셋팅
			function updateLeakHideSetting() {
				var params = new Object();

				$.extend(params, parent.searchComponentes);
				params.admin_no = $('#modal_admin_no').val();

				var result = ajaxUpdate({ sql: 'mars.icbm.map1.insertWaterLeak_hide_List', data: params });
				if (!result.success) {
					jAlert.error('저장', '정보를 저장하지 못하였습니다.<br><br>' + (result.error ? result.error.statusText : '서버에서 오류가 발생하였습니다.'));
					return false;
				}

				jAlert.info('저장', '수정한 정보를 저장 완료하였습니다.');

				loadHideSettingData(function () {
					mainGrid.search();
				});

				var modal = $('#hideSettingModal');

				modal.modal({ backdrop: 'static' });

				modalGridLayout(modal, 289);

				return true;
			}

			function findObject(list, key, value) {
				var result;
				list.some(function (item) {
					if (item[key] && item[key] == value) {
						result = item;
						return true;
					}
				});

				return result;
			}

			function refreshChart(id, data1, data2) {}

			function setTimer(data) {}

			function saveTimer() {}

			function updateSiteItems(data) {}

			function getAjax(qid, params, beforesend, callback, errCallback, async) {
				ajaxSelect({
					sql: qid,
					data: params,
					async: async ? async : true,
					beforeSend: function () {
						if (beforesend) beforesend();
					},
					success: function (result) {
						if (callback) callback(result);
					},
					error: function (error) {
						if (error.status == 401) {
							parent.document.location.reload();
							return;
						}

						if (errCallback) errCallback(error);

						refreshGrid([]);

						var msg = '데이터를 읽을 수 없습니다.<br>';
						msg += error.responseText ? error.responseText.trim() : '서버에 오류가 있습니다.';

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

			function dataDownload() {
				if (!dbParams) {
					jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
					return;
				}
				var params = new Object();

				params.qid = dbParams[dbParamsTb]['refer-sql'];
				params.colMapping = dbParams[dbParamsTb]['cols'];
				params.length = params.colMapping.length;

				params.downloadFileName = 'WaterMinLeak_' + kutil.dateFormat(new Date(), 'yymmddHHMMss');
				$.extend(params, makeParams());

				templetDownLoadStream(params, null, null, function () {
					jAlert.error('오류', '다운로드에 실패했습니다.');
				});
			}

			/* 단말번호 검색을 위한 스크립트 */
			function selectChangHandler(el) {
				var searchOption = $(el).val();
				var target = $('#' + $(el).data('target'));
				var plh;

				plh = searchOption == 0 ? '수용가 번호/이름/주소 ...' : '단말기 번호/미터기 번호 ...';

				target.attr('placeholder', plh);
			}

			// 2023.12.11 김용희 추가
			/*
			 * 각 요소 조회
			 */
			function loadComponent(qid) {
				var obj = new Object();
				/* 계량기 상태이상 데이터 조회 */
				getAjax(qid, obj, function () {}, refreshComponent, null, null);
			}

			function refreshComponent(result, bCallback) {
				// console.log('refreshComponent: ', result);
				if (result.length !== 0) {
					var key = result[0].key;
					var $select = $('.form-control[name="' + key + '"]');
					$select.empty(); // 기존 옵션 제거

					// "전체" 옵션 추가
					var el = $('<option>').attr('value', '').text('전체');
					$select.append(el);

					result.forEach(function (item, idx) {
						var el = $('<option>').attr('value', item.val).text(item.val);
						$select.append(el);
					});

					//// 구경값만  15로 설정
					//if (key == 2 && result.length > 1) {
					//	$select.val(result[0].val);
					//}
				}
			}

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
						msg += error.responseText ? error.responseText.trim() : '서버에 오류가 있습니다.';

						jAlert.error('오류', msg);
					},
				});
			}

			function deleteAjax(qid, params, beforesend, callback, errCallback, async) {
				ajaxDelete({
					sql: qid,
					data: params,
					async: async ? async : true,
					beforeSend: function () {
						if (beforesend) beforesend();
					},
					success: function (result) {
						if (callback) callback(result);
					},
					error: function (result) {
						if (errCallback) errCallback(error);

						var msg = '삭제 오류.<br>';
						msg += error.responseText ? error.responseText.trim() : '서버에 오류가 있습니다.';

						jAlert.error('오류', msg);
					},
				});
			}

			const leakStandards = [
				{ type: '가정용', diameter: 15, flow: 0.1 },
				{ type: '가정용', diameter: 20, flow: 0.156 },
				{ type: '가정용', diameter: 25, flow: 0.25 },
				{ type: '가정용', diameter: 30, flow: 0.394 },
				{ type: '가정용', diameter: 40, flow: 0.625 },
				{ type: '가정용', diameter: 50, flow: 1.0 },
				{ type: '가정용', diameter: 80, flow: 6.25 },
				{ type: '가정용', diameter: 100, flow: 10.0 },
				{ type: '가정용', diameter: 150, flow: 15.625 },
				{ type: '가정용', diameter: 200, flow: 25.0 },
				{ type: '가정용', diameter: 250, flow: 39.375 },
				{ type: '가정용', diameter: 300, flow: 62.5 },

				{ type: '일반용', diameter: 15, flow: 0.1 },
				{ type: '일반용', diameter: 20, flow: 0.156 },
				{ type: '일반용', diameter: 25, flow: 0.25 },
				{ type: '일반용', diameter: 30, flow: 0.394 },
				{ type: '일반용', diameter: 40, flow: 0.625 },
				{ type: '일반용', diameter: 50, flow: 1.0 },
				{ type: '일반용', diameter: 80, flow: 6.25 },
				{ type: '일반용', diameter: 100, flow: 10.0 },
				{ type: '일반용', diameter: 150, flow: 15.625 },
				{ type: '일반용', diameter: 200, flow: 25.0 },
				{ type: '일반용', diameter: 250, flow: 39.375 },
				{ type: '일반용', diameter: 300, flow: 62.5 },

				{ type: '일반용1', diameter: 15, flow: 0.1 },
				{ type: '일반용1', diameter: 20, flow: 0.156 },
				{ type: '일반용1', diameter: 25, flow: 0.25 },
				{ type: '일반용1', diameter: 30, flow: 0.394 },
				{ type: '일반용1', diameter: 40, flow: 0.625 },
				{ type: '일반용1', diameter: 50, flow: 1.0 },
				{ type: '일반용1', diameter: 80, flow: 6.25 },
				{ type: '일반용1', diameter: 100, flow: 10.0 },
				{ type: '일반용1', diameter: 150, flow: 15.625 },
				{ type: '일반용1', diameter: 200, flow: 25.0 },
				{ type: '일반용1', diameter: 250, flow: 39.375 },
				{ type: '일반용1', diameter: 300, flow: 62.5 },

				{ type: '일반겸업', diameter: 15, flow: 0.1 },
				{ type: '일반겸업', diameter: 20, flow: 0.156 },
				{ type: '일반겸업', diameter: 25, flow: 0.25 },
				{ type: '일반겸업', diameter: 30, flow: 0.394 },
				{ type: '일반겸업', diameter: 40, flow: 0.625 },
				{ type: '일반겸업', diameter: 50, flow: 1.0 },
				{ type: '일반겸업', diameter: 80, flow: 6.25 },
				{ type: '일반겸업', diameter: 100, flow: 10.0 },
				{ type: '일반겸업', diameter: 150, flow: 15.625 },
				{ type: '일반겸업', diameter: 200, flow: 25.0 },
				{ type: '일반겸업', diameter: 250, flow: 39.375 },
				{ type: '일반겸업', diameter: 300, flow: 62.5 },

				{ type: '공업용', diameter: 20, flow: 0.156 },
				{ type: '공업용', diameter: 25, flow: 0.25 },
				{ type: '공업용', diameter: 30, flow: 0.394 },
				{ type: '공업용', diameter: 40, flow: 0.625 },
				{ type: '공업용', diameter: 50, flow: 1.0 },
				{ type: '공업용', diameter: 80, flow: 6.25 },
				{ type: '공업용', diameter: 100, flow: 10.0 },
				{ type: '공업용', diameter: 150, flow: 15.625 },
				{ type: '공업용', diameter: 200, flow: 25.0 },
				{ type: '공업용', diameter: 250, flow: 39.375 },
				{ type: '공업용', diameter: 300, flow: 62.5 },

				{ type: '대중탕용', diameter: 15, flow: 0.1 },
				{ type: '대중탕용', diameter: 20, flow: 0.156 },
				{ type: '대중탕용', diameter: 25, flow: 0.25 },
				{ type: '대중탕용', diameter: 30, flow: 0.394 },
				{ type: '대중탕용', diameter: 40, flow: 0.625 },
				{ type: '대중탕용', diameter: 50, flow: 1.0 },
				{ type: '대중탕용', diameter: 80, flow: 6.25 },
				{ type: '대중탕용', diameter: 100, flow: 10.0 },
				{ type: '대중탕용', diameter: 150, flow: 15.625 },
				{ type: '대중탕용', diameter: 200, flow: 25.0 },
				{ type: '대중탕용', diameter: 250, flow: 39.375 },
				{ type: '대중탕용', diameter: 300, flow: 62.5 },

				{ type: '기타', diameter: 15, flow: 0.1 },
				{ type: '기타', diameter: 20, flow: 0.156 },
				{ type: '기타', diameter: 25, flow: 0.25 },
				{ type: '기타', diameter: 30, flow: 0.394 },
				{ type: '기타', diameter: 40, flow: 0.625 },
				{ type: '기타', diameter: 50, flow: 1.0 },
				{ type: '기타', diameter: 80, flow: 6.25 },
				{ type: '기타', diameter: 100, flow: 10.0 },
				{ type: '기타', diameter: 150, flow: 15.625 },
				{ type: '기타', diameter: 200, flow: 25.0 },
				{ type: '기타', diameter: 250, flow: 39.375 },
				{ type: '기타', diameter: 300, flow: 62.5 },
			];

			// 기준유량 조회 함수
			function getStandardFlow(type, diameter) {
				const item = leakStandards.find((entry) => entry.type === type && entry.diameter === diameter);
				return item ? item.flow : null;
			}

			function onSelectionChange() {
				const type = document.getElementById('business_name').value;
				const diameter = parseInt(document.getElementById('pipe_diameter').value);

				//console.log('Selected type:', type);
				//console.log('Selected diameter:', diameter);

				const match = leakStandards.find((entry) => entry.type === type && entry.diameter === diameter);
				//console.log('Matching entry:', match);
				const resultEl = document.getElementById('compare_term_cv');
				if (match) {
					resultEl.value = match.flow.toString();
				} else {
					resultEl.value = '0.05';
				}
			}

		// 프린트 페이지 열기
		function openPrintPage() {
			// pointListData에서 프린트할 데이터 추출 (zipcode, 수용가명, 주소)
			if (!pointListData || pointListData.length === 0) {
				alert('프린트할 데이터가 없습니다.');
				return;
			}

			// 수신동의 미동의 데이터만 필터링
			var printData = [];
			for (var i = 0; i < pointListData.length; i++) {
				var item = pointListData[i];

				// 수신동의 확인 (미동의인 경우만 포함)
				var receiveConsent = item.receive_consent;

				// 수신동의가 미동의인 경우만 추가
				if (receiveConsent !== true) {
					// zipcode 추출 (빈 문자열이면 null로 설정)
					var zipCodeValue = item.zipcode || item.zipCode || null;
					if (zipCodeValue === '' || zipCodeValue === 'null' || zipCodeValue === '123-123') {
						zipCodeValue = null;
					}

					printData.push({
						admin_no: item.admin_id || '',
						zipCode: zipCodeValue,
						custName: item.cust_nm || item.custName || '',
						addr: item.addr_new || item.addrNew || item.addr_old || item.addrOld || '',
					});
				}
			}

			// 필터링된 데이터가 없으면 알림
			if (printData.length === 0) {
				alert('수신 미동의 데이터가 없습니다.');
				return;
			}

			// 출력 이력 조회 후 확인 팝업 표시
			loadPrintHistoryAndShowConfirm(printData);
		}

		// 출력 이력 조회 후 확인 팝업 표시
		function loadPrintHistoryAndShowConfirm(printData) {
			// 수용가번호 목록 추출
			var adminNos = printData.map(function(item) {
				return item.admin_no;
			}).filter(function(no) {
				return no && no.trim() !== '';
			});

			// 데이터 초기화 (이력 없이)
			var initializeWithoutHistory = function() {
				labelPrintDataWithHistory = printData.map(function(item) {
					return {
						admin_no: item.admin_no,
						zipCode: item.zipCode,
						custName: item.custName,
						addr: item.addr,
						print_count: 0,
						last_print_dt: null,
						selected: true
					};
				});
				showLabelPrintConfirmPopup();
			};

			if (adminNos.length === 0) {
				initializeWithoutHistory();
				return;
			}

			// 출력 이력 조회
			try {
				getAjax(
					'mars.icbm.map1.selectLabelPrintHistoryByAdminNos',
					{ admin_nos: adminNos },
					null,
					function(historyData) {
						// 이력 데이터를 Map으로 변환
						var historyMap = {};
						if (historyData && historyData.length > 0) {
							historyData.forEach(function(item) {
								historyMap[item.admin_no] = item;
							});
						}

						// printData에 이력 정보 병합
						labelPrintDataWithHistory = printData.map(function(item) {
							var history = historyMap[item.admin_no];
							return {
								admin_no: item.admin_no,
								zipCode: item.zipCode,
								custName: item.custName,
								addr: item.addr,
								print_count: history ? history.print_count : 0,
								last_print_dt: history ? history.last_print_dt : null,
								selected: true  // 기본 선택
							};
						});

						// 확인 팝업 표시
						showLabelPrintConfirmPopup();
					},
					function(error) {
						// 에러 발생 시에도 팝업은 표시
						initializeWithoutHistory();
					}
				);
			} catch(e) {
				// 예외 발생 시에도 팝업은 표시
				initializeWithoutHistory();
			}
		}

		// 출력 확인 팝업 표시
		function showLabelPrintConfirmPopup() {
			var totalCount = labelPrintDataWithHistory.length;
			var newCount = labelPrintDataWithHistory.filter(function(item) {
				return item.print_count === 0;
			}).length;
			var reprintCount = totalCount - newCount;

			// 통계 정보 업데이트
			document.getElementById('totalPrintCount').textContent = totalCount;
			document.getElementById('newPrintCount').textContent = newCount;
			document.getElementById('reprintCount').textContent = reprintCount;
			updateSelectedCount();

			// 테이블 생성
			var tbody = document.getElementById('labelPrintTableBody');
			tbody.innerHTML = '';

			labelPrintDataWithHistory.forEach(function(item, index) {
				var tr = document.createElement('tr');
				tr.style.borderBottom = '1px solid #dee2e6';
				
				// 재출력인 경우 배경색 변경
				if (item.print_count > 0) {
					tr.style.background = '#fff3cd';
				}

				var lastPrintDtStr = '-';
				if (item.last_print_dt) {
					var dt = new Date(item.last_print_dt);
					lastPrintDtStr = kutil.dateFormat(dt, 'yyyy-mm-dd HH:MM');
				}

				var printCountStr = item.print_count === 0 
					? '<span style="color: #28a745; font-weight: bold;">신규</span>'
					: '<span style="color: #dc3545; font-weight: bold;">' + item.print_count + '회</span>';

				tr.innerHTML = 
					'<td style="padding: 10px; text-align: center;">' +
						'<input type="checkbox" class="print-item-checkbox" data-index="' + index + '" ' + 
						(item.selected ? 'checked' : '') + '/>' +
					'</td>' +
					'<td style="padding: 10px; text-align: center;">' + (item.admin_no || '-') + '</td>' +
					'<td style="padding: 10px; text-align: center;">' + (item.custName || '-') + '</td>' +
					'<td style="padding: 10px; text-align: left; font-size: 12px;">' + (item.addr || '-') + '</td>' +
					'<td style="padding: 10px; text-align: center;">' + printCountStr + '</td>' +
					'<td style="padding: 10px; text-align: center; font-size: 12px;">' + lastPrintDtStr + '</td>';

				tbody.appendChild(tr);
			});

			// 체크박스 이벤트 바인딩
			$('.print-item-checkbox').on('change', function() {
				var index = $(this).data('index');
				labelPrintDataWithHistory[index].selected = $(this).is(':checked');
				updateSelectedCount();
			});

			// 전체 선택 체크박스 이벤트
			$('#selectAllPrintItems').off('change').on('change', function() {
				var isChecked = $(this).is(':checked');
				$('.print-item-checkbox').prop('checked', isChecked);
				labelPrintDataWithHistory.forEach(function(item) {
					item.selected = isChecked;
				});
				updateSelectedCount();
			});

			// 팝업 표시
			document.getElementById('labelPrintConfirmPopup').style.display = 'block';
		}

		// 선택된 항목 수 업데이트
		function updateSelectedCount() {
			var selectedCount = labelPrintDataWithHistory.filter(function(item) {
				return item.selected;
			}).length;
			document.getElementById('selectedPrintCount').textContent = selectedCount;
		}

		// 재출력 항목 제외
		function excludeReprints() {
			labelPrintDataWithHistory.forEach(function(item, index) {
				if (item.print_count > 0) {
					item.selected = false;
					$('.print-item-checkbox[data-index="' + index + '"]').prop('checked', false);
				}
			});
			updateSelectedCount();
		}

		// 출력 확인
		function confirmLabelPrint() {
			var selectedItems = labelPrintDataWithHistory.filter(function(item) {
				return item.selected;
			});

			if (selectedItems.length === 0) {
				alert('출력할 항목을 선택해주세요.');
				return;
			}

			// 팝업 닫기
			closeLabelPrintConfirmPopup();

			// 실제 출력 (인쇄 페이지 열기)
			var form = document.createElement('form');
			form.method = 'POST';
			form.action = getContextPath() + '/ISTC_F11_PRINT';
			form.target = '_blank';

			var dataInput = document.createElement('input');
			dataInput.type = 'hidden';
			dataInput.name = 'printData';
			dataInput.value = JSON.stringify(selectedItems);
			form.appendChild(dataInput);

			document.body.appendChild(form);
			form.submit();
			document.body.removeChild(form);
		}

		// 팝업 닫기
		function closeLabelPrintConfirmPopup() {
			document.getElementById('labelPrintConfirmPopup').style.display = 'none';
		}

		// 라벨 출력 이력 저장 (인쇄 페이지에서 호출)
		function saveLabelPrintHistory(printData) {
			if (!printData || printData.length === 0) {
				return;
			}

			try {
				var items = printData.map(function(item) {
					return {
						admin_no: item.admin_no,
						cust_name: item.custName || item.cust_name,
						zipcode: item.zipCode || item.zipcode,
						addr: item.addr
					};
				});

				items.forEach(function(item) {
					if (!item.admin_no) {
						return;
					}

					$.ajax({
						url: getContextPath() + '/api/suspected-leaks/save-label-print-history',
						type: 'POST',
						contentType: 'application/json; charset=UTF-8',
						data: JSON.stringify(item),
					async: false,
					success: function(response) {
						// 저장 성공
					},
					error: function(xhr, status, error) {
						// 저장 실패
					}
				});
			});
		} catch(e) {
			// 저장 오류
		}
		}
		</script>

		<style type="text/css"></style>
	</head>

	<body>
		<div role="main" class="sub-content">
			<%@ include file="ISTC_F11_5_CONTENT.jsp" %>
			<div class="sub-cont-header">
				<h1></h1>
				<div class="sub-cont-header-area"></div>
			</div>
			<div class="dj-card">
				<div class="bcard card point-grid">
					<div class="card-body p-0" id="gridContainer">
						<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%"></div>
					</div>
				</div>
			</div>
		</div>

		<!-- 알림톡 모달 팝업 -->
		<div id="alrimTokPopup" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.6); z-index: 1000">
			<div
				style="
					background: #fff;
					width: 700px;
					max-width: 90%;
					margin: 150px auto;
					padding: 25px 20px;
					border-radius: 12px;
					box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
					font-family: 'Segoe UI', sans-serif;
					animation: fadeIn 0.3s;
					position: relative;
				"
			>
				<button
					onclick="closeAlrimTokPopup()"
					style="
						position: absolute;
						top: 10px;
						right: 10px;
						width: 32px;
						height: 32px;
						background: #f5f5f5;
						border: none;
						border-radius: 50%;
						cursor: pointer;
						font-size: 20px;
						font-weight: bold;
						color: #666;
						display: flex;
						align-items: center;
						justify-content: center;
						transition: all 0.2s ease;
						z-index: 10;
					"
					onmouseover="this.style.background='#e0e0e0'; this.style.color='#333';"
					onmouseout="this.style.background='#f5f5f5'; this.style.color='#666';"
					title="닫기"
				>
					×
				</button>
				<div style="border: 1px solid #ccc; margin-top: 10px; padding: 10px; padding-top: 20px">
					<div style="margin-bottom: 10px; font-size: 16px; font-weight: bold; color: #333; text-align: left">전체 대상 : <span id="alrimTokTotalCount">0</span>명</div>
					<div id="alrimTokResultGrid" class="data-list containerBorder" style="width: 100%; height: 400px"></div>
				</div>
				<button
					onclick="handleSendAlrimTok()"
					style="
						width: 100%;
						min-height: 60px;
						font-size: 20px;
						font-weight: bold;
						padding: 14px 20px;
						background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
						color: #ffffff;
						border: none;
						border-radius: 8px;
						cursor: pointer;
						box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
						transition: all 0.3s ease;
						text-align: center;
						display: block;
						margin-top: 10px;
					"
					onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 20px rgba(102, 126, 234, 0.6)';"
					onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 15px rgba(102, 126, 234, 0.4)';"
					onmousedown="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 10px rgba(102, 126, 234, 0.3)';"
					onmouseup="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 20px rgba(102, 126, 234, 0.6)';"
				>
					알림톡 전송
				</button>
			</div>
		</div>

		<!-- 라벨 출력 확인 팝업 -->
		<div id="labelPrintConfirmPopup" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.6); z-index: 1000">
			<div style="
				background: #fff;
				width: 900px;
				max-width: 95%;
				max-height: 90vh;
				margin: 40px auto;
				padding: 25px;
				border-radius: 12px;
				box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
				overflow-y: auto;
			">
				<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
					<h3 style="margin: 0; color: #333;">
						<i class="fa fa-print"></i> 라벨 출력 확인
					</h3>
					<button onclick="closeLabelPrintConfirmPopup()" style="
						background: #f5f5f5;
						border: none;
						border-radius: 50%;
						width: 32px;
						height: 32px;
						cursor: pointer;
						font-size: 20px;
						font-weight: bold;
						color: #666;
					">×</button>
				</div>

				<!-- 통계 정보 -->
				<div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
					<div style="display: flex; justify-content: space-around; text-align: center;">
						<div>
							<div style="font-size: 24px; font-weight: bold; color: #007bff;" id="totalPrintCount">0</div>
							<div style="font-size: 14px; color: #666;">전체 대상</div>
						</div>
						<div>
							<div style="font-size: 24px; font-weight: bold; color: #28a745;" id="newPrintCount">0</div>
							<div style="font-size: 14px; color: #666;">신규 출력</div>
						</div>
						<div>
							<div style="font-size: 24px; font-weight: bold; color: #dc3545;" id="reprintCount">0</div>
							<div style="font-size: 14px; color: #666;">재출력</div>
						</div>
						<div>
							<div style="font-size: 24px; font-weight: bold; color: #6c757d;" id="selectedPrintCount">0</div>
							<div style="font-size: 14px; color: #666;">선택된 항목</div>
						</div>
					</div>
				</div>

				<!-- 전체 선택 -->
				<div style="margin-bottom: 15px; padding: 10px; background: #e9ecef; border-radius: 5px;">
					<label style="margin: 0; cursor: pointer; font-weight: bold;">
						<input type="checkbox" id="selectAllPrintItems" checked style="margin-right: 8px;"/>
						전체 선택/해제
					</label>
					<button onclick="excludeReprints()" style="
						float: right;
						background: #ffc107;
						border: none;
						padding: 5px 15px;
						border-radius: 5px;
						cursor: pointer;
						font-weight: bold;
					">
						재출력 항목 제외
					</button>
				</div>

				<!-- 출력 목록 테이블 -->
				<div style="max-height: 400px; overflow-y: auto; border: 1px solid #dee2e6; border-radius: 5px;">
					<table id="labelPrintTable" style="width: 100%; border-collapse: collapse;">
						<thead style="position: sticky; top: 0; background: #f8f9fa; z-index: 10;">
							<tr>
								<th style="padding: 10px; border-bottom: 2px solid #dee2e6; text-align: center; width: 50px;">선택</th>
								<th style="padding: 10px; border-bottom: 2px solid #dee2e6; text-align: center; width: 80px;">수용가번호</th>
								<th style="padding: 10px; border-bottom: 2px solid #dee2e6; text-align: center; width: 80px;">고객명</th>
								<th style="padding: 10px; border-bottom: 2px solid #dee2e6; text-align: left;">주소</th>
								<th style="padding: 10px; border-bottom: 2px solid #dee2e6; text-align: center; width: 80px;">출력횟수</th>
								<th style="padding: 10px; border-bottom: 2px solid #dee2e6; text-align: center; width: 130px;">마지막 출력일</th>
							</tr>
						</thead>
						<tbody id="labelPrintTableBody">
							<!-- 동적으로 생성 -->
						</tbody>
					</table>
				</div>

				<!-- 버튼 영역 -->
				<div style="margin-top: 20px; text-align: center;">
					<button onclick="confirmLabelPrint()" style="
						background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
						color: white;
						border: none;
						padding: 15px 40px;
						font-size: 18px;
						font-weight: bold;
						border-radius: 8px;
						cursor: pointer;
						box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
					">
						<i class="fa fa-print"></i> 선택 항목 출력
					</button>
					<button onclick="closeLabelPrintConfirmPopup()" style="
						background: #6c757d;
						color: white;
						border: none;
						padding: 15px 40px;
						font-size: 18px;
						font-weight: bold;
						border-radius: 8px;
						cursor: pointer;
						margin-left: 10px;
					">
						취소
					</button>
				</div>
			</div>
		</div>

		<div class="modal fade" id="hideSettingModal" tabindex="-1" role="dialog">
			<div class="modal-dialog modal-dialog-scrollable modal-dialog-centered" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="exampleModalLabel2">제외 수용가 설정</h5>

						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>

					<form id="hideSettingForm" class="mt-lg-3 validator" autocomplete="off" data-toggle="validator" role="form">
						<div class="modal-body">
							<div class="bcard ccard overflow-hidden settingGrid">
								<div class="card-header border-0 bgc-white card-header-sm">
									<h6 class="card-title text-dark-m3 pl-25 pt-15 text-110">
										사용자 설정 <br />
										<span class="text-85 text-dark-l2"></span>
									</h6>
								</div>
								<div class="modal-body">
									<div class="form-group row">
										<div class="col-sm-12">
											<div class="form-group row">
												<div class="col-sm-2 col-form-label text-sm-right pr-0">
													<label class="mb-0" for="calc_hour">수용가 입력</label>
												</div>
												<div class="col-sm-8">
													<input type="text" id="modal_admin_no" class="form-control" />
												</div>
											</div>
											<div class="row">
												<div class="col-sm-12">
													<div class="dj-btn-group">
														<button class="btn dj-btn-primary btn-sm" type="submit">등록</button>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
								<div class="card-body p-0 bgc-whit flex-grow-1">
									<div id="hideSettionContainer" class="card-body p-0">
										<div id="hideSettingGrid" class="data-list containerBorder"></div>
									</div>
								</div>
							</div>
						</div>
					</form>
				</div>
			</div>
		</div>

		<div class="modal fade" id="ruleModal" tabindex="-1" role="dialog">
			<div class="modal-dialog modal-dialog-scrollable modal-dialog-centered" role="document">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="exampleModalLabel3">누수 규칙 설정 정보</h5>
						<button type="button" class="close" data-dismiss="modal" aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>
					<div class="modal-body">
						<div class="bcard ccard overflow-hidden settingGrid">
							<div class="card-header border-0 bgc-white card-header-sm">
								<h6 class="card-title text-dark-m3 pl-25 pt-15 text-110">
									누수 규칙 설정 <br />
									<span class="text-85 text-dark-l2"></span>
								</h6>
							</div>
							<div class="card-body p-0 bgc-whit flex-grow-1">
								<div id="ruleContainer" class="card-body p-0">
									<div id="ruleGrid" class="data-list containerBorder"></div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>

		<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
	</body>
</html>
