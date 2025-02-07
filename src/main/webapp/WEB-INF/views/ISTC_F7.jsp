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


<script type="text/javascript">

	var _animate = !AceApp.Util.isReducedMotion();

	var mainGrid;	
	
	var dbParams;
	
	var rawDbParams;
	
	var dbParamsTb = 'f7-export';
	
	var rawDbParamsTb = 'f7-2-export';
	
	
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
		
		getDbtableInfo2();
		
		/*
		* 날짜 초기 설정
		*/
		setInitDate();
		
		/*
		* 초기 데이터 일괄 로드
		*/
		loadData();
		
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

			var ht = ht1 - off.top - 10;
			$('#gridContainer').height(ht);

		}
		
	};
	
	function setInitDate() {
		
		var dt = new Date(Date.now());
		
		var y = kutil.dateFormat(dt, 'yyyy-mm-dd');
		
		$('#toDate').val(y);
		
		$('#baseDate').val(y);
		
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
			
		//setDescription();
	};
	
	
	function setDescription() {
		
		$('#description').empty();
		
		var str = '* ' + dDate[0].begDate + '~' + dDate[0].endDate + ' 최소유량입니다.';
		
		$('#description').text(str);
		
		
	};
	
	/*
	* 그리드 컬럼 요소 리빌딩
 	*/
 	var colfnc = function(value, item, c, d, e) {
 		
 		switch (this.name) {
 		case 'num':		
 			return (item.pageNo - 1) * item.pageSize + (c + 1);
 			
 		}
 		
 		return (value == 0 || value) ? value : '-';	
	};
	
	/*
	* 그리드 초기화
 	*/
 	function initGrid(container) {
		
 		var fields = [        
 			{ name: "num", 				title: "순번", 					type: "text", 	align:"center", 	width: 50, 	itemTemplate:colfnc, sortingDisabled:true},
 			{ name: "useType",     		title: "업종",	    			type: "text", 	align: "left",  	width: 70, 	itemTemplate:colfnc, hasGroup:true, group:groups[0]		},
 			{ name: "blkNm",     		title: "블럭",	    			type: "text", 	align: "left",  	width: 150, itemTemplate:colfnc, hasGroup:true	},
 			{ name: "adminId",     		title: "수용가 번호",   			type: "text", 	align: "left",  	width: 150, itemTemplate:colfnc, hasGroup:true},
 			{ name: "custName",     	title: "이름",   					type: "text", 	align: "left",  	width: 150, itemTemplate:colfnc, hasGroup:true	},
 			{ name: "readOpr",     		title: "검침원",   				type: "text", 	align: "left",  	width: 70, itemTemplate:colfnc, hasGroup:true	}
 			
 		];
 	    
 		fields = refactFields(fields);
 		
 		var opt = {
 				
 	        height: "100%",
 	        width: "100%",
 	        sorting: false,
 	       
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
 		   
 	        fields: fields,
 	        
 	        loadStrategy: function() {			
 	        	
 	        	return new CustomPageLoadingStrategy(this, loadData);          	        	        
 	        	
 	        },
 			rowDoubleClick: function(evt) {
 				
 				$('#infoModal', window.parent.document).modal('show'); //infoModal
 				
				loadModalData(false, evt.item);

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
	
	function refactFields(fields) {
		
		var baseDate = $('#toDate').val();
		
		if(!dDate[0].begDate || !dDate[0].endDate) {
			
			jAlert.alert('오류', '서버에 오류가 있습니다.');
			return ;
			
		}
		
		var startDayStr = dDate[0].begDate.split('-')[2];	
		var startDayEnd = getLastDate(dDate[0].begDate);	
		
		
		var endDayStr = 1;
		var endDayEnd = dDate[0].endDate.split('-')[2];	
		
		//groups[1].columns = dDate[0].cnt;
		
		var j = 1;
		
		for(var i = startDayStr; i <= startDayEnd; i++) {
			
			var obj = new Object();
			
			obj.name ='D' + kutil.lpad('00', j);
			obj.title = i;
			obj.type = 'number';
			obj.align = 'center';
			obj.width = 60;
			if(j == 1) 
				obj.group = groups[1];
			
			obj.hasGroup = true;
			obj.itemTemplate = function(value, item) {
				
				var result = (value == 0 || value) ? value : '-';
				
				if(item.flowMinPoint == value)
					return '<span style="font-size:11px; color:red">' + result + '</span>';
				else
					return result;
				
			}
			
			fields.push(obj);
			
			j++;
			
		}
			
		for(var i = endDayStr; i <= endDayEnd; i++) {
			
			var obj = new Object();
			
			obj.name ='D' + kutil.lpad('00', j);
			obj.title = i;
			obj.type = 'number';
			obj.align = 'center';
			obj.width = 60;	
			obj.hasGroup = true;		
			obj.itemTemplate = function(value, item) {
				
				var result = (value == 0 || value) ? value : '-';
				
				if(item.flowMinPoint == value)
					return '<span style="font-size:11px; color:red">' + result + '</span>';
				else
					return result;
				
			}
			
			fields.push(obj);
			
			j++;
		}
		
		return fields;
		
	};
	
	function getLastDate(baseDate) {
		
		var dateList =  baseDate.split('-');		
		var lastDate = ( new Date( dateList[0], dateList[1], 0) ).getDate();
		
		return lastDate;
	};


	var groups = [
		{title:'수용가', 			    columns: 5, align:"center"},
		{title:'일별 최소유량 (㎥/H)', 	columns: 32, align:"center"}
	];
	
	
	function loadData() {

		getAjax('mars.icbm.map1.beforeMonth', {'baseDate' : $('#toDate').val()}, function() {

			$('.bcard.point-grid').aceWidget('startLoading');

		}, function(result) {
			
			dDate = result;
			
			mainGrid = initGrid('mainGrid');
					
			var params = makeParams();
			
			if(!params.baseDate || params.baseDate.length == 0) {
				
				jAlert.error('오류', '날짜를 지정하세요');
				return;
				
			}
			
			getAjax('flowMinList_paging', params, function() {

				/* 로딩 시작 */
				$('.bcard.point-grid').aceWidget('startLoading');

			}, refreshGrid, null);


		}, null);
		
	};
		
	
	function makeParams() {
		
		var params = {};

		$.extend(params, parent.searchComponentes);
		$.extend(params, mainGrid.loadParams());
		
		params.baseDate = $('#toDate').val();	
		params.useCd = '1';
		
		params.searchOption = $('#searchOptionSelect').val();
		
		
		return params; 
		
	};


	/* modal 데이터 로드 */
	function loadModalData(useGparams, item) {
		
		var params = new Object();
		var type = $('#typeSelect', window.parent.document).val();
		var endDate = $('#fromDate', window.parent.document).val(); 				 		
 		if(!endDate || endDate.length == 0) {
 			
 			/* 날짜 초기화 */
 			$('#fromDate', window.parent.document).val(kutil.dateFormat(new Date(), 'yyyy-mm-dd')); 			
 			endDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd'); 
 			
 		}
 		
		
		if(useGparams)
			params = parent._params;
		else {
			
			if(item) {
				params.pointSq = item.pointSq;
				params.siteSq = item.siteSq;	
			}
			
		}
		
		params.endDate = endDate;
		
		var begDate = kutil.addMonth(endDate, (type == '0') ? -1 : -12); 		 		
 		params.begDate = moment(Date.parse(begDate)).format('YYYY-MM-DD');
		
		loadPointData(params);
		
		type == '0' ?
		loadRawData('pointHisdataRaw', params) : 
		loadRawData('pointHisdata', params);
		
		
		parent._params = params; 
		
	};

	function loadRawData(qid, params) {

		/* 검침값 조회 */
		getAjax(qid, params, function() {

			$('#infoModal', window.parent.document).aceWidget('startLoading');

		}, function(result) {

			parent.refreshModalMain(result);

		}, null);

	};

	/* 로드 수용가 정보 */
	function loadPointData(params) {

		/* 수용가 조회 */
		getAjax('mars.icbm.map1.pointList', params, null, function(result) {

			parent.updateValueFields(result);

		}, null);

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
	
	function getDbtableInfo2() {

		var url = getContextPath() + '/file/dbParams/' + rawDbParamsTb;

		ajaxSelect({
			url : url,
			success : function(data) {
				
				rawDbParams = data;				
				
			},
			error : function(result) {
				
				jAlert.error('오류', '데이터를 가져오는데 실패하였습니다.');
				
			}
		});

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

		
		params.downloadFileName = "FlowMin_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');							
		$.extend(params, makeParams());

		templetDownLoad(params, null, null, function() {
			
			jAlert.error('오류', '다운로드에 실패했습니다.');
			
		}); 

	};
	
	function rawDataDownload() {
				
		if(!rawDbParams) {
			
			jAlert.error('오류', '조건이 맞지 않아 데이터를 다운로드할 수 없습니다.');
			return;
			
		} 

		var params = new Object();
				
		params.qid = rawDbParams[rawDbParamsTb]['refer-sql'];
		params.colMapping = rawDbParams[rawDbParamsTb]['cols'];
		params.length = params.colMapping.length;

		
		params.downloadFileName = "RawData_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');							
		$.extend(params, makeParams());
		
		params.begRawDate = $('#baseDate').val();

		templetDownLoad(params, null, null, function() {
			
			jAlert.error('오류', '다운로드에 실패했습니다.');
			
		}); 

	};
	
	/* 단말번호 검색을 위한 스크립트 */
	 function selectChangHandler(el) {
		
			var searchOption = $(el).val();
			var target = $('#' + $(el).data('target'));
			var plh;
			
			plh = (searchOption == 0) ? '수용가 번호/이름/주소 ...' : '단말기 번호/미터기 번호 ...'; 
			
			target.attr('placeholder', plh);
			
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
                	최소유량
              </h1>

              

              <!-- search box -->
              <div class="ml-auto d-flex">
              
	            <!-- <div class="d-flex align-items-center px-lg-0">              
	              	<div class="bcard d-flex align-items-center p-2" id="description"></div>						
				</div> -->
				
				
              
                <div class="d-flex align-items-center px-lg-0">              
             
	                <div class="d-flex align-items-center" style="padding: 0 20px 0 0;">
	              		<input type="date" class="form-control" id="toDate">
	              	</div> 
	              	
	              	<div class="d-flex align-items-center" style="padding: 0 20px 0 0;">
              		<select data-placeholder="선택" id="searchOptionSelect" class="form-control border-1p" onchange="selectChangHandler(this);" data-target="searchInput">
	                  	<option value="0">수용가 정보로 검색</option>
	                  	<option value="1">단말,미터기로 검색</option>					                  	
	                  </select>
              	</div>
                  
                  <div class="d-flex align-items-center mx-4 mx-lg-0">
	                <i href="#none" class="fa fa-search mr-n35 text-black"></i>
	                <input type="text" id="searchInput" placeholder="수용가 번호/이름/주소 ..." class="pl-45 text-black form-control form-control-lg bgc-transparent brc-yellow-tp3 brc-on-focus border-none border-b-1 radius-0 shadow-none">		                
	                <a href="#none" title="검색 문구 지우기" class="btn btn-outline-warning btn-brc-tp radius-3px py-2" onclick="$('#searchInput').val('')"> <i class="fa fa-eraser text-140"></i></a>						
		          </div>
                  
                  <!-- <input type="text" id="searchInput" placeholder="수용가 번호/이름 ..." class="form-control brc-blue-m1 brc-on-focus border-none border-b-2 radius-0 shadow-none bgc-transparent pl-35 mr-1"> -->
<!--                   <a href="#none" title="검색" class="btn btn-outline-blue btn-brc-tp radius-3px py-2" onclick="mainGrid.search();"> <i class="fa fa-sync-alt text-140"></i></a> -->
					                
                </div>
                
                <div class="d-flex align-items-center px-lg-0">               
                  <div class="card-toolbar align-self-center no-border">
                      <div class="dropdown dd-backdrop dd-backdrop-none-md">
                        <a class="btn btn-light-blue text-600 btn-xs mr-1"  onclick="$('#rawModal').modal({backdrop: 'static'});">
                          	일데이터
                          <i class="fa fa-download ml-1 text-90"></i>
                        </a>
                        
                      </div>
                    </div>
                </div>
                
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
	
	
	
	
	
	
	
	
	<div class="modal fade" id="rawModal" tabindex="-1" role="dialog">
     <div class="modal-dialog modal-dialog-scrollable" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title" id="exampleModalLabel2">
             	일데이터 다운로드
           </h5>

           <button type="button" class="close" data-dismiss="modal" aria-label="Close">
	          <span aria-hidden="true">&times;</span>
	        </button>
         </div>

         <div class="modal-body">
      
		
			<div class="form-group row">
                <div class="col-sm-3 col-form-label text-sm-right pr-0">
                  <label for="id-form-field-1" class="mb-0">
                    	기준 날짜
                  </label>
                </div>

                <div class="col-sm-6">
                  <input type="date" class="form-control " name="value-Elementes" id="baseDate"/>
                </div>
                
                <div class="col-sm-3">
                  <a href="#none" title="다운로드" class="btn btn-outline-blue btn-brc-tp radius-3px py-2" onclick="rawDataDownload();"> <i class="fa fa-download text-140"></i></a>
                </div>                
              </div>
              

         </div>

         
       </div>
     </div>
   </div>
	
	



	<script type="text/javascript" src="${contextPath}/resources/lib/chart.js/dist/Chart.js"></script>
	<%-- <script type="text/javascript" src="${contextPath}/resources/lib/sortablejs/dist/sortable.umd.js"></script> --%>
	

</body>



</html>

