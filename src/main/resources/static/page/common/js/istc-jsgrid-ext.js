var jgexp = {};

jgexp.json2csv = function(jsgrid) {
	var data = jsgrid.command("option", "data");
    var array = typeof objArray != 'object' ? JSON.parse(data) : data;

    var str = '';

    for (var i = 0; i < array.length; i++) {
        var line = '';

        for (var index in array[i]) {
            line += array[i][index] + ',';
        }

        // Here is an example where you would wrap the values in double quotes
        // for (var index in array[i]) {
        //    line += '"' + array[i][index] + '",';
        // }

        line.slice(0,line.Length-1); 

        str += line + '\r\n';
    }
    return str; 
}

jgexp.table2csv = function(jsgrid, transforms) {
	return jsgrid.command("exportData", {
		type: "csv", //Only CSV supported
	    subset: "all" | "visible", //Visible will only output the currently displayed page
	    delimiter: ",", //If using csv, the character to seperate fields
	    includeHeaders: true, //Include header row in output
	    encapsulate: true, //Surround each field with qoutation marks; needed for some systems
	    newline: "\r\n", //Newline character to use
	    
	  //Takes each item and returns true if it should be included in output.
	    //Executed only on the records within the given subset above.
	    filter: function(item){return true},
	    
	    //Transformations are a way to modify the display value of the output.
	    //Provide a key of the field name, and a function that takes the current value.
	    transforms: transforms
	    /*transforms: {
	        "obsDate": function(value){
	        	return kutil.dateFormat(value, 'yyyy-mm-dd HH:MM');
	        	}
	    }*/
	});
}

jgexp.data2csv = function(jsgrid, transforms, data){
    var fields = jsgrid.jsGrid("option", "fields");
    var titleArray = typeof fields != 'object' ? JSON.parse(fields) : fields;
    //console.log(titleArray);
    var str = '';

    var line = '';
    for (var i = 0; i < titleArray.length; i++) {
        line += titleArray[i]['title'] + ',';
    }

    str += line.substring(0,line.length-1) + '\r\n';
    //console.log(str);

    var dataArray = typeof data != 'object' ? JSON.parse(data) : data;
    //console.log(dataArray);
    for (var j = 0; j < dataArray.length; j++) {
        var tmpLine = '';
        for (var i = 0; i < titleArray.length; i++) {
            var titleName = titleArray[i]['name'];
            var dataOne = dataArray[j][titleName];
            if (transforms.hasOwnProperty(titleName)){
                tmpLine += transforms[titleName](dataOne) + ',';
            }else{
                tmpLine += ((dataOne == 0 || dataOne) ? dataOne : '-') + ',';
            }
        }
        str += tmpLine.substring(0,tmpLine.length-1) + '\r\n';
    }
    //console.log(str);
    return str;
}

jgexp.download2 = function(jsgrid, transforms, data, filename, fileType){
    var csv = this.data2csv(jsgrid, transforms, data);
    jgexp.download(jsgrid, transforms, csv, filename, fileType);
}

jgexp.download = function(jsgrid, transforms, inCsv, filename, fileType) {
	var csv = "";
	if(inCsv){
        csv = inCsv;
	}else{
        //var csv = this.json2csv(objArray);
        csv = this.table2csv(jsgrid, transforms);
    }
    //console.log("csv", csv);
	if(!filename)
		filename = "report_"+ kutil.dateFormat( new Date(), 'yymmddHHMMss');

	var info = browserInfo().split(' ');
	var br =  info[0];
	var ver =  info[1];

    if (br == 'IE' && ver < 11) {
		alert('구버전 Internet Explore에서는 지원되지 않는 기능입니다.');
		return;
	}

	if ((br == 'IE' && ver >= 11) || br == 'Edge') {						// ms

		var textFileAsBlob = new Blob([ csv ], {type : 'text/plain'});
		
		window.navigator.msSaveBlob(textFileAsBlob, filename + '.' + (fileType ? fileType : "csv"));

	} else {																// chrome, firefox

		var uri = 'data:text/csv;chartset=UTF-8,\uFEFF' + encodeURI(csv);
		
		var link = document.createElement("a");
		link.href = uri;
		link.target = '_blank';
		link.style = "visibility:hidden";
		
		link.download = filename + '.' + (fileType ? fileType : "csv");

		document.body.appendChild(link);
				
		link.click();
		
		document.body.removeChild(link);
		
	}

}


