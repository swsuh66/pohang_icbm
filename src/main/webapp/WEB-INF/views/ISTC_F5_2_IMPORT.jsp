<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<!DOCTYPE html>
<html>
<head>
<meta charset=UTF-8>

<%@include file="/resources/inc/meta.inc"%>
<title>스마트수도미터원격검침시스템</title>

<%@include file="/resources/inc/base.inc"%>
<%@include file="/resources/inc/jsgrid.inc"%>

	<link rel="stylesheet" href="${contextPath}/resources/page/common/css/istc-file_wiz.css">	
<!--
	<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-file_wiz.js?v=1.1"></script>
-->

<script type="text/javascript">
// js 파일 없애고 개조

// 끝



var errorExcelGrid;
var resultParam;




$(function(){
	errorExcelGrid = errorInitGrid('errorExcelGrid');

	$('#insertForm').show();
	$('#gridWindow').hide();
	
	//errorExcelGrid.search();
});

function getContextPath() {
	
   return "${contextPath}";
   
};

function errorDataGridSearch(data) {
	
	if(data)
		errorExcelGrid.finishLoad(data||[]);
	else
		alert("data null");
		
};

function down() {
	params = {};
	
	params['errparam'] = resultParam;

	$.ajax({
		url : getContextPath()+'/file/errorexcl',
		contentType: 'application/json',
		xhr: function() {
		        var xhr = new XMLHttpRequest();
		        xhr.responseType = 'blob'; // responseType 설정은 여기서 처리
		        return xhr;
		},
	    data: JSON.stringify(params),
		type : 'POST',
		success: function(blobData) {
	        // Blob 데이터 처리하기
	        var url = window.URL.createObjectURL(blobData);
	        var a = document.createElement('a');
	        a.href = url;
	        a.download = 'errimport.xlsx';
	        document.body.appendChild(a);
	        a.click();
	        window.URL.revokeObjectURL(url);
			document.body.removeChild(a);

			$('#insertForm').show();
			$('#gridWindow').hide();
			document.getElementById('file').value='';
	    },
		error: function(xhr, status, error) {
            // 오류 발생 시 동작
            console.error(error);
            // 오류 처리를 수행합니다.

			$('#insertForm').show();
			$('#gridWindow').hide();
			document.getElementById('file').value='';
        }
	});
}

function submit2() {
	$.ajax({
		url : "file/insert_f5_2",
		processData : false,
		contentType : false,
		data : new FormData(insertForm),
		type : 'POST',
		success : function(result) {
			resultParam = result.errParam;
			errorDataGridSearch(result.errParam);
			if (resultParam.length > 0) {
				jAlert.error('에러', 'import 에 실패했습니다. 다음 목록은 에러리뷰 입니다. 에러목록 다운로드를 하여 확인해주세요.');
			}
			else {
				jAlert.info('정보', 'import 에 성공했습니다. ');
			}
				
			$('#insertForm').hide();
			$('#gridWindow').show();
		},
		error: function(xhr, status, error) {
            // 오류 발생 시 동작
            console.error(error);
			jAlert.error('오류', 'import 에 실패하였습니다.');
            // 오류 처리를 수행합니다.
        }
	});
}

	function updateSubmit() {
		$.ajax({
			url : "file/update_f5_2",
			processData : false,
			contentType : false,
			data : new FormData(insertForm),
			type : 'POST',
			success : function(result) {
				resultParam = result.errParam;
				errorDataGridSearch(result.errParam);
				if (resultParam.length > 0) {
					jAlert.error('에러', 'update 에 실패했습니다. 다음 목록은 에러리뷰 입니다. 에러목록 다운로드를 하여 확인해주세요.');
				}
				else {
					jAlert.info('정보', 'update 에 성공했습니다. ');
				}
					
				$('#insertForm').hide();
				$('#gridWindow').show();
			},
			error: function(xhr, status, error) {
				// 오류 발생 시 동작
				console.error(error);
				jAlert.error('오류', 'update 에 실패하였습니다.');
				// 오류 처리를 수행합니다.
			}
		});
	}

	function checkSubmit() {
		$.ajax({
			url : "file/check_f5_2",
			processData : false,
			contentType : false,
			data : new FormData(insertForm),
			type : 'POST',
			success : function(result) {
				resultParam = result.errParam;
				errorDataGridSearch(result.errParam);
				if (resultParam.length > 0) {
					jAlert.error('에러', 'check 에 성공했습니다. 다음 목록은 에러리뷰 입니다. 에러목록 다운로드를 하여 확인해주세요.');
				}
				else {
					jAlert.info('정보', 'check 에 성공했습니다. 이상없습니다.');
				}
					
				$('#insertForm').hide();
				$('#gridWindow').show();
			},
			error: function(xhr, status, error) {
				// 오류 발생 시 동작
				console.error(error);
				jAlert.error('오류', 'update 에 실패하였습니다.');
				// 오류 처리를 수행합니다.
			}
		});
	}

	function closeModal() {
		$('#importContainer').modal('hide');
		$('#insertForm').show();
		$('#gridWindow').hide();
		document.getElementById('file').value='';
	};
	
