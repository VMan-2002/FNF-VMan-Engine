package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

using StringTools;

class MultiWaitState extends MusicBeatState
{
	var checkTime:Float;

	public function new() {
		super();
		var waitText = new FlxText(0, 0, FlxG.width, "Waiting for the host to start the game...\nPress Esc to leave.");
		waitText.setFormat(null, 16, 0xffffffff, "center");
		waitText.screenCenter();
		add(waitText);
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK) {
			FlxG.switchState(new MainMenuState());
		} else {
			checkTime += elapsed;
			if (checkTime > 0.5) {
				checkTime = 0;
				trace('this is where i would check if the game is starting');
			}
		}
		super.update(elapsed);
	}
}
