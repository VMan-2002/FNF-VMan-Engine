package;

import CoolUtil.ScriptHelper as CoolScriptHelper;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.events.KeyboardEvent;
#if !html5
import Conductor.BPMChangeEvent;
import Reflect;
import Type;
import cpp.Int32;
import flixel.FlxG;
import flixel.addons.editors.ogmo.FlxOgmo3Loader.GridLayer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import llua.Lua;
import llua.LuaL;
import llua.State;

using StringTools;

//todo: remove this
class LuaScript {
	//todo: linc_luajit is so unintuitive why is it crashing what am i doing wrong why is there no error message why is there no documentation
	var state:MusicBeatState;
	var lua:State;
	var myPath:String;
	var myMod:String;
	static var printedLuaInfo:Bool = false;

	public static var persistVars:Map<String, Any> = new Map<String, Any>();
	public var isSaving:Bool = false;
	public var saveInst:FlxSave;
	public var tweenCurrent:Dynamic = {};
	public var tweenEase:Float->Float = FlxEase.linear;
	public var tweenDelay:Float = 0;

	public function new(path:String, state:MusicBeatState) {
		this.state = state;
		this.myPath = path;
		this.myMod = "Lua_Test";
		var fileData:String = Assets.getText(path);
		trace("Loading Lua script: " + path);
		lua = LuaL.newstate();
		if (!printedLuaInfo) {
			printedLuaInfo = true;
			trace("Lua version: " + Lua.version());
			trace("LuaJIT version: " + Lua.versionJIT());
		}
		trace("do code");
		doCode("
			os = nil
			io = nil
		");
		trace("add hprint");
		Lua_helper.add_callback(lua, "hprint", function(value:String) {
			//trace("hprint");
			//trace2(value);
			//return null;
		});
		trace("do script");
		doCode(fileData);
		trace("do hprint func a");
		doCode("function funnyFunc() hprint('This is called from lua!') end");
		trace("do func");
		runFunction("funnyFunc");
		trace("add sethealth");
		addFunction("setHealth", function(newHealth:Float) {
			PlayState.instance.health = newHealth;
			return null;
		});
		runFunction("onInit");

		//ha funny
		state.add(new FlxText(0, 0, FlxG.width, fileData));
	}

	function trace2(value:Dynamic) {
		//trace(value);
	}

	public function addFunction(name:String, func:Null<Dynamic>->Null<Dynamic>) {
		Lua_helper.add_callback(lua, name, func); //i had to look at psych engine for this :( why is it so unintuitive
	}

	public function runFunction(func:String, ?args:Null<Array<Dynamic>>):Null<Dynamic> {
		Lua.getglobal(lua, func);
		return Lua.pcall(lua, 0, 0, 0);
		//return doCode(func + (args == null || args.length == 0 ? "()" : "(" + args.join(", ") + ")")); //todo: this doesnt look like it would work
	}

	public inline function doCode(code:String):Null<Dynamic> {
		return LuaL.dostring(lua, code);
	}
	
	//functions lol
	//todo: put these in lua
	public static function getCharId(name:String) {
		var returnThing:Int = -1;
		for (i in Character.activeArray) {
			if (i.curCharacter.startsWith(name)) {
				if (i.curCharacter == name) {
					return i.thisId;
				}
				returnThing = i.thisId;
			}
		}
		return returnThing;
	}
	
	public function characterPlayAnim(id:Int, name:String, ?force:Bool) {
		Character.activeArray[id].playAnim(name, force);
	}

	//Get/Set variables
	
	public function getVarCharacter(id:Int, name:String) {
		return Reflect.getProperty(Character.activeArray[id], name);
	}
	
	public function getVar(name:String) {
		return Reflect.getProperty(FlxG.state, name);
	}
	
	public function getVarClass(id:String, name:String) {
		return Reflect.getProperty(Type.resolveClass(id), name);
	}

	public function getSongFormatted(name:String) {
		return Highscore.formatSong(name); 
	}

	public function getCurrentModifier() {
		return Highscore.getModeString();
	}

	//Persist vars

	public function setPersistVar(name, value) {
		persistVars.set('${myMod}:${name}', value);
	}

	public function getPersistVar(name) {
		return persistVars.get('${myMod}:${name}');
	}

	//Save data

	public function startSave() {
		saveInst = new FlxSave();
		saveInst.bind("mod_"+myMod);
		isSaving = true;
	}

	public function addSaveVar(name:String, value:Dynamic) {
		if (!isSaving) {
			return null;
		}
		FlxG.save.data.set(name, value);
		return null;
	}

	public function finishSave() {
		if (!isSaving) {
			return null;
		}
		saveInst.flush();
		isSaving = false;
		return null;
	}

	public function startLoad() {
		saveInst = new FlxSave();
		saveInst.bind("mod_"+myMod);
		isSaving = true;
	}

	public function loadSaveVar(name:String) {
		if (!isSaving) {
			return null;
		}
		return FlxG.save.data.get(name);
	}

	public function finishLoad() {
		if (!isSaving) {
			return null;
		}
		saveInst.close();
		isSaving = false;
		return null;
	}

	//Math stuff

	public function zag(num:Float) {
		return num % 2 > 1 ? -1 : 1;
	}

	public function lerp(a:Float, b:Float, t:Float) {
		return a + (b - a) * t;
	}

	public function centerof2(a:Float, b:Float) {
		return (a + b) / 2;
	}

	public function sign(num:Float, ?def:Float = 0) {
		if (num == 0) {
			return def;
		}
		return num > 0 ? 1 : -1;
	}

	//String stuff

	public function stringSplit(str:String, delim:String) {
		return str.split(delim);
	}

	public function stringJoin(arr:Array<String>, delim:String) {
		return arr.join(delim);
	}

	public function stringTrim(str:String) {
		return str.trim();
	}

	public function stringReplace(str:String, old:String, with:String) {
		return str.replace(old, with);
	}

	public function stringStartsWith(str:String, start:String) {
		return str.startsWith(start);
	}

	public function stringEndsWith(str:String, end:String) {
		return str.endsWith(end);
	}

	public function trimSameStart(str:String, start:String) {
		if (str.startsWith(start)) {
			return str.substring(start.length);
		}
		return str;
	}

	public function trimSameEnd(str:String, end:String) {
		if (str.endsWith(end)) {
			return str.substring(0, str.length - end.length);
		}
		return str;
	}

	//tween stuff

	public function clearTweenDeploy() {
		tweenDelay = 0;
		tweenEase = FlxEase.linear;
		tweenCurrent = {};
	}

	public function setTweenDeployArg(name:String, value:Dynamic) {
		if (name == "ease" && Std.isOfType(value, String)) {
			tweenEase = getEaseFromString(value);
		} else if (!Std.isOfType(value, Float)) {
			return trace("Lua: Can't set tween arg using non-float value");
		}
		if (name == "startDelay") {
			tweenDelay = value;
			return;
		}
		Reflect.setProperty(tweenCurrent, name, value);
	}

	public function runTween(object:String, time:Float) {
		FlxTween.tween(getObject(object), tweenCurrent, time, {startDelay: tweenDelay});
	}

	public function runTweenX(object:String, value:Float, time:Float) {
		FlxTween.tween(getObject(object), {x: value}, time, {startDelay: tweenDelay});
	}

	public function runTweenY(object:String, value:Float, time:Float) {
		FlxTween.tween(getObject(object), {y: value}, time, {startDelay: tweenDelay});
	}

	public function runTweenAngle(object:String, value:Float, time:Float) {
		FlxTween.tween(getObject(object), {angle: value}, time, {startDelay: tweenDelay});
	}

	public function runTweenAlpha(object:String, value:Float, time:Float) {
		FlxTween.tween(getObject(object), {alpha: value}, time, {startDelay: tweenDelay});
	}

	public function cancelTweensOf(object:String, args:Null<Array<String>>) {
		FlxTween.cancelTweensOf(getObject(object), args);
	}

	//Other

	//public function luaBroadcast(value:Dynamic, ?includeSelf:Null<Bool>):Null<Dynamic> {
		/*var result:Dynamic = null;
		for (luaThing in state.luaScripts) {
			if (includeSelf == true || luaThing != this) {
				var possible:Dynamic = luaThing.runFunction("onLuaBroadcast", [value, myMod, myPath]);
				if (possible != null) {
					result = possible;
				}
			}
		}
		return result;*/
	//}

	public function switchToCustomState(name:String, ?skipTransIn:Null<Bool>, ?skipTransOut:Null<Bool>) {
		if (skipTransIn == true) {
			FlxTransitionableState.skipNextTransIn = true;
		}
		if (skipTransOut == true || (skipTransIn == true && skipTransOut == null)) {
			FlxTransitionableState.skipNextTransOut = true;
		}
		return FlxG.switchState(new LuaCustomState(name, myMod));
	}

	//internal whatevers (not for addFunction)

	public static inline function getEaseFromString(name:String) {
		return CoolScriptHelper.getEaseFromString(name);
	}

	public inline function getObject(name:String) {
		return CoolScriptHelper.getObject(name, state);
	}
}
#end

class ScriptHelperOld extends CoolScriptHelper {}