/******************************************************************************/
/*
 * 
 */

function DataGrid(container, opt) {

	var _grid = null;

	var _config = {
			
		
		refreshData: function(data) {
		    var vsp = this._body.scrollTop();
		    //var hsp = this._body.scrollLeft();
		    
		    this._sortData(data);
		    this.option("data", data);
		    
		    this._body.scrollTop(vsp);
		},
	
		headerRowRenderer: function() {
	
		    var $tr;
		    var $result;
		    var grid = this;
	
		    var prepareTh = function(field) {
		        return $("<th style='height:37px;'>").addClass(grid.headerCellClass)
		            .addClass(('headercss' && field['headercss']) || field.css)
		            .addClass(field.align ? ("jsgrid-align-" + field.align) : "");
		    };
		    
		    /************************************************/
	
		    $tr = $("<tr>").height(0);
		    grid._eachField(function(field, index) {
		    	$("<th>").width(field.width).appendTo($tr);
		    });
		    $result = $tr;
		    
		    /************************************************/
		    
		    $tr = $("<tr>").addClass(grid.headerRowClass);
	
		    grid._eachField(function(field, index) {
		    	if(!field.hasGroup) {
		    		var $th = prepareTh(field).attr("rowspan", 2).html(field.title).addClass(grid.headerCellClass).attr("name", field.name).appendTo($tr);
		    		if(grid.sorting && field.sorting && !field.sortingDisabled) {
		            	$th.addClass('jsgrid-header-sortable');
		        		$th.on("click", function() {
		                	grid.sort(index);
		            	});
		            }
		    	}
		    	else {
		        	var group = field.group;
		    		if(group) {
		    			var $th = prepareTh(group).attr("colspan", group.columns).text(group.title).addClass('jsgrid-header-group').appendTo($tr);
		    		}
		    	}
		    });
		    $result = $result.add($tr);
		    
		    /************************************************/
		        
		    $tr = $("<tr>").addClass(grid.headerRowClass);
		    grid._eachField(function(field, index) {
		    	if(field.hasGroup) {
	
		        	//var $th = $("<th>").text(field.title).width(field.width).appendTo($tr);
		        	var $th = prepareTh(field).text(field.title).addClass(grid.headerCellClass).attr("name", field.name).appendTo($tr);
		            
		            if(grid.sorting && field.sorting && !field.sortingDisabled) {
		            	$th.addClass('jsgrid-header-sortable');
		        		$th.on("click", function() {
		                	grid.sort(index);
		            	});
		            }
		    	}
		    });
		    $result = $result.add($tr);
		    
		    /************************************************/
		    
		    return $result;
		},
	
		rowRenderer: function(item, itemIndex) {
		    var $result = $("<tr>");
		    
		    $result.bind('click', function(e) {
		    	$(this).parents('.jsgrid-table').find('tr.selected').removeClass('selected');	
		    	$(this).addClass('selected');
		    });
		    
		    this._renderCells($result, item, itemIndex);
			return $result ;
		},
		_renderCells: function($row, item, itemIndex) {
		    this._eachField(function(field) {
		        $row.append(this._createCell(item, field, itemIndex));
		    });
		    return this;
		},
		_createCell: function(item, field, itemIndex) {
		    var $result;
		    var fieldValue = this._getItemFieldValue(item, field);
		
		    var args = { value: fieldValue, item : item, itemIndex: itemIndex };
		    if($.isFunction(field.cellRenderer)) {
		        $result = this.renderTemplate(field.cellRenderer, field, args);
		    } else {
		        $result = $("<td>").append(this.renderTemplate(field.itemTemplate || fieldValue, field, args));
		    }
	
		    return this._prepareCell($result, field);
		},
		_setSortingCss:	function() {
		    var fieldIndex = $.inArray(this._sortField, this.fields); // this is how you know the sorting field index
	
		   	var ths = this._headerRow.find("th");
		   	for(var ix=0; ix<ths.length; ix++) {
		   		if($(ths[ix]).attr('name') == this.fields[fieldIndex].name) {
		   			$(ths[ix]).addClass(this._sortOrder === "asc" ? this.sortAscClass : this.sortDescClass);
		   			break;
		   		}
		   	}
		},
		_sortData: function(target) {
	        var sortFactor = this._sortFactor(),
	            sortField = this._sortField;
	
	        if(sortField) {
	        	if(!target) target = this.data;
	        	
	        	var sortFnc =($.isFunction(sortField.sorter) ? sortField.sorter : null);
	        	if(sortFnc) {
	        		var grid = this;
	                target.sort(function(item1, item2) {
	                    return sortFactor * sortFnc(sortField, item1, item2);
	                });
	        	}
	        	else {
	        		var fieldFnc = this._getItemFieldValue;
	        		target.sort(function(item1, item2) {
	        			var comp = 0;
	        			var v1 = fieldFnc(item1, sortField);	//item1[sortField.name];
	        			var v2 = fieldFnc(item2, sortField);	//item2[sortField.name];
	        			if(v1 != null && v2 != null)
	        				comp = sortField.sortingFunc(v1, v2);
	        			else if(v1 == null && v2 != null)
	        				comp = -1;
	        			else if(v1 != null && v2 == null)
	        				comp = 1;
	        			else
	        				comp = 0;
	        			
	        			return sortFactor * comp;
	                    //return sortFactor * sortField.sortingFunc(item1[sortField.name], item2[sortField.name]);
	                });
	        	}
	            /*target.sort(function(item1, item2) {
	                return sortFactor * sortField.sortingFunc(item1[sortField.name], item2[sortField.name]);
	            });*/
	        }
	    },
	    setSort: function(name, order) {
	    	//var field = this._getField(name);
			this._setSortingParams(name, order);
			this._setSortingCss();
		},
		clearSort: function() {
			this._resetSorting();
		},
		
	    loadParams: function() {
	       return this._loadStrategy.loadParams();      
	    },
	    finishLoad: function(data) {
	       this._loadStrategy.finishLoad(data);
	    },
	    setItemCount: function(cnt) {
	       this._loadStrategy.setItemCount(cnt);
	    },
	    
	    getItemCount: function() {
	       return this._loadStrategy.getItemCount();
	    },
	    
	    resetSorting: function() {
	       return this._loadStrategy.resetSorting();
	    },
	    
	    showNodata: function() {
	    	
	    	this._container.find(".jsgrid-nodata-row").find("td.jsgrid-cell")
			.css({
				"height" : "60px"
				, "color" : "#29a3cc"
			})
			.text("검색된 내용이 없습니다.");	    	
	    	
	    },
	    
    
		data: [],
		noDataContent:null
	};
	
	/* for custom pageLoading, 190619, kyo, */
	this.loadParams = function() {
    	return _grid.jsGrid("loadParams");
    }
    this.finishLoad = function(data) {
    	_grid.jsGrid("finishLoad", data);
    }

	this.command = function(cmd, key, value) {
		return _grid.jsGrid(cmd, key, value);
	}

    this.jsGrid = function(cmd, key) {
        return _grid.jsGrid(cmd, key);
    };
	
	this.showNodata = function() {
		_grid.jsGrid("option", "container").find(".jsgrid-nodata-row").find("td.jsgrid-cell")
			.css({
				"height" : "60px"
				, "color" : "#29a3cc"
			})
			.text("검색된 내용이 없습니다.");
	};

	this.search = function() {
		
		var id = _grid.jsGrid('option', 'searchContainer');
		if(!id) 
			return;
		
		var val = $(id).val();		
		_grid.jsGrid('option', 'searchParam', val);			
		
		
		var sOpt = _grid.jsGrid('option', 'searchOptionContainer');
		if(sOpt) {
			var val = $(sOpt).val();		
			_grid.jsGrid('option', 'searchOption', val);
		} 
			
				
		if( _grid.jsGrid("getItemCount") < 1 ) 		
			_grid.jsGrid("setItemCount", 1);
		
		this.command('openPage', 1);
		
	};
	
	this.resetSorting = function() {
		
		_grid.jsGrid("resetSorting");
		
	};
	
	this.init = function(container, opt) {
		
		$.extend(true, _config, opt);
		_grid = $('#'+ container ).jsGrid(_config);

	};
	
	
	this.init(container, opt);
	
	return this;
}




