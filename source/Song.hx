package;

import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

import ManiaInfo;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
	
	var gfVersion:String;
	var maniaStr:Null<String>;
	var mania:Null<Int>;
	var keyCount:Null<Int>;
	var stage:String;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	
	public var maniaStr:String = "4k";
	
	public var stage:String = "";

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json('${Highscore.formatSong(folder)}/' + jsonInput.toLowerCase())).trim();

		if (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.lastIndexOf("}"));
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		
		//mania sideways compat
		if (swagShit.maniaStr == null) {
			if (swagShit.keyCount != null) {
				//from leather
				swagShit.maniaStr = ManiaInfo.ManiaConvert[ManiaInfo.LeatherConvert[swagShit.keyCount]];
			} else if (swagShit.mania != null) {
				//from the other thing idk
				swagShit.maniaStr = ManiaInfo.ManiaConvert[swagShit.mania];
			} else {
				//no mania specified
				swagShit.maniaStr = "4k";
			}
		}
		
		return swagShit;
	}
}
