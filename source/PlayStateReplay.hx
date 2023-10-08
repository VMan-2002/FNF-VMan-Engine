package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

typedef ReplayData = {
	modName:String,
	song:String,
	difficulty:String,
	notes:Array<ReplayEventData>,
	events:Array<ReplayEventData>,
	eventNames:Array<String>
}

typedef ReplayEventData = {
	num:Int,
	evt:Int,
	time:Float
}

class PlayStateReplay extends PlayState {
	var replayNoteNum:Int = 0;
	var replayEventNum:Int = 0;

	var handlingNotes:Bool = true;
	var handlingEvents:Bool = true;
	
	public function new(dat:ReplayData) {
		super();
	}

	public override function keyShit() {
		//replay handling lol

		if (handlingNotes) {
			var notestuff = replay.notes[replayNoteNum];
			if (notestuff.time <= Conductor.songPosition) {
				for (thing in notes.members) {
					if (notestuff.num == thing.noteId) {
						goodNoteHit(thing, replay.eventNames[notestuff.evt]);
						break;
					}
				}
				replayNoteNum += 1;
				if (replay.notes.length == replayNoteNum)
					handlingNotes = false;
			}
		}

		if (handlingEvents) {
			var eventstuff = replay.events[replayEventNum];
			if (eventstuff.time <= Conductor.songPosition) {
				Scripting.runOnScripts("replayEvent", [eventstuff]);
				replayEventNum += 1;
				if (replay.events.length == replayEventNum)
					handlingEvents = false;
			}
		}
	}
}
