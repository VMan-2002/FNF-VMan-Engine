package;

import Alphabet.AlphaCharacter;
import AsyncLoad.AsyncAudioLoad;
import AsyncLoad.AsyncImageLoad;
import CoolUtil.MultiStepResult;
import CoolUtil.ScriptHelper;
import Note.SwagNoteSkin;
import Note.SwagNoteType;
import Note.SwagUIStyle;
import Options.PrivateOptions;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxStrip;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.AngleTween;
import flixel.tweens.misc.ColorTween;
import flixel.tweens.misc.NumTween;
import flixel.tweens.misc.VarTween;
import flixel.tweens.motion.CircularMotion;
import flixel.tweens.motion.CubicMotion;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.motion.LinearPath;
import flixel.tweens.motion.QuadMotion;
import flixel.tweens.motion.QuadPath;
import flixel.ui.FlxBar;
import flixel.util.FlxAxes;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import hscript.Interp;
import hscript.Parser;
import render3d.Render3D.VeFlxSprite3D;
import render3d.Render3D.VeModel3D;
import render3d.Render3D.VeObject3D;
import render3d.Render3D.VeScene3D;
import sys.FileSystem;
import sys.io.File;
import wackierstuff.VeFlxCamera;

using StringTools;

//todo: gotta keep implementing the scripting !!!!!!!!!
//more states, more callbacks, more a lot of things

