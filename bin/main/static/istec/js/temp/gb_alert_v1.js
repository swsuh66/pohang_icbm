/*
* Script File Name : gb_alert_v1.js
* Title            : alert 임시 모듈 (미완성)
* Desc             : 개발팀 개발 작업시 편의를 위한 alert method 작성
* Author           : gyubeom_park (박규범)
* Date             : 2022.03.22
*/

window.gbAlert = (function(){
	
	this.messages = {
		error : '시스템 가동 중 장애가 발생하였습니다.\n시스템 관리자에게 문의바랍니다.'
	};
	
	/*
	 * icon : success / info / warning / error
	 * */
	var alert = function(icon, title, content, btnBoolean, timer, url_or_func){		
		var filter = "win16|win32|win64|mac|macintel";
		
		if ( navigator.platform ) {
			if ( filter.indexOf( navigator.platform.toLowerCase() ) < 0 ) {
				 alert(content);
				 if(url_or_func != undefined && url_or_func != null && typeof url_or_func == 'string' && url_or_func != ''){
					 history.pushState(null, null, url_or_func);
					 window.onpopstate = function(){history.pushState(null, null, url_or_func);}
					 window.location.replace(url_or_func);
				 }else if(typeof url_or_func == 'function'){
					 url_or_func.call();
				 }
			} else {
				swall({
					icon : icon
					, title : title
					, text : content
					, buttons : btnBoolean
					, timer : timer
				}).then(function(){
					if(url_or_func != undefined && url_or_func != null && typeof url_or_func == 'string' && url_or_func != ''){
						history.pushState(null, null, url_or_func);
						window.onpopstate = function(){history.pushState(null, null, url_or_func);}
						window.location.replace(url_or_func);
					}else if(typeof url_or_func == 'function'){
						url_or_func.call();
					}
				}); 
			}
		}
	}
	
	/*
	 * swal confirm method
	 * 1st param : confirm message
	 * 2nd param : confirm call back
	 * 3rd param : cancel call back
	 * 4th param : call back return message 
	 * */	 
	var confirm = function(cMessage, _confirmFunc, _cancelFunc, rMsg){
		var returnBoolean = rMsg != undefined && rMsg != null && typeof rMsg == 'string';
		swall({
		  icon : 'info'
	      , text : cMessage
		  , buttons: {
		    cancel: "취소"
	    	, confirm: {
	    		text: "확인",
	    		value: "confirm",
		    }
		  },
		})
		.then(function (value) {
			switch (value) {
		    case "confirm":
		      if((typeof(_confirmFunc)) == 'function'){
		    	  _confirmFunc.call();
		    	  if(returnBoolean){
		    		  alert('success', 'SUCCESS', rMsg);
		    	  }
		      }
		      return true;
		    case null: // case "cancel":
		        if((typeof(_cancelFunc)) == 'function'){
		    		_cancelFunc.call();
					if(returnBoolean){
						alert('success', 'SUCCESS', rMsg);
					}
		    	}
		    	return false;
		    default:
		    	break;
		  }
		});
	}
	
	/*
	 * error alert (작성 중.)
	 * */
	var error = function(){
		swall({
			icon : 'error'
			, title : "시스템 오류"
			, text : this.messages.error
			, buttons : false
			, timer : null
		});
	}
	
	return {
		"confirm" : confirm
	    , "alert" : alert
	    , "error" : error
	};
	
})();