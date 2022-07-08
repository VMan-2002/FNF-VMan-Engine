package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class PlayStateOffsetCalibrate extends PlayState
{
	var hitOffsets = new Array<Float>();

	public function new() {
		PlayState.modName = "";
		Options.botplay = false;
		CoolUtil.difficultyArray = ["Normal"];
		PlayState.SONG = Song.loadFromJson(Highscore.formatSong("Input Offset Calibrate"), "input-offset-calibrate");
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		super();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function goodNoteHit(note:Note) {
		hitOffsets.push(Conductor.songPosition - note.strumTime);
		super.goodNoteHit(note);
	}

	override function endSong() {
		var result:Float = 0;
		for (n in hitOffsets) {
			result += n;
		}
		result /= hitOffsets.length;
		trace("Average offset: " + result);
		super.endSong();
	}
}
