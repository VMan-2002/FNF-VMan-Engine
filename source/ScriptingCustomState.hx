package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ScriptingCustomState extends MusicBeatSubstate {
	public static var instance:ScriptingCustomState;
	public var id:String;
	public var modName:String;
	public var path:String;

	public function new(path:String, modName:String) {
		super();
		id = '${modName}:${path}';
		this.modName = modName;
		this.path = path;
		instance = this;
	}

	public override function create() {
		super.create();
		var script = new Scripting(path, modName, "ScriptingCustomState");
		if (script.interp == null) {
			NoSongsState.doThing("story mode", "custom state", script.id);
		} else{
			script.interp.variables.set("vmanCustomStateInstance", this);
			thing("statePostInit", ["ScriptingCustomState", id, this]);
		}
	}

	inline function thing(name:String, arg:Array<Dynamic>) {
		Scripting.runOnScripts(name, arg);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		thing("update", [elapsed]);
		if (controls.ACCEPT) {
			thing("onAccept", []);
		}
		if (controls.BACK) {
			thing("onBack", []);
		}
	}
}