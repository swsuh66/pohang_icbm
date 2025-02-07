(function(window, $, undefined) {



    var getOrApply = function(value, context) {
        return 'a';
    };
   


    function Grid(element, config) {
        var $element = $(element);

        this._container = $element;
        this.data = [];
        this.fields = [];

        this._init(config);      
    };

    Grid.prototype = {
    		
    	_1: function() {
    		alert('1');
    	},
    	
    	_2: function() {
    		alert('2');
    	}
    	
    };

    $.fn.jsGrid = function(config) {
        var args = $.makeArray(arguments),
            methodArgs = args.slice(1),
            result = this;

        this.each(function() {
            var $element = $(this),
                instance = $element.data(JSGRID_DATA_KEY),
                methodResult;

            if(instance) {
                if(typeof config === "string") {
                    methodResult = instance[config].apply(instance, methodArgs);
                    if(methodResult !== undefined && methodResult !== instance) {
                        result = methodResult;
                        return false;
                    }
                } else {
                    instance._detachWindowResizeCallback();
                    instance._init(config);
                    instance.render();
                }
            } else {
                new Grid($element, config);
            }
        });

        return result;
    };

    var fields = {};

    var setDefaults = function(config) {
        var componentPrototype;

        if($.isPlainObject(config)) {
            componentPrototype = Grid.prototype;
        } else {
            componentPrototype = fields[config].prototype;
            config = arguments[1] || {};
        }

        $.extend(componentPrototype, config);
    };

    var locales = {};

    var locale = function(lang) {
        var localeConfig = $.isPlainObject(lang) ? lang : locales[lang];

        if(!localeConfig)
            throw Error("unknown locale " + lang);

        setLocale(jsGrid, localeConfig);
    };

    var setLocale = function(obj, localeConfig) {
        $.each(localeConfig, function(field, value) {
            if($.isPlainObject(value)) {
                setLocale(obj[field] || obj[field[0].toUpperCase() + field.slice(1)], value);
                return;
            }

            if(obj.hasOwnProperty(field)) {
                obj[field] = value;
            } else {
                obj.prototype[field] = value;
            }
        });
    };

    window.jsGrid = {
        Grid: Grid,
        fields: fields,
        setDefaults: setDefaults,
        locales: locales,
        locale: locale,
        version: '1.5.3'
    };

}(window, jQuery));


(function(jsGrid, $, undefined) {

    function DirectLoadingStrategy(grid) {
        this._grid = grid;
    }

    DirectLoadingStrategy.prototype = {

        firstDisplayIndex: function() {
            var grid = this._grid;
            return grid.option("paging") ? (grid.option("pageIndex") - 1) * grid.option("pageSize") : 0;
        },

        lastDisplayIndex: function() {
            var grid = this._grid;
            var itemsCount = grid.option("data").length;

            return grid.option("paging")
                ? Math.min(grid.option("pageIndex") * grid.option("pageSize"), itemsCount)
                : itemsCount;
        },

        itemsCount: function() {
            return this._grid.option("data").length;
        },

        openPage: function(index) {
            this._grid.refresh();
        },

        loadParams: function() {
            return {};
        },

        sort: function() {
            this._grid._sortData();
            this._grid.refresh();
            return $.Deferred().resolve().promise();
        },

        reset: function() {
            this._grid.refresh();
            return $.Deferred().resolve().promise();
        },

        finishLoad: function(loadedData) {
            this._grid.option("data", loadedData);
        },

        finishInsert: function(insertedItem) {
            var grid = this._grid;
            grid.option("data").push(insertedItem);
            grid.refresh();
        },

        finishDelete: function(deletedItem, deletedItemIndex) {
            var grid = this._grid;
            grid.option("data").splice(deletedItemIndex, 1);
            grid.reset();
        }
    };


    
}(jsGrid, jQuery));
