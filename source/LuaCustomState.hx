package;


//todo: remove this
class LuaCustomState extends MusicBeatSubstate {
	public function new(path:String, modName:String) {
		super();
		thing("onPostInit");
	}

	inline function thing(name) {}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		thing("onUpdate");
		if (controls.ACCEPT) {
			thing("onAccept");
		}
		if (controls.BACK) {
			thing("onCancel");
		}
		thing("onPostUpdate");
	}
}
