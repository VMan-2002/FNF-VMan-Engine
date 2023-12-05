package;

import flixel.FlxG;

class ScriptingCustomState extends MusicBeatState {
	public static var instance:ScriptingCustomState;
	public var id:String;
	public var modName:String;
	public var path:String;
	public var init:Bool = false;

	public static function cat(name:String, modName:String) {
		return new ScriptingCustomState('scripts/${modName}/${name}', modName);
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
		var script = new Scripting(path, modName, "ScriptingCustomState", function(thing:Bool) {
			NoSongsState.doThing("story mode", thing ? "customstate error" : "customstate", '${modName}:${path}');
		});
		if (script.interp == null)
			return;
		super.update(FlxG.elapsed);
		script.interp.variables.set("vmanCustomStateInstance", this);
	}

	inline function thing(name:String, arg:Array<Dynamic>) {
		Scripting.runOnScripts(name, arg);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (!init) {
			init = true;
			thing("statePostInit", ["ScriptingCustomState", id, this]); //Moving this should fix a bug where stuff can't be added in statePostInit
		}
		thing("update", [elapsed]);
		if (controls.ACCEPT)
			thing("onAccept", ["ScriptingCustomState", null, null]);
		if (controls.BACK)
			thing("onBack", ["ScriptingCustomState", null, null]);
	}
}