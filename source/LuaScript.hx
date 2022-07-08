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

using StringTools;

class LuaScript {
	public function new(path:String) {
		//idk Lol!
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
	
	public static function characterPlayAnim(id:Int, name:String, ?force:Bool) {
		Character.activeArray[id].playAnim(name, force);
	}
	
	public static function getVarCharacter(id:Int, name:String) {
		return Reflect.getProperty(Character.activeArray[id], name);
	}
	
	public static function getVar(name:String) {
		return Reflect.getProperty(FlxG.state, name);
	}
	
	public static function getVarClass(id:String, name:String) {
		return Reflect.getProperty(Type.resolveClass(id), name);
	}
}
