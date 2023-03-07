package;

import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OptionsWarningState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var latestOptionsWarning:Int = 2;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		/*var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Hi!\n\nThis mod may contain *Flashing Lights*!\nIn addition, you can change the *Language*!\n\nPress O to go to the Options menu now,\nor press Enter to go to the main menu.",
		32);*/
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Hi!\n\nThis mod may contain *Flashing Lights*!\nYou're supposed to be able to turn this off,\nas well as change the *Language*, but since I'm a lazy ass,\nFlashing Lights doesn't do much right now.\n\nPress O to go to the Options menu,\nor press Enter to go to the main menu.",
		32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.applyMarkup(txt.text, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xffffff22, false, false, 0xff444402), "*")
		]);
		txt.screenCenter();
		txt.y -= FlxG.height / 4;
		makeThing(0, FlxG.height - 450, "flashing lights");
		makeThing(FlxG.width - 450, FlxG.height - 450, "language");
		add(txt);
	}
	
	inline function makeThing(x:Float, y:Float, thing:String) {
		var imageThing1 = new FlxSprite(x, y);
		imageThing1.frames = Paths.getSparrowAtlas("menu/vman_options");
		imageThing1.animation.addByPrefix("idle", thing);
		imageThing1.animation.play("idle");
		add(imageThing1);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.O) {
			leftState = true;
			Options.seenOptionsWarning = latestOptionsWarning;
			FlxG.switchState(new OptionsMenu());
		} else if (controls.ACCEPT) {
			leftState = true;
			Options.seenOptionsWarning = latestOptionsWarning;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
