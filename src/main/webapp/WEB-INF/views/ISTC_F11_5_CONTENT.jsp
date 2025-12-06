<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<%-- ISTC_F11_1_CONTENT --%> <%-- 누수필터 화면 --%> <%@include file="/resources/inc/meta.inc" %>
		<title>스마트수도미터원격검침시스템</title>
		<script type="text/javascript"></script>
		<script>
			$(function () {
				//화면 오픈시
				loadComponentBase();
			});

			var searchComponentes = {
				statCd: null,
				useType: null,
				blkSq: null,
				custPhone: null,
				setYears: null,
				comSq: null,
				amiType: null,
				pipeDia: null,
				siteSq: null,
				upSiteSq: parent.getSiteSq(),
				lv: 1,
				fullNm: ['전체'],
			};

			/*
			 * 검색 컴포넌트 변경
			 */
			function baseComponentChangHandler(el) {
				var val = $(el).val() != '-1' ? $(el).val() : null;
				searchComponentes[$(el).attr('id')] = val;
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

			function resetComponentes() {
				$('.componentsSelect').val('').trigger('chosen:updated');
				$.extend(searchComponentes, {
					statCd: null,
					useType: null,
					blkSq: null,
					custPhone: null,
					setYears: null,
					comSq: null,
					amiType: null,
					pipeDia: null,
				});
			}

			// 기본컴포넌트 생성.
			function loadComponentBase() {
				var params = { key: 0 };
				$.extend(params, searchComponentes);
				baseComponent('mars.icbm.map1.selectComponentes', 'setYears', params); //0
				params.key = 1;
				baseComponent('mars.icbm.map1.selectComponentes', 'comSq', params);
				params.key = 2;
				baseComponent('mars.icbm.map1.selectComponentes', 'amiType', params);
				params.key = 3;
				baseComponent('mars.icbm.map1.selectComponentes', 'pipeDia', params);
				params.key = 4;
				baseComponent('mars.icbm.map1.selectComponentes', 'useType', params);
				params.key = 5;
				baseComponent('mars.icbm.map1.selectComponentes', 'custPhone', params);
				params.key = 6;
				baseComponent('mars.icbm.map1.selectComponentes', 'blkSq', params);
			}

			/**
			 * base 조회조건 조회
			 */
			function baseComponent(url, name, param) {
				ajaxSelect({
					sql: url,
					data: param,
					success: function (data) {
						if (data != 0) {
							data.forEach(function (item, idx) {
								if (item != null) {
									if (item.sq != '' && item.sq != null && item.val != '' && item.val != null) {
										var el = $('<option>').attr('value', item.sq).text(item.val);
										$('.componentsSelect[name="' + name + '"]').append(el);
									}
								}
							});
						}
					},
					error: function (result) {
						jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
					},
				});
			}
		</script>
	</head>
	<body>
		<div class="dj-card" id="filter">
			<div class="row">
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">수용가번호</span>
						<input type="text" class="componentsSelect" id="admin_no" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">수용가명</span>
						<input type="text" class="componentsSelect" id="cust_nm" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">설정 구경</span>
						<select data-placeholder="선택" class="form-control" name="2" id="pipe_diameter" data-component="pipe_diameter" onchange="onSelectionChange()">
							<!-- <option value="" selected>전체</option> -->
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">설정 업종</span>
						<select data-placeholder="선택" class="form-control" name="1" id="business_name" data-component="business_name" onchange="onSelectionChange()">
							<!--
                        <option value="" selected>전체</option>							
                        --></select>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">검침원</span>
						<input type="text" class="componentsSelect" id="read_responsi" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">제외기간</span>
						<div style="display: flex; align-items: center;">
							<input type="date" class="componentsSelect" id="exclude_date" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" style="flex: 1;" />
							<span style="margin-left: 8px; white-space: nowrap;">이전</span>
						</div>
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-8 col-lg-12 col-xl-12">
					<div class="dj-btn-group">
						<button type="button" class="btn dj-btn-primary btn-sm" onclick="parent.searchGrid();">검색</button>
						<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="resetComponentes();">초기화</button>
						<button type="button" class="btn dj-btn-outline-green btn-sm" onclick="dataDownload();"><i class="ico i-excel"></i>엑셀다운</button>
						<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="openAlrimTokPopup();"><i class="ico i-kakao"></i>누수알림</button>
						<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="openRuleModal();"><i class="fa fa-search"></i>설정보기</button>
						<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="openPrintPage();"><i class="fa fa-print"></i>프린트</button>
						<!-- <button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="openHideSettingModal();"><i class="ico i-set"></i>제외 수용가 설정</button> -->
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
