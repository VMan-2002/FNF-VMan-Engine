package;

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

class LuaScript {
	//todo: this is very broken please fix
	var state:MusicBeatState;
	var lua:State;
	var myPath:String;
	var myMod:String;
	static var printedLuaInfo:Bool = false;

	public static var persistVars:Map<String, Any> = new Map<String, Any>();
	public var isSaving:Bool = false;
	public var saveInst:FlxSave;

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
		doCode("funnyFunc()");
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
		return doCode(func + (args == null || args.length == 0 ? "()" : "(" + args.join(", ") + ")")); //todo: this doesnt look like it would work
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

	//Other

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

	public function switchToCustomState(name:String) {
		return null; //todo: This
	}
}
