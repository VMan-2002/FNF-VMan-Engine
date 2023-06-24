package;

import flixel.FlxG;
import flixel.math.FlxMath;
import hscript.Interp;
import hscript.Parser;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class Scripting {
    public static var parser:Parser = new Parser();
    public static var namedScripts:Map<String, Scripting> = new Map<String, Scripting>();
    public static var scripts:Array<Scripting> = new Array<Scripting>();
    final classThings:Map<String, Dynamic> = [
        "PlayState" => PlayState,
        "Options" => Options,
        "Conductor" => Conductor,
        "Character" => Character,
        "FlxG" => FlxG,
        "CoolUtil" => CoolUtil,
        "Paths" => Paths,
        "Math" => Math,
        "FlxMath" => FlxMath
    ];

    var validFuncs:Map<String, Bool>;
    var interp:Interp;
    var id:String;
    var context:String;

    public static function clearScripts() {
        for (thing in scripts) {
            thing.runFunction("destroy", new Array<Dynamic>());
        }
        namedScripts.clear();
        scripts.resize(0);
    }

    public static function clearScriptsByContext(context:String) {
        var toRemove = new Array<String>();
        for (thing in scripts) {
            if (thing.context == context) {
                thing.runFunction("destroy", new Array<Dynamic>());
                toRemove.push(thing.id);
            }
        }
        for (thing in toRemove) {
            scripts.remove(namedScripts.get(thing));
            namedScripts.remove(thing);
        }
    }

    public static function runOnScripts(funcName:String, args:Array<Dynamic>) {
        for (script in scripts) {
            script.runFunction(funcName, args);
        }
    }

    public static function runModchartUpdateOnScripts() {
        if (!Options.instance.modchartEnabled)
            return;
        for (script in scripts) {
            script.runFunction("modchartUpdate", [FlxG.elapsed]);
        }
    }

    public function new(name:String, ?modName:String, ?context:String = "") {
        id = '${modName}:${name}';
        this.context = context;
        var filepath = 'mods/${modName}/${name}';
        if (!namedScripts.exists(id) && FileSystem.exists(filepath)) {
            namedScripts.set(id, this);
            scripts.push(this);
            interp = new Interp();
            interp.variables.set("vmanScriptID", id);
            for (thing in classThings.keys())
                interp.variables.set(thing, classThings.get(thing));
            try {
                interp.execute(parser.parseString(File.getContent(filepath)));
            } catch (err) {
                trace("Error \""+err.message+"\" while loading loading script "+id+". details: "+err.details);
            }
            checkValidFuncs(["init", "update", "updateModchart", "destroy"]);
        }
    }

    public function killScript() {
        runFunction("destroy", new Array<Dynamic>());
        namedScripts.remove(id);
        scripts.remove(this);
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

    public inline function runModchartUpdate() {
        if (Options.instance.modchartEnabled)
            runFunction("modchartUpdate", [FlxG.elapsed]);
    }
}