/** *************************************************************************** */
/*
 * 
 */

var CustomPageLoadingStrategy = function(grid, pageHandler) {
	
	this.pagingHandler = pageHandler;
    jsGrid.loadStrategies.PageLoadingStrategy.call(this, grid);
    
};
 
CustomPageLoadingStrategy.prototype = new jsGrid.loadStrategies.PageLoadingStrategy();
 
CustomPageLoadingStrategy.prototype.openPage = function() {
	
	if(this.pagingHandler && typeof this.pagingHandler == 'function')
		this.pagingHandler();
	
};

CustomPageLoadingStrategy.prototype.sort = function() {
	
	if(this.pagingHandler && typeof this.pagingHandler == 'function')
		this.pagingHandler();
	
};

CustomPageLoadingStrategy.prototype.finishLoad = function(data) {
   
   var isEmpty = false;
   
   if(data && data.length) 
      this._itemsCount = data[0].totalCount;      
   else {
	   
	  isEmpty = true;
      this._itemsCount = 0;
      
   }
      
   this._grid.option("data", data);
   
   if(isEmpty)
	   this._grid.showNodata();
   
};

CustomPageLoadingStrategy.prototype.setItemCount = function(cnt) {
	   
	this._itemsCount = cnt;
   
};

CustomPageLoadingStrategy.prototype.getItemCount = function() {
	
	return this._itemsCount;
	
};

