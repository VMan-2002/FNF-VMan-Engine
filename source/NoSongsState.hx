package;

import Translation;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxColor;


class NoSongsState extends MusicBeatState {
	var goBack:String;
	var context:String;
	var extra:String;
	public override function new(goBack:String, context:String, ?ext:String = "") {
		this.goBack = goBack;
		this.context = context;
		extra = ext;
		super();
	}

	override function create() {
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			switch(context) {
				case "customstate":
					Translation.getTranslation("invalid custom state", "engine", [extra], "Invalid custom state script!\nTried to load from script ID:\n" + extra);
				case "customstate error":
					Translation.getTranslation("custom state error", "engine", [extra], "Error while loading custom state!\nTried to load from script ID:\n" + extra);
				default:
					Translation.getTranslation("no songs", context, null, "You have no songs!\nYou need to enable a mod first.");
			},
		32).setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
		return;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		if (controls.BACK)
			MainMenuState.returnToMenuFocusOn(goBack);
	}

	public static function doThing(goBack:String, context:String, ?ext:String = "") {
		FlxTransitionableState.skipNextTransIn = true;
		FlxG.state.switchTo(new NoSongsState(goBack, context, ext));
	}
}
