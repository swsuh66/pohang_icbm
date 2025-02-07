
var _olmap;

/******************************************************************************/
/*
 * 
 */

function OLMap(container, option)
{
	this.constructor.population++;
	
	/********************************************/
	/* private variable
	 * 
	 */

	var _domEle = document.createElement('li');
	var _meta_queue = new Object();
	var _map_layers = new Array();;

	var _map;// = _createMap(container, option);
	var _opt;
	
	_olmap = this;
	
	/********************************************/
	/* private function
	 * 
	 */

	var _internelDispatchEvent = function(type, detail) 
	{
		//var event = new CustomEvent('change-visible', { 'detail': meta.id });
		try {
			var event = new Event(type);
			event.detail = detail;
			_domEle.dispatchEvent(event);
		}catch(error) {
			var event = document.createEvent("Event");
			var doesnt_bubble = false;
			var isnt_cancelable = false;
			event.initEvent(type, doesnt_bubble, isnt_cancelable);
		}
	}

	var _createMap = function(container, option)
	{
		var interactions = [
		    new ol.interaction.MouseWheelZoom({duration: 0})
		  ];
		
		_opt = option;
		var opt = {
			controls: option.controls,				
			loadTilesWhileInteracting: true,
			target: container,
			//layers: _map_layers,
			//interactions: [interactions],
			/*interactions: ol.interaction.defaults({
			    //dragPan: true,
			    mouseWheelZoom: true
			  }).extend([
			    //new ol.interaction.DragPan({kinetic: false}),
			    new ol.interaction.MouseWheelZoom({duration: 200})
			  ]),*/		
			view: new ol.View({
				projection: option.projection,
				center: option.defult_center,
				zoom: option.defult_zoom,
				maxZoom: 20,
				minZoom: 6
			})
		};
			
		var map = new ol.Map(opt);
		
		/*layer_country.on('change:visible', function(){
		    alert("Countries");
		});*/
		
		map.getView().on('change:center', function(e){
			//_dispatchChange(e);
			//_dispatchMoveEnd(map);
		});
		map.getView().on('change:resolution', function(e){
			var view = e.target;
			//_refreshLayerVisible(view.getZoom());
			//_dispatchMoveEnd(map);
			/*if(_zc_timer) clearTimeout(_zc_timer);
			_zc_timer = setTimeout(_zoom_change_handler.bind(this), 200);*/
			_zoom_change_handler(e);
		});
		
		_dispatchMoveEnd(map);
		
		
		map.on("pointermove", function (evt) {
		    var hit = this.forEachFeatureAtPixel(evt.pixel, function(feature, layer) {
		        return true;
		    }); 
		    if (hit) {
		        this.getTargetElement().style.cursor = 'pointer';
		    } else {
		        this.getTargetElement().style.cursor = '';
		    }
		});		
		
		map.on("click", function(e) {
		    map.forEachFeatureAtPixel(e.pixel, function (feature, layer) {
		    	//console.log(feature, layer, e)
		    	//map.getView().setCenter(feature.getGeometry().getCoordinates());
		    	
		    	var query = feature.getProperties()['features'][0].S;	
		    	//console.log(query)

		    	map.getView().setCenter(ol.proj.transform([query.locLng, query.locLat], 'EPSG:4326', 'EPSG:3857'));
		    	map.getView().setZoom(18);
		    	
				parent.parent.loadModalData(false, query);
		    	return  true;
		    });
		});

		map.on('moveend', function(event) {
			var center = map.getView().getCenter(); // 현재 맵의 중심 좌표를 가져옴
			var lonLat = ol.proj.toLonLat(center); // 중심 좌표를 위경도 좌표로 변환
			var zoom = map.getView().getZoom();
			mapMoveHandlerForAddress(lonLat,zoom);
		});
		
		return map;
	}

	var _getZoom = function(map) {
		if(!map) map = _map;
		var zoom = map.getView().getZoom();
		if(!zoom) zoom = _lastZoom;
		return zoom;
	}
	var _lastZoom;

	/********************************************/
	
	var _zoom_change_handler = function(e) {
		_map.updateSize();
		/*var zoom = _getZoom();
		if(zoom != _lastZoom) {
			_lastZoom = zoom;
			_refreshLayerVisible(_lastZoom);
		}*/
		_dispatchMoveEnd();
	}
	
	var _dispatchMoveEnd = function(map) {
		if(!map) map = _map;
		var view = map.getView();
		//var zoom = view.getZoom();
		var zoom = _getZoom(map);
		var center = view.getCenter();
		var resolution = view.getResolution();
		var maxResolution = resolution * Math.pow(2, zoom);
		if(mapMoveEndHandler)
			mapMoveEndHandler(center, zoom, resolution, maxResolution);
	}
	
	/********************************************/
	/* public function
	 * 
	 */

	this.addEventListener = function(type, listener, useCapture)
	{
		_domEle.addEventListener(type, listener, useCapture);
	}
	
	/**********************************/
	var _tooltipOverlay;
	
	this.setTooltipOvlay = function(tooltipElementId) {
		var tooltipElement = document.getElementById(tooltipElementId);
		/*var mapBoundary = _map.getView().calculateExtent(_map.getSize());
		mapBoundary = ol.proj.transformExtent(mapBoundary, 'EPSG:3857', 'EPSG:4326');
		var mapLonMin = mapBoundary[0];
		var mapLonMax = mapBoundary[2];
		var mapLatMin = mapBoundary[1];
		var mapLatMax = mapBoundary[3];*/
		
		_tooltipOverlay = new ol.Overlay({
			element: tooltipElement,
			offset: [0, 0]
			/*positioning: 'bottom-center',
			stopEvent: false,
			offset: [0, -50]*/
		});
		_tooltipOverlay.setPosition(ol.proj.transform([0, 0], 'EPSG:4326', 'EPSG:3857'));
		_map.addOverlay(_tooltipOverlay);
	}
	
	this.getTooltipOvlay = function() {
		return _tooltipOverlay;
	}


	/**********************************/

	this.getMap = function()
	{
		return _map;
	}

	this.updateSize = function() {
		_map.updateSize();
		//setTimeout( function() { _map.updateSize();}, 10);
	}
	
	/**********************************/

	this.autosetMinZoom = function() {
		var properties = _map.getView().getProperties();
		properties["minZoom"] = _getZoom();
		_map.setView(new ol.View(properties));	
		//_map.setOptions({restrictedExtent: _opt.bounding_extent});
	}
	
	this.fitView = function(boundingExtent, save) {
		if(!boundingExtent)
			boundingExtent = _opt.bounding_extent;
		
		if(boundingExtent) {
			_map.getView().fit(boundingExtent, _map.getSize());
			
			if(save) {
				_opt.bounding_extent = boundingExtent;
				_opt.defult_center = _map.getView().getCenter();
				_opt.defult_zoom = _getZoom();
				
				//this.autosetMinZoom();
			}
			_map.getView().setCenter(_opt.defult_center);
			_map.getView().setZoom(_opt.defult_zoom);
		}
	}
	
	this.resetCenter = function()
	{
		if(!_opt) return;
		
		if(_opt.bounding_extent)
			this.fitView(_opt.bounding_extent);
		else {
			_map.getView().setCenter(_opt.defult_center);
			_map.getView().setZoom(_opt.defult_zoom);
		}
	}
	
	this.setCenter = function(lon, lat, zoom)
	{
		_map.getView().setCenter(ol.proj.transform([lon, lat], 'EPSG:4326', 'EPSG:3857'));
		if(zoom)
			_map.getView().setZoom(zoom);
	}
	
	this.getCenter = function()
	{
		return _map.getView().getCenter();
	}
	
	this.setZoom = function(zoom)
	{
		_map.getView().setZoom(zoom);
	}
	
	this.getZoom = function()
	{
		return _getZoom();//_map.getView().getZoom();
	}
	
	/**********************************/
	
	this.getLayer = function(id)
	{
		var layer = _meta_queue[id];
		if(layer)
			return layer;
		return null;
	}
	
	this.addLayer = function(layer, id)
	{
		if(id) {
			_meta_queue[id] = id;
			layer.set('name', id);
		}
		_map.addLayer(layer);
	}
	
	this.removeLayer = function(id)
	{
		var layer = _meta_queue[id];
		_meta_queue[id] = null;
		if(layer)
			_map.removeLayer(layer);
	}
	
	/**********************************/

	this.getLayerVisible = function(id)
	{
		var layer = getLayer(id);
		if(layer)
			return layer.getVisible();
		return false;
	}

	this.setLayerVisible = function(id, visible)
	{
		var layer = getLayer(id);
		if(layer)
			return layer.setVisible(visible);
	}
	
	/**********************************/

	this.resolutionForZoom = function(zoom)
	{
		var resolution = 156543.03390625;
		for(var i=0; i<zoom; i++) {
			resolution /= 2;
		}
		return resolution;
	}
	
	/**********************************/
	
	_map = _createMap(container, option);
}



function loadModalRawData(pointSq, siteSq) {
	
	var type = $('#typeSelect', window.parent.parent.document).val();
	var endDate = $('#fromDate', window.parent.parent.document).val(); 				 		
		if(!endDate || endDate.length == 0) {
			
			/* 날짜 초기화 */
			$('#fromDate', window.parent.parent.document).val(kutil.dateFormat(new Date(), 'yyyy-mm-dd')); 			
			endDate = kutil.dateFormat(new Date(), 'yyyy-mm-dd'); 
			
		}
		
		var obj = new Object();

		obj.endDate = endDate;
	
	var begDate = kutil.addMonth(endDate, (type == '0') ? -1 : -12); 		 		
	obj.begDate = moment(Date.parse(begDate)).format('YYYY-MM-DD');
	obj.pointSq = pointSq;
	obj.siteSq = siteSq;

	window.parent.parent._params = obj; 
	setTimeout(function(){
		window.parent.parent.loadModalData();		
	},100);
};
        
