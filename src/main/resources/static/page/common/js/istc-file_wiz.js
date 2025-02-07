/**
 * Step Wizard 및 File Grid 객체 입니다.
 */
var fileUp = {
	container: null,
	tb_info: null,
	parseData: null,
	fileGrid: null,
	modal: null,
	wizard: null,
	tokenKey: null
};

/**
 * Step Wizard 2페이지 전환 시 로직을 정의합니다.
 */
fileUp.loadPage2 = function(target) {
	
	var form = $(target).find('form');

	form[1].reset();
	
	$(form).aceWidget('startLoading');

	// 파일 파싱 요청
	$.ajax({
		url : $(form[0]).attr('action'),
		processData : false,
		contentType : false,
		data : new FormData(form[0]),
		type : 'POST',
		success : function(result) {

			fileUp.parseData = result;			
			fileUp.tokenKey = result.tokenKey;

			resetGrid(fileUp.parseData.data);

		},
		error : function(e) {
			
			fileUp.parseData = null;
			
			//fileUp.fileGrid.showNodata();
			fileUp.fileGrid.command('refreshData'); 
			
			jAlert.error('에러', errMsg(e.status));			
			
		},
		complete : function(result) {
			
			$('#isHeader').trigger('click');
			$('#trim').trigger('click');
			
			$(form).aceWidget('stopLoading');
		}
	});
};

/**
 * Step Wizard 1페이지 전환 시 로직을 정의합니다.
 */
fileUp.loadPage1 = function(target) {
	
	$('.table-header-selector').find('option:selected').removeAttr('selected');
	 
};

/**
 * Step Wizard를 초기화 합니다.
 */
fileUp.initStepWizard = function(con, reset) {

	this.wizard = $('#' + con).steps(fileUp.wiz_opt);
	
	this.setToolTips();
	
	if(this.modal) {			
		this.createCloseBtn();	
	}		
	
};

fileUp.setIsModal = function(con) {
	this.modal = con;	
}

fileUp.getTokenKey = function() {
	return this.tokenKey;	
}

/**
 * Step Wizard에 모달창 닫기 버튼을 만듭니다.
 */
fileUp.createCloseBtn = function() {
	
	var btn = $('<a>').attr({
								title: '작업을 취소합니다.', 
								role: 'menuitem'
							})
							.text('취소')
							.on('click', closeFileModal);	
	
	var ul = $('<ul>').addClass('cancel').append(btn);
	
	this.wizard.find('.actions.clearfix').append(ul);
		
};

/**
 * Step Wizard 관련 버튼에 tool tip을 설정합니다.
 */
fileUp.setToolTips = function() {
	
	var btn = this.wizard.find('.actions.clearfix a');
	
	$(btn[0]).attr('title', '이전 단계로 돌아갑니다.');
	$(btn[1]).attr('title', '다음 단계로 진행합니다.');
	$(btn[2]).attr('title', '최종적으로 데이터를 저장합니다.');

}

/**
 * 파일을 파싱한 데이터를 출력할 grid를 초기화 설정을 진행 합니다.
 */
fileUp.initFileGrid = function(con, dbParams) {

	this.tb_info = dbParams;
	var tb_meta = Object.keys(this.tb_info)[0];
	var colList = this.tb_info[tb_meta].cols;
		
	this.createDataGrid(con, colList);

};

/**
 * 파일을 파싱한 데이터를 출력할 grid를 초기화 설정을 진행 합니다.
 */
fileUp.createDataGrid = function(con, colList) {
	
	var fields = new Array();
	
	colList.forEach(function(item) {
		fields.push({
			name : item.name,
			title : item.title,
			type : 'text',
			width : 150
		});
	});
	
	var opt = fileUp.grid_opt;
	opt.fields = fields;

	this.fileGrid = new DataGrid(con, opt);		
	this.container = con;
	
};

/**
 * Grid의 필드를 다시 설정해야 할 시 header 순서에 맞추어 순서를 다시 맞춥니다.
 */
fileUp.reconstructGridFields = function(headers) {
	
	var reconCols = new Array();
			
	var tb_meta = Object.keys(this.tb_info)[0];
	var cols = this.tb_info[tb_meta].cols;

	cols.forEach(function(item, i) {

		for(var j=0; j < headers.length; j++) {
			
			if( headers[j] == item.name ) {
									
				reconCols[j] = item;
				break;
				
			} 
				
		}

	});

	this.tb_info[tb_meta].cols = reconCols;
	
	return reconCols;

};


