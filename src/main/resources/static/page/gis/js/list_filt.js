/*
function updateFiltItems(data) {
	var blkArr = [], utpArr = [];
	var keys = {blk:{}, utp:{}};
	var lbl;
	
	for(var ix=0; ix<data.length; ix++) {
		var item = data[ix];
		
		lbl = item.blkNm2;
		if(lbl && !keys.blk[lbl]) {
			keys.blk[lbl] = 1;
			blkArr.push(item);
		}
		
		lbl = item.useType;
		if(lbl && !keys.utp[lbl]) {
			keys.utp[lbl] = 1;
			utpArr.push(lbl);
		}
	}
	
	var select = $("#filter-select");
	
	var rst = '';
	
	rst += '<option value="0"  class="select_opt" selected>전체</option>';

	rst += '<optgroup label="업종">';
	rst += '<option value="utp_1" class="select_opt">가정용</option>';
	rst += '<option value="utp_2" class="select_opt">일반용</option>';
	rst += '<option value="utp_3" class="select_opt">학교용</option>';
	rst += '</optgroup>';

	rst += '<optgroup label="상태">';
	rst += '<option value="stt_1" class="select_opt">정상 상태</option>';
	rst += '<option value="stt_2" class="select_opt">통신 장애</option>';
	rst += '<option value="stt_3" class="select_opt">누수 경고</option>';
	rst += '<option value="stt_4" class="select_opt">동파 경고</option>';
	rst += '<option value="stt_5" class="select_opt">비만 경고</option>';
	rst += '<option value="stt_6" class="select_opt">역류 상태</option>';
	rst += '<option value="stt_7" class="select_opt">BAT 경고</option>';
	rst += '</optgroup>';

	rst += '<optgroup label="블럭">';
	rst += '<option value="blk_0"  class="select_opt">미지정</option>';
	for(var ix=0; ix<blkArr.length; ix++) {
		rst += '<option value="blk_'+ item.blkSq +'">'+ item.blkNm2 +'</option>';	
	}	
	rst += '</optgroup>';
    	
	select.html( rst );
}*/


function filtSelectHandler() {
	//$('#filt-text').val('');
	
	filtListData();
	this.blur();
}
function filtInputHandler() {
	//$("#filter-select").prop('selectedIndex',0);
	
	filtListData();
	this.blur();
}

function filtInputResetHandler() {
	$('#filt-text').val('');
	
	filtListData();
	this.blur();
}
function filtSearchResetHandler() {
	$("#filter-select").prop('selectedIndex',0);

	filtListData();
	this.blur();
}

function filtListData() {
	var data = dsMap.getList('point_list');

	var value;
	
	value = $('#filt-text').val().trim();
	if(value) {
		$('#filt-text').blur();
		if(value.substr(0, 1) == '.')
			data = do_filtListData(data, 'pointSq', parseInt(value.substr(1)));
		else if(value.substr(0, 1) == '#')
			data = do_filtListData(data, 'amiSn', value.substr(1));
		else if(value.substr(0, 1) == '@')
			data = do_filtListData(data, 'meterId', value.substr(1));
		else
			data = do_filtListData(data, 'custNm', value);
		$("#filt-search-reset-btn").removeClass("btn-default").addClass("btn-warning");
	}
	else {
		$("#filt-search-reset-btn").removeClass("btn-warning").addClass("btn-default");
	}
					
	value = $('#filter-select').val();
	if(value) {
		if(value.substr(0, 4) == 'blk_') {
			value = parseInt(value.substr(4));
			data = do_filtListData(data, 'blkSq', value);
		}
		else if(value.substr(0, 4) == 'stt_') {
			value = value.substr(4);
			data = do_filtListData(data, 'sttCd', value);
		}
		else if(value.substr(0, 4) == 'utp_') {
			value = $('#filter-select option:selected').text();
			data = do_filtListData(data, 'useType', value);
		}
		else {
			if(value != '0')
				$("#filter-select").prop('selectedIndex',0);
			$("#filt-select-reset-btn").removeClass("btn-warning").addClass("btn-default");
		}
	}
	
	refreshGrid(data);
}

