
//데이터를 요청하는 함수 입니다.
function commonAjax(url, params, callBack){
	$.ajax({
		url: url,
		data: JSON.stringify(params),
		processData: true,
		type: "POST",
		contentType : "application/json; charset=UTF-8",
		success: function (res) {
			callBack(res);
		},
		error : function(err){
			console.log('error');
			callBack(err);
		}
	});
}


//페이징 관련 함수 입니다.
function buildTable(_url, _param, view){
	commonAjax(_url, _param, function(result){
		_param.pgCnt2 = result.pgCnt;
		view(result);
		_tailMaker(_url, _param, result, view);
	});
}

//페이징 번호를 받아 이동하는 함수
function moveTarget2(changePg, _pgCnt2, _url, _param, view) {
	if (changePg <= _pgCnt2) {
		_param.curPage = changePg-1;
		buildTable(_url, _param, view);
	}
}

//하단부 꼬리를 만듭니다.
function _tailButtonMaker(attr,event,val, _url, _param, view){
	let obj = $('<li>').addClass(attr).addClass("page-item");
	obj.append(
		$('<span>')
		.addClass("page-link").css('cursor','pointer').append(val)
		.click(function(){
			moveTarget2(event,_param.pgCnt2, _url, _param, view)
		})
	)
	return obj;
}

//페이징 하단 꼬리 그리기용 함수
function _tailMaker(_url, _param, dat, view){
	let pgConts = $('<ul></ul>').addClass('pagination justify-content-center');
	let curpg = Number(dat.curPage)+1;
	let prevpg = 1;
	let startpg = Number(dat.start);
	let endpg = Number(dat.end);
	if(curpg != 1){
		prevpg = curpg - 1;
	}
	pgConts.append(
		_tailButtonMaker('page-item',1,'<i class=\'ico i-prev-double\'></i>', _url, _param, view)
	);
	pgConts.append(
		_tailButtonMaker(curpg==1?'page-item':'page-item',prevpg,'<i class=\'ico i-prev\'></i>', _url, _param, view)
	);

	for(startpg; startpg <= endpg;startpg++){
		let cls = 'page-item';
		if(curpg == startpg){
			cls = 'page-item active';
		}
		pgConts.append(_tailButtonMaker(cls,startpg,startpg, _url, _param, view));
	}
	pgConts.append(
		_tailButtonMaker(curpg==dat.pgCnt?'page-item':'page-item',(curpg+1),'<i class=\'ico i-next\'></i>', _url, _param, view)
	);

	$('.'+_param.tail_class_name).children().remove();
	let lastPg = Math.ceil(dat.totCnt / dat.pageSize);
	pgConts.append(
		_tailButtonMaker('page-item',lastPg,'<i class=\'ico i-next-double\'></i>', _url, _param, view)
	);

	$('.'+_param.tail_class_name).append(pgConts);//1차 생성
}

//페이징 넘버링 함수 입니다.
let getNumbering = (result, index, option) => {  //테이블에서 맨 앞 숫자를 표기합니다. option값이 있으면 asc입니다.
	if(option) return (result.curPage) * result.pageSize + index
	return result.totCnt-((result.curPage) * result.pageSize + index)
}

//날짜 프로토타입 재 정의1
Date.prototype.yyyymmdd = function(type) {
	if(this=="Invalid Date"){
		return "";
	}
	let mm = this.getMonth() + 1;
	let dd = this.getDate();
	if(type!=null){
		return [this.getFullYear(), (mm>9 ? '' : '0') + mm, (dd>9 ? '' : '0') + dd ].join(type);
	}
	return [this.getFullYear(), (mm>9 ? '' : '0') + mm, (dd>9 ? '' : '0') + dd ].join('-');
};

//날짜 프로토타입 재 정의2
Date.prototype.yymmdd = function(type) {
	if(this=="Invalid Date"){
		return "";
	}
	let mm = this.getMonth() + 1;
	let dd = this.getDate();
	let yy = this.getYear() -100;
	if(type!=null){
		return [yy, (mm>9 ? '' : '0') + mm, (dd>9 ? '' : '0') + dd ].join(type);
	}
	return [yy, (mm>9 ? '' : '0') + mm, (dd>9 ? '' : '0') + dd ].join('-');
};

//날짜 프로토타입 재 정의3
Date.prototype.hhmmss = function() {
	let hh = this.getHours();
	let mm = this.getMinutes();
	let ss = this.getSeconds();
	return [(hh>9 ? '' : '0') + hh, (mm>9 ? '' : '0') + mm, (ss>9 ? '' : '0') + ss ].join(':');
};

//날짜 프로토타입 재 정의4
Date.prototype.yyyymmddhhmmss = function() {
	return this.yyyymmdd() + " " + this.hhmmss();
};

//날짜 프로토타입 재 정의5

Date.prototype.hhmm = function() {
	let hh = this.getHours();
	let mm = this.getMinutes();
	return [(hh>9 ? '' : '0') + hh, (mm>9 ? '' : '0') + mm ].join(':');
};

Date.prototype.yyyymmddhhmm = function() {
	return this.yyyymmdd() + " " + this.hhmm();
}
