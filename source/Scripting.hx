package;

import Alphabet.AlphaCharacter;
import Note.SwagNoteSkin;
import Note.SwagNoteType;
import Note.SwagUIStyle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Constraints.IMap;
import hscript.Interp;
import hscript.Parser;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class MyFlxColor {
    //exists because i cant fucking put FlxColor in the thing
    //i do indeed seethe :')
    public static var d = [
        "BLACK" => FlxColor.BLACK,
        "BLUE" => FlxColor.BLUE,
        "BROWN" => FlxColor.BROWN,
        "CYAN" => FlxColor.BROWN,
        "GRAY" => FlxColor.GRAY,
        "GREEN" => FlxColor.GREEN,
        "LIME" => FlxColor.LIME,
        "MAGENTA" => FlxColor.MAGENTA,
        "ORANGE" => FlxColor.ORANGE,
        "PINK" => FlxColor.PINK,
        "PURPLE" => FlxColor.PURPLE,
        "RED" => FlxColor.RED,
        "TRANSPARENT" => FlxColor.TRANSPARENT,
        "WHITE" => FlxColor.WHITE,
        "YELLOW" => FlxColor.YELLOW
    ];
    public static function fromInt(n) {
        return FlxColor.fromInt(n);
    }
    public static function fromRGB(r, g, b, a) {
        return FlxColor.fromRGB(r, g, b, a);
    }
    public static function fromRGBFloat(r, g, b, a) {
        return FlxColor.fromRGBFloat(r, g, b, a);
    }
    public static function fromString(s) {
        return FlxColor.fromString(s);
    }
    public static function getRed(n:FlxColor) {
        return n.red;
    }
    public static function getGreen(n:FlxColor) {
        return n.green;
    }
    public static function getBlue(n:FlxColor) {
        return n.blue;
    }
    public static function getAlpha(n:FlxColor) {
        return n.alpha;
    }
}

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
        "MyFlxColor" => MyFlxColor, //why cant i put FlxColor here ????????? wtf!!!!!!!!!
        "FlxCamera" => FlxCamera,
        "FlxSpriteGroup" => FlxSpriteGroup,
        "FlxTypedGroup" => FlxTypedGroup,
        "FlxEase" => FlxEase,
        "Highscore" => Highscore,
        "ModsMenuState" => ModsMenuState,
        "ScriptUtil" => ScriptUtil,
        "LoadingState" => LoadingState,
        "FlxPoint" => FlxPoint,
        "FlxCollision" => FlxCollision,
        "FlxTilemap" => FlxTilemap,
        "FlxTextBorderStyle" => FlxTextBorderStyle,
        "Alphabet" => Alphabet,
        "AlphaCharacter" => AlphaCharacter,
        "Std" => Std,
        "FreeplayState" => FreeplayState,
        "FlxSound" => FlxSound,
        "Reflect" => Reflect,
        "Translation" => Translation,
        "EReg" => EReg, //Regular Expression (RegEx) (RegExp) <---- Remember that this is RegEx because the usual syntax ~/(RegEx)/g doesn't work for some reason
        "SwagUIStyle" => SwagUIStyle,
        "SwagNoteType" => SwagNoteType,
        "SwagNoteSkin" => SwagNoteSkin
    ];

	public static var gamePlatform(default, never) =
	#if windows 
		"windows";
	#elseif html5
		"html5";
	#elseif android
		"android";
	#elseif ios
		"ios";
	#elseif linux
		"linux";
	#else
		"unknown";
	#end

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

    public static inline function clearScriptsByContext(context:String) {
        /*var toRemove = new Array<String>();
        for (thing in scripts) {
            if (thing.context == context) {
                thing.runValidFunction("destroy", new Array<Dynamic>());
                toRemove.push(thing.id);
            }
        }
        for (thing in toRemove) {
            scripts.remove(namedScripts.get(thing));
            namedScripts.remove(thing);
        }*/
        clearScriptsByCritera(function(script) {
            return script.context == context;
        });
    }

    public static function clearScriptByID(id:String) {
        if (namedScripts.exists(id))
            namedScripts.get(id).killScript();
    }

    public static function clearScriptsByCritera(context:Scripting->Bool) {
        var toRemove = new Array<String>();
        for (thing in scripts) {
            if (context(thing)) {
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

    public static function runModchartUpdateOnScripts(name:String) {
        if (!Options.instance.modchartEnabled)
            return;
        for (script in scripts) {
            script.runValidFunction(name, [FlxG.elapsed]);
        }
    }

    public static function arrayToNameMap<T>(arr:Array<T>, nameVar:String, ?modNameVar:Null<String>) {
        var result = new Map<String, T>();
        for (thing in arr)
            result[(modNameVar != null ? Reflect.getProperty(thing, modNameVar) + ":" : "") + Reflect.getProperty(thing, nameVar)] = thing;
        return result;
    }

    public static function nameMapToArray<T>(map:Map<String, T>) {
        var result = new Array<T>();
        for (thing in map) {
            result.push(thing);
        }
        return result;
    }

    public static function runCheckUnlocksOnScripts<T>(category:String, args:Array<T>, nameVar:String, ?modNameVar:Null<String>) {
        var inputMap = arrayToNameMap(args, nameVar, modNameVar);
        for (script in scripts)
            script.runValidFunction("checkUnlocks", [category, args]);
        return nameMapToArray(inputMap);
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
        trace("Loaded scripts for context "+context+", now "+scripts.length+" scripts are loaded");
    }

    public function new(name:String, ?modName:String, ?context:String = "", ?loadError:Null<Void->Void>) {
        id = '${modName}:${name}';
        var filepath = modName == "" ? 'assets/${name}.hxs' : 'mods/${modName}/${name}.hxs';
        if (FileSystem.exists(filepath)) {
            if (!namedScripts.exists(id)) {
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
                    if (loadError != null)
                        loadError();
                    return;
                }
                scripts.push(this);
                namedScripts.set(id, this);
                checkValidFuncs([
                    "statePostInit",
                    "update",
                    "updatePost",
                    "modchartUpdate",
                    "modchartPostUpdate",
                    "destroy",
                    "beatHit",
                    "stageInit",
                    "stageChange",
                    "onAccept",
                    "onBack",
                    "scriptRun",
                    "enterFolder",
                    "cameraSetOnCharacter",
                    "noteMiss",
                    "goodNoteHit",
                    "charNoteHit",
                    "opponentNoteHit",
                    "preCreateMenuButtons",
                    "checkUnlocks",
                    "titleText",
                    "onSpawnNote"
                ]);
                trace("Success Load script: "+id);
            }
            namedScripts[id].runFunction("scriptRun", []);
        }/* else {
            trace('Didnt find script ${filepath}');
        }*/
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

    public inline function runModchartUpdate(name:String) {
        if (Options.instance.modchartEnabled)
            runValidFunction(name, [FlxG.elapsed]);
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
