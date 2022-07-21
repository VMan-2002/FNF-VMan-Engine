package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class PlayStateOffsetCalibrate extends PlayState
{
	public var hitOffsets = new Array<Float>();
	public var hitOffsetMin:Float = 0;
	public var hitOffsetMax:Float = 0;
	public var hitOffsetAvg:Float = 0;

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
		var thisOffset = Conductor.songPosition - note.strumTime;
		if (hitOffsets.length == 0) {
			hitOffsetMin = hitOffsetMax = thisOffset; //i think this is a thing
		} else {
			hitOffsetMin = Math.min(hitOffsetMin, thisOffset);
			hitOffsetMax = Math.max(hitOffsetMax, thisOffset);
		}
		hitOffsets.push(thisOffset);
		hitOffsetAvg = 0;
		for (n in hitOffsets) {
			hitOffsetAvg += n;
		}
		hitOffsetAvg /= hitOffsets.length;
		super.goodNoteHit(note);
	}

	override function endSong() {
		trace("Average offset: " + hitOffsetAvg);
		super.endSong();
	}
}
