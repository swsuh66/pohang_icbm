var dataGrid = {grid:null};


dataGrid.apply = function(data, container) {
	var sum = {crCnt1:null, crCnt2:null, curRat:null, curVlm:null, efVlm:null};
	if(data && data.length) {
		sum = {obsCnt1:0, obsCnt2:0, obsRat:0, obsVlm:0, effVlm:0};
		for(var ix=0; ix<data.length; ix++) {
			var item = data[ix];
			var meas = item.meas;
			//if(meas && meas.obsDate && meas.obsVlm && meas.effVlm) {
			if(meas && meas.obsValid == '1') {
				sum.obsCnt1 ++;
				sum.obsVlm += meas.obsVlm;
				sum.effVlm += meas.effVlm;
			}
			else {
				sum.obsCnt2 ++;
			}
		}
		sum.obsRat = sum.obsVlm / sum.effVlm * 100;
	}
	
	var text;
	
	text = kutil.v2n(sum.obsCnt1, 0);
	if(sum.obsCnt2)
		text += '<small style="color:gray;"> ('+ kutil.v2n(sum.obsCnt2, 0) +')</span>';
	$('#list_sum_cnt').html(text);
	$('#list_sum_rat').text(kutil.v2n(sum.obsRat, 1));
	$('#list_sum_vlm').text(kutil.v2n(sum.obsVlm/1000, 1));
	
	if(!this.grid)
		this.grid = this.init(data, container);
	else
		this.command("option", "data", data);
}			

dataGrid.command = function(cmd, key, value) {
	return this.grid.jsGrid(cmd, key, value);
}

dataGrid.init = function(data, container) {
    var colfnc = this.columnFunction;
    var sortFnc = dataGrid.sortFunction;
    
	//return $("#jsGrid").jsGrid({
    return $('#'+ container ).jsGrid({
        height: "100%",
        width: "100%",
 
        /* 
        heading: false,
        filtering: false,
        editing: true, 
        */
        sorting: true,
        paging: false,
        /*
        pageWholeSize : 100,
        pageSize: 10,	// 10까지.
        pageButtonCount: 2,
        deleteConfirm: "Do you really want to delete the client?", 
        */
		noDataContent:null,
 
		gridHeaderClass: "table-header",
        data: data,
 
        fields: [
            { name: "meterStateCd", title: "상태", 	type: "text", align:"center", width: 50, itemTemplate:colfnc },
            { name: "custNm",		title: "수용가", 	type: "text", align:"center", width: 'auto', itemTemplate:colfnc},
            { name: "adminId",		title: "수용가 번호", 	type: "text", align:"center", width: '20.0%', itemTemplate:colfnc},
            { name: "blkNm2",		title: "블록", 	type: "text", align:"center", width: '13.5%', itemTemplate:colfnc, sorter:sortFnc },
            { name: "useType",		title: "구분", 	type: "text", align:"center", width: '13.5%', itemTemplate:colfnc, sorter:sortFnc },
            { name: "meas.obsVlm", 	title: "일평사용량(ton)", 	type: "text", 	align:"right", width: '13.5%', itemTemplate:colfnc },
            { name: "meas.obsAcc", 	title: "최종검침값(ton)", 	type: "text", 	align:"right", width: '13.5%', itemTemplate:colfnc }
            //{ name: "meas.obsDate", 	title: "검침일시", 	type: "text", 	align:"center", width: 70, itemTemplate:colfnc }
        ],
        
        _sortData: function() {
            var sortFactor = this._sortFactor(),
                sortField = this._sortField;

            if(sortField) {
            	var sortFnc =($.isFunction(sortField.sorter) ? sortField.sorter : null);
            	if(sortFnc) {
            		var grid = this;
                    this.data.sort(function(item1, item2) {
                        return sortFactor * sortFnc(sortField, item1, item2);
                    });
            	}
            	else {
            		this.data.sort(function(item1, item2) {
                        return sortFactor * sortField.sortingFunc(item1[sortField.name], item2[sortField.name]);
                    });
            	}
                /*this.data.sort(function(item1, item2) {
                    return sortFactor * sortField.sortingFunc(item1[sortField.name], item2[sortField.name]);
                });*/
            }
        },


        /*
		{
            item: item,
            itemIndex: itemIndex,
            event: e
        }
		*/
        rowClick: function(evt) {
        	var pointSq = evt.item.pointSq;
        	mapCenterToPoint(pointSq);
        },
		rowDoubleClick: function(evt) {
        	//var equipSq = evt.item.equipSq;
        	openInfoWnd(evt.item);
        }
    });
}

dataGrid.sortFunction = function(sortField, item1, item2) {
	var ret = 0;
	if(sortField.name == 'blkNm2') {
		var sorter = jsGrid.sortStrategies['string'];
		ret = sorter(item1[sortField.name], item2[sortField.name]);
		if(ret == 0) {
			ret = sorter(item1.useType +'_'+ item1.pipeDia, item2.useType +'_'+ item2.pipeDia);
		}
	}
	return ret;
}
dataGrid.columnFunction = function(value, item, c, d, e) {
	
	//var valid = (item && item.meas && item.meas.obsValid == '1');
	var valid = (item && item.meas && item.useCd == '1');
	switch (this.name) {
	case 'blkNm2':
		var ix = -1;
		if(value) {
			ix = value.indexOf(':');
			if(ix >= 0)
				value = value.substr(ix+1);
		} else {
			value = '-';
		}
		return value;
	case 'useType':		
		value = item.useType +'&nbsp;'+ item.pipeDia +'<small>mm</small>';
		//value = item.useType +'&nbsp;'+ item.pipeDia +'<small>mm</small><br>'+ (value?value:'&nbsp;') ;
		return value;
	case 'meas.obsVlm':
		return kutil.v2n((valid?value:NaN), 0);
	case 'meterStateCd':
		value = value || '2';
		return '<img src="'+ meterSttIco(value) +'"/><br><span style="font-size:11px;">'+ meterSttLbl(value) +'</span>'; break;
	case 'meas.obsAcc':
		if(!item.meas || !item.meas.obsDate) {
			return '-';
		}
		return kutil.v2n((valid?value:NaN), 0) + '<span style="font-size:11px;">'+ kutil.dateFormat(new Date(item.meas.obsDate), 'mm.dd HH:MM') +'</span>';
		
	case 'meas.obsRat':
		return kutil.v2n((valid?value:NaN), 1);
	/*case 'meas.obsDate':
		if(!value || !valid) 
			return '-';
		var dt = new Date(value);
		return '<span style="font-size:11px;line-height:10px;color:gray;">'+
			kutil.dateFormat(dt, 'yy.mm.dd') +'</span><br><span style="font-size:11px;">'+
			kutil.dateFormat(dt, 'HH:MM:ss') +'</span>';*/
		//return kutil.dateFormat(new Date(a), 'yyyy.mm.dd HH:MM:ss');
	}
	
	return (value?value:this.name);
}

