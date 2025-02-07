function ol_drag(option) {
	
	option = option || {};

	/**
	 * @param {ol.MapBrowserEvent} evt Event.
	 */
	var handleMoveEvent = function(evt) {
		if (!this.cursor_) return;
		
		var feature;
		if(ol.events.condition.platformModifierKeyOnly(evt)) {
			var map = evt.map;
			var feature = map.forEachFeatureAtPixel(evt.pixel, function(feature, layer) {
				if(filt_function_ == null || filt_function_(feature, layer) ) {
					return feature;
				}
			});
		}
		
		var element = evt.map.getTargetElement();
		if (feature) {
			if (element.style.cursor != this.cursor_) {
				this.previousCursor_ = element.style.cursor;
				element.style.cursor = this.cursor_;
			}
			focused_feature_ = feature;
		} else if (this.previousCursor_ !== undefined) {
			element.style.cursor = this.previousCursor_;
			this.previousCursor_ = undefined;
			
			focused_feature_ = null;
		}
	};

	/**
	 * @param {ol.MapBrowserEvent} evt Map browser event.
	 * @return {boolean} `true` to start the drag sequence.
	 */
	var handleDownEvent = function(evt) {
		
		//if(!ol.events.condition.platformModifierKeyOnly(evt)) return false;
		if(!focused_feature_) return false;
		
		var map = evt.map;

		var feature = map.forEachFeatureAtPixel(evt.pixel, function(feature, layer) {
			//if(filt_function_ == null || filt_function_(feature, layer) ) {
			if(focused_feature_ == feature) {
				return feature;
			}
			//return feature;
		});

		if (feature) {
			this.coordinate_ = evt.coordinate;
			this.feature_ = feature;
		}

		return !!feature;
	};

	/**
	 * @param {ol.MapBrowserEvent} evt Map browser event.
	 */
	var handleDragEvent = function(evt) {
		var deltaX = evt.coordinate[0] - this.coordinate_[0];
		var deltaY = evt.coordinate[1] - this.coordinate_[1];

		var geometry = /** @type {ol.geom.SimpleGeometry} */
		(this.feature_.getGeometry());
		geometry.translate(deltaX, deltaY);

		this.coordinate_[0] = evt.coordinate[0];
		this.coordinate_[1] = evt.coordinate[1];
	};

	/**
	 * @return {boolean} `false` to stop the drag sequence.
	 */
	var handleUpEvent = function() {
		if(result_function_ != null) 
			result_function_(this.feature_);
		
		focused_feature_ = null;
		
		this.coordinate_ = null;
		this.feature_ = null;
		return false;
	};
	
	ol.interaction.Pointer.call(this, {
		handleDownEvent : handleDownEvent,
		handleDragEvent : handleDragEvent,
		handleMoveEvent : handleMoveEvent,
		handleUpEvent : handleUpEvent
	});

	var filt_function_ = (option.preHandler ? option.preHandler : null);
	var result_function_ = (option.postHandler ? option.postHandler: null);
	
	var focused_feature_ = null;
	
	/**
	 * @type {ol.Pixel}
	 * @private
	 */
	this.coordinate_ = null;

	/**
	 * @type {string|undefined}
	 * @private
	 */
	this.cursor_ = 'pointer';

	/**
	 * @type {ol.Feature}
	 * @private
	 */
	this.feature_ = null;

	/**
	 * @type {string|undefined}
	 * @private
	 */
	this.previousCursor_ = undefined;

};
ol.inherits(ol_drag, ol.interaction.Pointer);