class Scripting {
    public static var parser:Parser = new Parser();
    public static var namedScripts:Map<String, Scripting> = new Map<String, Scripting>();
    public static var scripts:Array<Scripting> = new Array<Scripting>();
    final classThings:Map<String, Dynamic> = [
        //Game classes
        "Options" => Options,
        "Conductor" => Conductor,
        "Character" => Character,
        "CoolUtil" => CoolUtil,
        "Scripting" => Scripting,
        "SpriteVMan" => SpriteVMan,
        "Highscore" => Highscore,
        "ScriptUtil" => ScriptUtil,
        "Alphabet" => Alphabet,
        "AlphaCharacter" => AlphaCharacter,
        "Translation" => Translation,
        "Paths" => Paths,
        "Paths2" => Paths2,
        "SwagUIStyle" => SwagUIStyle,
        "SwagNoteType" => SwagNoteType,
        "SwagNoteSkin" => SwagNoteSkin,
        "ManiaInfo" => ManiaInfo,
        "VeShader" => VeShader,
        "MultiStepResult" => MultiStepResult,
        "AsyncImageLoad" => AsyncImageLoad,
        "AsyncAudioLoad" => AsyncAudioLoad,
        "ScriptHelper" => ScriptHelper,
        "Note" => Note,
        "ChartingNote" => ChartingNote,
        "StrumLine" => StrumLine,
        "HealthIcon" => HealthIcon,

        //Game state classes
        "PlayState" => PlayState,
        "FreeplayState" => FreeplayState,
        "LoadingState" => LoadingState,
        "ModsMenuState" => ModsMenuState,
        "ScriptingCustomState" => ScriptingCustomState,
        
        //Library classes
        "Math" => Math,
        "Std" => Std,
        "Reflect" => Reflect,
        "EReg" => EReg, //Regular Expression (RegEx) (RegExp) <---- Remember that this is RegEx because the usual syntax ~/(RegEx)/g doesn't work for some reason
        "StringTools" => StringTools,

        //Flixel library classes
        "FlxG" => FlxG,
        "FlxMath" => FlxMath,
        "FlxTimer" => FlxTimer,
        "FlxTween" => FlxTween,
        "FlxEase" => FlxEase,
        "FlxCamera" => VeFlxCamera, //Modified for colorblind filter usage
        "FlxPoint" => FlxPoint,
        "FlxSound" => FlxSound,
        "FlxAxes" => FlxAxes, //Deprecated
        "FlxTransitionableState" => FlxTransitionableState,

        "FlxTypedGroup" => FlxTypedGroup,
        "FlxSprite" => FlxSprite,
        "FlxSkewedSprite" => FlxSkewedSprite,
        "FlxEffectSprite" => FlxEffectSprite,
        "FlxTileblock" => FlxTileblock,
        "FlxStrip" => FlxStrip,
        "FlxText" => FlxText,
        "FlxTextBorderStyle" => FlxTextBorderStyle,
        "FlxBar" => FlxBar,
        "FlxBackdrop" => FlxBackdrop,
        "FlxTilemap" => FlxTilemap,
        "FlxSpriteGroup" => FlxSpriteGroup,
        "FlxCollision" => FlxCollision,
        
        //Three Dimensions
        "VeScene3D" => VeScene3D,
        "VeObject3D" => VeObject3D,
        "VeModel3D" => VeModel3D,
        "VeFlxSprite3D" => VeFlxSprite3D,
        
        //retools
        "MyFlxColor" => MyFlxColor,//, //why cant i put FlxColor here ????????? wtf!!!!!!!!!
        //"MySystem" => MySystem //im worried about security lol

        //what
        "ValueAccessor" => Accessor,
        "FlxAtlasFrames" => FlxAtlasFrames
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
    public static var gameBuildType(default, never) =
    #if debug
        "debug";
    #else
        "release";
    #end

    public var validFuncs:Map<String, Bool>;
    public var interp:Interp;
    public var id:String;
    public var modName(default, never):String;
    public var name:String;
    public var context:String;
    public var alive:Bool = true;
    //public var exitStateDelete:Bool = false;

    /**
        Get a script by id, loading it if it doesn't already exist
    **/
    public static function getScript(name:String, modName:String, ?context:String = "", ?loadError:Null<Bool->Void>) {
        return namedScripts.exists('${modName}:${name}') ? namedScripts['${modName}:${name}'] : new Scripting(name, modName, context, loadError);
    }

    /**
        Clear ALL SCRIPTS
    **/
    public static function clearScripts() {
        runOnScripts("destroy", new Array<Dynamic>());
        namedScripts.clear();
        scripts.resize(0);
    }

    /**
        Clear ALL SCRIPTS associated with a context
    **/
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

    /**
        Clear a script via it's ID
    **/
    public static function clearScriptByID(id:String) {
        if (namedScripts.exists(id))
            namedScripts.get(id).killScript();
    }

    /**
        Clear ALL SCRIPTS that match a custom criteria
    **/
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

    /**
        Run a function on all loaded scripts
    **/
    public static function runOnScripts(funcName:String, args:Array<Dynamic>) {
        for (script in scripts)
            script.runValidFunction(funcName, args);
    }

    /**
        Run a function on all loaded scripts, without checking validFuncs
    **/
    public static function runOnScriptsNoWhitelist(funcName:String, args:Array<Dynamic>) {
        for (script in scripts) {
            if (Reflect.isFunction(script.interp.variables.get(funcName)))
                Reflect.callMethod(script, script.interp.variables.get(funcName), args);
        }
    }

    /**
        Run modchartUpdate on scripts
    **/
    public static function runModchartUpdateOnScripts(name:String) {
        if (!Options.instance.modchartEnabled)
            return;
        for (script in scripts)
            script.runValidFunction(name, [FlxG.elapsed]);
    }

    /**
        Create a map from an array, using a variable's value a value's key
    **/
    public static function arrayToNameMap<T>(arr:Array<T>, nameVar:String, ?modNameVar:Null<String>) {
        var result = new Map<String, T>();
        for (thing in arr)
            result[(modNameVar != null ? Reflect.getProperty(thing, modNameVar) + ":" : "") + Reflect.getProperty(thing, nameVar)] = thing;
        return result;
    }

    /**
        Push all values of a map to an array
    **/
    public static function nameMapToArray<T>(map:Map<String, T>, ?result:Array<T> = null) {
        if (result == null)
            result = new Array<T>();
        for (thing in map)
            result.push(thing);
        return result;
    }

    /**
        Run checkUnlocks on scripts
    **/
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

    /**
        Load scripts by a context
    **/
    public static function initScriptsByContext(context:String) {
        for (mod in ModLoad.enabledMods)
            new Scripting("scripts/context/"+context, mod, context);
        trace("Loaded scripts for context "+context+", now "+scripts.length+" scripts are loaded");
    }

    /**
        New script object
        
        `name`: Path of the script relative to the mod name

        `modName`: Mod the script belongs to

        `context`: Context to associate this script with

        `loadError`: Function to run if the script fails to load with 1 `Bool` arg. Called with `true` if the script errored while loading, `false` if the script wasn't found
    **/
    public function new(name:String, ?modName:String, ?context:String = "", ?loadError:Null<Bool->Void>) {
        id = '${modName}:${name}';
        var filepath = modName == "" ? 'assets/${name}.hxs' : 'mods/${modName}/${name}.hxs';
        if (FileSystem.exists(filepath)) {
            if (!namedScripts.exists(id)) {
                this.context = context;
                interp = new Interp();
                interp.variables.set("vmanScript", this);
                interp.variables.set("vmanIsPrimaryMod", modName == ModLoad.primaryMod.id);
                interp.variables.set("killScript", killScript);
                interp.variables.set("addScriptResult", addScriptResult);
                parser.line = 1;
                for (thing in classThings.keys())
                    interp.variables.set(thing, classThings.get(thing));
                #if debug
                @:privateAccess
                if (PrivateOptions.typeClassAvailable && PrivateOptions.checkTypeClassAllowed())
                    interp.variables.set("Type", Type);
                #end
                try {
                    interp.execute(parser.parseString(File.getContent(filepath)));
                } catch (err) {
                    trace('Error while loading loading script ${id}: ${err.message}');
                    if (loadError != null)
                        loadError(true);
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
                    "onSpawnNote",
                    "substatePostInit",
                    "startCountdown",
                    "endSong",
                    "replayEvent",
                    "dialogueCloseAnim",
                    "dialogueStart",
                    "dialogueLine",
                    "dialogueUpdate",
                    "dialogueBoxStyle",
                    "songCredit",
                    "maniaSpecial"
                ]);
                trace("Success Load script: "+id);
            }
            namedScripts[id].runFunction("scriptRun", []);
        } else if (loadError != null) {
            loadError(false);
        }
    }

