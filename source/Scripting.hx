package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Constraints.IMap;
import hscript.Interp;
import hscript.Parser;
import sys.FileSystem;
import sys.io.File;

using StringTools;

//class MyFlxColor extends FlxColor {}

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
        "FlxTimer" => FlxTimer,
        "Scripting" => Scripting,
        "ScriptingCustomState" => ScriptingCustomState,
        "FlxText" => FlxText,
        "FlxSprite" => FlxSprite,
        "FlxBar" => FlxBar,
        "FlxBackdrop" => FlxBackdrop,
        "SpriteVMan" => SpriteVMan,
        "FlxTween" => FlxTween,
        //"FlxColor" => MyFlxColor, //why cant i put FlxColor here ????????? wtf!!!!!!!!!
        "FlxCamera" => FlxCamera,
        "FlxSpriteGroup" => FlxSpriteGroup,
        "FlxTypedGroup" => FlxTypedGroup,
        "FlxEase" => FlxEase,
        "Highscore" => Highscore,
        "ModsMenuState" => ModsMenuState,
        "ScriptUtil" => ScriptUtil,
        "LoadingState" => LoadingState
    ];

    public var validFuncs:Map<String, Bool>;
    public var interp:Interp;
    public var id:String;
    public var modName:String;
    public var name:String;
    public var context:String;
    //public var exitStateDelete:Bool = false;

    public static function getScript(name:String, modName:String, ?context:String = "") {
        return namedScripts.exists('${modName}:${name}') ? namedScripts['${modName}:${name}'] : new Scripting(name, modName, context);
    }

    public static function clearScripts() {
        runOnScripts("destroy", new Array<Dynamic>());
        namedScripts.clear();
        scripts.resize(0);
    }

    public static function clearScriptsByContext(context:String) {
        var toRemove = new Array<String>();
        for (thing in scripts) {
            if (thing.context == context) {
                thing.runValidFunction("destroy", new Array<Dynamic>());
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
            script.runValidFunction(funcName, args);
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
            script.runValidFunction("modchartUpdate", [FlxG.elapsed]);
        }
    }

    //todo: do i need this
    /*public static function runStatePostInitOnScripts(arr:Array<String>) {
        for (script in scripts) {
            script.runStatePostInit(arr);
        }
    }*/

    public static function initScriptsByContext(context:String) {
        for (mod in ModLoad.enabledMods) {
            new Scripting("scripts/context/"+context, mod, context);
        }
    }

    public function new(name:String, ?modName:String, ?context:String = "") {
        id = '${modName}:${name}';
        var filepath = modName == "" ? 'assets/${name}.hxs' : 'mods/${modName}/${name}.hxs';
        if (!namedScripts.exists(id) && FileSystem.exists(filepath)) {
            this.context = context;
            interp = new Interp();
            interp.variables.set("vmanScript", this);
            interp.variables.set("vmanIsPrimaryMod", modName == ModLoad.primaryMod.id);
            interp.variables.set("killScript", killScript);
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
            checkValidFuncs(["statePostInit", "update", "modchartUpdate", "destroy", "beatHit", "stageInit", "onAccept", "onBack"]);
            trace("Success Load script: "+id);
        }
    }

    public function killScript() {
        runValidFunction("destroy", new Array<Dynamic>());
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
        return validFuncs;
    }

    public function runValidFunction(funcName:String, args:Array<Dynamic>):Dynamic {
        return validFuncs.exists(funcName) ? Reflect.callMethod(this, interp.variables.get(funcName), args) : null;
    }

    public function runFunction(funcName:String, args:Array<Dynamic>):Dynamic {
        return Reflect.isFunction(interp.variables.get(funcName)) ? Reflect.callMethod(this, interp.variables.get(funcName), args) : null;
    }

    public inline function runModchartUpdate() {
        if (Options.instance.modchartEnabled)
            runValidFunction("modchartUpdate", [FlxG.elapsed]);
    }

    /*public inline function runStatePostInit(arr:Array<String>) {
        if (exitStateDelete && arr[0] != context)
            killScript();
        else
            runValidFunction("statePostInit", arr);
    }*/

    public static function path(name:String, mod:String) {
        return 'scripts/${mod}/${name}';
    }

    //Epic Shared vars !!
    public static var sharedVars = new Map<String, Dynamic>();

    public static function listSharedVarsByNamespace(namespace:String, ?arr:Array<String>) {
        if (arr == null)
            arr = new Array<String>();
        for (n in sharedVars.keys()) {
            if (n.startsWith(namespace + ":")) {
                arr.push(n);
            }
        }
        return arr;
    }

    public static function clearSharedVarsByNamespace(namespace:String) {
        for (n in sharedVars.keys()) {
            if (n.startsWith(namespace + ":")) {
                sharedVars.remove(n);
            }
        }
    }
}
