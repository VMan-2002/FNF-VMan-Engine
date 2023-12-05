package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class ModchartEditorState extends PlayState
{
	public var unspawnNotes2:Array<Note>;
	
	public function new() {
		super();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function generateSong(thing:String) {
		super.generateSong(thing);
		unspawnNotes2 = unspawnNotes.copy(); //keep notes stored so you can reverse time
	}

	override function goodNoteHit(note:Note) {
		super.goodNoteHit(note);
	}

	override function onSpawnNote(daNote:Note) {
		daNote.mustPress = false;
	}

	override function endSong() {
		super.endSong();
	}
}
