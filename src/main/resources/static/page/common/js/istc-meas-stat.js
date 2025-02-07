var meterStatCd = {

	info: function(type, statCd) {

		var opt = {
			str : [
				'통신 장애',	// 0
				'계량기 장애',	// 1
				'Q3초과',		// 2 Q3초과
				'역류',		// 3 역류
				'누수',		// 4 누수
				'정상',		// 5
				'정상',		// 6
				'BAT',		// 7 BAT
				'정상',		// 8
				'지하수',		// 9
				'수검침'		// 10
			],
			color : [
				'danger',	// 0
				'orange',	// 1
				'primary',	// 2
				'success',	// 3
				'purple',	// 4
				'info',		// 5
				'info',		// 6
				'secondary',// 7
				'info'	,	// 8
				'info'	,	// 9
				'info'		// 10
			],
			icon : [
				'box-icon-07',		// 0
				'box-icon-08',	// 1
				'box-icon-11',	// 2
				'box-icon-03',		// 3
				'box-icon-12',		// 4
				'box-icon-06',		// 5
				'box-icon-06',		// 6
				'box-icon-10',		// 7
				'box-icon-06',		// 8
				'underwater2',		// 9
				'watermeter'		// 10
			],
			image : [
				'resources/img/marker/box-icon-07-sm.png',		// 0
				'resources/img/marker/box-icon-08-sm.png',	// 1
				'resources/img/marker/box-icon-11-sm.png',	// 2
				'resources/img/marker/box-icon-03-sm.png',		// 3
				'resources/img/marker/box-icon-12-sm.png',		// 4
				'resources/img/marker/box-icon-06-sm.png',		// 5
				'resources/img/marker/box-icon-06-sm.png',		// 6
				'resources/img/marker/box-icon-10-sm.png',		// 7
				'resources/img/marker/box-icon-06-sm.png',		// 8
				'resources/img/marker/i-underwater-sm.png'	,	// 9
				'resources/img/marker/i-watermeter-sm.png'		// 10
			]
			
		};

		if(statCd) {
			// 2023.11.24 김용희 : 외부업체 수동측정으로 상태코드값이 이럴경우 추가된 이미지보여줌.
			if(statCd == '008880080' || statCd == '108880080') {
				return opt[type][9];
			}
			if(statCd == '009990090' || statCd == '109990090') {
				return opt[type][10];
			}

			var idx = statCd.indexOf('1');

			if(idx == -1)
				return opt[type][8];

			return opt[type][idx];
		}


		return '-'


	},
	getStr: function(statCd) {
		return this.info('str', statCd);
	},
	getColor: function(statCd) {
		return this.info('color', statCd);
	},
	getIcon: function(statCd) {
		return this.info('icon', statCd);
	},
	getImage: function(statCd) {
		return getAbsolutepath(this.info('image', statCd));
	}

};

var deviceStatCd = {

	info: function(type, statCd) {

		var opt = {
			str : [
				'통신 장애',	// 0
				'계량기 장애',	// 1
				'정상',		// 2 Q3초과
				'정상',		// 3 역류
				'정상',		// 4 누수
				'정상',		// 5
				'정상',		// 6
				'정상',		// 7 BAT
				'정상',		// 8
				'지하수',		// 9
				'수검침'		// 10
			],
			color : [
				'danger',	// 0
				'orange',	// 1
				'primary',	// 2
				'success',	// 3
				'purple',	// 4
				'info',		// 5
				'info',		// 6
				'secondary',// 7
				'info'	,	// 8
				'info'	,	// 9
				'info'		// 10
			],
			icon : [
				'box-icon-07',		// 0
				'box-icon-08',	// 1
				'box-icon-06',	// 2
				'box-icon-06',		// 3
				'box-icon-06',		// 4
				'box-icon-06',		// 5
				'box-icon-06',		// 6
				'box-icon-06',		// 7
				'box-icon-06',		// 8
				'underwater2',		// 9
				'watermeter'		// 10
			],
			image : [
				'resources/img/marker/box-icon-07-sm.png',		// 0
				'resources/img/marker/box-icon-08-sm.png',	// 1
				'resources/img/marker/box-icon-06-sm.png',	// 2
				'resources/img/marker/box-icon-06-sm.png',		// 3
				'resources/img/marker/box-icon-06-sm.png',		// 4
				'resources/img/marker/box-icon-06-sm.png',		// 5
				'resources/img/marker/box-icon-06-sm.png',		// 6
				'resources/img/marker/box-icon-06-sm.png',		// 7
				'resources/img/marker/box-icon-06-sm.png',		// 8
				'resources/img/marker/i-underwater-sm.png'	,	// 9
				'resources/img/marker/i-watermeter-sm.png'		// 10
			]
			
		};

		if(statCd) {
			// 2023.11.24 김용희 : 외부업체 수동측정으로 상태코드값이 이럴경우 추가된 이미지보여줌.
			if(statCd == '008880080' || statCd == '108880080') {
				return opt[type][9];
			}
			if(statCd == '009990090' || statCd == '109990090') {
				return opt[type][10];
			}

			var idx = statCd.indexOf('1');

			if(idx == -1)
				return opt[type][8];

			return opt[type][idx];
		}


		return '-'


	},
	getStr: function(statCd) {
		return this.info('str', statCd);
	},
	getColor: function(statCd) {
		return this.info('color', statCd);
	},
	getIcon: function(statCd) {
		return this.info('icon', statCd);
	},
	getImage: function(statCd) {
		return getAbsolutepath(this.info('image', statCd));
	}

};





