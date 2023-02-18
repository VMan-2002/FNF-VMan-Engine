package;

import Translation;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxColor;


class NoSongsState extends MusicBeatState {
	var goBack:String;
	var context:String;
	public override function new(goBack:String, context:String) {
		this.goBack = goBack;
		this.context = context;
		super();
	}

	override function create() {
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			Translation.getTranslation("no songs", context, null, "You have no songs!\nYou need to enable a mod first."),
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

	public static function doThing(goBack:String, context:String) {
		FlxTransitionableState.skipNextTransIn = true;
		FlxG.state.switchTo(new NoSongsState(goBack, context));
	}
}