    /**
        Remove the script from memory
    **/
    public function killScript() {
        runValidFunction("destroy", new Array<Dynamic>());
        namedScripts.remove(id);
        scripts.remove(this);
        alive = false;
    }
    
    /**
        Add function names to `validFuncs` if the functions exist
    **/
    public function checkValidFuncs(funcNames:Array<String>) {
        validFuncs = new Map<String, Bool>();
        for (n in funcNames) {
            if (Reflect.isFunction(interp.variables.get(n)))
                validFuncs.set(n, true);
        }
        return validFuncs;
    }

    /**
        Runs a function if it is in the `validFuncs` array (if it's not a default function, you should add it using `checkValidFuncs`)
    **/
    public function runValidFunction(funcName:String, args:Array<Dynamic>):Dynamic {
        return validFuncs.exists(funcName) ? Reflect.callMethod(this, interp.variables.get(funcName), args) : null;
    }

    /**
        Runs a function if it is a function
    **/
    public function runFunction(funcName:String, args:Array<Dynamic>):Dynamic {
        return Reflect.isFunction(interp.variables.get(funcName)) ? Reflect.callMethod(this, interp.variables.get(funcName), args) : null;
    }

    /**
        Runs modchartUpdate
    **/
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

    //Script results

    public static var scriptResults:Map<String, Dynamic> = new Map<String, Dynamic>();
    public function addScriptResult(value:Dynamic) {
        scriptResults.set(id, value);
    }

    public static inline function clearScriptResults() {
        scriptResults.clear();
    }

    public static function scriptResultsContains(value:Dynamic) {
        for (thing in scriptResults) {
            if (thing == value)
                return true;
        }
        return false;
    }

    //Misc

    public static function setBlendMode(obj:FlxSprite, blend:String)
        obj.blend = blend.toLowerCase();

    public static function emptyDynamicMap()
        return new Map<Dynamic, Dynamic>();

    public static function emptyStringMap()
        return new Map<String, Dynamic>();

    public static function textBorderStyle(name:String) {
        switch(name.toLowerCase()) {
            case "shadow":
                return FlxTextBorderStyle.SHADOW;
            case "outline":
                return FlxTextBorderStyle.OUTLINE;
            case "outlinefast" | "outline_fast":
                return FlxTextBorderStyle.OUTLINE_FAST;
        }
        return FlxTextBorderStyle.NONE;
    }

