package;

import Conductor.BPMChangeEvent;
import Reflect;
import Type;
import cpp.Int32;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import llua.Lua;
import llua.LuaL;
import llua.State;

using StringTools;

class LuaScript {
	var state:MusicBeatState;
	var lua:State;
	var myPath:String;
	var myMod:String;
	static var printedLuaInfo:Bool = false;

	public function new(path:String, state:MusicBeatState) {
		this.state = state;
		this.myPath = path;
		this.myMod = "Lua_Test";
		trace("Loading Lua script: " + path);
		lua = LuaL.newstate();
		if (!printedLuaInfo) {
			printedLuaInfo = true;
			trace("Lua version: " + Lua.version());
			trace("LuaJIT version: " + Lua.versionJIT());
		}
		LuaL.dostring(lua, "
			os = nil
			io = nil
		");
		LuaL.dofile(lua, path);
		addFunction("setHealth", function(newHealth:Float) {
			PlayState.instance.health = newHealth;
			return null;
		});
		runFunction("onInit");
	}

	public function addFunction(name:String, func:Null<Dynamic>->Null<Dynamic>) {
		Lua.add_callback_function(lua, name); //todo: the "func" argument won't fit. why is this unintuitive?
	}

	public function runFunction(func:String, ?args:Null<Array<Dynamic>>):Null<Dynamic> {
		return LuaL.dostring(lua, func + "(" + args.join(", ") + ")"); //todo: this doesnt look like it would work
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

	public function luaBroadcast(value:Dynamic, ?includeSelf:Null<Bool>):Null<Dynamic> {
		var result:Dynamic = null;
		for (luaThing in state.luaScripts) {
			if (includeSelf == true || luaThing != this) {
				var possible:Dynamic = luaThing.runFunction("onLuaBroadcast", [value, myMod, myPath]);
				if (possible != null) {
					result = possible;
				}
			}
		}
		return result;
	}
}