/**
 * grid를 초기화하고 다시 그립니다.
 */
function resetGrid(data) {
	/**
	 * 사용자 지정 테이블 데이터 중 헤더에 해당하는 요소를 얻습니다.
	 */
	var getHeader = function(data) {

		var headers = new Array();

		var tb_meta = Object.keys(fileUp.tb_info)[0];
		var cols = fileUp.tb_info[tb_meta].cols;

		var nmList = data[0];

		if (!nmList)
			return headers;

		if ($('input[name="isHeader"]').is(":checked")) { // 헤더 포함

			for (var i = 0; i < nmList.length; i++) {
				var isFind = false;

				for (var j = 0; j < cols.length; j++) {

					if (nmList[i] == cols[j].title) {

						headers[i] = cols[j].name;
						isFind = true;

						break;
					}
				}

				if (!isFind)
					headers[i] = 'error';
			}

			return headers;
		}

		cols.forEach(function(item, i) {
			headers[i] = item.name;
		});

		return headers;
	};
	
	var headers = getHeader(data);

	if (headers.indexOf('error') > -1) {

		jAlert.error('오류', '입력할 수 없는 데이터입니다.<br />데이터를 다시 확인해주세요.');
		fileUp.fileGrid.showNodata();

		return;
	}

	var strRow = $('input[name="isHeader"]').is(":checked") ? 1 : 0;
	var trim = $('input[name="trim"]').is(":checked") ? true : false;

	var obj = {
		headers : headers,
		data : data,
		strRow : strRow,
		trim : trim
	}

	if(fileUp.fileGrid)
		fileUp.createDataGrid( fileUp.container, fileUp.reconstructGridFields(headers) )
	
	fileUp.fileGrid.command('refreshData', obj);

}

/******************************************************************************/
/*
 * 
 */

/**
 * step wizard 옵션입니다.
 */
fileUp.wiz_opt = {
	headerTag : "h3",
	bodyTag : "form",
	transitionEffect : "slideLeft",
	autoFocus : true,

	onStepChanging : function(event, currentIndex, newIndex) {

		if (currentIndex == 0 && newIndex == 1) {
			
			fileUp.loadPage2(this);

		} else if (currentIndex == 1 && newIndex == 0) {
			
			fileUp.loadPage1(this);
			
		}

		return true;
	},
	onFinishing : function(event, currentIndex) {
		
		if(fileUp.parseData){
			confirmData(this); // post insert data
		}			
		
	},
	labels : {
		finish : "저장",
		next : "다음",
		previous : "이전"
	}
};


/**
 * file grid 옵션입니다.
 */
fileUp.grid_opt = {
	height: "100%",
	width: "93%",
	gridHeaderClass : "table-header",
	headerRowRenderer : function() {
		var $tr;
		var $result;
		var grid = this;

		var prepareTh = function(field) {

			return $("<th style='height:37px; width:150px;'>")
					.addClass(grid.headerCellClass).addClass(('headercss' && field['headercss']) || field.css)							
					.addClass(field.align ? ("jsgrid-align-" + field.align) : "");
							
		};

		var prepareSelector = function(fields) {

			var sel = $("<select>").css({'color' : 'black'}).addClass('table-header-selector').attr('disabled', true).css('border', '0px');
			var opt = $("<option>").attr('id', 'error').html('지정하세요.');

			sel.append(opt);

			fields.forEach(function(item) {

				opt = $("<option>");
				opt.attr('id', item.name).html(item.title);
				sel.append(opt);

			});

			sel.change(function() {

				var elId = $(this).find('option:selected').attr('id');

				$(this).find('option').removeAttr('selected');
				$('select.table-header-selector').find('option[id="' + elId + '"]:selected').removeAttr('selected');

				$(this).find('option[id="' + elId + '"]').attr('selected', 'selected');
						
				var selList = $('select.table-header-selector');

				for (var i = 0; i < selList.length; i++) {

					var seleted = $(selList[i]).find('option[selected="selected"]');

					if (seleted.length < 1) {

						$(selList[i]).find('option[id="error"]').attr('selected', 'selected');

					}

				}
			});
			return sel;
		};

		$tr = $("<tr>").height(0).addClass(grid.headerRowClass);
		$result = $tr;

		var fields = grid.fields;

		grid.fields.forEach(function(field, index) {

			var selEl = prepareSelector(fields);
			var $th = prepareTh(field).html(selEl).addClass(grid.headerCellClass)
												  .addClass('header-cell-white')
												  .attr("name", field.name).appendTo($tr);					
		});
		

		return $result.add($tr);
	},
	refreshData : function(data) {		

		var reDt = data;

		if (data) {

			this._setHeaderSelector(data.headers);			
			reDt = this._reconstructData(data.headers, data.data, data.strRow, data.trim);
			
			reDt = refactoryTxt(reDt);
			
			this.option("data", reDt);

		} else {

			this.option("data", []);
			//this.showNodata();
		}

	},
	_setHeaderSelector : function(headers) {
		
		var el = $('.table-header-selector');		
		el.find('option:selected').removeAttr('selected');

		headers.forEach(function(item, index) {
			
			$(el[index]).find('option[id="' + item + '"]').attr('selected', 'selected');

		});

	},	
	_reconstructData : function(headers, data, strRow, trim) {

		var reconData = new Array();
		var obj = null;

		data.forEach(function(item, i) {

			if (i >= strRow) {
				obj = new Object();

				item.forEach(function(item, j) {

					if (typeof item === 'string' && trim)
						item = item.trim();

					obj[headers[j]] = item;

				});

				reconData.push(obj);
			}

		});

		return reconData;

	}

};