function do_filtListData(data, gubun, value) {
	if(gubun == 'blkSq') {
		data = $.grep(data, function(item) {
             return (value?(item.blkSq === value):(!item.blkSq));
        });
		$("#filt-select-reset-btn").removeClass("btn-default").addClass("btn-warning");
	}
	if(gubun == 'sttCd') {
		data = $.grep(data, function(item) {
			return (item && meterSttHasFlag(item, value)) ? true : false;
        });
		$("#filt-select-reset-btn").removeClass("btn-default").addClass("btn-warning");
	}
	else if(gubun == 'useType' && value) {
		data = $.grep(data, function(item) {
             return item.useType === value;
        });
		$("#filt-select-reset-btn").removeClass("btn-default").addClass("btn-warning");
	}
	else if(gubun == 'custNm' && value) {
		data = $.grep(data, function(item) {
             return (item.custNm.indexOf(value) > -1) || (item.adminId.indexOf(value) > -1);
        });
		$("#filt-search-reset-btn").removeClass("btn-default").addClass("btn-warning");
	}
	else if(gubun == 'pointSq' && value) {
		data = $.grep(data, function(item) {
			return (item.pointSq == value);
        });
		$("#filt-search-reset-btn").removeClass("btn-default").addClass("btn-warning");
	}
	else if(gubun == 'meterId' && value) {
		data = $.grep(data, function(item) {
			return (item.meterId.indexOf(value) > -1);
        });
		$("#filt-search-reset-btn").removeClass("btn-default").addClass("btn-warning");
	}
	else if(gubun == 'amiSn' && value) {
		data = $.grep(data, function(item) {
			return (item.amiSn.indexOf(value) > -1);
        });
		$("#filt-search-reset-btn").removeClass("btn-default").addClass("btn-warning");
	}
	
	
	return data;
}


function updateFiltItems(blkData) {
	/*var blkArr = [], utpArr = [];
	var keys = {blk:{}, utp:{}};
	var lbl;
	
	for(var ix=0; ix<data.length; ix++) {
		var item = data[ix];
		
		lbl = item.blkNm2;
		if(lbl && !keys.blk[lbl]) {
			keys.blk[lbl] = 1;
			blkArr.push(item);
		}
		
		lbl = item.useType;
		if(lbl && !keys.utp[lbl]) {
			keys.utp[lbl] = 1;
			utpArr.push(lbl);
		}
	}*/
	
	var select = $("#filter-select");
	
	var rst = '';
	
	rst += '<option value="0"  class="select_opt" selected>전체</option>';

	rst += '<optgroup label="업종">';
	rst += '<option value="utp_1" class="select_opt">가정용</option>';
	rst += '<option value="utp_2" class="select_opt">일반용</option>';
	rst += '<option value="utp_3" class="select_opt">학교용</option>';
	rst += '</optgroup>';

	if(blkData && blkData.length) {
		rst += '<optgroup label="블럭">';
		rst += '<option value="blk_0"  class="select_opt">미지정</option>';
		
		var lastLevel = 0;
		var prefix = '&nbsp; &nbsp;';
		for(var ix=0; ix<blkData.length; ix++) {
			var item = blkData[ix];
			
			while(item.level < lastLevel--) {
				rst += '</optgroup>';
			}
			
			var label = item.blkNm;
			if(item.level == 0)
				rst += '<optgroup label="'+ prefix + label +'">';
			else {
				label = kutil.repeat('&nbsp; &nbsp; ', item.level-1) + label;
				rst += '<option value="blk_'+ item.blkSq +'">'+ prefix + label +'</option>';
			}
			lastLevel = item.level;
			
			//var lbl = kutil.repeat('&nbsp; &nbsp; ', item.level) + item.blkCd +':'+ item.blkNm 
			//rst += '<option value="blk_'+ item.blkSq +'">'+ lbl +'</option>';
		}
		while(0 < lastLevel--) {
			rst += '</optgroup>';
		}
		
		rst += '</optgroup>';
	}

	rst += '<optgroup label="상태">';
	rst += '<option value="stt_00000000" class="select_opt">정상 상태</option>';
	rst += '<option value="stt_01000000" class="select_opt">Q4 초과</option>';
	rst += '<option value="stt_10000000" class="select_opt">통신 장애</option>';	
	rst += '<option value="stt_00010000" class="select_opt">누수 경고</option>';	
	rst += '<option value="stt_00000010" class="select_opt">BATT 경고</option>';
	rst += '</optgroup>';

	select.html( rst );
}
