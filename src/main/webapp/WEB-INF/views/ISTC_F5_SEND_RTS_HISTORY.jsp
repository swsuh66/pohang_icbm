<%@ page language="java" contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="EUC-KR">
	<title>스마트수도미터원격검침시스템</title>
	<link rel="shortcut icon" type="image/png"  href="resources/img/logo-checkall-mk1.png">
	<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/bootstrap/dist/css/bootstrap.css">
	<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/fontawesome.css">
	<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/regular.css">
	<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/brands.css">
	<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/solid.css">
	<link rel="stylesheet" type="text/css" href="${contextPath}/resources/page/common/css/ace-themes.css">
	<script type="text/javascript" src="${contextPath}/resources/lib/jquery/dist/jquery.js"></script>
	<script type="text/javascript" src="${contextPath}/resources/rts.js"></script>
	<script src="${contextPath}/resources/lib/bootstrap/dist/js/bootstrap.js"></script>
	<link rel="stylesheet" type="text/css"
		  href="${contextPath}/resources/page/common/css/custom.css">
	<script src="${contextPath}/resources/page/common/js/custom.js"></script>

</head>
<body>
<div role="main" class="sub-content">
	<div class="sub-cont-header">
		<h1>명령 이력</h1>
	</div>
<%--	<h1 style='font-size : 1.3em; float:left;'>--%>
<%--		명령 이력--%>
<%--	</h1>--%>
<%--	<div>--%>

<%--	</div>--%>

	<!-- 히스토리 데이터를 표시 합니다.  -->
<div class="dj-card">
	<div class="dj-table">
		<table>
			<thead>
				<tr>
					<th class="bgCyon">no</th>
					<th class="bgCyon">요청 주소 설명</th>
					<th class="bgCyon">요청 주소</th>
					<th class="bgCyon">실행 날짜</th>
					<th class="bgCyon">대상 갯수</th>
					<th class="bgCyon">실행 아이피</th>
					<th class="bgCyon">실행 아이디</th>
					<th class="bgCyon">결과</th>
					<th class="bgCyon">보기</th>
				</tr>
			</thead>
			<tbody id='showTable'></tbody>
		</table>
	</div>
	<nav class="page-align" id="pagination"></nav>

	<!-- 히스토리에 대한 세부 데이터를 표시 합니다.  -->
	<div class="modal" tabindex="-1" role="dialog" id='detailModal'>
	  <div class="modal-dialog modal-lg" role="document" style='max-width: 1480px'>
	    <div class="modal-content">
	      <div class="modal-header">
	        <h5 class="modal-title">세부 목록</h5>
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
	          <span aria-hidden="true">&times;</span>
	        </button>
	      </div>
	      <div class="modal-body">
	        <form id='insertForm'>
				<table class='table table-bordered table-hover table-sm'>
					<thead>
						<tr>
							<th class="bgCyon">no</th>
							<th class="bgCyon">세부 URL</th>
							<th class="bgCyon">기록일</th>
							<th class="bgCyon">서버응답 결과</th>
						</tr>
					</thead>
					<tbody id='detailShowTable'>

					</tbody>
				</table>
				<nav class="page-align2"></nav>
	        </form>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
	      </div>
	    </div>
	  </div>
	</div>
</div>
</div>
</body>
</html>

<script>


$(document).ready(function(){

	const listUrl= 'api/getHistoryList';  //히스토리 데이터를 가져오는 주소 입니다.
	const detailListUrl = 'api/getHistoryItemList';  //히스토리 세부 데이터를 가져오는 주소 입니다.

	//기본 파라미터입니다.
	const param = {
		'pageSize' : 10,  //한번에 보여지는 사이즈
		'rowSize' : 10,   //하단에 생기는 페이지 수
		'curPage' : 0,
		'tail_class_name':'page-align'
	}


	//히스토리 데이터 테이블 화면을 그리는 함수 입니다.
	function viewer(result){

		$('#showTable').children().remove();

		if(result?.list){
			result.list.forEach( (data,index)=>{
				let { idx, url_desc, url_name, reg_date, working_status, size, user_id, user_ip } = data;
				let item = $('<tr/>').append(
					$('<td/>').addClass('').text( getNumbering(result, index) ),
					$('<td/>').text( url_desc ),
					$('<td/>').text( url_name ),
					$('<td/>').text( reg_date != null ? new Date(reg_date).yyyymmddhhmmss() : ''  ),
					$('<td/>').text( size ),
					$('<td/>').text( user_ip  ),
					$('<td/>').text( user_id  ),
					$('<td/>').text( working_status  ),
					$('<td/>').append(
						$('<input type="button"/>').addClass('btn btn-primary btn-xs').css('padding','3px').val('세부보기').click(()=>{  //세부목록 보기 버튼 기능 입니다.
							const param2 = {
								'pageSize' : 10,  //한번에 보여지는 사이즈
								'rowSize' : 10,   //하단에 생기는 페이지 수
								'curPage' : 0,
								'tail_class_name':'page-align2',
								'history_idx' : idx
							}
							$('#detailModal').modal('show');
							buildTable(detailListUrl, param2, viewer2);  //Ajax를 통해 데이터를 받아온 뒤 콜백함수인 viewer2를 실행 합니다.
						})
					)
				)
				$('#showTable').append(item);  //위의 객체를 append합니다.
			});

		}
	}

	//Ajax를 통해 데이터를 받아온 뒤 콜백함수인 viewer를 실행 합니다.
	buildTable(listUrl, param, viewer);


	//히스토리 세보목록 테이블 화면을 그리는 함수 입니다.
	function viewer2(result){
		$('#detailShowTable').children().remove();
		if(result?.list){
			result.list.forEach( (data,index)=>{
				let { url_name, reg_date, working_result } = data;
				let working_show = $('<span>').text(working_result).css('color','blue');
				if(working_result != '200'){
					working_show.css('color','#ff7979');
				}
				let item = $('<tr/>').addClass('tr').append(
					$('<td/>').addClass('').text( getNumbering(result, index) ),
					$('<td/>').text( url_name ),
					$('<td/>').text( reg_date != null ? new Date(reg_date).yyyymmddhhmmss() : ''  ),
					$('<td/>').append( working_show )
				)
				$('#detailShowTable').append(item);  //위의 객체를 append합니다.
			});
		}
	}

});


</script>
