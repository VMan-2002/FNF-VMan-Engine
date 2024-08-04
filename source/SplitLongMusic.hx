package;

import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

class SplitLongMusic {
	//todo: Idk if this is finished yet

	public var sounds:Array<FlxSound> = new Array<FlxSound>();
	public var curSound:Int = 0;
	public var soundStarts:Array<Float> = new Array<Float>();
	public var looped:Bool = false;
	public static var soundGroup:FlxSoundGroup = new FlxSoundGroup();
	public var trackPos:Float;

	/**
		Function run when the last FlxSound in the SplitLongMusic is finished playing.
	**/
	public var onComplete:Void->Void;

	public function new() {
		if (soundGroup == null) {
			soundGroup = new FlxSoundGroup();
		}
	}

	/**
		Add a sound to the SplitLongMusic object. This overrides the FlxSound's `OnComplete` function, so use the SplitLongMusic's `OnComplete` function instead for similar behaviour.
	**/
	public function addSound(snd:FlxSound) {
		if (snd.looped) {
			looped = true;
			snd.looped = false;
		}
		sounds.push(snd);
		soundGroup.add(snd);
		snd.onComplete = soundNext;
	}

	public function stop() {
		sounds[curSound].stop();
		curSound = 0;
	}

	public function play(?forceRestart:Bool = false, ?startTime:Float = 0) {
		if (forceRestart) {
			var startAt:Int = 0;
			while (soundStarts.length + 1 < startAt && soundStarts[startAt + 1] < startTime) {
				
			}
			if (curSound > 0) {
				sounds[curSound].stop();
			}
			curSound = 0;
			sounds[0].play(true, startTime);
		}
	}

	public function resume() {
		sounds[curSound].resume();
	}

	public function pause() {
		sounds[curSound].pause();
	}

	/**
		Used internally to play the next sound when one is finished
	**/
	function soundNext() {
		curSound += 1;
		if (curSound == sounds.length) {
			curSound = 0;
			if (onComplete != null) {
				onComplete();
			}
			if (!looped) {
				return;
			}
		}
		sounds[curSound].play(true);
	}
}
