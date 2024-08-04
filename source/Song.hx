package;

import ManiaInfo;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong = {
	var song:String;
	var newtitle:Null<String>; //display name
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
	var attributes:Array<Array<Dynamic>>;
	var noteSkin:String;
	var noteSkinOpponent:Array<String>;
	var uiStyle:String;
	var rankWords:String;
	
	var vmanEventTime:Array<Float>;
	var vmanEventOrder:Array<Int>;
	var vmanEventData:Array<Dynamic>;

	var hide_girlfriend:Null<Bool>;

	var moreStrumLines:Null<Int>;

	var timeSignature:Null<Int>;

	var voicesName:Null<String>;
	var voicesOpponentName:Null<String>;
	var instName:Null<String>;
	
	var threeLanes:Null<Bool>; //Pasta night :))))))

	var picospeaker:Null<String>; //Week 7 stress
	var picocharts:Null<Array<String>>; //It dont Crap

	var loopbackPoint:Null<Float>; //Music that is just endless on it's own
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

	public var timeSignature:Null<Int> = 4;

	public function new(song, notes, bpm) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static inline function songFunc():SwagSong {
		return {
			song: 'Test',
			notes: new Array<SwagSection>(),
			bpm: 150,
			needsVoices: true,
			player1: 'bf',
			player2: 'dad',
			speed: 1,
			validScore: false,
			maniaStr: "4k",
			mania: 0,
			keyCount: 0,
			gfVersion: "gf",
			stage: "",
			usedNoteTypes: new Array<String>(),
			healthDrain: 0,
			healthDrainMin: 0,
			moreCharacters: new Array<String>(),
			actions: new Array<String>(),
			attributes: new Array<Array<Dynamic>>(),
			noteSkin: "",
			noteSkinOpponent:[],
			uiStyle: "",
			vmanEventTime: new Array<Float>(),
			vmanEventOrder: new Array<Int>(),
			vmanEventData: new Array<Dynamic>(),
			hide_girlfriend: false,
			moreStrumLines: 0,
			timeSignature:4,
			voicesName:null,
			voicesOpponentName:null,
			instName:null,
			threeLanes:false,
			newtitle:null,
			picospeaker:null,
			loopbackPoint:null,
			picocharts:null,
			rankWords:""
		};
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		var rawJson = Assets.getText(Paths.json('${Highscore.formatSong(folder)}/' + jsonInput.toLowerCase())).trim();

		if (!rawJson.endsWith("}")) {
			rawJson = rawJson.substring(0, rawJson.lastIndexOf("}") + 1);
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
				swagShit.maniaStr = '${swagShit.keyCount}k';
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

		if (swagShit.usedNoteTypes == null || swagShit.usedNoteTypes.length == 0)
			swagShit.usedNoteTypes = ["Normal Note"];
		/*if (Options.playstate_guitar && !swagShit.usedNoteTypes.contains("Guitar Note")) {
			swagShit.usedNoteTypes[swagShit.usedNoteTypes.contains("Normal Note") ? swagShit.usedNoteTypes.indexOf("Normal Note") : swagShit.usedNoteTypes.length] = "Guitar Note";
		}*/

		if (swagShit.actions == null)
			swagShit.actions = new Array<String>();

		if (swagShit.vmanEventOrder == null)
			swagShit.vmanEventOrder = new Array<Int>();

		if (swagShit.timeSignature == null)
			swagShit.timeSignature = 4;

		//todo: this is supposed to convert note types from Psych Engine
		if (swagShit.notes != null) {
			for (section in swagShit.notes) {
				for (note in section.sectionNotes) {
					if (Std.isOfType(note[3], String)) {
						if (!swagShit.usedNoteTypes.contains(note[3])) {
							swagShit.usedNoteTypes.push(note[3]);
						}
						note[3] = swagShit.usedNoteTypes.indexOf(note[3]);
					}
				}
			}
		}

		if (swagShit.moreStrumLines == null)
			swagShit.moreStrumLines = 0;

		if (swagShit.threeLanes == true && swagShit.moreStrumLines < 1) { //Pasta night
			if (swagShit.moreStrumLines < 1) {
				swagShit.moreStrumLines = 1;
			}
			for (section in swagShit.notes) {
				if (section.sectionNotes == null || section.sectionNotes.length == 0) {
					continue;
				}
				var toRemove = new Array<Any>();
				for (note in section.sectionNotes) {
					if (note[1] >= 8) {
						note[1] -= 8;
						if (section.notesMoreLayers == null || section.notesMoreLayers.length == 0) {
							section.notesMoreLayers = [[note]];
						} else {
							section.notesMoreLayers[0].push(note);
						}
						toRemove.push(note);
					}
				}
				for (thing in toRemove) {
					section.sectionNotes.remove(thing);
				}
			}
		}
		
		return swagShit;
	}

	public inline static function getSongStuff(name:String):Array<String> {
		return CoolUtil.coolTextFile('data/${Highscore.formatSong(name)}/song.txt');
	}
}
