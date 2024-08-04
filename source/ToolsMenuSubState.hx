package;

import Options.PrivateOptions;
import flixel.system.FlxSound;
import haxe.macro.Context;
import new_editors.StageEditorState;
import openfl.desktop.Clipboard;
import openfl.net.FileReference;
import sys.FileSystem;
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

//@:build(ToolsMenuSubState.build())
class ToolsMenuSubState extends OptionsSubStateBasic
{
	var fileref:FileReference;
	override function optionList() {
		var result = [
			'Chart Editor',
			"Strip File Data",
			"Animation Debug",
			#if debug
			"Cutscene Anim Test",
			//"Texture Atlas Test",
			#end
			//"Week Editor",
			//"Folder Editor",
			//"Menu Character Editor",
			"Intro Text Test",
			#if debug
			"Title Intro Test",
			#end
			"Stage Editor",
			//"Dialogue Editor",
			//"Spritesheet Tool",
			//"Noteskin Creator",
			"Clone Hero Import",
			//"New FNF Backporter",
			"Unload Scripts",
			"Documentation",
			"Discord Server"
		];
		#if debug
		@:privateAccess
		if (PrivateOptions.checkTypeClassAllowed())
			result.push("UNLOCK TYPE CLASS");
		#end
		return result;
	}
	var debugThingyCopy:String;
	var debugCopySound = new FlxSound().loadEmbedded(Paths.sound("clickText"));
	
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
		optionsImage.animation.addByPrefix("confusion", "confusion0", 12, true);
		optionsImage.animation.addByPrefix("activate new mods", "activate new mods0", 12, true);
		optionsImage.animation.addByPrefix("self awareness", "self awareness0", 12, true);

		var debugThingy = new FlxText(0, FlxG.height - 4, FlxG.width * 2, 'VE ${Main.gameVersionNoSubtitle} | VerInt: ${Main.gameVersionInt} | Platform: ${Scripting.gamePlatform} | BuildType: ${Scripting.gameBuildType}\n');
		//todo: i dont know how to make this work
		/*var eatItLibs:Map<String, String> = [
			//Flixel
			"flixel" => macro $v{haxe.macro.Context.definedValue("flixel")},
			"flixel-addons" => macro $v{haxe.macro.Context.definedValue("flixel-addons")},
			"flixel-ui" => macro $v{haxe.macro.Context.definedValue("flixel-ui")},
			//Non flixel
			"json2object" => macro $v{haxe.macro.Context.definedValue("json2object")},
			"flxanimate" => macro $v{haxe.macro.Context.definedValue("flxanimate")},
			"polymod" => macro $v{haxe.macro.Context.definedValue("polymod")},
			"hxWebP" => macro $v{haxe.macro.Context.definedValue("hxWebP")},
			//Niche
			"discord_rpc" => macro $v{haxe.macro.Context.definedValue("discord_rpc")},
			"extension-networking" => macro $v{haxe.macro.Context.definedValue("extension-networking")},
			"away3d" => macro $v{haxe.macro.Context.definedValue("away3d")}
		];*/
		/*var eatItLibs = libVersions();
		trace(eatItLibs);
		debugThingy.text += CoolUtil.iteratorToArray(eatItLibs.keys()).map(function(k) {
			return k + ": " + eatItLibs.get(k);
		}).join(" | ");
		debugThingyCopy = debugThingy.text;
		debugThingy.text += "\nCtrl+C to copy this";
		debugThingy.y -= debugThingy.textField.textHeight * 0.5;
		debugThingy.scale.set(0.5, 0.5);*/
		add(debugThingy);

