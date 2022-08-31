package;

import ManiaInfo;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong = {
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
	var mania:Null<Int>; //for Kade/Psych (7k and 9k vs shaggy charts dont get interpreted right)
	var keyCount:Null<Int>; //for Leather
	var stage:String;
	var usedNoteTypes:Array<String>;

	var healthDrain:Float;
	var healthDrainMin:Float;
	
	var moreCharacters:Array<String>;

	var actions:Array<String>;
	var noteSkin:String;
	var uiStyle:String;
	
	var vmanEventTime:Array<Float>;
	var vmanEventOrder:Array<Int>;
	var vmanEventData:Array<Dynamic>;

	var hide_girlfriend:Null<Bool>;

	var moreStrumLines:Int;
}

class Song {
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

	public var usedNoteTypes:Array<String> = new Array<String>();
	public var healthDrain:Float = 0;
	public var healthDrainMin:Float = 0;
	public var moreCharacters:Array<String> = new Array<String>();

	public var actions:Array<String> = new Array<String>();

	public function new(song, notes, bpm) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
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

	public static function parseJSONshit(rawJson:String):SwagSong {
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		return sanitizeSong(swagShit);
	}

	public static function sanitizeSong(swagShit:SwagSong) {
		swagShit.validScore = true;
		
		//mania sideways compat
		if (swagShit.maniaStr == null) {
			if (swagShit.keyCount != null) {
				//from leather
				swagShit.maniaStr = '${swagShit.keyCount}k'; //ManiaInfo.ManiaConvert[ManiaInfo.LeatherConvert[swagShit.keyCount]];
			} else if (swagShit.mania != null) {
				//from the other thing idk
				swagShit.maniaStr = ManiaInfo.ManiaConvert[swagShit.mania];
			} else {
				//no mania specified
				swagShit.maniaStr = "4k";
			}
		} else {
			swagShit.keyCount = ManiaInfo.GetManiaInfo(swagShit.maniaStr).keys;
		}

		if (swagShit.usedNoteTypes == null || swagShit.usedNoteTypes.length == 0) {
			swagShit.usedNoteTypes = ["Normal Note"];
		}
		/*if (Options.playstate_guitar && swagShit.usedNoteTypes.indexOf("Guitar Note") == -1) {
			swagShit.usedNoteTypes[swagShit.usedNoteTypes.indexOf("Normal Note")] = "Guitar Note";
		}*/

		if (swagShit.actions == null) {
			swagShit.actions = new Array<String>();
		}

		if (swagShit.vmanEventOrder == null) {
			swagShit.vmanEventOrder = new Array<Int>();
		}
		
		return swagShit;
	}

	public inline static function getSongStuff(name:String):Array<String> {
		return CoolUtil.coolTextFile('data/${Highscore.formatSong(name)}/song.txt');
	}
}