/*
* 그리드 초기화
	*/
	function errorInitGrid(container) {
	    
		var opt = {
				
	        height: "100%",
	        width: "100%",
	        sorting: true,
	        pageLoading: true,       
	        paging: true,        
	        pageSize: 50,
		 	pageButtonCount: 5, 	// 페이지 버튼 개수
		 	pagerFormat: "{first} {prev} {pages} {next} {last}    {pageIndex} of {pageCount}",	        
	        pagePrevText: "이전",
	        pageNextText: "다음",
	        pageFirstText: "처음",
	        pageLastText: "마지막",
	        
	        rnTop: 50,
	        rnBottom: 0,
	                
	        searchContainer: '#searchInput',
		   
	        fields: [
	        	{ name: "data_sq", 		title: "순번", 	     type: "text", align:"center", width: 50 	},
	            { name: "custNm",       title: "수용가명", 	     type: "text",   width: 100 },
	            { name: "adminNo",      title: "수용가번호", 	 type: "text",   width: 70  },
	            { name: "addr",         title: "구주소", 	     type: "text",   width: 170}, 	             	           
	            { name: "addrNew",      title: "도로명주소", 	 type: "text",   width: 200 }, 
	            { name: "locLng", 	    title: "경도", 	     type: "text",   align:"left", width: 120  },
	            { name: "locLat",  		title: "위도", 	     type: "text", 	 align:"center", width: 120},
	            { name: "useType", 		title: "업종", 	     type: "text", align:"right",  width: 100 },
	            { name: "siteNm", 	    title: "동",          type: "text", align:"right",  width: 80 },
	            { name: "blkNm", 	    title: "블록", 	     type: "text", align:"right",  width: 80},
	            { name: "custPhone", 	title: "수용가 전화번호",  type: "text", align:"right",  width: 80},
	            { name: "setYears", 	title: "수용가 대상 년도", type: "text", align:"right",  width: 80 },
	            { name: "readOpr", 	    title: "검침원", 	     type: "text", align:"right",  width: 80 },
	            { name: "checkDay", 	title: "검침일", 	     type: "text", align:"right",  width: 80},
	            { name: "meterNo", 	    title: "계량기번호", 	 type: "text", align:"center",  width: 80},
	            { name: "pipeDia",      title: "구경", 		 type: "text",   width: 80},  ////////////// 2022-11-30
	            { name: "amiType",      title: "통신", 		 type: "text",   width: 80},  ////////////// 2022-11-30
	            { name: "subDevNo",     title: "단말부번호", 	 type: "text",   width: 80},  ////////////// 2022-11-30
	            { name: "devNo",        title: "단말 주번호", 	 type: "text",   width: 80},  ////////////// 2022-11-30
	            { name: "companyNm",    title: "단말 회사", 	 type: "text",   width: 80},  ////////////// 2022-11-30
	            { name: "setDt",        title: "단말 설치일", 	 type: "text",   width: 80}  ////////////// 2022-11-30
				
	            //{ name: "msg",          title: "에러메시지", 	 type: "text",   width: 80}  ////////////// 2022-11-30
	        ],
	        
	        loadStrategy: function() {			
	        	
	        	return new CustomPageLoadingStrategy(this, null);          	        	        
	        	
	        },
			rowDoubleClick: function(evt) {

			}
		};

		return new DataGrid(container, opt);
	}
</script>

</head>
<body>
	<div id="fileUp">
			<form id="insertForm" action="" method="post" enctype="multipart/form-data" style="border: 1px solid #eee;background-color: white; padding: 10px;">
				
				<div class="form-group">
					<label for="file_info"
					class="control-label col-md-4  requiredField"><spring:message
					code="mgmt.equipinfo.col.model" text="파일 첨부" /><span
					class="asteriskField">*</span> </label>
					<div class="controls col-md-8 ">
						<div class="filebox bs3-primary">
							<input  type="file" class="info componentsFont" id="file" name="file" accept=".xlsx">
						</div> 
					</div>
				</div>
				<div class="form-group ">
					<label for="exFileDown"
					class="control-label col-md-4  requiredField"><spring:message
					code="mgmt.equipinfo.col.model" text="" /><span
					class="asteriskField"></span></label>
					<div class="controls col-md-8 ">
						<a  id="exFileDown" class="btn dj-btn-outline-green btn-sm" onclick="exFileDownload();">
							첨부파일 예시 다운로드						
						</a>
					</div>
				</div>
				<div class="dj-btn-group">
					<a class="btn dj-btn-primary btn-sm" onclick="submit2();"> 
						신규					
					</a>
					<a class="btn dj-btn-green btn-sm" onclick="updateSubmit();"> 
						수정					
					</a>
					<a class="btn dj-btn-outline-green btn-sm" onclick="checkSubmit();"> 
						체크					
					</a>
					<a class="btn dj-btn-outline-red btn-sm" onclick="closeModal();"> 
						닫기					
					</a>
				</div>
			</form>
			
			<div id="gridWindow" style="border: 1px solid #eee;background-color: white; padding: 10px;">
				<div class="form-group">
					<div id="errorExcelGrid" class="data-list file-grid"></div>
				</div>
				<div class="dj-btn-group">
					<a class="btn dj-btn-primary btn-sm" onclick="down();"> 
						에러목록 다운로드					
					</a>
					<a class="btn dj-btn-outline-red btn-sm" onclick="closeModal();"> 
						닫기					
					</a>
				</div>
			</div>
	</div>   		
</body>
</html>