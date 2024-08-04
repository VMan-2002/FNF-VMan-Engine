package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.ShaderParameter;
import openfl.filters.ShaderFilter;
import sys.FileSystem;
import sys.io.File;

using StringTools;

//u suck
/* class VeShaderParamater<T> extends ShaderParameter<T> {
    public override function new(?value:Null<Array<T>>) {
        super();
        this.value = value;
    }
} */

class VeShader extends FlxShader {
    //When I Veshad. I'm a Veshader
    public var filter:ShaderFilter;

	public override function new(name:String, modName:String) {
        super();
        var fragpath = 'mods/${modName}/shaders/${name}.frag';
        var vertpath = 'mods/${modName}/shaders/${name}.vert';
        if (FileSystem.exists(fragpath))
            glFragmentSource = File.getContent(fragpath);
        if (FileSystem.exists(vertpath))
            glVertexSource = File.getContent(vertpath);
        //not efficient
        for (name in Reflect.fields(data)) {
            switch(name) {
                case "iResolution":
                    /*var p = new ShaderParameter<Int>();
                    p.value = [FlxG.stage.stageWidth, FlxG.stage.stageWidth];
                    data.iResolution = p;*/
                    data.iResolution = VeShader.shaderParameter([FlxG.stage.stageWidth, FlxG.stage.stageHeight]);
            }
        }
        filter = new ShaderFilter(this);
    }

    @:arrayAccess
    public function set(name:String, value:String) {
        Reflect.setProperty(data, name, value);
    }

    @:arrayAccess
    public function get(name:String) {
        Reflect.getProperty(data, name);
    }

    /**
        Applies the shader to the specified FlxCamera.
        
        `camera`: The camera to apply this shader to

        `state`: Whether to add (`true`) or remove (`false`)

        `noDupes`: Whether to prevent duplicates (don't add if already applied, or remove all that are applied)
    **/
    public function cameraApply(camera:FlxCamera, ?state:Bool = true, ?noDupes:Bool = true) {
        @:privateAccess
        if (camera._filters == null) {
            if (state)
                camera.setFilters([filter]);
        } else {
            if (state) {
                @:privateAccess
                if (!noDupes || !camera._filters.contains(filter)) {
                    @:privateAccess
                    camera._filters.push(filter);
                }
            } else {
                do {
                    @:privateAccess
                    camera._filters.remove(filter);
                } while (noDupes && @:privateAccess camera._filters.contains(filter));
            }
        }
       /* if (camera.filters == null) {
            if (state)
                camera.filters = [filter];
        } else {
            if (state) {
                if (!noDupes || !camera.filters.contains(filter)) {
                    camera.filters.push(filter);
                }
            } else {
                do {
                    camera.filters.remove(filter);
                } while (noDupes && camera.filters.contains(filter));
            }
        }*/
    }

    /**
        Helper function to create a ShaderParameter with predefined value
    **/
    public static function shaderParameter<T>(value:Null<Array<T>>):ShaderParameter<T> {
        var result = new ShaderParameter<T>();
        result.value = value;
        return result;
    }
}