    public static function axes(name:String) {
        switch(name.toLowerCase()) {
            case "x":
                return FlxAxes.X;
            case "y":
                return FlxAxes.Y;
        }
        return FlxAxes.XY;
    }

    public static function ease(name:String) {
        //todo: move the code here
        return ScriptHelper.getEaseFromString(name);
    }

    public static function tweenType(name:String) {
        switch(name.toLowerCase()) {
            case "backward":
                return FlxTweenType.BACKWARD;
            case "looping":
                return FlxTweenType.LOOPING;
            case "persist":
                return FlxTweenType.PERSIST;
            case "pingpong":
                return FlxTweenType.PINGPONG;
        }
        return FlxTweenType.ONESHOT;
    }

    public static function cloneTween(tween:FlxTween, obj:Dynamic, ?cont:Bool = true):FlxTween {
        var options:TweenOptions = {
            type: tween.type,
            onStart: tween.onStart,
            onUpdate: tween.onUpdate,
            ease: tween.ease,
            onComplete: tween.onComplete,
            startDelay: tween.startDelay,
            loopDelay: tween.loopDelay
        };
        var result:FlxTween = switch(Type.getClass(tween)) {
            case AngleTween:
                var tAng:AngleTween = cast tween;
                //guys i LOVE typing @:privateAccess!!!!!!!!!
                @:privateAccess var newTAng = new AngleTween(options, tween.manager);
                @:privateAccess return newTAng.tween(tAng._start, tAng._start + tAng._range, tween.duration, obj);
            case CircularMotion:
                var mCirc:CircularMotion = cast tween;
                //guys i love it
                @:privateAccess var newCirc = new CircularMotion(options, tween.manager);
                newCirc.setObject(obj);
                @:privateAccess return newCirc.setMotion(mCirc._centerX, mCirc._centerY, mCirc._radius, mCirc._angleStart, mCirc._angleFinish >= 0, tween.duration);
            case ColorTween:
                var color:ColorTween = cast tween;
                //i love it so much
                @:privateAccess var newColor = new ColorTween(options, tween.manager);
                @:privateAccess return newColor.tween(tween.duration, color.startColor, color.endColor, obj);
            case CubicMotion:
                var mCube:CubicMotion = cast tween;
                //so much in fact
                @:privateAccess var newMCube = new CubicMotion(options, tween.manager);
                newMCube.setObject(obj);
                @:privateAccess return newMCube.setMotion(mCube._fromX, mCube._fromY, mCube._aX, mCube._aX, mCube._bX, mCube._bY, mCube._toX, mCube._toY, tween.duration);
            case LinearMotion:
                var mLine:LinearMotion = cast tween;
                //that uhhhh
                @:privateAccess var newMLine = new LinearMotion(options, tween.manager);
                newMLine.setObject(obj);
                @:privateAccess return newMLine.setMotion(mLine._fromX, mLine._fromY, mLine._moveX + mLine._fromX, mLine._moveY + mLine._fromY, tween.duration);
            case LinearPath:
                var pLine:LinearPath = cast tween;
                //i forgot how to love it
                @:privateAccess var newPLine = new LinearPath(options, tween.manager);
                newPLine.setObject(obj);
                newPLine.points = pLine.points.copy();
                @:privateAccess newPLine._pointD = pLine._pointD.copy();
                @:privateAccess return newPLine.setMotion(tween.duration);
            case NumTween:
                var tNum:NumTween = cast tween;
                //what's a private access again?
                @:privateAccess var newTNum = new NumTween(options, tween.manager);
                @:privateAccess return newTNum.tween(tNum._start, tNum._range + tNum._start, tween.duration, tNum._tweenFunction);
            case QuadMotion:
                var mQuad:QuadMotion = cast tween;
                //seems like something invasive and bothering
                @:privateAccess var newMQuad = new QuadMotion(options, tween.manager);
                newMQuad.setObject(obj);
                @:privateAccess return newMQuad.setMotion(mQuad._fromX, mQuad._fromY, mQuad._controlX, mQuad._controlY, mQuad._toX, mQuad._toY, tween.duration);
            case QuadPath:
                var pQuad:QuadPath = cast tween;
                //it sucks to have to be so invasive
                @:privateAccess var newPQuad = new QuadPath(options, tween.manager);
                newPQuad.setObject(obj);
                @:privateAccess newPQuad._points = pQuad._points;
                @:privateAccess newPQuad._updateCurve = true;
                @:privateAccess return newPQuad.setMotion(tween.duration);
            case VarTween:
                var tVar:VarTween = cast tween;
                //sadb
                @:privateAccess var newTVar = new VarTween(options, tween.manager);
                @:privateAccess return newTVar.tween(obj, tVar._properties, tween.duration);
            default:
                trace("Tween type "+ Type.getClassName(Type.getClass(tween)) +" not found when trying to Scripting.cloneTween (Probably gonna crash now?)");
                null;
        }
        if (cont)
            @:privateAccess result._secondsSinceStart = tween._secondsSinceStart;
        return @:privateAccess tween.manager.add(result);
    }

