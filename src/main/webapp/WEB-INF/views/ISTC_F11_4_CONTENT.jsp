    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<%@include file="/resources/inc/meta.inc" %>
		<title>스마트수도미터원격검침시스템</title>
		<script type="text/javascript"></script>
		<script>
			function resetComponentes() {
				$('.componentsSelect').each(function() {
					if ($(this).is('select')) {
						$(this).val($(this).find('option:first').val());
					} else {
						$(this).val('');
					}
				});
				$('.componentsSelect').trigger('chosen:updated');
				$('#filterType').val('all');
				$('#startDate').val('');
				$('#endDate').val('');
			}
		</script>
	</head>
	<body>
		<div class="dj-card" id="filter">
			<div class="row">
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">수용가명</span>
						<input type="text" class="componentsSelect" id="tgt_nm" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">수신번호</span>
						<input type="text" class="componentsSelect" id="phone_num" onKeypress="javascript:if(event.keyCode == 13) { parent.searchGrid(); }" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2" id="fromDateGroup">
					<div class="dj-input-group">
						<span class="info componentsFont">시작일</span>
						<input type="date" id="startDate" name="startDate" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2" id="toDateGroup">
					<div class="dj-input-group">
						<span class="info componentsFont">종료일</span>
						<input type="date" id="endDate" name="endDate" />
					</div>
				</div>
				<div class="col-12 col-sm-6 col-md-4 col-lg-3 col-xl-2">
					<div class="dj-input-group">
						<span class="info componentsFont">조회구분</span>
						<select id="filterType" class="componentsSelect" onchange="parent.searchGrid();">
							<option value="all" selected>전체</option>
							<option value="error">오류</option>
						</select>
					</div>
				</div>
				<div class="col-12 col-sm-12 col-md-8 col-lg-6 col-xl-12">
					<div class="dj-btn-group">
						<button type="button" class="btn dj-btn-primary btn-sm" onclick="parent.searchGrid();">검색</button>
						<button type="button" class="btn dj-btn-outline-gray btn-sm" onclick="resetComponentes();">초기화</button>
						<button type="button" class="btn dj-btn-outline-green btn-sm" onclick="dataDownload();"><i class="ico i-excel"></i>엑셀다운</button>
					</div>
				</div>
			</div>
		</div>
	</body>
</html>
