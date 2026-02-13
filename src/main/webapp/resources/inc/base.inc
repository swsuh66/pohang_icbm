<script>
/*
* Title            : global definition
* Desc             : 개발팀 개발 작업시 편의를 위한 global definition 작성
* Author           : gyubeom_park (박규범)
* Date             : 2022.03.22
*/
window.dd = window.console.log.bind(window.console);
window.CONTEXT_PATH='${contextPath}';

var _ctx = CONTEXT_PATH;

var gbAjaxFunc = function(opts){
	var result;

	var url = opts.url || '';
	var fullUrl = _ctx + url;
	var params = opts.data || {};
	var async = opts.async || false;
	var type = opts.type || 'POST';
	var cache = opts.cache || false;

	var ajaxParams = {
		'url': fullUrl
		, 'data' : params
		, 'async': async
		, 'type': type
		, 'cache': cache
		, 'success': function(r) {
			result = r;
		}
		, 'error': function(e) {
			result = e;
		}
	};

	var params = $.extend(true, opts, ajaxParams);
	$.ajax(params);

	return result;

};

window.gb = {
	isNot: function(param){ return (param == null || param == undefined || (param.hasOwnProperty('length') && param.length == 0) || ((typeof param == 'string') && !param.length) || (Array.isArray(param) && !param.length) || (param.constructor == Object && getObjectLength(param) == 0) ); }
	, isString : function(v, emptycheck){
		return (typeof v == 'string') && (emptycheck == true ? v.length != 0 : true);
	}
	, getYMD : function(date, unit){ // unit(Number) : undefined, 1, 2, 3
		var u = unit || 3;
		var d = undefined == date || '' == date ? new Date() : new Date(date);

		let year = d.getFullYear();
	    let month = '' + (d.getMonth() + 1);
	    let day = '' + d.getDate();

	    if (month.length < 2) month = '0' + month;
	    if (day.length < 2) day = '0' + day;

	    return [year, month, day].slice(0, unit).join('-');
	}
	, promise : function(){
		var gbPromise = function(){
			this.catchException;

			this.able = false;
			this.queue = [];

			var self = this;

			this.catchExcecuter = function(e){
				if(self.catchException && typeof catchException == 'function') self.catchException(e);
			};

			this.execute = function(promiseParamData){
				if(this.able) return this;

				var queueFactor = this.queue.shift();

				if(queueFactor){
					this.able = true;

					try{
						queueFactor(function(param){
							self.able = false;
							self.execute(param);
						}, function(e){
							self.catchExcecuter(e);
						}, promiseParamData);
					}catch(e){
						self.catchExcecuter(e);
					}

				}else{
					this.able = false;
				}

			};

			this.then = function(func){
				this.queue.push(func);
				this.execute();
				return this;
			};

			this.catch = function(func){
				self.catchException = func;
			};

		};

		return new gbPromise();

	}
	, await : {
		postForm : function(url, params){
			return gbAjaxFunc({
				url : url
				, data : params
				, enctype: 'multipart/form-data'
				, processData : false
				, contentType : false
			});
		}
		, post : function(url, params){
			return gbAjaxFunc({
				url : url
				, data : params
			});
		}
		, get : function(url, params){
			return gbAjaxFunc({
				url : url
				, data : params
				, type : 'GET'
			});
		}
	}
	, post: function(url, params){
		return gbAjaxFunc({
			url : url
			, data : params
			, async : true
		});
	}
	, get : function(url, params){
		return gbAjaxFunc({
			url : url
			, data : params
			, type : 'GET'
			, async : true
		});
	}
};
</script>

<!-- logo -->
<link rel="shortcut icon" type="image/png"  href="resources/img/logo-checkall-mk1.png">

<!-- css : common -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/bootstrap/dist/css/bootstrap.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/fontawesome.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/regular.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/brands.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/@fortawesome/fontawesome-free/css/solid.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/page/common/css/ace-themes.css">

<!-- form -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/bootstrap-star-rating/css/star-rating.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/bootstrap-select/dist/css/bootstrap-select.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/bootstrap-duallistbox/dist/bootstrap-duallistbox.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/select2/dist/css/select2.css">
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/chosen-js/chosen.css">

<!-- include fonts -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/page/common/css/ace-font.css">