CustomPageLoadingStrategy.prototype.resetSorting = function() {

	this._grid._resetSorting();
	
};

CustomPageLoadingStrategy.prototype.loadParams = function(count) {
      
   var grid = this._grid;      
      
   return {
       pageIndex: grid.option("pageIndex"),
       pageSize: grid.option("pageSize"),
       rnTop: grid.option("pageIndex") * grid.option("pageSize"),
       rnBottom: grid.option("pageIndex") * grid.option("pageSize") - grid.option("pageSize"),
       searchParam: grid.option("searchParam"),
       searchOption: grid.option("searchOption"),       
       sortField: grid._sortingParams().sortField,
       sortOrder: grid._sortingParams().sortOrder
   };

};

/*CustomPageLoadingStrategy.prototype.loadParams = function(count) {
	
	var grid = this._grid;
    return {
        pageIndex: grid.option("pageIndex"),
        pageSize: grid.option("pageSize"),
        rnTop: grid.option("rnTop"),
        rnBottom: grid.option("rnBottom"),
        searchParam: grid.option("searchParam")
    };
	
};
*/



/** *************************************************************************** */
/*
 * 
 */

var dataGrid = {grid:null};

dataGrid.command = function(cmd, key, value) {
	return this.grid.command(cmd, key, value);
};

dataGrid.showNodata = function() {
	this.grid.showNodata();
};

dataGrid.init = function(container, opt) {
	
	this.grid = new DataGrid(container, opt);
    return this.grid;
};
