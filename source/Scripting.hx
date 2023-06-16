package;

import ManiaInfo;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import hscript.Interp;
import lime.utils.Assets;

using StringTools;

class Scripting {
    public static var scripts:Map<String, Scripting>;
    var validFuncs:Map<String, Bool>;
    var interp:Interp;

    public static function clearScripts() {
        
    }

    public function new(name:String, ?modName:String) {
        scripts.set('${modName}:${name}', this);
    }
    
    public function checkValidFuncs(funcNames:Array<String>) {
        validFuncs = new Map<String, Bool>();
        for (n in funcNames) {
            if (Reflect.isFunction(interp.variables.get(n))) {
                validFuncs.set(n, true);
            }
        }
    }

    public function runFunction(funcName:String, args:Array<Dynamic>) {
        if (validFuncs.exists(funcName))
            Reflect.callMethod(this, interp.variables.get(funcName), args);
    }
}
