<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="contextPath" value="<%=request.getContextPath()%>"></c:set>
<%@ page language="java" session="false"
	contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>

<%@include file="/resources/inc/meta.inc"%>
<title>스마트수도미터원격검침시스템</title>

<%@include file="/resources/inc/base.inc"%>
<%@include file="/resources/inc/jsgrid.inc"%>
<%@include file="/resources/inc/validation.inc"%>


<script type="text/javascript">

	var _animate = !AceApp.Util.isReducedMotion();

	var mainGrid;
	
	var errGrid;
	
	var dbParams;
	
	var dbImportParams;
	
	var dbParamsTb = 'f5-3-export';
	
	var userQid;
	
	var userData = [];
	
	$(function(){
		
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
		
		loadSites();
		
		setSubmitValidation('pwdForm', updatePwd);
		
		setSubmitValidation('editForm', userControll);
		
			
	});
	
	
	/*
	* 리소스 path
 	*/
	function getContextPath() {
		
	   return "${contextPath}";
	   
	};
	
	function getSiteSq() {
		
		return ${user.getSiteSq()};
		
	};	
	
	function getSiteLv() {
		
		return ${user.getSiteLv()};
		
	};	
	
	function getUserRoll() {
		
		return ${user.getUserRoll()};
		
	};
	
	function getUserSq() {
		
		return ${user.getuserSq()};
		
	};
	
	function getUserNm() {
		
		return ${user.getUserNm()};
		
	};
	
	
	
	getUserNm
	
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
		
		$('#errGridContainer').height(480);
		
	};
	
	function modalGridLayout(modal, height) {
		
		modal.find('.jsgrid-grid-body').css('height',  height + 'px');
		
		$(window).resize(function () {
			
			modal.find('.jsgrid-grid-body').css('height',  height + 'px');
			
		});
		
	};
	
	function refreshSites(data) {
		
		if(!data || data.length == 0)
			return;
		
		var input = $('select[name="siteSq"]');
		input.empty();
		
		data.forEach(function(item) {
			
			var opt = $("<option>").val(item.grpSeq).text(item.grpName);		
			input.append(opt);	
			
		});
			
	};

	/*
	* 그리드 갱신
 	*/
	function refreshGrid(data) {
		
		if(data)
			mainGrid.finishLoad(data||[]);
		else
			mainGrid.command('refresh');
		
		$('.bcard.point-grid').aceWidget('stopLoading');
		
		userData = data;
			
	};
	
	function refreshErrGrid(data) {
		
		if(data)
			errGrid.finishLoad(data||[]);
		else
			errGrid.command('refresh');
		
		
		$('#errGridContainer .jsgrid-grid-body').height(400);
			
	};
	
	function setSubmitValidation(id, callback){
		
		var _form = $('#' + id);
		
		_form.validate({
			focusCleanup: false,		
			onfocusout: false,
			onkeyup: false,
			focusInvalid: false,
			showErrors : function(errorMap, errorList) {
				validate_util.setError(this, errorList);
			},
			onfocusin : function(element){			
				validate_util.setValid(this, element);			
			},
			submitHandler: function(element) {				
				if(callback)
					callback(element);
			},
	        rules: validate_util.rules,
	        messages: validate_util.messages
		});
			
		_form.submit(function(){
			_form.valid();
		})	
	};
	
	/*
	* 그리드 컬럼 요소 리빌딩
 	*/
 	var colfnc = function(value, item, c, d, e) {
 		
 		switch (this.name) {
 		case 'num':		
 			return (item.pageNo - 1) * item.pageSize + (c + 1);
 		case 'loginDt':
 			return kutil.dateFormat(new Date(value), 'yyyy-mm-dd HH:MM:ss');		
 			
 		}
 		

 		return value?value:'-';
	};
	

	
	var errFields = [
        { name: "dataSq", 		title: "엑셀 순번", 	     	 type: "text", 	align:"center", width: 50, sortingDisabled:true},
        { name: "msg",			title: "엑셀 오류 내용", 	 	 type: "text",   width: 'auto', sortingDisabled:true}                     
 	];	
	
	var mainFields = [
		{ name: "num", 			title: "순번", 	     type: "text", align:"center", width: 40, 	itemTemplate:colfnc, sortingDisabled:true},
		{ name: "userId",      title: "접속ID", 		 type: "text",   width: 70,  itemTemplate:colfnc, hasGroup:true},
		{ name: "loginDt",        title: "로그인시간", 		 type: "text",   width: 100, itemTemplate:colfnc, hasGroup:true},
        { name: "sessionId",      title: "세션 정보", 	 type: "text",   width: 160, itemTemplate:colfnc, hasGroup:true}, 	             	           
        /* { name: "ctcharNm",     title: "정수장", 	 	 type: "text",   width: 140, itemTemplate:colfnc, hasGroup:true}, */ 	            
        { name: "ipAddr",       title: "접속IP정보", 		 type: "text",   width: 100, itemTemplate:colfnc, hasGroup:true},                        
        { name: "Refer",      title: "웹페이지주소", 	 type: "text",   width: 200,  itemTemplate:colfnc, hasGroup:true}
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
 	        pagePrevText: "이전",
 	        pageNextText: "다음",
 	        pageFirstText: "처음",
 	        pageLastText: "마지막",
 	        
 	        rnTop: 50,
 	        rnBottom: 0,
 	                
 	        searchContainer: '#searchInput',
 		   
 	        fields: mainFields,
 	        
 	        loadStrategy: function() {			
 	        	
 	        	return new CustomPageLoadingStrategy(this, loadData);          	        	        
 	        	
 	        },
 			rowDoubleClick: function(evt) {
 				
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
	

	
	
	
	function loadSites() {
		
		var params = {};
		params.upSiteSq = getSiteSq();
		params.lv = 1;
		params.noMaster = 1;
		
		
		/* 수용가 조회 */
		getAjax('sitesList', params, function() {

		}, refreshSites, null);
		
	};


	function makeParams() {
		
		var params = {};

		$.extend(params, parent.searchComponentes);
		$.extend(params, mainGrid.loadParams());
		
		params.lv = 1;
		
		return params;
	};
	
	
	/* 메인 gird 로드  */
	function loadData() {
		
		var params = makeParams();
		
		/* 수용가 조회 */
		getAjax('loginList_Paging', params, function() {

			/* 로딩 시작 */
			$('.bcard.point-grid').aceWidget('startLoading');

		}, refreshGrid, null);

	};
	


	function getAjax(qid, params, beforesend, callback, errCallback, async) {

		ajaxSelect({
			sql : qid,
			data : params,
			async : async ? async : true,
			beforeSend : function() {

				if (beforesend)
					beforesend();

			},
			success : function(result) {

				if (callback)
					callback(result);

			},
			error : function(error) {
				
				if(error.status == 401) {
					
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
			url : url,
			success : function(data) {
				
				dbParams = data;				
				
			},
			error : function(result) {
				
				jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
				
			}
		});
		
	};

	
	function findObject(list, key, value) {
		
		var result;
		list.some(function(item) {
			
			if(item[key] && item[key] == value) {
				
				result = item;
				return true;
				
			}
			
		});
		
		return result;		
	};
	
	function clearForm(id) {
    	
    	$('#' + id)[0].reset();
    	
    	$('#' + id).resetValidation();
    	
    };
	
	
	
	function dataDownload() {

		
		if(!dbParams) {
			
			jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
			return;
			
		} 

		var params = new Object();
				
		params.qid = dbParams[dbParamsTb]['refer-sql'];
		params.colMapping = dbParams[dbParamsTb]['cols'];
		params.length = params.colMapping.length;
	
		params.downloadFileName = "Session_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');
		$.extend(params, makeParams());

		templetDownLoadStream(params, null, null, function() {
			
			jAlert.error('오류', '다운로드에 실패했습니다.');
			
		}); 

	};
	
</script>

<style type="text/css">

	
</style>

	

</head>



<body>


	<div role="main" class="main-content">


		<!-- <div class="page-content container container-plus px-md-4 px-xl-5"> -->
		<div class="page-content container container-plus px-md-4 px-xl-5">
		
		
		<div class="page-header mt-2 mx-lg-n2 border-0 justify-content-start flex-wrap flex-md-nowrap">
              <h1 class="text-dark-m3 pb-0 mb-3 mb-md-0 text-130">
                	사용자 접속 정보
              </h1>

              

              <!-- search box -->
              <div class="ml-auto d-flex">
              
              
                <!-- <div class="d-flex align-items-center px-lg-0">               
                  
                  <div class="d-flex align-items-center mx-4 mx-lg-0">
	                <i href="#none" class="fa fa-search mr-n35 text-black"></i>
	                <input type="text" id="searchInput" placeholder="수용가 번호/이름/주소 ..." class="pl-45 text-black form-control form-control-lg bgc-transparent brc-yellow-tp3 brc-on-focus border-none border-b-1 radius-0 shadow-none">		                
	                <a href="#none" title="검색 문구 지우기" class="btn btn-outline-warning btn-brc-tp radius-3px py-2" onclick="$('#searchInput').val('')"> <i class="fa fa-eraser text-140"></i></a>
						
	              </div>
                  
                  
                  <a href="#none" title="검색" class="btn btn-outline-blue btn-brc-tp radius-3px py-2" onclick="mainGrid.search();"> <i class="fa fa-sync-alt text-140"></i></a>
					                
                </div> -->
                
        
                
                <div class="d-flex align-items-center px-lg-0">               
                  <div class="card-toolbar align-self-center no-border">
                      <div class="dropdown dd-backdrop dd-backdrop-none-md">
                        <a class="btn btn-light-green text-600 btn-xs mr-1"  onclick="dataDownload();">
                          Export
                          <i class="fa fa-download ml-1 text-90"></i>
                        </a>
                        
                      </div>
                    </div>
                </div>
                
                
              </div>
              
              
            </div>


			<!-- <div class="page-header border-0 justify-content-start flex-wrap flex-md-nowrap">
              <h1 class="text-dark-m3 pb-0 mb-3 mb-md-0 text-130">
                	검침현황
              </h1>
              
              <div class="d-flex align-items-center px-lg-0">
                  <i class="fa fa-search text-blue mr-n3"></i>
                  <input type="text" placeholder="Search ..." class="form-control brc-blue-m1 brc-on-focus border-none border-b-2 radius-0 shadow-none bgc-transparent pl-35 mr-1">
                </div>
         
            </div> -->


			<div class="row mt-def">

				<div class="col-12">

					<div class="bcard card h-100 point-grid">
					
					
						<div class="card-body p-0" id="gridContainer"">							
							<div id="mainGrid" class="data-list containerBorder" style="width: 100%; height: 100%;"></div>
						</div>

					</div>
				
			</div>



			</div>


		</div>
	
	
	
	</div>
	

	
	<div class="modal fade dialog-50" id="editModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title" id="">
             	정보 수정
           </h5>

           <button type="button" class="close" id="editModalCloseBtn" data-dismiss="modal" aria-label="Close" onclick="clearForm('editForm');">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>
         
         <form id="editForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">

	         <div class="modal-body">
	      
	      		
	      		<input class="form-control" name="userSq" type="text" style="display: none;"/>
	      		<input class="form-control" name="qid" type="text" style="display: none;"/>
	      		
	      		<div class="form-group row">
	      			<div class="col-sm-6" style="border-right: solid 0.1px #dcdcdc;">
	      			
	      				<div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userNm" class="mb-0">
			                    	사용자 이름<span class="asteriskField">*</span>
			                  </label>
			                </div>
			
			                <div class="col-sm-9">
			                  <input class="form-control" name="userNm" type="text"/>
			                  <label for="userNm" generated="true" class="error errclr">24자 이내로 입력해 주세요.</label>
			                </div>                                
		              </div>
		              
		              <div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userId" class="mb-0">
			                    	사용자 ID<span class="asteriskField">*</span>
			                  </label>
			                </div>
			
			                <div class="col-sm-9">
			                  <input class="form-control" name="userId" type="text"/>
			                  <label for="userId" generated="true" class="error errclr">4이상 10자 이하로 입력하세요.</label>
			                </div>                                
		              </div>
		              
		              <div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="rollCd" class="mb-0">
			                    	사용자 유형<span class="asteriskField">*</span>
			                  </label>
			                </div>
				
			                <div class="col-sm-9">
				           		<select data-placeholder="선택" name="rollCd" class="form-control border-1p">
				           			<option value="1" selected>일반사용자</option>
				                	<option value="5">시스템관리자</option>	                  						                 
				                </select>
				                <label for="rollCd" generated="true" class="error errclr">사용자 유형을 선택하세요.</label>
			               </div>
			            </div>
			            
			            
			            <div class="form-group row">
			               <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                 <label for="siteSq" class="mb-0">
			                   	소속 지자체<span class="asteriskField">*</span>
			                 </label>
			               </div>
			
			                <div class="col-sm-9">
				           		<select data-placeholder="선택" name="siteSq" class="form-control border-1p">           				                  						               
				                </select>
				                <label for="siteSq" generated="true" class="error errclr">소속 지자체를 선택하세요.</label>
			               </div>
			            </div>
		              
		               
	      			
	      			</div>
	      			<div class="col-sm-6">
	      			
	      				<div class="form-group row show-add-user">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userPwd" class="mb-0">
			                    	암호 설정<span class="asteriskField">*</span>
			                  </label>
			                </div>
			
			                <div class="col-sm-9">
			                  <input class="form-control" name="userPwd" id="userPwd" type="password"/>
			                  <label for="userPwd" generated="true" class="error errclr">4이상 15자 이하로 입력하세요.</label>
			                </div>                                
		              </div>
		              
		              <div class="form-group row show-add-user">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userPwdConfirm" class="mb-0">
			                    	암호 재입력<span class="asteriskField">*</span>
			                  </label>
			                </div>
			
			                <div class="col-sm-9">
			                  <input class="form-control" name="userPwdConfirm" type="password"/>
			                  <label for="userPwdConfirm" generated="true" class="error errclr">패스워드를 재입력하세요.</label>
			                </div>                                
		              </div>
	      			    
			            <div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="email" class="mb-0">
			                    	이메일
			                  </label>
			                </div>
			
			                <div class="col-sm-9">
			                  <input class="form-control" name="email" type="text"/>
			                  <label for="email" generated="true" class="error errclr">이메일 형식으로 입력하세요.</label>
			                </div>                                
			             </div>
			              
			             <div class="form-group row">
			               <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                 <label for="custPhone" class="mb-0">
			                   	전화번호
			                 </label>
			               </div>
			
			               <div class="col-sm-9">
			                 <input class="form-control" name="custPhone" type="text"/>
			                 <label for="custPhone" generated="true" class="error errclr">전화번호를 -없이 숫자만 입력하세요.</label>
			               </div>                                
			             </div>
	      			
	      			</div>
	      		</div>

	         </div>
	         
	         <div class="modal-footer">
			        
		        <button class="btn btn-info btn-bold px-4" type="submit">
		        	<i class="fa fa-check mr-1"></i>저장                  	
		        </button>
			        
		    </div>
		
		</form>

         
       </div>
     </div>
   </div>
   
   
   
   
   <div class="modal fade" id="pwdModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title" id="">
             	암호 재설정
           </h5>

           <button type="button" class="close" id="pwdModalCloseBtn" data-dismiss="modal" aria-label="Close" onclick="clearForm('pwdForm');">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>
         
         <form id="pwdForm" class="mt-lg-3 validator" autocomplete="off"  data-toggle="validator" role="form">

	         <div class="modal-body">
	      
	      		
	      		<input class="form-control" name="userSq" type="text" style="display: none;"/>
	      		
	      		<div class="form-group row">
	      			<div class="col-sm-12">
	      			
	      				 <div class="form-group row">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userId" class="mb-0">
			                    	사용자 ID<span class="asteriskField">*</span>
			                  </label>
			                </div>
			
			                <div class="col-sm-9">
			                  <input class="form-control" name="userId" type="text" disabled/>
			                  <label for="userId" generated="true" class="error errclr">현제 선택된 사용자 아이디입니다.</label>
			                </div>                                
		              </div>
	      			
	      				<div class="form-group row show-add-user">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userPwd2" class="mb-0">
			                    	암호 설정<span class="asteriskField">*</span>
			                  </label>
			                </div>
			
			                <div class="col-sm-9">
			                  <input class="form-control" name="userPwd" id="userPwd2" type="password"/>
			                  <label for="userPwd2" generated="true" class="error errclr">4이상 15자 이하로 입력하세요.</label>
			                </div>                                
		              </div>
		              
		              <div class="form-group row show-add-user">
			                <div class="col-sm-3 col-form-label text-sm-right pr-0">
			                  <label for="userPwdConfirm2" class="mb-0">
			                    	암호 재입력<span class="asteriskField">*</span>
			                  </label>
			                </div>
			
			                <div class="col-sm-9">
			                  <input class="form-control" name="userPwdConfirm2" type="password"/>
			                  <label for="userPwdConfirm2" generated="true" class="error errclr">패스워드를 재입력하세요.</label>
			                </div>                                
		              </div>
		              
		               
	      			
      				</div>
	      			
	      		</div>

	         </div>
	         
	         <div class="modal-footer">
			        
		        <button class="btn btn-info btn-bold px-4" type="submit">
		        	<i class="fa fa-check mr-1"></i>저장                  	
		        </button>
			        
		    </div>
		
		</form>

         
       </div>
     </div>
   </div>
   
   

	



	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
	<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>
	

</body>



</html>

