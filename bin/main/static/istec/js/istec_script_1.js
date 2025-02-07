$(document).ready(function(){
	
	var _ctx = window.CONTEXT_PATH;
	
	var $doc = $(document);
	var $cal = $doc.find('input#rs-sunshine-calendar-day');
	
	//========== # start of ISTC_F2.jsp ==========
	
	var $modal = undefined;
	
	var fd = new FileDownloader({
		fileName : 'result'
		, timeUnit : 'month'
		, header : false
		, option : 'mapper'
		, mapperId : 'getDatDownloadList'
		, fileType : 'dat'
		, setDoubleQuotes : false
		, delimiter : ''
		, loadText : '.dat 파일 다운로드 중...'
	});
	
	fd.onSuccess = function(){
		gbAlert.alert('success', '', 'dat 파일 다운로드 완료');
		$modal.modal('hide');
	};
	
	$doc.on('click', 'a#is-dat-download', function(){
		$modal = $('div#dat-download-modal');
		
		if($modal){
			fn_createIstecF2Cal();
			$modal.modal('show');
		}
		
	});
	
	$doc.on('click', 'button#dat-download-btn', function(){
		var pv = $cal.val().replace('-', '');
		
		
		gb.promise().then(function(res, rej, data){
			
			var c = gb.await.post('/istec/countDatDownloadList.do', {yyyymm : pv}).result;
			
			if(1 > c){
				gbAlert.alert('info', '', '지정 년월에 해당하는 데이터는 존재하지 않습니다.');
				return false;
			}else{
				res();
			}
		}).then(function(res, rej, data){
			fd.setData({ yyyymm : pv });
			fd.download();
			res();
		}).catch(function(e){
			console.error(e);
		});
	});
	
	//========== end of ISTC_F2.jsp ==========
	
	var fn_createIstecF2Cal = function(){
		var open = false;
		
		$cal.datepicker({
			format: 'yyyy-mm'
			// , startDate: '-0d'
			, viewMode: "months"
			, minViewMode: "months"
			, autoclose : true
			, calendarWeeks : false
			, clearBtn : false	
			, disableTouchKeyboard : false
			, immediateUpdates: false
			, templates : {
				leftArrow: '<i class="fas fa-angle-left"></i>'
				, rightArrow: '<i class="fas fa-angle-right"></i>'
			}
			, showWeekDays : true
			, todayHighlight : true
			, weekStart : 0
			, language : 'ko'
		}).on('changeDate', function(){
			open = !1;
		});
		
		$(document).on('click', 'button.digital-calendar-button', function(e){
			e.preventDefault();
			e.stopImmediatePropagation();
			
			if(open){
				$cal.datepicker('hide');
				open = !1;
			}else{
				$cal.datepicker('show');
				open = !0;
			}
		});
		
		$cal.val(gb.getYMD(0, 2));
		
	}
	
});