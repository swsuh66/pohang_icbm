/*
 * required: ol_data_loader.js 
 */


String.prototype.trunc = String.prototype.trunc || function(n) {
	return this.length > n ? this.substr(0, n - 1) + '...' : this.substr(0);
};

function stringDivider(str, width, spaceReplacer) {
	if (str.length > width) {
		var p = width;
		while (p > 0 && (str[p] != ' ' && str[p] != '-')) {
			p--;
		}
		if (p > 0) {
			var left;
			if (str.substring(p, p + 1) == '-') {
				left = str.substring(0, p + 1);
			} else {
				left = str.substring(0, p);
			}
			var right = str.substring(p + 1);
			return left + spaceReplacer
					+ stringDivider(right, width, spaceReplacer);
		}
	}
	return str;
}


function OLlayerBoundary(olMap, url)
{
	
	var _olm = olMap;
	var _map = _olm.getMap();

	/**************************************************************************/
	/*
	 * 
	 */

	/**************************************************************************/

	var getMaxPoly = function(polys) {
		  var polyObj = [];
		  //now need to find which one is the greater and so label only this
		  for (var b = 0; b < polys.length; b++) {
		    polyObj.push({ poly: polys[b], area: polys[b].getArea() });
		  }
		  polyObj.sort(function (a, b) { return a.area - b.area });

		  return polyObj[polyObj.length - 1].poly;
	}
	
	var getText = function(feature, attrib) {
		var type = 'shorten';
		//var maxResolution = 400;
		var text = feature.get(attrib);//'SIG_KOR_NM');
		//var code = feature.get('SIG_CD');
		
		/*if(code == '48840') {
			var a=1;
		}
		if (!text || resolution > maxResolution) {*/
		if (!text) {
		  text = '';
		} else if (type == 'hide') {
		  text = '';
		} else if (type == 'shorten') {
		  text = text.trunc(12);
		} else if (type == 'wrap') {
		  text = stringDivider(text, 16, '\n');
		}
		
		return text;
	};

	var _textOption = {
		maxResolution: 320,
		align: 'center',
		baseline: 'middle',
		offsetX: '0',
		offsetY: '0',
		rotation: '0',
		font: 'normal 12px FontAwesome',	//FontAwesome dotum
    	fillColor: 'blue',
    	outlineColor: '#ffffff',
    	outlineWidth: '2'
	};


	/*var _boundaryPolyStyle = new ol.style.Style({
		stroke: new ol.style.Stroke({
			color: 'rgba(255, 0, 0, 0.9)',
			width: 10
			})
	});*/

	var _childrenPolyStyle = new ol.style.Style({
		stroke: new ol.style.Stroke({
			color: 'rgba(128, 128, 255, 0.9)',
			width: 2
			})/*,
		fill: new ol.style.Fill({
			color: 'rgba(255, 255, 0, 0.1)'
			})*/
		//text: getTextStyle(feature, resolution)
	});
	
	var _highlistPolyStyle = new ol.style.Style({
		stroke: new ol.style.Stroke({
			color : 'rgba(252, 252, 0, 1)', //'#f00',
			width : 3
			}),
		fill: new ol.style.Fill({
			color: 'rgba(255, 255, 0, 0.01)'
			})
		//text: getTextStyle(feature, resolution)
	});

	/**************************************************************************/

	var _textStyleCache = {};

	var getTextStyle = function(feature, resolution) {
		var code = feature.get('EMD_CD');
		
		if(!code || resolution > _textOption.maxResolution) {
			return null;
		}
		
		var textStyle = _textStyleCache[code];
		if(!textStyle) {

			var retPoint;
			var polygon;
			if (feature.getGeometry().getType() === 'MultiPolygon') {
				polygon =  getMaxPoly(feature.getGeometry().getPolygons());
			} else if (feature.getGeometry().getType() === 'Polygon') {
				polygon = feature.getGeometry();
			} else {
				return null;
			}
			var polyinfo = {area:polygon.getArea(), point:polygon.getInteriorPoint()};
			feature.set("polyinfo", polyinfo);

			//-------------------------
	
			_textStyleCache[code] = textStyle = new ol.style.Style({
				text:new ol.style.Text({
					textAlign: _textOption.align,
					textBaseline: _textOption.baseline,
					font: _textOption.font,
					text: getText(feature, 'EMD_KOR_NM'),
					fill: new ol.style.Fill({color: _textOption.fillColor}),
					stroke: new ol.style.Stroke({color: _textOption.outlineColor, width: _textOption.outlineWidth}),
					offsetX: _textOption.offsetX,
					offsetY: _textOption.offsetY,
					rotation: _textOption.rotation
				}),
				geometry: function(feature){   
					var retPoint = polyinfo.point;
					//console.log(retPoint)
					return retPoint;
				}
			});
		}
		
		return textStyle;        
	};

	var _boundaryStyleFunction = function(feature, resolution) {
    	return _boundaryPolyStyle;
    }
 
    var _childrenStyleFunction = function(feature, resolution) {
    	var textStyle = null;//getTextStyle(feature, resolution);
    	var styles = (textStyle) ? [_childrenPolyStyle, textStyle] : _childrenPolyStyle;
    	
    	return styles;
    }

    var _polygonStyleFunction2 = function(feature, resolution) {
    	var textStyle = getTextStyle(feature, resolution);
    	var styles = (textStyle) ? [_highlistPolyStyle, textStyle] : _highlistPolyStyle;
    	
    	return styles;
    }
    
    /**************************************************************************/

    var _boundaryLayer;
    var _childrenLayer;
    var _highliteLayer;

    var load = function(url) {

    	/*_boundaryLayer = new ol.layer.Vector({
            source: new ol.source.Vector({
                url: 'http://localhost:8080/demo/geojson/base?code=46150',
                format: new ol.format.GeoJSON()
        		}),
            style: _boundaryStyleFunction,
            visible: true,
          });
    	_map.addLayer(_boundaryLayer);*/
    	
    	_childrenLayer = new ol.layer.Vector({
            source: new ol.source.Vector({
                url: 'http://localhost:8080/demo/geojson/child?code=46150',
                format: new ol.format.GeoJSON()
        		}),
            style: _childrenStyleFunction,
            visible: true,
          });
    	
    	_map.addLayer(_childrenLayer);

        _highliteLayer = new ol.layer.Vector({
    		source : new ol.source.Vector(),
    		//map : _map,
    		style : _polygonStyleFunction2
    	});
    	_map.addLayer(_highliteLayer);

    	_map.on('pointermove', function(evt) {
    		if (evt.dragging) {
    			return;
    		}
    		var pixel = _map.getEventPixel(evt.originalEvent);
    		highliteFeature(pixel);
    	});

    	_map.on('click', function(evt) {
    		highliteFeature(evt.pixel);
    	});
    	
    }
	
    
    var _highlight;
    var highliteFeature = function(pixel) {
      var feature = _map.forEachFeatureAtPixel(pixel, function(feature, layer) {
    	  if(layer == _childrenLayer)
    	  return feature;
      });

      /*var info = document.getElementById('info');
      if (feature) {
        info.innerHTML = feature.getId() + ': ' + feature.get('name');
      } else {
        info.innerHTML = '&nbsp;';
      }*/

      if( feature ) {
    	  if (feature !== _highlight) {
	    	  if (_highlight) {
	    		  _highliteLayer.getSource().removeFeature(_highlight);
	    	  }
	    	  _highliteLayer.getSource().addFeature(feature);
	    	  _highlight = feature;
    	  }
      }
      else if (_highlight) {
		  _highliteLayer.getSource().removeFeature(_highlight);
		  _highlight = feature;
	  }
      
      /*if (feature !== _highlight) {
        if (_highlight) {
        	_highliteLayer.getSource().removeFeature(_highlight);
        }
        if (feature) {
        	_highliteLayer.getSource().addFeature(feature);
        }
        _highlight = feature;
      }*/

    };

	/**************************************************************************/
	/*
	 * 
	 */

    load(url);
}

/******************************************************************************/
	

