
const _ol_meta_equip = {

	labelTextColor: '#000000',
	highlightTextColor: '#0000FF',
	//highlightTextColor: '#8B1A1A',
		
		
	fetureKind: {
		'F0':'미지정',
		'F1':'미터기'
	},

	layerMetas : [
		/*{id:'FM0', name:'미지정', visible:true, child: [
			{	marker: {type:'mkr', zoom_min:8}, 
				label:  {type:'lbl', zoom_min:12}
			}
		]},*/
		{id:'FM1', name:'미터기', visible:true, child: [
			{	marker: {type:'mkr', zoom_min:8},
				label:  {type:'lbl', zoom_min:12}
			}
		]}
	]

};

function OLlayerEquip(olMap)
{
	
	var _olm = olMap;
	var _map = _olm.getMap();
	var _meta_queue = {};
	var _meta_list = [];
	var _layers;
	
	var _highliteLayer;
	
	/**************************************************************************/
	/*
	 * 
	 */
	
	var _makeLayers = function(srcMeta) {
		var meta;
		var options;

		_meta_queue = {};
		_meta_list = [];

		_layers = [];
		
		for (var i=0;i<srcMeta.length;i++)
		{
			_makeLayerGroup( srcMeta[i] );
		}
		
        _highliteLayer = new ol.layer.Vector({
    		source : new ol.source.Vector(),
    		style : _focusedFeautreStyleFnc,
    		zIndex:4
    	});
    	_map.addLayer(_highliteLayer);
	}
	
	var _makeLayerGroup = function(row) {
		var meta;
		var options;
		var child = [];
		var layer;
		var meta;
		var lid;
		
		for(var ix=0; ix<row.child.length; ix++) {
			meta = row.child[ix].marker;
			options = {source: new ol.source.Vector({}), visible:true, zIndex:3};
			
			layer = new ol.layer.Vector(options);
			if(meta.zoom_min)
				layer.setMaxResolution( _olm.resolutionForZoom(meta.zoom_min) );
			if(meta.zoom_max)
				layer.setMinResolution( _olm.resolutionForZoom(meta.zoom_max) );

			lid = _lidforMeta(row.id, meta.type);
			layer.set('context_data', {id:lid, type:'marker'});
			
			_setLayerForId(lid, layer);
			child.push(layer);
			_layers.push(layer);
			
			//---------------------

			meta = row.child[ix].label;
			if(!meta) continue;
			
			options = {source: new ol.source.Vector({}), visible:true, zIndex:2};
			
			layer = new ol.layer.Vector(options);
			if(meta.zoom_min)
				layer.setMaxResolution( _olm.resolutionForZoom(meta.zoom_min) );
			if(meta.zoom_max)
				layer.setMinResolution( _olm.resolutionForZoom(meta.zoom_max) );
			
			lid = _lidforMeta(row.id, meta.type);
			_setLayerForId(lid, layer);
			child.push(layer);
			_layers.push(layer);
		}
		
		var featureLayer = new ol.layer.Group({
			layers: child,
			visible: row.visible
		});

		_olm.addLayer(featureLayer, row.name);
	}
	
	var _lidforMeta = function(gid, type) 
	{
		return gid+'_'+ type;
	}

	var _setLayerForId = function(id, layer) 
	{
		_meta_queue[id] = layer;
	}
	var _getLayerForId = function(id) 
	{
		return _meta_queue[id];
	}
	
	var _getLayerSource = function(id) {
		var layer = _getLayerForId(id);
		if(layer)
			return layer.getSource();
		return null;
	}
	
	var _refreshLayers = function() {
		for(var ix=0; ix<_layers.length; ix++){
			_layers[ix].changed();
		}
	}
	
	_makeLayers(_ol_meta_equip.layerMetas);
	
	/**************************************************************************/
	/*
	 * 
	 */

	/**************************************************************************/
	/*
	 * 
	 */

	var _markers_map = {};
	var _labels_map = {};
	var _self = this;
	
	/**********************************/
	
	var _styleCache_def_marker = {};
	/*
	var _defMkrStyleFnc = function(resolution) {
		var opt = this.get('opt');
		var state = opt.state;
		if(state instanceof Function)
			state = state(this);
		var style_key = opt.icopf + state + '_'+(opt.hasAct?1:0);
		
		var style = _styleCache_def_marker[style_key];
		if(!style)
			_styleCache_def_marker[style_key] = style = [
				new ol.style.Style({
					image: new ol.style.Circle({
		                radius: 10,
		                stroke: new ol.style.Stroke({
		                  color: '#fff'
		                }),
		                fill: new ol.style.Fill({
		                  color: '#3399CC'
		                })
		              })					
					
					image: new ol.style.Icon({
						anchor: [0.5, 0.5],
						anchorXUnits: 'fraction',
						anchorYUnits: 'fraction',
						src: 'resources/img/marker/'+ state,//'resources/img/gmarker/Point_'+ opt.icopf + state +'.png',
						opacity: (this.get('opt').hasAct ? 1 : 0.6)
					})
				})
			];
		return style;
	}
	
	var _getLblStyle = function(feature, resolution, textColor){
		var opt = feature.get('opt');
		var value = opt.value;
		if(value instanceof Function)
			value = value(feature);

		var style = [
			new ol.style.Style({
				//image: _styleCache_def_background,
				text: new ol.style.Text({
					font: 'bold 12px FontAwesome',
					textAlign: 'start',
					textBaseline: 'bottom',
					text: opt.name||'',
					fill: new ol.style.Fill({color: textColor}),
					stroke: new ol.style.Stroke({color: '#ffffff', width: 2}),
					offsetX: 16,
					offsetY: 0,
					rotation: 0
				})
			}),
			new ol.style.Style({
				text: new ol.style.Text({
					font: 'bold 12px FontAwesome',	//dotum
					textAlign: "Start",
					textBaseline: 'top',
					text: value||'',
					fill: new ol.style.Fill({color: textColor}),
					stroke: new ol.style.Stroke({color: '#ffffff', width: 2}),
					offsetX: 16,
					offsetY: 0,
					rotation: 0
				})
			})
		];
		return style;
		
	}
	
	var _defLblStyleFnc = function(resolution) {
		return _getLblStyle(this, resolution, _ol_meta_equip.labelTextColor);
	}
	*/

	var _focusedFeautreStyleFnc = function(resolution) {
		return _getLblStyle(this, resolution, _ol_meta_equip.highlightTextColor);
	}

	/**************************************************************************/

	var _fncMarkerState = function(feature) {
		var opt = feature.get('opt');
		var data = opt.data;
		var meas = data.meas;
		//var stat = (meas ? meas.obsStt || '0' : '0');

		return meterStatCd.getImage(data.statCd);
	}
	
	var _fncLabelValue = function(feature) {
		var opt = feature.get('opt');
		var data = opt.data;
		var meas = data.meas;
		//var stat = (meas ? meas.obsStt || '0' : '0');

		return meterStatCd.getStr(data.statCd);
	}
	
	/**********************************/
	
	var _gidForKind = function(kind)
	{
		var gid = 'FM0';
		
		if(kind == '1') {
			gid = 'FM1';
		}

		return gid;
	}

	var _getMarkerFeture = function(pointSq) {
		var meta = _markers_map['pt_'+ pointSq];
		if(meta)
			return meta.feature;
		return null;
	}
	
	var _featureIdForData = function(data) 
	{
		if(typeof data === 'object')
			return 'pt_'+ data.pointSq;
		return 'pt_'+ data;
	}

	/**********************************/
/*
	var _addFacFeature = function(row) {
		var featureId = _featureIdForData(row);
		var geom = new ol.geom.Point(ol.proj.transform([row.locLng, row.locLat], 'EPSG:4326', 'EPSG:3857'));
		var source;
		var lid;
		
		var kind = row.meterGb;

		var opt = {};
		opt.hasAct = parseInt(row.useCd) == 1;
		opt.name = row.meterNo;
		opt.value = _fncLabelValue;
		opt.state = _fncMarkerState;
		opt.kind = kind;
		opt.data = row;
		opt.featureKind = 'pointFeature';

		//-----------------------------
		
		lid = _lidforMeta(_gidForKind(kind), 'mkr');
		source = _getLayerSource(lid);
		
		if(source) {
			var marker = new ol.Feature({geometry:geom, opt:opt});

			marker.setId(featureId);
			marker.setStyle(_defMkrStyleFnc);
			
			var last_marker_meta = _markers_map[featureId];
			if(last_marker_meta) {
				last_marker_meta.source.removeFeature(last_feature.feature);
			}

			source.addFeature(marker);
			_markers_map[featureId] = {feature:marker, source:source};
		}

		//-----------------------------
		
		lid = _lidforMeta(_gidForKind(kind), 'lbl');
		source = _getLayerSource(lid);
		
		if(source) {
			var label = new ol.Feature({geometry:geom, opt:opt});

			label.setId(featureId);
			label.setStyle(_defLblStyleFnc);
			
			var last_label_meta = _labels_map[featureId];
			if(last_label_meta) {
				last_label_meta.source.removeFeature(last_label_meta.feature);
			}
			
			source.addFeature(label);
			_labels_map[featureId] = {feature:label, source:source};
		}
	}*/

	/**************************************************************************/
	
	var _meter_lbl_style = function(feature, resolution, geometry){
		if(!geometry)
			geometry = feature.getGeometry();
		if(feature.get('features'))
			feature = feature.get('features')[0];
		
		//textColor = textColor || '#0000ff';
		var textColor = '#0000ff';
		var opt = feature.get('opt');
		var data = opt.data;
		var meas = data.meas;
		var name = opt.name || '';

		if(name.length > 5)
			name = name.substr(0, 5) +'..';
		
		var style = [
			new ol.style.Style({
				geometry: geometry,
				text: new ol.style.Text({
					font: 'bold 12px FontAwesome',
					textAlign: 'start',
					textBaseline: 'bottom',
					text: name||'',
					fill: new ol.style.Fill({color: textColor}),
					stroke: new ol.style.Stroke({color: '#ffffff', width: 2}),
					offsetX: 10,
					offsetY: 8,
					rotation: 0
				})
			})/*,
			new ol.style.Style({
				text: new ol.style.Text({
					font: 'bold 12px FontAwesome',	//dotum
					textAlign: "Start",
					textBaseline: 'top',
					text: value||'',
					fill: new ol.style.Fill({color: textColor}),
					stroke: new ol.style.Stroke({color: '#ffffff', width: 2}),
					offsetX: 10,
					offsetY: 0,
					rotation: 0
				})
			})*/
		];
		return style;
		
	}
	
	var _meter_mkr_style = function(feature, resolution, geometry) {
		
		if(!geometry)
			geometry = feature.getGeometry();
		if(feature.get('features'))
			feature = feature.get('features')[0];
		
		var defStatCd = '10000000';
		var flag = meterStatCd.getStr(defStatCd);
		var src = meterStatCd.getImage(defStatCd);
		var opt = feature.get('opt');
		var data = opt.data;
		
		flag = meterStatCd.getStr(data.statCd);
		src = meterStatCd.getImage(data.statCd);					
		
		var icon = _iconCache[flag]; 
		if(!icon) {
			icon = _iconCache[flag] = new ol.style.Icon({
				anchor: [0.5, 0.5],
				anchorXUnits: 'fraction',
				anchorYUnits: 'fraction',				
				src: src,//getAbsolutepath('resources/img/marker/icon'+flag+'_s.png'),
				opacity: 0.9
			});
		}
		var style = new ol.style.Style({
			geometry: geometry,
			image: icon
		})
		var style2 = new ol.style.Style({
			geometry: geometry
			//image: meter_circle
		});

		return [style, style2];
	}
	
	var _iconCache = {};
	
	var meter_circle = new ol.style.Circle({
		radius: 9,
		stroke: new ol.style.Stroke({
	        color: '#727272',			
	        width: 1
		})
	});
	
	var _meter_lnk_stroke = new ol.style.Stroke({
        color: '#808080',
        width: 1
    });
	
	var cluster_mkr_stroke = new ol.style.Stroke({
		color: '#fff'
	});
	var cluster_mkr_stroke2 = new ol.style.Stroke({
		width: 1,
		color: 'rgb(108, 122, 122)',
		 /*color: [255, 255, 255, 0.6],*/
	});
	var cluster_mkr_fill = new ol.style.Fill({
		/*color: '#33CC33'*/
/*		color: '#6B8E23'*/
		/*color: '#228B22'*/
		color: '#2E8B57'
	/*	color: '#008080'*/
	});
	var cluster_mkr_fill2 = new ol.style.Fill({
		color: '#ff0000'
	});
	var cluster_lbl_fill = new ol.style.Fill({
		color: '#fff'
	});
	
	var _clearStyleCache = function() {
		_styleCache = {};
	}

	var _refreshClusterAttr = function() {
		/*var lid = _lidforMeta(_gidForKind('1'), 'mkr');
		var clustFeatures = _getLayerSource(lid).getSource().getFeatures();*/
		var clustFeatures = _clusterSource.getFeatures();

		for(var iy=0; iy<clustFeatures.length; iy++ ) {
			var features = clustFeatures[iy].get('features');
			var flag = '0';
			var size = features.length;
			for(var ix=0; ix<size; ix++) {
				var feature = features[ix];
				var data = feature.get('opt').data; 
				
				var statCd;
				if( data.statCd ) {
					
					statCd = data.statCd;
					flag = statCd.substr(flag, 1);
					
				} else
					flag = '0';
					
				//var flag = meterSttGetFlag(data.meas, 0);
				
				/*if(flag != '0') {
					flag = '2';
					break;
				}*/
			}
			
			clustFeatures[iy].set('opt', {flag:flag});
		}
		
	}
	var _last_resolution;
	
	var _meter_cluster_style = function(feature, resolution) {
		var size = feature.get('features').length;

		if(_last_resolution != resolution) {
			_refreshClusterAttr();
		}
		
		var flag = feature.get('opt').flag;
		var cacheKey = size;//+'_'+ flag;
		var style = _styleCache[cacheKey];

		if (!style) {
			style = new ol.style.Style({
				image: new ol.style.Circle({
					radius: 14,
					stroke: cluster_mkr_stroke,
					fill: cluster_mkr_fill
					//fill: (flag == '0' ? cluster_mkr_fill : cluster_mkr_fill2)
				}),
				text: new ol.style.Text({
					font: 'bold 12px FontAwesome',	//dotum
					text: size.toString(),
					fill: cluster_lbl_fill
				})
			});
			
			//_styleCache[size] = style;
			_styleCache[cacheKey] = style;
		}
		if(flag != '0') {
			var center = feature.getGeometry().getCoordinates();
			var point = new ol.geom.Point([ center[0]+8*resolution, center[1]+8*resolution ]);
			var temp = new ol.style.Style({
				geometry: point,
				image: new ol.style.Circle({
					radius: 5,
					stroke: cluster_mkr_stroke,
					fill: cluster_mkr_fill2
				})
			});

			var overCircle = new ol.style.Style({
				geometry: new ol.geom.Point([center[0], center[1]]),
				image: new ol.style.Circle({
					radius: 15,
					stroke: cluster_mkr_stroke2,
				})
			});
			
			/*style = [style, overCircle, temp];*/
			style = [style, temp];
		}
		return style;
	}

	var _meter_cluster_style2 = function(feature, resolution) {
		var size = feature.get('features').length;
        var originalFeatures = feature.get('features');
        var originalFeature;
        var style = [];

        var center = feature.getGeometry().getCoordinates();
    	var max = originalFeatures.length;
    	
    	var pix = resolution;
    	//var r = pix * 26 * (0.5 + Math.ceil(size / 4));
    	var r = pix * 30 * (0.5 + (size / 4));
    	
		for (var i = originalFeatures.length - 1; i >= 0; --i) {
        	originalFeature = originalFeatures[i];

        	var a = 2*Math.PI*i/max;
        	if (max==2 || max == 4) a += Math.PI/4;
        	var p = [ center[0]+r*Math.sin(a), center[1]+r*Math.cos(a) ];
        	var g2 = new ol.geom.Point(p);

        	var s1 = _meter_lbl_style(originalFeature, resolution, g2);
        	var s2 = _meter_mkr_style(originalFeature, resolution, g2);
        	var s3 = [
	        	new ol.style.Style({
	        		geometry: feature.getGeometry(),
					image: new ol.style.Circle({
						radius: 4,
						stroke: cluster_mkr_stroke,
						fill: cluster_mkr_fill
					})
	        	}),
        		new ol.style.Style({
					geometry: new ol.geom.LineString([center, p]),
					stroke: _meter_lnk_stroke
				})
	        ];
        	
        	style = style.concat(s1).concat(s2).concat(s3);
        }
	
        return style;
	}

	var _styleCache = {};
	var fnc_cluster_style = function(feature, resolution) {
		var size = feature.get('features').length;
		var style;
		
		if(size == 1) {
			//var feature = feature.get('features')[0];
			style = _meter_lbl_style(feature, resolution).concat(
					_meter_mkr_style(feature, resolution) 
			);
		}
		else if( _olm.getZoom() >= 18 ) {
			style = _meter_cluster_style2(feature, resolution);
		}
		else {
			style = _meter_cluster_style(feature, resolution);
		}
		return style;
	}
		
	var _makeMeterFeature = function(row) {
		var featureId = _featureIdForData(row);
		var geom = new ol.geom.Point(ol.proj.transform([row.locLng, row.locLat], 'EPSG:4326', 'EPSG:3857'));
		var source;
		var lid;
		
		var kind = row.useCd;
		//if(!kind) kind = '0'; 

		var opt = {};
		opt.hasAct = parseInt(row.useCd) == 1;
		opt.name = row.custNm;
		opt.kind = kind;
		opt.data = row;
		opt.featureKind = 'pointFeature';

		//-----------------------------
		
		lid = _lidforMeta(_gidForKind(kind), 'mkr');
		source = _getLayerSource(lid);
		
		if(!source) {
			var a = source;
		}
		
		var feature;
		if(source) {
			feature = new ol.Feature({geometry:geom, opt:opt});
			feature.setId(featureId);
			feature.setProperties(row);
		}
		
		return feature;
	}

	var _resolutionFunction = function() {
		return _map.getView().getResolution();
	}
	var _geometryFunction = function(feature) {
		/*if( _map.getView().getZoom() >= 20 )
			return null;*/
		  return feature.getGeometry();
	} 
	
	
	var _clusterSource;
	var _createFeatures2 = function(dataList) {

		var features = [];
		for(var i=0; i<dataList.length; i++) {
			var data = dataList[i];
			
			if(!data) 
				continue;
			if(!kutil.isValidNumber(data.locLng) || !kutil.isValidNumber(data.locLat))
				continue;
			
			var feature = _makeMeterFeature(data);
			//debugger;
			//console.log(data.pointSq, data.siteSq )
			//feature.setGeometryName(data.devNo)
//			feature.set('pointSq', '1abcd')
//			feature.set('siteSq', '2abcd')
//			feature.setProperties(data);
			
			features.push(feature);
			//_markers_map[featureId] = {feature:feature, source:source};
		}

		//source.addFeatures(features);
		if(!features) {
			var a = 1;
		}
		
		if(features&& features.length > 0){
			
			features = features.filter(function(n){return n !== undefined});
		
			var clusterSource = new ol.source.Cluster({
				distance: 42,
		        source: new ol.source.Vector({
					features: features
				}),
		        
		        resolutionFunction: _resolutionFunction,
		        geometryFunction: _geometryFunction,
		        maxZoomToClust: 20
			});
			_clusterSource = clusterSource;

			lid = _lidforMeta(_gidForKind('1'), 'mkr');
			var layer = _getLayerForId(lid);
			if(layer) {
				layer.setStyle(fnc_cluster_style);
				layer.setSource(clusterSource);
			}
		}
	}
	
	var ol_drag_;
	

	var drag_filt_function = function(feature) {
		var features = feature.get('features');
		if(features) {
			if(features.length == 1) return true;
			if(_map.getView().getZoom() >= 18) return true;
		}
		return false;
	}
	var drag_end_function = function(feature) {
		if(!feature) return;

		if(!confirmFeatureModify || !(confirmFeatureModify instanceof Function))
			return;
		
		//confirmFeatureModify( function(confirm){drag_post_handler(feature, confirm);} );
		
		__dragTarget = feature;
		confirmFeatureModify( function(confirm){drag_post_handler(confirm);});
	}
	var __dragTarget;
	
	var drag_post_handler = function(confirm) {
		var feature = __dragTarget;
		if(!feature) return;
		
		var need_rollback = true; 
		var features = feature.get('features');
		if(confirm && saveFeatureModify && (saveFeatureModify instanceof Function) ) {
			var coordinates = feature.getGeometry().getCoordinates();
			
			feature.getGeometry().setCoordinates(coordinates);
			
			var location = ol.proj.transform(coordinates, 'EPSG:3857', 'EPSG:4326');
			location[0] = Math.round(location[0]*10000000)/10000000;
			location[1] = Math.round(location[1]*10000000)/10000000;
			
			var data = [];
			for(var ix=0; ix<features.length; ix++) {
				var row = features[ix].get('opt').data;
				//row.locLng = coordinates[0];
				//row.locLat = coordinates[1];
				data.push({
					pointSq: row.pointSq,
					locLng: location[0],
					locLat: location[1]
				});
			}
			
			if(saveFeatureModify(data)) {
				for(var ix=0; ix<features.length; ix++) {
					var opt = features[ix].get('opt');
					var row = opt.data;

					row.locLng = location[0];
					row.locLat = location[1];
					features[ix].getGeometry().setCoordinates(coordinates);
				}
				need_rollback = false;
			}
		}
		
		if(need_rollback){
			feature.getGeometry().setCoordinates(features[0].getGeometry().getCoordinates());
		}
	}
	
	var _add_dag_controller = function() {
		
		if(ol_drag_) {
			_map.removeInteraction(ol_drag_);
		}
		
		ol_drag_ = new ol_drag({
			preHandler: drag_filt_function, 
			postHandler: drag_end_function	
		});
		_map.addInteraction(ol_drag_); 
	}
	
	/**************************************************************************/

	var _clearFearures = function() {
		for(var obj in _markers_map) {
			obj.source.removeFeature(obj.feature);
			obj = null;
		}
		_markers_map = {};
		
		for(var obj in _labels_map) {
			obj.source.removeFeature(obj.feature);
			obj = null;
		}
		_labels_map = {};
	}
	
	//----------------------------------
	/*
	var _updateFeatureDataBySourceID = function(source_id, item, feature) {
		var opt = feature.get('opt');
		switch(source_id) {
			case 'meas_meter':
				break;
			default:
				return;
		}
		feature.set('opt', opt);
	}*/

	var _updateFeatures = function(src_id, dataList) {
		/*var cnt = dataList ? dataList.length : 0;
		for (var i=countst;i<cnt;i++) {
			var row = dataList[i];
			var featureId = _featureIdForData(row);
			
			var meta = _markers_map[featureId];
			_updateFeatureDataBySourceID(src_id, row, meta.feature);
		}
		_refreshLayers();
		*/
		
		_clearStyleCache();
		var lid = _lidforMeta(_gidForKind('1'), 'mkr');
		 _getLayerForId(lid).changed();

	}

	//----------------------------------
	/*
	var _createFeatures = function(dataList) {

		for(var i=0; i<dataList.length; i++) {
			var data = dataList[i];
			
			if(!data) 
				continue;
			if(!kutil.isValidNumber(data.locLng) || !kutil.isValidNumber(data.locLat))
				continue;
			
			_addFacFeature(data);
		}
	}*/

	
	/**************************************************************************/
	/*
	 * 
	 */
	
	this.clearFearures = function() {
		_clearFearures();
	}
	
	this.createFeatures = function(dataList) {
		//_createFeatures(dataList);
		_createFeatures2(dataList);
	}
	
	//---------------------------------

	this.updateFeature = function(dataList, pt_type) {
		_updateFeatures(pt_type, dataList);
	}

	this.centerToPoint = function(pointSq, zoom) {
		var fid = _featureIdForData(pointSq);
		var lid = _lidforMeta(_gidForKind('1'), 'mkr');
		var features = _getLayerSource(lid).getSource().getFeatures();

		var feature;// = _getMarkerFeture(pointSq);
		for(var ix=0; ix<features.length; ix++) {
			if(features[ix].getId() == fid) {
				feature = features[ix];
				break;
			}
		}
		if(feature) {
			var geo = feature.getGeometry();
			if(geo && geo.getCoordinates) {
				var coord = geo.getCoordinates();
				_map.getView().setCenter(coord);
				if(_map.getView().getZoom() < zoom)
					_map.getView().setZoom(zoom);
			}
		}
		//olMap.setCenter(value.lon, value.lat, value.zoom);
	}
	
	this.addDagController = function() {
		_add_dag_controller();
	}
	/**************************************************************************/
	/*
	 * 
	 */
	
	_getChildFeatureAtPixcel = function(p0, feature) {
		var distance = function(p1, p2) {
			var dy = p1[0] - p2[0];
			var dx = p1[1] - p2[1];
			return Math.sqrt(dx*dx + dy*dy);
		}
		
		var features = feature.get('features');
		var size = features.length;
		
		var c = _map.getPixelFromCoordinate(feature.getGeometry().getCoordinates());
    	var r = 20 * (0.5 + size / 4);
		var min_rad = -1;
    	var target;
    	
    	for(var ix=0; ix<size;ix++) {
			var a = 2*Math.PI*ix/size;
        	if (size==2 || size == 4) a += Math.PI/4;
        	var p = [ c[0]+r*Math.cos(a), c[1]-r*Math.sin(a) ];
			var d = distance(p0, p) ;
			if(!target || d < min_rad) {
				min_rad = d;
				target = features[ix];
			}
		}
    	return target;
	}
	
	_map.on('singleclick', function(e) {
		var feature = _map.forEachFeatureAtPixel(e.pixel, function(feature, layer) {
			if( feature.get('features') )
				return feature;
		});
		if(!feature) return;

		var features = feature.get('features');
		var size = features.length;
		if(!size) return;
		
		var data;
		
		if(size == 1){
			data = features[0].get('opt').data;
		}
		else if(_olm.getZoom() >= 18) {
			var target = _getChildFeatureAtPixcel(e.pixel, feature);
	    	data = target.get('opt').data;
		}
		
		if(data) {
			//if(movePageTo) movePageTo(data);
			//if(findTo) findTo(data);
		}
		else {
			var geometry = feature.getGeometry();
			if(geometry && geometry.getCoordinates) {
				var coord = geometry.getCoordinates();
				var zoom = _map.getView().getZoom();
				_map.getView().animate({
					center: coord,
					zoom: zoom + 1,
			        duration: 500
			        //easing: elastic
				});
			}
		}
	});

	/*_map.on('pointermove', function(evt) {
		if (evt.dragging) {
			return;
		}
		var pixel = _map.getEventPixel(evt.originalEvent);
		
		var feature = _map.forEachFeatureAtPixel(pixel, function(feature, layer) {
			var context_data = layer.get('context_data');
			if(context_data && context_data.type == 'marker') {
				//return featue;
				//features.push(feature);
		    	var meta = _labels_map[feature.getId()];
				if(meta) {
					return meta.feature;
				}
			}
		});
		
		highliteFeature(feature);
	});*/
	
	var _highlightedFeature;
    var highliteFeature = function(feature) {

    	/*var info = document.getElementById('info');
	  	if (feature) {
	    	info.innerHTML = feature.getId() + ': ' + feature.get('name');
	  	} else {
	    	info.innerHTML = '&nbsp;';
	  	}*/
    	
    	var dehighliteFeature = function() {
    		/*var source = _highliteLayer.getSource();
    		var features = source.getFeatures();
			features.forEach(function(feature) {
				source.removeFeature(feature);
    			feature.setStyle(_defLblStyleFnc);
			});*/
			if(_highlightedFeature) {
				_highliteLayer.getSource().removeFeature(_highlightedFeature);
				_highlightedFeature.setStyle(_defLblStyleFnc);
				_highlightedFeature = null;
			}
    	}
    	
    	if( feature ) {
    		if (feature !== _highlightedFeature) {
    			dehighliteFeature();
    			
    			feature.setStyle(_focusedFeautreStyleFnc);
    			_highliteLayer.getSource().addFeature(feature);
    			_highlightedFeature = feature;
    		}
    	}
    	else if (_highlightedFeature) {
    		dehighliteFeature();
    	}

    };
}



