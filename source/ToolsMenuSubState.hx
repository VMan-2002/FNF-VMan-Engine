package;

#if !html5
import Section.SwagSection;
import Section;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.io.File;

using StringTools;


class ToolsMenuSubState extends OptionsSubStateBasic
{
	override function optionList() {
		return [
			'Chart Editor',
			"Animation Debug",
			//"Week Editor",
			//"Folder Editor",
			//"Menu Character Editor",
			"Intro Text Test",
			//"Stage Editor",
			//"Spritesheet Tool",
			//"Noteskin Creator",
			"Clone Hero Import",
		];
	}
	
	override public function new() {
		super();
		var menuBG:FlxSprite = CoolUtil.makeMenuBackground('Desat');
		menuBG.color = 0xFF242424;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		insert(0, menuBG);
		
		optionsImage.color = FlxColor.WHITE;
		optionsImage.animation.addByPrefix("freeplay folders", "freeplay folders0", 12, true);
		optionsImage.animation.addByPrefix("change color advanced", "change color advanced0", 12, true);
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "chart editor":
				return ["Edit song charting."];
			case "animation debug":
				return ["Look at animations n stuff."];
			case "week editor":
				return ["Edit in-game weeks for Story Mode."];
			case "folder editor":
				return ["Edit category structures for the Freeplay menu.", "", "freeplay folders"];
			case "menu character editor":
				return ["Edit characters for the Story Mode menu.", "", "animation debug"];
			case "intro text test":
				return ["Preview the randomized intro text."];
			case "stage editor":
				return ["Edit stages, including positions of stage sprites."];
			case "spritesheet tool":
				return ["Convert spritesheets to or from individual frames.", "", "animation debug"];
			case "noteskin creator":
				return ["Create noteskins.", "", "change color advanced"];
			case "character editor":
				return ["Edit characters.", "", "animation debug"];
			case "dialogue editor":
				return ["Edit dialogue."];
			case "clone hero import":
				return ["Import a song from Clone Hero.\n\nThe file must be in the same folder as the game executable and must be named \"clonehero_import.chart\".\nWork in progress :)", "", "chart editor"];
		}
		return ["Unknown option.", '', 'unknownOption'];
	}

	override function optionAccept(name:String) {
		switch (name)
		{
			case "chart editor":
				FlxG.state.closeSubState();
				FlxG.switchState(new ChartingState());
			case "animation debug":
				FlxG.state.closeSubState();
				FlxG.switchState(new AnimationDebug());
			case "intro text test":
				FlxG.state.closeSubState();
				FlxG.switchState(new IntroTextTest());
			case "clone hero import":
				cloneHeroImport();
		}
		return false;
	}
	
	static function cloneHeroTiming(n:Float, res:Float, bpm:Float, ?bpmChanges:Array<Array<Float>>) {
		if (bpmChanges != null && bpmChanges.length > 0) {
			var nowChange:Float = 0;
			var nowN:Float = 0;
			for (change in bpmChanges) {
				//0 is the step, 1 is the new bpm
				if (n > change[0]) {
					//nowChange += cloneHeroTiming(change[0] - nowN, res, bpm);
					nowChange = change[2];
					bpm = change[1];
					nowN += change[0];
				}
			}
			return cloneHeroTiming(n - nowN, res, bpm) + nowChange;
		}
		return n / (res * bpm / 60000);
	}

	static function cloneHeroImport() {
		//todo: not everything of this is implemented yet
		//load from file "clonehero_import.chart"
		var content = File.getContent("clonehero_import.chart");
		if (content == null) {
			trace("Could not load Clone Hero import file.");
			return;
		}
		var diff = "Expert";
		var instrument = diff+"Single";
		var instrumentOpponent = diff+"DoubleGuitar";
		CoolUtil.difficultyArray = [diff];
		PlayState.storyDifficulty = 0;
		var isGHL:Bool = instrument.indexOf("GHL") != -1;
		var lines = content.split("\n");
		var song = {
			song: "Some Clone Hero Chart",
			notes: new Array<SwagSection>(),
			bpm: 150.0,
			needsVoices: true,
			player1: 'bf',
			player2: 'dad',
			speed: 2.5,
			validScore: false,
			maniaStr: null,
			mania: isGHL ? 1 : 3,
			keyCount: 0,
			gfVersion: "gf",
			stage: "stage",
			usedNoteTypes: new Array<String>(),
			healthDrain: 0.0,
			healthDrainMin: 0.0,
			moreCharacters: null,
			actions: ["importedFromCloneHero"],
			noteSkin: "",
			uiStyle: "",
			vmanEventTime: null,
			vmanEventOrder: new Array<Int>(),
			vmanEventData: null,
			hide_girlfriend: false
		};
		var noteDataArr:Array<Float> = isGHL ? [3, 4, 5, 0, 1, 0, 0, 0, 2] : [0, 1, 2, 3, 4, 5, 0, 0];
		var noteTypeArr:Array<Int> = [0, 0, 0];
		song.keyCount = ManiaInfo.GetManiaInfo(ManiaInfo.ManiaConvert[song.mania]).keys;
		var newSection = {
			sectionNotes: new Array<Dynamic>(),
			lengthInSteps: 16,
			typeOfSection: 0,
			mustHitSection: true,
			bpm: 150.0,
			changeBPM: false,
			altAnim: false,
			gfSection: false,
			focusCharacter: null,
			changeMania: false,
			maniaStr: null
		};
		song.notes.push(newSection);
		var curSection:String = "";
		var offset:Float = 0;
		var resolution:Float = 192;
		var bpmChanges:Array<Array<Float>> = new Array<Array<Float>>();
		var sectionDiv:Float = 0;
		var addNotes:Array<Array<Float>> = new Array<Array<Float>>();
		var tapCount:Int = 0;
		var openCount:Int = 0;
		var guitarCount:Int = 0;
		var hopoCount:Int = 0;
		var openHopoCount:Int = 0;
		var thisRow = new Array<Array<Float>>();
		var thisTime:Int = 0;
		var lastRowItems:Array<Int> = new Array<Int>();
		var thisRowItems:Array<Int> = new Array<Int>();
		var rowForced:Bool = false;
		var hasOpponentNotes:Bool = false;
		for (line in lines) {
			var linetrim = line.trim();
			if (linetrim.length == 0) continue;
			if (linetrim.startsWith("[") && linetrim.endsWith("]")) {
				curSection = linetrim.substring(1, linetrim.length - 1);
				continue;
			}
			if (linetrim.indexOf("=") == -1) continue;
			var splitted:Array<String> = linetrim.split("=");
			var name:String = splitted[0].trim();
			var value:Array<String> = splitted[1].split(" ").map(function(s:String) { return s.trim(); }).filter(function(s:String) { return s.length > 0; });
			if (curSection == "Song") {
				switch(name) {
					case "Name":
						song.song = value.join(" ").trim();
						song.song = song.song.substring(1, song.song.length - 1);
					case "Offset":
						offset = Std.parseFloat(value[0]);
					case "Resolution":
						resolution = Std.parseFloat(value[0]);
				}
				continue;
			}
			if (curSection == "SyncTrack") {
				if (value[0] == "B") {
					if (name == "0") {
						song.bpm = Std.parseFloat(value[1]) / 1000;
						trace("BPM: " + song.bpm);
						sectionDiv = 1 / ((song.bpm / 60) * 1000);
					} else {
						var tAdd:Float = 0;
						for (fun in bpmChanges) {
							tAdd += fun[2];
						}
						bpmChanges.push([Std.parseFloat(name), Std.parseFloat(value[1]) / 1000, cloneHeroTiming(Std.parseFloat(name), resolution, song.bpm, bpmChanges) + tAdd]);
						trace('added bpm change: ${bpmChanges[bpmChanges.length - 1].join(",")}');
					}
				}
				continue;
			}
			if (curSection == instrument || curSection == instrumentOpponent) {
				switch(value[0]) {
					case "N": //note
					var t = Std.parseInt(name);
					if (thisTime != t) {
						var isHopo = false;
						thisRowItems.sort(function(a:Int, b:Int) { return a - b; });
						if (thisRowItems != lastRowItems) {
							if (thisTime + 65 >= t && thisRowItems.length == 1 && t > thisTime) {
								isHopo = true;
							}
							lastRowItems = thisRowItems;
						}
						thisTime = t;
						while (thisRow.length > 0) {
							var item = thisRow.length - 1;
							if (isHopo != rowForced && thisRow[item][3] != 1) {
								thisRow[item][3] = thisRow[item][3] == 2 ? 4 : 3;
							}
							addNotes.push(thisRow.pop());
						}
						rowForced = false;
					}
					if (value[1] == "6") { // 6: convert to tap note
						for (thing in thisRow) {
							tapCount++;
							thing[3] = 1;
						}
						trace("converted " + thisRow.length + " notes at " + thisTime + " to tap notes");
					} else if (value[1] == "5") {
						rowForced = true;
					} else {
						if (value[1] == "7") { //7: open note
							openCount++;
						} else { //otherwise: guitar note
							guitarCount++;
						}
						var addNoteData = 0;
						if (curSection == instrumentOpponent) {
							hasOpponentNotes = true;
							addNoteData = 16;
						}
						thisRow.push([
							t, //time
							Std.parseFloat(value[1]), //notedata
							Std.parseFloat(value[2]), //length
							(value[1] == "7" ? 2 : 0) + addNoteData //note type
						]);
						thisRowItems.push(Std.parseInt(value[1]));
					}
					//todo: handle other elements, such as S. what does S mean?
				}
				continue;
			}
		}
		while (thisRow.length > 0) {
			addNotes.push(thisRow.pop());
		}
		guitarCount -= tapCount;
		if (guitarCount > 0) {
			song.usedNoteTypes.push("Guitar Note");
			noteTypeArr[0] = song.usedNoteTypes.length - 1;
			trace('${guitarCount} notes are guitar notes');
		} else {
			trace("No guitar notes");
		}
		if (tapCount > 0) {
			song.usedNoteTypes.push("Normal Note");
			noteTypeArr[1] = song.usedNoteTypes.length - 1;
			trace('${tapCount} notes are tap notes');
		} else {
			trace("No tap notes");
		}
		if (openCount > 0) {
			song.usedNoteTypes.push("Guitar Open Note");
			noteTypeArr[2] = song.usedNoteTypes.length - 1;
			trace('${openCount} notes are open notes');
		} else {
			trace("No open notes");
		}
		if (hopoCount > 0) {
			song.usedNoteTypes.push("Guitar HOPO Note");
			noteTypeArr[3] = song.usedNoteTypes.length - 1;
			trace('${hopoCount} notes are hopos');
		} else {
			trace("No hopos");
		}
		if (openHopoCount > 0) {
			song.usedNoteTypes.push("Guitar Open HOPO Note");
			noteTypeArr[4] = song.usedNoteTypes.length - 1;
			trace('${openHopoCount} notes are open hopos');
		} else {
			trace("No open hopos");
		}
		if (!hasOpponentNotes) {
			song.player2 = "gf";
		}
		for (note in addNotes) {
			//var section:Int = Math.floor(t * sectionDiv);
			var section:Int = 0; //this is hard.
			while (song.notes.length <= section) {
				song.notes.push(newSection);
			}
			var t:Float = (cloneHeroTiming(note[0], resolution, song.bpm, bpmChanges) + offset);
			song.notes[section].sectionNotes.push([
				t, //time
				noteDataArr[Math.floor(note[1])] + (note[3] >= 16 ? song.keyCount : 0), //notedata
				note[2] == 0 ? 0 : cloneHeroTiming(note[0] + note[2], resolution, song.bpm, bpmChanges) + offset - t, //length
				noteTypeArr[Math.floor(note[3]) % 16] //note type
			]);
		}
		PlayState.SONG = Song.sanitizeSong(song);
		FlxG.state.closeSubState();
		FlxG.switchState(new ChartingState());
	}
}

#end