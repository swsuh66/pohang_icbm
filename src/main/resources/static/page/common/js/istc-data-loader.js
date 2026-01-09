$.ajaxSelect = function(opt) {
	var result;
	var options = $.extend({}, opt);
	
	options.async = (options.async===false?false:true);
	options.type = (options.data?'POST':'GET');
	options.data = (options.data?JSON.stringify(options.data):null);	// data to be sent to the server
	options.contentType = 'application/json;charset=UTF-8';	// for send to server
	//contentType: "application/x-www-form-urlencoded; charset=UTF-8",
	//options.url : options.url;//ctrp +'query/json?qid=' + sql_id,
	options.dataType = (options.dataType ? options.dataType : 'json');	// The type of data that you're expecting back from the server
	
	options.success = function(response) { 
		if(response && (typeof response == 'string') )
			response = JSON.parse(response);
		if(opt.success)
			opt.success(response);
		
		result = response;
		
		if(opt.interval > 0)
			setTimeout($.ajaxSelect, opt.interval*1000, opt);
	};
	options.error = function(e) {
		if(opt.error)
			opt.error(e);
		/*else
			alert(	'\n처리중 에러가 발생했습니다.\n\n'+
				'('+e.status +') '+ e.statusText //+ 
				//(e.responseText?'\n'+e.responseText.trim():'')
				);*/
		result = e;
	};
	
	$.ajax(options);
	return result;
}

$.ajaxExcute = function(opt) {
	var result;
	var options = $.extend({}, opt);

	var data = opt.data;
	if( data && !(data instanceof Array) )
		data = [data];
	if(data)
		data = JSON.stringify(data);
	
	options.async = (options.async?true:false);
	options.type = (data?'POST':'GET');
	options.data = data;
	options.contentType = 'application/json;charset=UTF-8';
	//contentType: "application/x-www-form-urlencoded; charset=UTF-8",
	//options.url = options.url;
	options.dataType = 'json';
	options.success = function(response) {
		result = {success: true, response: response};
		if(opt.success)
			opt.success(result);
	};
	options.error = function(err) {
		result = {success: false, error: err};
		if(opt.error)
			opt.error(result);
	};
	
	$.ajax(options);
	return result;
}


function ajaxInsert(options) {
	if(!options.url)
		options.url = getContextPath() +'/query/json/insert?qid=' + options.sql;
	return $.ajaxExcute(options);
}
function ajaxUpdate(options) {
	if(!options.url)
		options.url = getContextPath() +'/query/json/update?qid=' + options.sql;
	return $.ajaxExcute(options);
}
function ajaxDelete(options) {
	if(!options.url)
		options.url = getContextPath() +'/query/json/delete?qid=' + options.sql;
	return $.ajaxExcute(options);
}

function ajaxSelect(options) {
	if(!options.url)
		options.url = getContextPath() +'/query/json?qid=' + options.sql;
	return $.ajaxSelect(options);
}

/******************************************************************************/


ajaxUrl = function(sql_id, parmeters) {
	var url = getContextPath() +'/query/json?qid=' + sql_id;
	if(parmeters) {
		for(var key in parmeters) url += '&'+ key +'='+ parmeters[key];
	}
	return url;
}

var dLoader = {
	loaderContainer: {},

	generateUUID : function() { // Public Domain/MIT
	    var d = new Date().getTime();
	    if (typeof performance !== 'undefined' && typeof performance.now === 'function'){
	        d += performance.now(); //use high-precision timer if available
	    }
	    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
	        var r = (d + Math.random() * 16) % 16 | 0;
	        d = Math.floor(d / 16);
	        return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16);
	    });
	}
};

dLoader.multiLoad = function(src_list) {
	var _getUUid = function() {
		for (key in dLoader.loaderContainer) {
			if(dLoader.loaderContainer[key] == undefined) {
				return key;
			}
		}
		return dLoader.generateUUID();
	}
	var uuid = _getUUid();
	dLoader.loaderContainer[uuid] = new _multilLoader(src_list, uuid);
}

function _multilLoader(src_list, uuid) {
	var _sources = src_list;
	var _proc_index = 0;

	var _internalSuccessHandler = function(transport, json) {
		var src = _sources[_proc_index++];
		var isLast = (_proc_index >= _sources.length)?true:false;
		var cbf = src.success;
		var sid = src.id;
		if(transport && cbf)
			cbf(sid, transport, isLast);
		
		if(isLast)
			dLoader.loaderContainer[uuid] = undefined;
		else
			_load();
	}
	var _internalErrorHandler = function(e) {
		var src = _sources[_proc_index++];
		var isLast = (_proc_index >= _sources.length)?true:false;
		
		src.error(src.id, e);
		dLoader.loaderContainer[uuid] = undefined;
	}
	
	var _load = function() {
		if(_proc_index >= _sources.length) return false;
		
		var src = _sources[_proc_index];
		$.ajaxSelect({
				url: src.url ? src.url : ajaxUrl(src.sql), 
				data:src.data, 
				success:_internalSuccessHandler, 
				error:src.error?_internalErrorHandler:null,
				timeout: 300000	// 5분 타임아웃
			});
	}

	_load();
}

//-----------------------------------------------------------------------------/

dLoader.asyncLoad = function(options) {
	dLoader.stopAsync(options.id);
	dLoader.loaderContainer[options.id] = new _asyncLoader(options);
};

dLoader.stopAsync = function(id) {
	var loader = dLoader.loaderContainer[id];
	if(loader) 
		loader.stopAsync();
	dLoader.loaderContainer[id] = undefined;
};


/******************************************************************************/
/*
 * 
 * options
 * 	@id			-> request id
 * 	@url		-> ajax url
 * 	@success	-> call-back function for success
 * 	@error		-> call-back function for success
 * 	@parameters	-> object for parameters
 * 	@interval	-> interval seconds for repeat call 
 */

//function _asyncLoader(id, url, callback, interval) {
function _asyncLoader(options) {
	this.id = options.id;
	this.url = options.url ? options.url : ajaxUrl(options.sql), 
	this.parameters = options.parameters;
	this.success = options.success;
	this.error = options.error;
	this.interval= options.interval;
	this.timer = 0;
	this.state = 0;

	var self = this;
	this.successHandler = function(transport, json) {
		if(self.state < 1) return;
		
		if(transport && self.success) {
			self.success(self.id, transport);
		}
		
		self.loadPost();
	};
	this.errorHandler = function(e) {
		//if(self.state < 1) return;
		
		if(e && self.error) {
			self.error(self.id, e);
		}
		
		self.loadPost();
	};


	this.loadAsync();
}
//_asyncLoader.prototype = new Object();
_asyncLoader.prototype.constructor = _asyncLoader;

_asyncLoader.prototype.loadPost = function() {
	if(this.interval) {
		this.state = 2;
		this.timer = setTimeout( this.loadAsync.bind(this), this.interval*1000);
	}
	else {
		this.timer = 0;
		this.state = 0;
	}
};

_asyncLoader.prototype.loadAsync = function() {
	
	if(this.timer) {
		clearTimeout(this.timer);
		this.timer = 0;
	}
	
	this.state = 1;
	$.ajaxSelect({
		url: this.url, 
		data: this.parameters, 
		success: this.successHandler, 
		error: ((this.error)?this.errorHandler:null),
		timeout: 300000	// 5분 타임아웃
	});
};

_asyncLoader.prototype.stopAsync = function() {
	if(this.timer) {
		clearTimeout(this.timer);
		this.timer = 0;
	}
	this.state = 0;
};


