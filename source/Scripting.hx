package;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
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
        "FlxMath" => FlxMath,
        "FlxTimer" => FlxTimer
    ];

    var validFuncs:Map<String, Bool>;
    var interp:Interp;
    var id:String;
    var context:String;

    public static function clearScripts() {
        runOnScripts("destroy", new Array<Dynamic>());
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

    public static function runOnScriptsNoWhitelist(funcName:String, args:Array<Dynamic>) {
        for (script in scripts) {
            if (Reflect.isFunction(script.interp.variables.get(funcName)))
                Reflect.callMethod(script, script.interp.variables.get(funcName), args);
        }
    }

    public static function runModchartUpdateOnScripts() {
        if (!Options.instance.modchartEnabled)
            return;
        for (script in scripts) {
            script.runFunction("modchartUpdate", [FlxG.elapsed]);
        }
    }

    public static function initScriptsByContext(context:String) {
        for (mod in ModLoad.enabledMods) {
            new Scripting("scripts/context/"+context, mod, context);
        }
    }

    public function new(name:String, ?modName:String, ?context:String = "") {
        id = '${modName}:${name}';
        var filepath = modName == "" ? 'assets/${name}.hx' : 'mods/${modName}/${name}.hx';
        if (!namedScripts.exists(id) && FileSystem.exists(filepath)) {
            this.context = context;
            interp = new Interp();
            interp.variables.set("vmanScriptID", id);
            interp.variables.set("vmanScriptName", name);
            interp.variables.set("vmanScriptMod", modName);
            interp.variables.set("vmanIsPrimaryMod", modName == ModLoad.primaryMod.id);
            parser.line = 1;
            for (thing in classThings.keys())
                interp.variables.set(thing, classThings.get(thing));
            try {
                interp.execute(parser.parseString(File.getContent(filepath)));
            } catch (err) {
                trace('Error while loading loading script ${id}: ${err.message}');
                return;
            }
            scripts.push(this);
            namedScripts.set(id, this);
            checkValidFuncs(["postStateInit", "update", "updateModchart", "destroy", "beatHit", "stageInit"]);
            trace("Success Load script: "+id);
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