    /**
        This is not ScriptingCustomState().switchToThis(), it exists for convenience
    **/
    public function switchToThis() {
        var mod = id.substring(0, id.indexOf(":") - 1);
        var name = id.substring(id.indexOf(":") + 1);
        new ScriptingCustomState(name, mod).switchToThis();
    }

    //interp variables map stuff

    @:arrayAccess
    public function get(name:String)
        return interp.variables.get(name);

    @:arrayAccess
    public function set(name:String, value:Dynamic)
        return interp.variables.set(name, value);

    public function exists(name:String)
        return interp.variables.exists(name);

    public function iterator()
        return interp.variables.iterator();

    public function keyValueIterator()
        return interp.variables.keyValueIterator();

    public function keys()
        return interp.variables.keys();

    public function remove(name:String)
        return interp.variables.remove(name);
}

class ScriptSave {
    private var name:String;
    private var modName:String;
    private var dsav:FlxSave;


    public function new(name:String, modName:String) {
        this.name = name;
        this.modName = modName;
    }

    public function load(?setAll:Bool = false) {

    }

    public function save() {
        
    }

    /*@:arrayAccess
    public function get(name:String)
        return interp.variables.get(name);

    @:arrayAccess
    public function set(name:String, value:Dynamic)
        return interp.variables.set(name, value);*/
}

class MyFlxColor {
    //exists because i cant fucking put FlxColor in the thing
    //i do indeed seethe :')
    public static var d = [
        "BLACK" => FlxColor.BLACK,
        "BLUE" => FlxColor.BLUE,
        "BROWN" => FlxColor.BROWN,
        "CYAN" => FlxColor.CYAN,
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
    public static var BLACK = FlxColor.BLACK;
    public static var BLUE = FlxColor.BLUE;
    public static var BROWN = FlxColor.BROWN;
    public static var CYAN = FlxColor.CYAN;
    public static var GREEN = FlxColor.GREEN;
    public static var LIME = FlxColor.LIME;
    public static var MAGENTA = FlxColor.MAGENTA;
    public static var ORANGE = FlxColor.ORANGE;
    public static var PINK = FlxColor.PINK;
    public static var PURPLE = FlxColor.PURPLE;
    public static var RED = FlxColor.RED;
    public static var TRANSPARENT = FlxColor.TRANSPARENT;
    public static var WHITE = FlxColor.WHITE;
    public static var YELLOW = FlxColor.YELLOW;

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

//todo: why doesnt this work
/*class MySystem {
    public static var freeMemory(get, never):Float;
    public static var totalMemoryNumber(get, never):Float;

    static function get_freeMemory() {
        return System.freeMemory;
    }

    static function get_totalMemoryNumber() {
        return System.totalMemoryNumber;
    }
}*/

class Accessor {
    var obj:Dynamic;
    var prop:String;
    /**
        This class is a shortcut for `Reflect.getProperty` and `Reflect.setProperty`, using `this.get` and `this.set` respectively
    **/
    public function new(obj:Dynamic, property:String) {
        this.obj = obj;
        prop = property;
    }

    public function get()
        return Reflect.getProperty(obj, prop);

    public function set(val:Dynamic)
        return Reflect.setProperty(obj, prop, val);
}