		//FlxG.sound.list.add(debugCopySound);
	}

	/*public static macro function build():Map<String, String> {
		var names:Array<String> = ["flixel", "flixel-addons", "flixel-ui", "json2object", "flxanimate", "polymod", "hxWebP", "discord_rpc", "extension-networking", "away3d"];
		// The context is the class this build macro is called on
		var fields = Context.getBuildFields();
		// A map is an array of `key => value` expressions
		var map : Array<Expr> = [];
		// We add a `key => value` expression for every name
		for (name in names) {
		  // Expression reification generates expression from argument
		  map.push(macro $v{name} => $v{haxe.crypto.Sha256.encode(name)});
		}
		// We push the map into the context build fields
		fields.push({
		  // The line position that will be referenced on error
		  pos: Context.currentPos(),
		  // Field name
		  name: "namesHashed",
		  // Attached metadata (we are not adding any)
		  meta: null,
		  // Field type is Map<String, String>, `map` is the map
		  kind: FieldType.FVar(macro : Map<String, String>, macro $a{map}),
		  // Documentation (we are not adding any)
		  doc: null,
		  // Field visibility
		  access: [Access.AStatic]
		});
		// Return the context build fields to build the type
		return fields;
	}

	static function libVersions():Map<String, String> {
		//this is the most wack ass idea (casting Array<Expr> to Map) i hope it works
		return namesHashed;
	} */
	
	override function optionDescription(name:String) {
		switch(name) {
			case "chart editor":
				return ["Edit song charting."];
			case "animation debug":
				return ["Look at animations n stuff."];
			#if debug
			case "cutscene anim test":
				return ["Cutscene anim test"];
			//case "texture atlas test":
			//	return ["Texture atlast text", "", "animation debug"];
			#end
			case "week editor":
				return ["Edit in-game weeks for Story Mode."];
			case "folder editor":
				return ["Edit category structures for the Freeplay menu.", "", "freeplay folders"];
			case "menu character editor":
				return ["Edit characters for the Story Mode menu.", "", "animation debug"];
			case "intro text test":
				return ["Preview the randomized intro text."];
			case "title intro test":
				return ["Preview the title screen intro."];
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
				return ["Import a chart from Clone Hero.\n\nThe chart file must be in the same folder as the game executable and be named \"clonehero_import.chart\".\nWork in progress :)"];
			case "new fnf backporter":
				return ["New shit from new FNF :O"];
			case "strip file data":
				return ["Strip unneeded data from saved files such as charts, drastically reducing the file size.", Options.dataStrip ? "Enabled" : "Disabled", "confusion"];
			case "documentation":
				return ["Learn a few things about developing stuff in VMan Engine.", "", "activate new mods"];
			case "unload scripts":
				var list = "Currently loaded:\n";
				if (Scripting.scripts.length == 0) {
					list = "No scripts loaded";
				} else {
					var counts = new Map<String, Int>();
					for (thing in Scripting.scripts) {
						var modFrom = thing.id.substring(0, thing.id.indexOf(":"));
						counts[modFrom] = counts.exists(modFrom) ? (counts[modFrom] + 1) : 1;
					}
					for (name in counts.keys()) {
						list += counts[name] + " from " + name + "\n";
					}
				}
				return ["Unload all currently loaded scripts.", list, "unknownOption"];
			case "discord server":
				return ["A Discord Server, for VMan Engine discussion and probably more"];
			case "unlocke type class":
				@:privateAccess
				return ["Unlock access to the \"Type\" class in scripts. Debug builds only, and causes a SEVERE security issue. This option is not saved to your save data and will reset on quit.", PrivateOptions.typeClassAvailable ? "Enabled" : "Disabled", "self awareness"];
		}
		return ["Unknown option.", '', 'unknownOption'];
	}

	override function optionAccept(name:String) {
		switch (name) {
			case "chart editor":
				FlxG.state.closeSubState();
				FlxG.switchState(new ChartingState());
			case "animation debug":
				FlxG.state.closeSubState();
				FlxG.switchState(new AnimationDebug());
			case "intro text test":
				FlxG.state.closeSubState();
				FlxG.switchState(new IntroTextTest());
			case "title intro test":
				FlxG.state.closeSubState();
				FlxG.switchState(new TitleState(true));
			case "clone hero import":
				cloneHeroImport();
			case "strip file data":
				Options.dataStrip = !Options.dataStrip;
				return true;
			case "documentation":
				FlxG.openURL("https://vman-2002.github.io/vmanengine_doc/index.html");
			#if debug
			case "cutscene anim test":
				FlxG.state.closeSubState();
				FlxG.switchState(new CutsceneAnimTestState());
			//case "texture atlas test":
			//	FlxG.state.closeSubState();
			//	FlxG.switchState(new AtlasTestState());
			#end
			case "stage editor":
				FlxG.state.closeSubState();
				FlxG.switchState(new StageEditorState());
			case "unload scripts":
				Scripting.clearScripts();
				return true;
			case "discord server":
				FlxG.openURL("https://discord.gg/aYkugcADnd");
			#if debug
			case "unlock type class":
				@:privateAccess
				PrivateOptions.typeClassAvailable = !PrivateOptions.typeClassAvailable;
				return true;
			#end
			case "new fnf backporter":
				fileref = new FileReference();
				fileref.browse();
				fileref.addEventListener("select", function(evt) {
					var result:Dynamic = CoolUtil.loadJsonFromFile(fileref.name);
					trace(fileref.name);
					trace(result.generatedBy);
				});
		}
		return false;
	}

	public override function update(elapsed:Float) {
		/*if (FlxG.keys.justPressed.C && FlxG.keys.pressed.CONTROL) {
			trace("Copied game debug info");
			Clipboard.generalClipboard.setData(TEXT_FORMAT, debugThingyCopy);
			debugCopySound.play(true);
		}*/
		return update(elapsed);
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
		var isGHL:Bool = instrument.contains("GHL");
		var lines = content.split("\n");
		
		var song = Song.songFunc();
		song.song = "Some Clone Hero Chart";
		song.speed = 2.5;
		song.mania = isGHL ? 1 : 3;
		song.actions.push("importedFromCloneHero");
		song.keyCount = ManiaInfo.GetManiaInfo(ManiaInfo.ManiaConvert[song.mania]).keys;

		var newSection = Section.sectionFunc();
		song.notes.push(newSection);

		var noteDataArr:Array<Float> = isGHL ? [3, 4, 5, 0, 1, 0, 0, 0, 2] : [0, 1, 2, 3, 4, 5, 0, 0];
		var noteTypeArr:Array<Int> = [0, 0, 0];
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
			if (!linetrim.contains("=")) continue;
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

	function newFnfPorter() {
		
	}
}

#end