/******************************************************************************/
/*
 *	JSP global funciton 
 */

function refactoryTxt(reDt) {
	
	var reFacTxt;
	var limitLen = 15;
	var cutStr = function(txt) {
		
		if( txt.length > limitLen ) {
								
			txt = txt.substr(0,txt.length-1);			
			cutStr(txt);
			
		} else {
			
			reFacTxt = txt + '...';					
			return;
		}
	}
	
	reDt.forEach(function(item, i) {
		
		var keys = Object.keys(item);					
		for(var i=0 ; i<keys.length ; i++) {
			
			var key = keys[i];
			var txt = item[key];
			
			if( txt != null &&txt.length > limitLen ) {
				
				cutStr(txt);
				item[key] = reFacTxt;
				
			} 										
			
		}				
		
	});
	
	return reDt;
	
}

/**
 * 파일이 바뀔 때 마다 동작합니다.
 */
function fileHandleChange(el) {

	var filename = '파일을 첨부해 주세요.';

	if (window.FileReader) { // 브라우저가 local 파일을 읽을 수 있는 reader api를 지원 할 시

		if ($(el)[0].files[0])
			var filename = $(el)[0].files[0].name;

	} else { // 브라우저가 local 파일을 읽을 수 있는 reader api를 지원 하지 않을 시

		if ($(el).val())
			var filename = $(el).val().split('/').pop().split('\\').pop();

	}

	$(el).siblings('.upload-name').val(filename);

}

/**
 * 첫 행 헤더 및 공백 제거 체크박스 체크/해제 시 동작하여 테이블을 reset 합니다.
 */
function chkboxHandleChange(el) {

	var nm = $(el).attr('name');

	if (fileUp.parseData)
		resetGrid(fileUp.parseData.data);
}

/**
 * 파일 첨부 설정에서 여러 조건을 선택할 시 선택에 따라 동작합니다.
 */
function selectorHandleChange(el) {

	var nm = $(el).attr('name');
	var val = $(el).find('option:selected').val();

	if (nm == 'fileType') {

		var $sel = $('select[name="delimeter"]');

		$sel.find('option').prop('selected', false);
		$sel.prop('disabled', true);
		$sel.find('option').prop('disabled', false);
		
		setLimitFileSelect(val);

		if (val == 1 || val == 2) { // CSV 파일 or 텍스트 파일 

			$sel.prop('disabled', false);

		}

		if (val == 1) { // CSV 파일		

			$sel.find('option').prop('disabled', true);
			$sel.find('option[value=","]').prop('disabled', false);
			$sel.find('option[value=","]').prop('selected', true);

		}

	}

}

/**
 * 선택한 파일 타입에 맞게 해당 파일만 선택할 수 있게 합니다.
 */
function setLimitFileSelect(type) {
	
	var el = $('input[type="file"]');
	
	el.removeAttr('accept');
	
	switch ( Number(type) ) {							
		case 0: el.attr('accept', '.xlsx'); break;
		case 1: el.attr('accept', '.csv');  break;
		case 2: el.attr('accept', '.txt');  break;	
		case 4: el.attr('accept', '.xml');  break;
	}
	
}

/**
 * 파일 업로드 설정 모달 창을 닫습니다.
 */
