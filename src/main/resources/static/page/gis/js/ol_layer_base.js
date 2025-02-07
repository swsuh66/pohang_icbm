/******************************************************************************/
/*
 * 
 */

var olbase = {};
var licenseKey = "";
 function getVlicense() {
	$.ajax({
			url : "getLicense",
			type : 'POST',
			async : false,
			dataType : 'json', 
			success : function(data) {
				console.log ('licenseKey : ' + data.license);
				if (data.isSucces == 'Y') {
					licenseKey = data.license;
				}
				else {
					console.log ('실패');
				}
			},
			error : function(e) {
				console.log ('에러 : ' + e);
			},
		});
}


/******************************************************************************/
/*
 * 
 */

function OLlayerBase(olMap)
{
	olbase.layerSources = [
		/*
		{
			source: new ol.source.XYZ({
				url: 'http://api.vworld.kr/req/wmts/1.0.0/'+licenseKey+'/Base/{z}/{y}/{x}.png',
				maxZoom: 18
			}),
			id: 'base_Base',
			symbol: 'B',
			title: '일반',
			type : 'base',
			displayInLayerSwitcher: true,
			opacity:1,
			visible: true
		},
		{
			source: new ol.source.XYZ({
				url: 'http://api.vworld.kr/req/wmts/1.0.0/'+licenseKey+'/gray/{z}/{y}/{x}.png',
				maxZoom: 18
			}),
			id: 'base_Base',
			symbol: 'G',
			title: '그레이',
			type : 'base',
			displayInLayerSwitcher: true,
			opacity:1,
			visible: false
		},
		{
			source: new ol.source.XYZ({
				url: 'http://api.vworld.kr/req/wmts/1.0.0/'+licenseKey+'/Satellite/{z}/{y}/{x}.jpeg',
				maxZoom: 18
			}),
			id: 'base_Satellite', 
			symbol: 'S',
			title: '위성',
			type : 'base',
			displayInLayerSwitcher: true,
			opacity:1,
			visible: false
		}
		*/
		{
			source: new ol.source.OSM(),
			id: 'base_Base',
			symbol: 'B',
			title: 'normal',
			type : 'base',
			displayInLayerSwitcher: true,
			opacity:1,
			visible: true
		},
		{
			source: new ol.source.Stamen({layer: 'watercolor'}),
			id: 'watercolor', 
			symbol: 'W',
			title: 'water color',
			type : 'base',
			displayInLayerSwitcher: true,
			opacity:1,
			visible: false
		},
		{
			source: new ol.source.Stamen({layer: 'terrain-lines'}),
			id: 'terrain-lines', 
			symbol: 'T',
			title: 'terrain lines',
			type : 'base',
			displayInLayerSwitcher: true,
			opacity:1,
			visible: false
		}
	];
	
	var _olm = olMap;
	var _map = _olm.getMap();
	
	var _baseLayer;
	var _boundLayer;
	//var _layer_bing;
	//var _layer_vword;

	var _layer_mask;
	var _active_layer;
	
	/**************************************************************************/

    var _getBoundaryExtent = function(polys) {
		var extent = ol.extent.createEmpty();
		for (var b = 0; b < polys.length; b++) {
			ol.extent.extend(extent, polys[b].getExtent());
		}
		return extent;
	}


	var _boundaryPolyStyles = [
		new ol.style.Style({
			stroke: new ol.style.Stroke({
				//color : 'rgba(255,255,255, 1)', //'#f00'
				//color : 'rgba(0,0,255, 1)', //'#f00'
				color: '#2b908f',
				width: 5
				})
		}),
		new ol.style.Style({
			stroke: new ol.style.Stroke({
				color : 'rgba(255,255,255, 1)', //'#f00'
				width: 5
				})
		})
	];
	

	var _boundaryStyleFunction = function(feature, resolution) {
		
		var lyrid = _active_layer.get('id');
		if(_active_layer && _active_layer.get('id') == 'base_Satellite')
			return _boundaryPolyStyles[1];
		else
			return _boundaryPolyStyles[0];
    }
 
	
	var _createBaseLayer = function() {
		
		//_layer_vword = new ol.layer.Tile(olbase.sources.base_vword);
		//_layer_bing = new ol.layer.Tile(olbase.sources.base_bing);
		//_layer_vword.setMaxResolution( _olm.resolutionForZoom(10) );
		//_layer_bing.setMinResolution( _olm.resolutionForZoom(10) );
		
		var layers = [];
		for(var ix=0; ix<olbase.layerSources.length; ix++) {
			var layer = new ol.layer.Tile(olbase.layerSources[ix]);
			layers.push(layer); 
			
			if(layer.getVisible())
				_active_layer = layer;
			
			layer.on('change:visible', function(e) {
				if(_layer_mask) {
					var visible = this.getVisible();
					if(visible) {
						_active_layer = this;
						this.addFilter(_layer_mask);
						_boundLayer.changed();
					}
					else
						this.removeFilter(_layer_mask);
				}
			}); 
		}

		_baseLayer = new ol.layer.Group({
			layers: layers,
			visible: true,
			title: '기본도',
			type : 'group',
			displayInLayerSwitcher: true
		});
		
		olMap.addLayer(_baseLayer, 'layer_base');
		
		_boundLayer = new ol.layer.Vector({
            source: new ol.source.Vector(),
            style: _boundaryStyleFunction,
            visible: true,
          });
		olMap.addLayer(_boundLayer, 'layer_boundary');
		//olMap.addLayer(_boundLayer);
		
		_map.addControl(new ol.control.LayerSwitcher({tipLabel:'지도종류'}));

		///
		/*
		var geoJsn=new ol.layer.Vector({
			source: new ol.source.Vector({
			   //url: '/resources/battnam.json',
			   url: '/resources/indonesia.json',
			   format: new ol.format.GeoJSON({
				  defaultDataProjection :'EPSG:4326', 
				  projection: 'EPSG:3857'
			   })
			}),
			name: 'NAME 1',
			style : new ol.style.Style({
				 stroke: new ol.style.Stroke({
					 //color : '#cf4a32', //'#f00'
					 color : '#008080', //'색변경'
					 width: 5
				 })
			 })
		 });
	 _map.addLayer(geoJsn, 'geoJsn');
	 */
	}

    var _makeFeature = function(coordinates) {
    	var geom = new ol.geom.MultiPolygon(coordinates);
    	/*if(geometry.type == 'MultiPolygon')
    		geom = new ol.geom.MultiPolygon(geometry.coordinates);
    	else if(geometry.type == 'Polygon')
    		geom = new ol.geom.Polygon(geometry.coordinates);*/
    	geom.transform('EPSG:4326', 'EPSG:3857');
    	
		var feature = new ol.Feature({geometry:geom});//, properties:data.properties});
		
		return feature;
    }
    
    
	var _addBoundaryPolygon = function(feature) {
		
		var source = _boundLayer.getSource();
    	source.clear();
    	
		if(feature)
			source.addFeature(feature);
	}
	
	/**************************************************************************/

	this.setBoundaryData = function(features) {
		
		var source = _boundLayer.getSource();
    	source.clear();
    	if(!features)return;
    	
		var appendArray = function(arr1, arr2) {
			for(var ix=0; ix<arr2.length; ix++)
				arr1.push(arr2[ix]);
		}
		var geometry = {type:'MultiPolygon', coordinates:[]};
		for(var ix=0; ix<features.length; ix++) {
			if(features[ix].type != 'Feature')
				continue;
			appendArray(geometry.coordinates, features[ix].geometry.coordinates);
		}
		var feature = _makeFeature(geometry.coordinates);
		
/*		
		var crop = new ol.filter.Crop({ feature: feature, inner:false });
		_layer_bing.addFilter(crop);
		_layer_vword.addFilter(crop);

		crop.set('inner', false); 
		crop.set('active', true); 
*/
		//------------------------------
		
		//var mask = new ol.filter.Mask({ feature: feature, inner:false, fill: new ol.style.Fill({ color:[212,212,255,0.4] }) });
		var mask = new ol.filter.Mask({ feature: feature, inner:false, fill: new ol.style.Fill({ color:[255,255,255,0.5] }) });
		//mask.fillColor_ = 'yellow';
		mask.set('inner',false); 
		mask.set('active', true); 

		_layer_mask = mask;
		
		if(_active_layer)
			_active_layer.addFilter(mask);
		
		_olm.fitView( _getBoundaryExtent(feature.getGeometry().getPolygons()), true );
		
		_addBoundaryPolygon(feature);
	}
	
	/**************************************************************************/
	/*
	 * 
	 */
	
	_createBaseLayer();
	
	
}
