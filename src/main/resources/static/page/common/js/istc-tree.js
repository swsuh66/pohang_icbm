function GroupData(data) {
			this._root = {children: [], site: [], count: 0, parent: null};
			this._lstGroup = [];
			this._lstSite = [];
			this._mapGroup = {};
			this._mapSite = {};
			
			if(data)
				this.setGroupData(data);
		}
		GroupData.prototype.constructor = GroupData;
		
		GroupData.prototype.getData = function() {
			return this._root;
		};

		GroupData.prototype.hasGroup = function(value) {
			var value;
			if(value && typeof value === 'object' && value.grpSeq)
				value = this.getGroupValue(value.grpSeq);
			else if(typeof value === 'number') 
				value = this.getGroupValue(value);
			
			return (value ? true : false);
		};

		GroupData.prototype.getGroupValue = function(grpSeq) {
			return (grpSeq ? this._mapGroup[grpSeq+''] : this._root);
		};

		GroupData.prototype.getSiteValue = function(grpSeq) {
			return this._mapSite[siteSeq+''];
		};

		///////////////////////////////
		
		GroupData.prototype.setGroupData = function(data) {
			this._mapGroup = {};
			this._lstGroup = [];
			for(var ix=0; ix<data.length; ix++) {
				this.addGroup(data[ix]);
			}
		}
		GroupData.prototype.setSiteData = function(data) {
			this._mapSite = {};
			this._lstSite = [];
			for(var ix=0; ix<data.length; ix++) {
				this.addSite(data[ix]);
			}
		}

		///////////////////////////////

		GroupData.prototype.addGroup = function(item) {
			if(this._mapGroup[item.grpSeq+''])
				return;
			
			var par = item.parSeq ? this._mapGroup[item.parSeq+''] : null;
			if(!par)
				par = this._root;
			
			var value = {item: item, children: [], site: [], count: 0, parent: par};

			par.children.push(value);
			this._mapGroup[item.grpSeq +''] = value;
			this._lstGroup.push(value);
		};
			
		GroupData.prototype.addSite = function(item) {
			var addSiteCount = function(item) {
				item.count ++;
				if(item.parent)
					addSiteCount(item.parent);
			};

			var par = this.getGroupValue(item.parSeq);
			if(!par)
				par = this._root;
			
			var value = {item:item, parent: par};

			addSiteCount(par);
			
			par.site.push(value);
			this._mapSite[item.siteSeq +''] = value;
			this._lstSite.push(value);
		};

		///////////////////////////////
		
		GroupData.prototype.matchGroupName = function(key, cbf) {
			if(!this._lstGroup || !this._lstGroup.length) 
				return;
			
			var cnt = this._lstGroup.length;
			for(var ix=0; ix<cnt; ix++) {
				var value = this._lstGroup[ix];
				if(value.item.grpName.indexOf(key) > -1)
					cbf(value, ix, this._lstGroup);
			}
		} 

		GroupData.prototype.matchSiteName = function(key, cbf) {
			if(!this._lstSite || !this._lstSite.length)
				return;
			
			var key_group;
			var key_site = key;
			var nx = key.indexOf(',');
			if(nx > -1) {
				key_group = key.substr(0, nx).trim();
				key_site = key.substr(nx+1).trim(); 
			}
			
			var cnt = this._lstSite.length;
			for(var ix=0; ix<cnt; ix++) {
				var value = this._lstSite[ix];
				if(value.item.siteName.indexOf(key_site) > -1) {
					if(!key_group || !value.parent || value.parent.item.fullName.indexOf(key_group) > -1)
						cbf(value, ix, this._lstSite);
				}
			}
		} 