<!-- ace.css -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/page/common/css/ace.css">

<!-- base.css -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/page/common/css/istc-base.css">

<!-- istec css -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/istec/css/istec_1.css" />
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/istec/lib/sweetalert/css/sweetalert.css" />
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/istec/module/loadingbar/css/LoadingBar_gyubeompark_ver1.0.css" />
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/istec/lib/bootstrap/css/bootstrap-datepicker.css" />

<!-- script : common -->
<script type="text/javascript" src="${contextPath}/resources/lib/jquery/dist/jquery.js"></script>
<script type="text/javascript" src="${contextPath}/resources/istec/lib/sweetalert/js/sweetalert.js"></script>
<script type="text/javascript" src="${contextPath}/resources/istec/lib/jquery/js/jquery.fileDownload.js"></script>

<script type="text/javascript" src="${contextPath}/resources/lib/jquery-i18n/jquery.i18n.properties.js"></script>
<script src="${contextPath}/resources/lib/popper.js/dist/umd/popper.js"></script>
<script src="${contextPath}/resources/lib/bootstrap/dist/js/bootstrap.js"></script>
<script type="text/javascript" src="${contextPath}/resources/istec/lib/bootstrap/js/bootstrap-datepicker.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/istec/lib/bootstrap/js/bootstrap-datepicker.ko.js"></script>

<!-- istec module -->
<script type="text/javascript" src="${contextPath}/resources/istec/module/loadingbar/js/LoadingBar_gyubeompark_ver1.0.js"></script>
<script type="text/javascript" src="${contextPath}/resources/istec/js/temp/gb_alert_v1.js"></script>
<script type="text/javascript" src="${contextPath}/resources/istec/module/filedownloader/js/filedownloader_gyubeompark_ver1.0.js"></script>

<!-- istec script -->
<script type="text/javascript" src="${contextPath}/resources/istec/js/istec_script_1.js"></script>


<!-- moment -->
<script type="text/javascript" src="${contextPath}/resources/lib/moment/moment.js"></script>

<!-- jquery step -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/jquery.step/jquery.steps.css">
<script src="${contextPath}/resources/lib/jquery.step/jquery.steps.js"></script>


<!-- alert -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/lib/jquery-confirm-v3.3.4/jquery-confirm.css">
<script type="text/javascript" src="${contextPath}/resources/lib/jquery-confirm-v3.3.4/jquery-confirm.js"></script>

<!-- include ace.js -->
<script type="text/javascript" src="${contextPath}/resources/page/common/js/ace.js"></script>

<!-- include istc js -->
<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-sha256.js"></script>
<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-kutil.js?v=1.3"></script>
<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-common-utils.js"></script>
<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-data-loader.js"></script>
<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-alert.js"></script>
<script type="text/javascript" src="${contextPath}/resources/page/common/js/istc-meas-stat.js"></script>


 <!-- alert -->
<script src="${contextPath}/resources/lib/sweetalert2/dist/sweetalert2.all.js"></script>
<!--<script src="${contextPath}/resources/lib/interactjs/dist/interact.js"></script> -->


 <!-- file down -->
<script src="${contextPath}/resources/lib/jquery-filedownload/jquery-filedownload.js"></script>







<script src="${contextPath}/resources/lib/bootstrap-star-rating/js/star-rating.js"></script>
<script src="${contextPath}/resources/lib/typeahead.js/dist/typeahead.bundle.js"></script>
<!----  <script src="${contextPath}/resources/lib/bootstrap-select/dist/js/bootstrap-select.js"></script>  ---->
<script src="${contextPath}/resources/lib/bootstrap-duallistbox/dist/jquery.bootstrap-duallistbox.js"></script>
<script src="${contextPath}/resources/lib/select2/dist/js/select2.js"></script>
<script src="${contextPath}/resources/lib/chosen-js/chosen.jquery.js"></script>
<script src="${contextPath}/resources/lib/bootstrap-tagsinput/dist/bootstrap-tagsinput.js"></script>


<!-- custom css/js -->
<link rel="stylesheet" type="text/css" href="${contextPath}/resources/page/common/css/custom.css">
<script src="${contextPath}/resources/page/common/js/custom.js"></script>
<script type="text/javascript" src="${contextPath}/resources/lib/colResizable/colResizable-1.6.min.js"></script>