function closeFileModal() {
	
	/*jAlert.confirm('알림', '등록을 취소하시겠습니까?', function() {		
        if (this.val()) {

			if(fileUp.modal) {
				
				$('#' + fileUp.modal).modal('hide');
				
			}					
			
			resetAllFileUpForm();
        }
    });*/
	
	if(fileUp.modal) {
		
		$('#' + fileUp.modal).modal('hide');
		
	}					
	
	resetAllFileUpForm();

}



/**
 * 파일 import에 관한 모든 폼과 wizard를 reset 시킵니다.
 */
function resetAllFileUpForm() {
	
	var form = fileUp.wizard.find('form');

	form[0].reset(); 																	// 파일 업로드 페이지 모든 form reset
	
	setLimitFileSelect( form.find('select[name="fileType"] option:selected').val() ); 	// 파일 선택 제한 reset
	
	$('.table-header-selector').find('option:selected').removeAttr('selected');			// header selector reset
	
	if(fileUp.wizard.data("state").currentIndex != 0) {
		fileUp.wizard.steps('reset'); 													// step wizard reset
	}	
			
	fileUp.fileGrid.command('refreshData'); 											// 파일 grid reset																	

}

/**
 * 실제 데이터를 서버에 저장 요청합니다.
 */
function confirmData(el) {
	
	var data = new Object();
	var colMapping = new Array();
	var tb_meta = Object.keys(fileUp.tb_info)[0];

	data.tokenKey = fileUp.parseData.tokenKey;
	data.startRow = $('input[name="isHeader"]').is(":checked") ? 2 : 1;
	data.trim = $('input[name="trim"]').is(":checked") ? 1 : 0;
	data.referSql = fileUp.tb_info[tb_meta]['refer-sql'];
	data.exSql = fileUp.tb_info[tb_meta]['excute-sql'];
	data.afterSql = fileUp.tb_info[tb_meta]['after-sql'];

	var cellEl = fileUp.wizard.find('.jsgrid-header-cell');

	for (var i = 0; i < cellEl.length; i++) {

		var mappingObj = {
			id:	$(cellEl[i]).find('select option:selected').attr('id'),
			index: i
		};	

		colMapping.push(mappingObj);
	}

	data.colMapping = colMapping;	
	
	var pageIndex = fileUp.wizard.data("state").currentIndex;
	var form =$(el).find('form')[pageIndex];

	$.ajaxExcute({	
		url : $(form).attr('action'),
		data : data,
		async : true,
		beforeSend : function() {
			
			$(form).aceWidget('startLoading');
			
		},
		success : function(result) {
	
			resetAllFileUpForm(); // wizard 안의 모든 요소 reset
			
			if(fileUp.modal) 
				$('#' + fileUp.modal).modal('hide'); // 파일 첨부 모달 페이지 닫음;	
			
			doCreateCompleteLogic(result.response);
			

		},
		error : function(result) { // 오류 발생		

			var code = result.error.status;
			var txt = result.error.getResponseHeader('errMsg');
			
			jAlert.error('에러:' + code, errMsg(code, txt));
			
			if(code == 404)
				resetAllFileUpForm();
			
			

		},
		complete : function(result) {
			
			$(form).aceWidget('stopLoading');
			
		}
	});

}

/**
 * 오류 메시지를 return합니다.
 */
function errMsg(code, txt) {

	if (typeof code == 'string')
		return code;

	switch (code) {

		case 400:
			return '파일이 첨부되지 않았습니다.';		
		case 405:
			return '다른 사용자가 기능을 사용중입니다. 잠시후에 다시 이용해 주세요.';
		case 415:
			return '첨부 파일과 설정이 맞지 않거나 데이터가 존재하지 않습니다.';
		case 501:
			return '참조 할 데이터가 없거나 부족합니다. 관리자에게 문의하세요.';
		case 20001:
			return '참조 할 데이터가 없거나 부족합니다. 관리자에게 문의하세요.';				
		default:
			
			return '알 수 없는 오류가 발생했습니다. 관리자에게 문의하세요.';

	}

};
/*
function getDetailErrorMsg(custErrMsg) {
	
	var msg;
	var idx = custErrMsg.indexOf('ERROR:');
	var lIdx = custErrMsg.indexOf('### The error may involve');		

	
	if(idx > 0) {
		
		msg = custErrMsg.substring(idx,lIdx);
		break;
		
	}
	
	return msg;	
	
};*/
