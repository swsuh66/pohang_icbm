

/**
 * @classdesc
 * Layer source to cluster vector data. Works out of the box with point
 * geometries. For other geometry types, or if not all geometries should be
 * considered for clustering, a custom `geometryFunction` can be defined.
 *
 * @constructor
 * @param {olx.source.ClusterOptions} options Constructor options.
 * @extends {ol.source.Vector}
 * @api
 */
ol.source.CustomCluster = function(options) {
	ol.source.Vector.call(this, {
		attributions : options.attributions,
		extent : options.extent,
		logo : options.logo,
		projection : options.projection,
		wrapX : options.wrapX
	});	

	this.resolution = undefined;

	this.distance = options.distance !== undefined ? options.distance : 20;

	this.features = [];

	this.geometryFunction = options.geometryFunction || function(feature) {
		var geometry = /** @type {ol.geom.Point} */
		(feature.getGeometry());
		ol.asserts.assert(geometry instanceof ol.geom.Point, 10); // The default `geometryFunction` can only handle `ol.geom.Point` geometries
		return geometry;
	};

	this.source = options.source;

	this.source.on('change',
			ol.source.CustomCluster.prototype.refresh, this);
	
	this.resolutionFunction = options.resolutionFunction;
	this.maxZoomToClust = options.maxZoomToClust;
};
ol.inherits(ol.source.CustomCluster, ol.source.Vector);

ol.source.CustomCluster.prototype.getDistance = function() {
	return this.distance;
};
ol.source.CustomCluster.prototype.getSource = function() {
	return this.source;
};
ol.source.CustomCluster.prototype.loadFeatures = function(extent, resolution,
		projection) {
	this.source.loadFeatures(extent, resolution, projection);
	if (resolution !== this.resolution) {
		this.clear();
		this.resolution = resolution;
		this.cluster();
		this.addFeatures(this.features);
	}
};
ol.source.CustomCluster.prototype.setDistance = function(distance) {
	this.distance = distance;
	this.refresh();
};
ol.source.CustomCluster.prototype.refresh = function(event) {
	var resolution = this.resolutionFunction();
	//if(this.resolution != resolution) {
		this.clear();
		this.resolution = resolution;
		this.cluster();
		this.addFeatures(this.features);
		ol.source.Vector.prototype.refresh.call(this);
	//}
};

ol.source.CustomCluster.prototype.cluster = function() {
	if (this.resolution === undefined) {
		return;
	}
	this.features.length = 0;
	var extent = ol.extent.createEmpty();
	var mapDistance = this.distance * this.resolution;
	var features = this.source.getFeatures();

	var zoom = 0;
	var resolution = 156543.03390625;
	while(resolution > this.resolution) {
		resolution /= 2;
		zoom ++;
	}

	var clustered = {};

	
	var _createOrUpdate = function(minX, minY, maxX, maxY, opt_extent) {
		if (opt_extent) {
			opt_extent[0] = minX;
			opt_extent[1] = minY;
			opt_extent[2] = maxX;
			opt_extent[3] = maxY;
			return opt_extent;
		} else {
			return [ minX, minY, maxX, maxY ];
		}
	};
	var _createOrUpdateFromCoordinate = function(coordinate, opt_extent) {
		var x = coordinate[0];
		var y = coordinate[1];
		return _createOrUpdate(x, y, x, y, opt_extent);
	};
	_getUid = function(obj) {
		return obj.ol_uid || (obj.ol_uid = ++_uidCounter_);
	};
	var _uidCounter_ = 0;


	for (var i = 0, ii = features.length; i < ii; i++) {
		var feature = features[i];
		if (!(_getUid(feature).toString() in clustered)) {
			var geometry = this.geometryFunction(feature);
			if (geometry) {
				if(zoom < this.maxZoomToClust) {
					var coordinates = geometry.getCoordinates();
					//ol.extent.createOrUpdateFromCoordinate(coordinates, extent);
					_createOrUpdateFromCoordinate(coordinates, extent);
					ol.extent.buffer(extent, mapDistance, extent);
	
					var neighbors = this.source.getFeaturesInExtent(extent);
					neighbors = neighbors.filter(function(neighbor) {
						var uid = _getUid(neighbor).toString();
						if (!(uid in clustered)) {
							if(!this.filtFunction || this.filtFunction(neighbor)) {
								clustered[uid] = true;
								return true;
							}
							else {
								return false;
							}
						} else {
							return false;
						}
					});
				}
				else {
					var neighbors = [feature];
				}
				this.features.push(this.createCluster(neighbors));
			}
		}
	}
};

ol.source.CustomCluster.prototype.createCluster = function(features) {
	var _scale = function(coordinate, scale) {
		coordinate[0] *= scale;
		coordinate[1] *= scale;
		return coordinate;
	};
	
	var centroid = [ 0, 0 ];
	for (var i = features.length - 1; i >= 0; --i) {
		var geometry = this.geometryFunction(features[i]);
		if (geometry) {
			ol.coordinate.add(centroid, geometry.getCoordinates());
		} else {
			features.splice(i, 1);
		}
	}
	
	
	_scale(centroid, 1 / features.length);

	var cluster = new ol.Feature(new ol.geom.Point(centroid));
	cluster.set('features', features);
	return cluster;
};
