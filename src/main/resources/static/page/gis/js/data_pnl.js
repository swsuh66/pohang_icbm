/**
 * @namespace {object} data_pnl
 * @description 데쉬보드 검친 현황 grid Functions
 */

/**
 * @method refreshGrid
 * @description jsGrid에 데이터를 그립니다.
 * @param {list} data
 * @returns none
 */
function refreshGrid(data) {
	
	if(data)
		dataGrid.finishLoad(data||[]);
	else
		dataGrid.command('refresh');
	
};

/**
 * @method updateSummary
 * @description 검침 현황 값을 계산해 append합니다.
 * @param {Array} data
 * @returns none
 */
var updateSummary = function(data) {
		
	$('.valueField.measVal').text(0);
	
	var allCnt = 0;
	if(data && data.length) {
		
		for(var i=0; i<data.length; i++) {
			
			var cnt = data[i].cnt;
			var statCd = data[i].statCd;
			
			var el = $('#measStatVal-' + statCd);
			
			el.text( cnt );
			el.removeClass('lightGray fs_b2').addClass('orangeText fs_b4');			
			
			allCnt += cnt;
			
		}

	}
	
	var cnt = '<span class="fs_b1"><small> / </small>'+ allCnt +'</span>';
	$('#measStatVal-00000000').append(cnt);

};


/**
 * @method initGrid
 * @description jsGrid초기화 과정을 거칩니다.
 * @param {Sting} jsGrid
 * @returns none
 */
function initGrid(container) {
    var colfnc = dataGrid.columnFunction;
    //var sortFnc = dataGrid.sortFunction;
    
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
        
        searchContainer: '#filt-text',
 
		gridHeaderClass: "table-header",
 
        fields: [
            { name: "statCd", 	title: "상태", 					type: "text", 	align:"center", width: 42, 		itemTemplate:colfnc},
            { name: "adminId",		title: "수용가번호<br>수용가명", 		type: "text", 	align:"left", 	width: 'auto', 	itemTemplate:colfnc},
            { name: "blkNm2",		title: "불록<br>구분", 			type: "text", 	align:"left", 	width: 120, 	itemTemplate:colfnc},
            { name: "rawCnt", 	title: "일간검침수<br>당일 | 30일", 	type: "text", 	align:"right", 	width: 87, 		itemTemplate:colfnc},
            { name: "measDt", 	title: "최종검침일시<br>최종검침값", 	type: "text", 	align:"right", 	width: 99, 	itemTemplate:colfnc }
            //{ name: "meas.obsDate", 	title: "검침일시", 	type: "text", 	align:"center", width: 70, itemTemplate:colfnc }
        ],
        rowClick: function(evt) {
        	
        	var pointSq = evt.item.pointSq;
        	mapCenterToPoint(pointSq);
        	
        },
		rowDoubleClick: function(evt) {
			
			movePageTo(evt.item);
			
        },
        loadStrategy: function() {			
        	
        	return new CustomPageLoadingStrategy(this, loadPointData);          	        	        	
        	
        }
    };
    
    return new DataGrid(container, opt);
}

dataGrid.scrollTo = function(item) {
	
	var row = dataGrid.grid.command('rowByItem', item);
	
	if(row && row.length)
		row[0].scrollIntoView();
}

/**
 * @method dataGrid.columnFunction
 * @description 표에 append할 데이터 값을 반환합니다.
 * @returns {String}
 */
dataGrid.columnFunction = function(value, item, c, d, e) {

	switch (this.name) {
	
	case 'adminId':
		value = '<span style="font-size:11px;" id="' + item.adminId + '">'+ item.adminId +'</span><br>'+ (item.custNm?item.custNm:'&nbsp;');		
		return value;
		
	case 'blkNm2':
		var ix = -1;
		
		if(value) {
			
			ix = value.indexOf(':');
			if(ix >= 0)
				value = value.substr(ix+1);
			
		}
		
		value = (value?value:'&nbsp;') +'<br>'+ item.useType +'&nbsp;'+ item.pipeDia +'<small>mm</small>';
		
		return value;
	case 'statCd':
		if(!item.statCd)
			return '-';
		
		return '<img src="'+ meterSttIcoSrc(item.statCd) +'"/><br><span style="font-size:11px;">'+ meterSttLbl(item.statCd) +'</span>'; break;
		
	case 'rawCnt':
		
		return kutil.v2n(item.rawCnt_0d, 1) +'<br>'+ kutil.v2n(item.rawCnt_30d, 1);
		
	case 'measDt':
		
		if(!item.measDt)
			return '-';
		
		var v1 = kutil.v2n(item.accuIv, 3) +'<span style="font-size:11px;"> ㎥</span>';
		var v2 = '<span style="font-size:11px;">'+ kutil.dateFormat(new Date(item.measDt), 'yy.mm.dd HH:MM') +'</span>' 
		return v2 +'<br>'+ v1;

	}
	
	return (value?value:this.name);
}

