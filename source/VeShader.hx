package;

import flixel.FlxCamera;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class VeShader extends Shader {
    //When I Veshad. I'm a Veshader
    public var filter:ShaderFilter;

	public override function new(name:String, modName:String) {
        super();
        var fragpath = 'mods/${modName}/shaders/${name}.frag';
        var vertpath = 'mods/${modName}/shaders/${name}.vert';
        if (FileSystem.exists(fragpath))
            glFragmentSource = File.getContent(fragpath);
        if (FileSystem.exists(vertpath))
            glFragmentSource = File.getContent(vertpath);
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

        `noDupes`: Whether to prevent duplicates
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
                } while (noDupes && camera._filters.contains(filter));
            }
        }
    }
}
