package wackierstuff;

import flixel.FlxCamera;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

class VeFlxCameraFilters {
    public var parent:VeFlxCamera;

    public function new(parent:VeFlxCamera) {
        this.parent = parent;
        updateColorblind();
    }

    public function updateColorblind() {
        if (filterArr.length != 0) {
            var topFilter = filterArr[filterArr.length - 1];
            if (Std.isOfType(topFilter, ShaderFilter) && Std.isOfType(cast(topFilter, ShaderFilter).shader, ColorblindShader)) //this if statement is a bit weird
                filterArr.pop();
        }
        if (Options.colorblind == "")
            return;
        filterArr.push(ColorblindShader.instanceFilter);
    }

    public var filterArr(get, set):Array<BitmapFilter>;

    function set_filterArr(value:Array<BitmapFilter>):Array<BitmapFilter> {
        @:privateAccess return parent._filters = value;
    }

    function get_filterArr():Array<BitmapFilter> {
        @:privateAccess return parent._filters == null ? new Array<BitmapFilter>() : parent._filters;
    }
}

class VeFlxCamera extends FlxCamera {
    public var ve_filters:VeFlxCameraFilters;

    public function new(?x:Int = 0, ?y:Int = 0, ?width:Int = 0, ?height:Int = 0, ?zoom:Float = 0) {
        super(x, y, width, height, zoom);
        ve_filters = new VeFlxCameraFilters(this);
    }
}