/**
 * @method validate_util
 * @description 유효성 검사에 필요한 요소들을 포함합니다.
 */
var validate_util = {
		rules : {
			inserPhone : {				
				pattern : /^[0-9]+$/,
				minlength : 10,
				maxlength : 12
			},
			email: {
				pattern : /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
			},			
			adminNo : {
				required : true,
				minlength : 8,
				maxlength : 16
			},			
			custNm : {
				required : true,
				minlength : 2,
				maxlength : 24
			},						
			addr : {				
				maxlength : 64
			},	
			useType : {				
				maxlength : 10
			},	
			pipeDia : {				
				pattern : /^\d{2,3}$/
			},
			meterNo : {				
				maxlength : 64
			},
			prjSiteSq : {
				required : true				
			},
			siteNm : {
				required : true,
				maxlength : 30
			},
			inserNm : {
				required : true,
				minlength : 2,
				maxlength : 10
			},
			inserNm : {
				required : true,
				maxlength : 10
			},
			userId : {
				required : true,
				minlength : 2,
				maxlength : 10
			}
		},
		// 규칙체크 실패시 출력될 메시지
		messages : {
			inserPhone : {				
				pattern : "전화번호를 -없이 숫자만 입력하세요.",
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. "),
				minlength : $.validator.format("최소 {0} 글자 이상 입력하세요.")
			},
			email: {
				pattern : "이메일 형식이 올바르지 않습니다."
			},
			adminNo: {
				required : "고객번호를 입력하세요.",
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. "),
				minlength : $.validator.format("최소 {0} 글자 이상 입력하세요.")
			},
			custNm : {
				required : "수용가 이름을 입력해 주십시오.",
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. "),
				minlength : $.validator.format("최소 {0} 글자 이상 입력하세요.")
			},
			addr : {				
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. "),				
			},
			useType : {				
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. "),				
			},
			pipeDia : {				
				pattern : "2자리 혹은 3자리 숫자를 입력하세요."
			},
			meterNo : {				
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. "),				
			},
			prjSiteSq: {
				required : "프로젝트를 선택해주세요."				
			},
			siteNm : {
				required : "프로젝트 이름을 입력해 주십시오.",
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. ")				
			},
			inserNm : {
				required : "설치자 이름을 입력해 주십시오.",
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. "),
				minlength : $.validator.format("최소 {0} 글자 이상 입력하세요.")
			},
			comNm : {
				required : "회사 이름을 입력해 주십시오.",
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. ")				
			},
			userId : {
				required : "로그인 아이디를 입력해 주십시오.",
				maxlength : $.validator.format("{0}자를 넘을 수 없습니다. "),
				minlength : $.validator.format("최소 {0} 글자 이상 입력하세요.")
			}
		},
		// 원래 라벨의 문구들으 정의 합니다.
		originMessages : {
			phone           : "전화번호를 -없이 숫자만 입력하세요.",
			email           : "이메일 형식으로 입력하세요.",
			adminNo         :  "고객번호를 입력하세요.",						
			custNm          :  "2이상 24자 이하로 입력하세요.",
			addr          	:  "64자 이하로 입력하세요.",
			useType         :  "10자 이하로 입력하세요.",
			pipeDia         :  "2자리 혹은 3자리 숫자를 입력하세요.", 
			meterNo         :  "64자 이하로 입력하세요.",
			prjSiteSq       :  "프로젝트를 선택해주세요.",
			siteNm       	:  "프로젝트 이름을 입력해 주십시오.",
			inserNm       	:  "10자 이하로 입력하세요.",
			comNm       	:  "10자 이하로 입력하세요.",
			userId       	:  "로그인 아이디를 입력해 주십시오."
			
		},		
		// 유효성 검사 결과 라벨을 콘트롤합니다.
		setError : function(el, errorList){
			var i, elements, error, label;
			
			// error 라벨 요소들의 색과 에러 문구로 변경
			for ( i = 0; errorList[ i ]; i++ ) {
				error = errorList[ i ];
				el.settings.highlight(error.element, el.settings.errorClass, el.settings.validClass );				
				el.showLabel( error.element, error.message );
			}

			// 유효한 라벨 요소들의 색과 원래 문구로 변경
			for ( i = 0, elements = el.validElements(); elements[ i ]; i++ ) {				
				if($('label.errclr[for="' + $(elements[i]).attr('id') + '"]').length > 0){
					el.settings.unhighlight(elements[ i ], el.settings.errorClass, el.settings.validClass );
					
					label = el.errorsFor( elements[i] );									
					var ruleNm = $('#' + label.attr('for') ).attr('name');
					var labelTxt = this.originMessages[ruleNm];
					if(labelTxt) {
						el.showLabel( elements[i], labelTxt );					
					}					
				}
			}
		},		
		// 유효한 라벨 요소의 색과 원래 문구로 변경		
		setValid : function(el, focusEl){
			var label = $('label.errclr[for="' + $(focusEl).attr('id') + '"]');
			if(label.length > 0){
				$( focusEl ).removeClass( 'error' ).addClass( 'valid' );
				
				var labelTxt = this.originMessages[$( focusEl ).attr('name')];
				if(labelTxt) {
					label.text(labelTxt);					
				}										
			}
		}
};

// 원래 형태로 라벨을 돌려 놓습니다.
$.fn.resetValidation = function(elNm) {
	
	
	var errLabel;
	var originMsg;	
	this.validate().resetForm();
	
	errLabel = $(this).find('label.errclr');
	
	for (var i = 0; i < errLabel.length; i++) {
		
		var name;		
		var valiEl = $(errLabel[i]).parent();
		
		if (valiEl.find('input').length != 0)
			name = valiEl.find('input')[0].name;		
		else if (valiEl.find('textarea').length != 0)
			name = valiEl.find('textarea')[0].name;
		else if (valiEl.find('select').length != 0)
			name = valiEl.find('select')[0].name;
		
		var originMsg = validate_util.originMessages[name];
		$(errLabel[i]).text(originMsg).show();
		
	}
}

