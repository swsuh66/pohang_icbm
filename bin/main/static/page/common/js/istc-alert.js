var jAlert = {
		
	_alert: null,
	
	open: function(type, title, content, callback) {
		
		var option = {
		    title: title,
		    content: content,
		    type: (type == 'error') ? 'red' : 'blue',
		    typeAnimated: true,
		    buttons: (type == 'confirm') ?  
		    {
		        tryAgain: {
		            text: '예',
		            btnClass: 'btn-blue', 
		            action: function(){
		            	
		            	if(callback)
		            		callback();
		            	
		            }
		        },
		        close: function () {}		        	
		    } 
		    : {		       
		        close: function () {}		       
		    }	
		};
		
		
		if(this._alert != null && this._alert.isOpen())
			return;
		
		this.setDom( $.confirm(option) );
		
	},	
	info: function(title, content) {
		return this.open('info', title, content);
	},
	error: function(title, content) {
		return this.open('error', title, content);
	},	
	confirm: function(title, content, callback) {
		return this.open('confirm', title, content, callback);
	},	
	setDom: function(el) {
		this._alert = el;
	}
};

