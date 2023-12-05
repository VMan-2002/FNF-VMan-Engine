package;

import flixel.FlxG;

class ScriptingCustomSubstate extends MusicBeatSubstate {
	public static var instance:ScriptingCustomSubstate;
	public var id:String;
	public var modName:String;
	public var path:String;
	public var init:Bool = false;

	public static function cat(name:String, modName:String) {
		return new ScriptingCustomSubstate('scripts/${modName}/${name}', modName);
	}

	public function new(path:String, modName:String) {
		super();
		id = '${modName}:${path}';
		this.modName = modName;
		this.path = path;
		instance = this;
	}

	public override function create() {
		super.create();
		var script = new Scripting(path, modName, "ScriptingCustomSubstate", function(thing:Bool) {
			NoSongsState.doThing("story mode", thing ? "customstate error" : "customstate", '${modName}:${path}');
		});
		if (script.interp == null)
			return;
		super.update(FlxG.elapsed);
		script.interp.variables.set("vmanCustomSubstateInstance", this);
	}

	inline function thing(name:String, arg:Array<Dynamic>) {
		Scripting.runOnScripts(name, arg);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (!init) {
			init = true;
			thing("substatePostInit", ["ScriptingCustomSubstate", id, this]); //Moving this should fix a bug where stuff can't be added in statePostInit
		}
		thing("update", [elapsed]);
		if (controls.ACCEPT)
			thing("onAccept", ["ScriptingCustomSubstate", null, null]);
		if (controls.BACK)
			thing("onBack", ["ScriptingCustomSubstate", null, null]);
	}
}