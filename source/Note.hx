package;

import Character.SwagCharacterAnim;
import CoolUtil;
import ManiaInfo.SwagMania;
import ThingThatSucks.ErrorReportSubstate;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfThree;
import json2object.JsonParser;
import lime.utils.Assets;
import openfl.utils.Assets;

using StringTools;
#if !html5
import sys.FileSystem;
import sys.io.File;
#end

/*#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end*/

class SwagNoteSkin {
	public var image:String;
	public var imageDownscroll:Null<String>;
	public var scale:Null<Float>;
	public var antialias:Null<Bool>;
	public var arrows:Map<String, Array<SwagCharacterAnim>>;
	public var arrowColors:Map<String, Array<Int>>;
	public var noteSplashImage:String;
	public var noteSplashScale:Null<Float>;
	public var noteSplashFramerate:Null<Int>;

	public static function loadNoteSkin(name:String, modName:String) {
		if (Note.loadedNoteSkins.exists('${modName}:${name}')) {
			return Note.loadedNoteSkins.get('${modName}:${name}');
		}
		var parser = new JsonParser<SwagNoteSkin>();
		var noteSkin:SwagNoteSkin;
		/*if (FileSystem.exists(modName + "/objects/noteskins/" + name + ".json")) {
			noteSkin = parser.fromJson(File.getContent(modName + "/objects/noteskins/" + name + ".json"));
		} else if (Assets.exists("objects/noteskins/" + name + ".json")) {
			noteSkin = parser.fromJson(Assets.getText("objects/noteskins/" + name + ".json"));
		} else {
			return null;
		}*/
		noteSkin = parser.fromJson(CoolUtil.tryPathBoth('objects/noteskins/${name}.json', modName));
		if (noteSkin == null) {
			ErrorReportSubstate.addError("Could not load note skin " + name);
			return null;
		}
		if (Options.downScroll && noteSkin.imageDownscroll != null) {
			noteSkin.image = noteSkin.imageDownscroll;
		}
		noteSkin.scale = noteSkin.scale != null ? noteSkin.scale : 1.0;
		noteSkin.antialias = noteSkin.antialias != null ? noteSkin.antialias : false;
		noteSkin.arrowColors = noteSkin.arrowColors != null ? noteSkin.arrowColors : new Map<String, Array<Int>>();
		noteSkin.noteSplashScale = noteSkin.noteSplashScale != null ? noteSkin.noteSplashScale : 1.0;
		noteSkin.noteSplashFramerate = noteSkin.noteSplashFramerate != null ? noteSkin.noteSplashFramerate : 24;
		noteSkin.noteSplashImage = noteSkin.noteSplashImage != null ? noteSkin.noteSplashImage : "normal/notesplash";
		if (noteSkin.arrows != null && !noteSkin.arrows.keys().hasNext()) {
			noteSkin.arrows = null;
		}
		Note.loadedNoteSkins.set('${modName}:${name}', noteSkin);
		trace('loaded noteskin ${modName}:${name}');
		return noteSkin;
	}

	public static function clearLoadedNoteSkins() {
		Note.loadedNoteSkins.clear();
	}
}

class SwagUIStyleFile { //Because Float->Float doesnt work with the JsonParser
	public var three:String;
	public var two:String;
	public var one:String;
	public var go:String;
	public var numbers:Array<String>;
	public var combo:String;
	public var sick:String;
	public var good:String;
	public var bad:String;
	public var shit:String;
	public var sickcool:String;
	public var healthBar:String;
	public var threeSound:String;
	public var twoSound:String;
	public var oneSound:String;
	public var goSound:String;
	public var countdownScale:Null<Float>;
	public var ratings:Map<String, String>;
	public var ratingScale:Null<Float>;
	public var comboScale:Null<Float>;
	public var comboSpacing:Null<Float>;
	public var antialias:Null<Bool>;
	public var healthBarSides:Array<Float>;
	public var hudThingPos:Null<Map<String, Array<Float>>>;
	public var iconEaseStr:Null<String>;
	public var iconEase:Null<Float>;
	public var font:Null<String>;

	public function new() {
		return;
	}
}

class SwagUIStyle {
	public var three:String;
	public var two:String;
	public var one:String;
	public var go:String;
	public var numbers:Array<String>;
	public var combo:String;
	public var healthBar:String;
	public var threeSound:String;
	public var twoSound:String;
	public var oneSound:String;
	public var goSound:String;
	public var countdownScale:Null<Float>;
	public var ratings:Map<String, String>;
	public var ratingScale:Null<Float>;
	public var comboScale:Null<Float>;
	public var comboSpacing:Null<Float>;
	public var antialias:Null<Bool>;
	public var healthBarSides:Array<Float>;
	public var hudThingPos:Null<Map<String, Array<Float>>>;
	public var iconEase:Null<Float>;
	public var iconEaseFunc:Null<Float->Float>;
	public var font:String = "vcr font";

	public function new() {
		return;
	}

	public static function loadUIStyle(name:String, modName:String):SwagUIStyle {
		if (Note.loadedUIStyles.exists('${modName}:${name}')) {
			return Note.loadedUIStyles.get('${modName}:${name}');
		}
		var parser = new JsonParser<SwagUIStyleFile>();
		var uiStyleFile:SwagUIStyleFile;
		uiStyleFile = cast parser.fromJson(CoolUtil.tryPathBoth('objects/uiStyles/${name}.json', modName));
		if (uiStyleFile == null) {
			ErrorReportSubstate.addError('loading default ui style because ${modName}:${name} wasnt found');
			uiStyleFile = new SwagUIStyleFile();
		}
		var uiStyle:SwagUIStyle = new SwagUIStyle(); //for some reason a cast fails here
		uiStyle.three = uiStyleFile.three != null ? uiStyleFile.three : "";
		uiStyle.two = uiStyleFile.two != null ? uiStyleFile.two : "normal/ready";
		uiStyle.one = uiStyleFile.one != null ? uiStyleFile.one : "normal/set";
		uiStyle.go = uiStyleFile.go != null ? uiStyleFile.go : "normal/go";
		uiStyle.numbers = uiStyleFile.numbers != null ? uiStyleFile.numbers : ["normal/num0", "normal/num1", "normal/num2", "normal/num3", "normal/num4", "normal/num5", "normal/num6", "normal/num7", "normal/num8", "normal/num9"];
		uiStyle.combo = uiStyleFile.combo != null ? uiStyleFile.combo : "normal/combo";
		uiStyle.healthBar = uiStyleFile.healthBar != null ? uiStyleFile.healthBar : "normal/healthBar";
		uiStyle.threeSound = uiStyleFile.threeSound != null ? uiStyleFile.threeSound : "intro3";
		uiStyle.twoSound = uiStyleFile.twoSound != null ? uiStyleFile.twoSound : "intro2";
		uiStyle.oneSound = uiStyleFile.oneSound != null ? uiStyleFile.oneSound : "intro1";
		uiStyle.goSound = uiStyleFile.goSound != null ? uiStyleFile.goSound : "introGo";
		uiStyle.countdownScale = uiStyleFile.countdownScale != null ? uiStyleFile.countdownScale : 1.0;
		if (uiStyleFile.ratings == null) {
			uiStyle.ratings = ["sick" => uiStyleFile.sick, "good" => uiStyleFile.good, "bad" => uiStyleFile.bad, "shit" => uiStyleFile.shit, "sick-cool" => (uiStyleFile.sickcool == null ? uiStyleFile.sick : uiStyleFile.sickcool)];
		}
		if (uiStyle.ratings.get("sick") == null) {
			uiStyle.ratings.set("sick", "normal/sick");
			if (uiStyle.ratings.get("sick-cool") == null) {
				uiStyle.ratings.set("sick-cool", "normal/sick-cool");
			}
		} else {
			if (uiStyle.ratings.get("sick-cool") == null) {
				uiStyle.ratings.set("sick-cool", uiStyle.ratings.get("sick"));
			}
		}
		if (uiStyle.ratings.get("good") == null) {
			uiStyle.ratings.set("good", "normal/good");
		}
		if (uiStyle.ratings.get("bad") == null) {
			uiStyle.ratings.set("bad", "normal/bad");
		}
		if (uiStyle.ratings.get("shit") == null) {
			uiStyle.ratings.set("shit", "normal/shit");
		}
		uiStyle.ratingScale = uiStyleFile.ratingScale != null ? uiStyleFile.ratingScale : 0.7;
		uiStyle.comboScale = uiStyleFile.comboScale != null ? uiStyleFile.comboScale : 0.5;
		uiStyle.comboSpacing = uiStyleFile.comboSpacing != null ? uiStyleFile.comboSpacing : 43;
		uiStyle.antialias = uiStyleFile.antialias != false;
		uiStyle.healthBarSides = uiStyleFile.healthBarSides != null ? uiStyleFile.healthBarSides : [4, 4, 4, 4];
		if (uiStyleFile.healthBarSides == null || uiStyleFile.healthBarSides.length == 0) {
			uiStyle.healthBarSides = [4, 4, 4, 4];
		} else {
			uiStyle.healthBarSides = [uiStyleFile.healthBarSides[0]];
			uiStyle.healthBarSides[1] = uiStyleFile.healthBarSides[uiStyleFile.healthBarSides.length < 2 ? 0 : 1];
			uiStyle.healthBarSides[2] = uiStyleFile.healthBarSides[uiStyleFile.healthBarSides.length < 3 ? 0 : 2];
			uiStyle.healthBarSides[3] = uiStyleFile.healthBarSides[uiStyleFile.healthBarSides.length < 4 ? 1 : 3];
		}
		if (uiStyleFile.iconEaseStr != null && uiStyleFile.iconEaseStr != "") {
			uiStyle.iconEaseFunc = LuaScript.ScriptHelper.getEaseFromString(uiStyleFile.iconEaseStr);
		} else {
			uiStyle.iconEase = uiStyleFile.iconEase != null ? uiStyleFile.iconEase : 1.0;
		}
		uiStyle.font = uiStyleFile.font == null ? "vcr font" : uiStyleFile.font;
		uiStyle.hudThingPos = uiStyleFile.hudThingPos == null ? new Map<String, Array<Float>>() : uiStyleFile.hudThingPos;
		
		Note.loadedUIStyles.set('${modName}:${name}', uiStyle);
		trace('loaded uistyle ${modName}:${name}');
		return uiStyle;
	}

	public static function clearLoadedUIStyles() {
		Note.loadedUIStyles.clear();
	}
}

class SwagNoteType {
	public var healthHit:Null<Float>;
	public var healthHitSick:Null<Float>;
	public var healthHitGood:Null<Float>;
	public var healthHitBad:Null<Float>;
	public var healthHitShit:Null<Float>;
	public var healthMiss:Null<Float>;
	public var healthMaxMult:Null<Float>;
	public var ignoreMiss:Null<Bool>;
	public var imagePrefix:String;
	public var animPostfix:String;
	public var animReplace:String;
	public var bob:Null<Float>;
	public var glitch:Null<Bool>;
	public var guitar:Null<Bool>;
	public var guitarOpen:Null<Bool>;
	public var guitarHopo:Null<Bool>;
	public var characterName:Null<String>;
	public var characterNum:Null<Int>;
	public var confused:Null<Bool>;
	public var hasPressNote:Null<Bool>;
	public var hasReleaseNote:Null<Bool>;
	public var charNums:Null<Array<Int>>;
	public var charNames:Null<Array<String>>;

	public static function loadNoteType(name:String, modName:String, ?putInto:Null<String>) {
		if (putInto == null) {
			putInto = name;
		}
		if (Note.loadedNoteTypes.exists('${modName}:${putInto}')) {
			return Note.loadedNoteTypes.get('${modName}:${putInto}');
		}
		var parser = new JsonParser<SwagNoteType>();
		var noteType:SwagNoteType;
		noteType = parser.fromJson(CoolUtil.tryPathBoth('objects/notetypes/${name}.json', modName));
		if (noteType == null) {
			if (name == "Normal Note") {
				throw 'Tried to load a nonexistant note type and normal note couldn\'t be loaded instead';
			}
			ErrorReportSubstate.addError('failed to load notetype ${modName}:${name}, loading normal note instead');
			//todo: there is a bug here where the note type loaded here is stored in "Normal Note" instead of what was originally tried to be loaded. no fkin idea why
			return loadNoteType("Normal Note", modName, putInto); //a valid note type must be loaded!
		}
		noteType.healthHit = noteType.healthHit != null ? noteType.healthHit : 0.023;
		noteType.healthHitSick = noteType.healthHitSick != null ? noteType.healthHitSick : noteType.healthHit;
		noteType.healthHitGood = noteType.healthHitGood != null ? noteType.healthHitGood : noteType.healthHit;
		noteType.healthHitBad = noteType.healthHitBad != null ? noteType.healthHitBad : noteType.healthHit;
		noteType.healthHitShit = noteType.healthHitShit != null ? noteType.healthHitShit : noteType.healthHit;
		noteType.healthMiss = noteType.healthMiss != null ? noteType.healthMiss : -0.0475;
		noteType.healthMaxMult = noteType.healthMaxMult != null ? noteType.healthMaxMult : 1;
		noteType.ignoreMiss = noteType.ignoreMiss != null ? noteType.ignoreMiss : false;
		noteType.imagePrefix = noteType.imagePrefix != null ? noteType.imagePrefix : "";
		noteType.animPostfix = noteType.animPostfix != "" ? noteType.animPostfix : null;
		noteType.animReplace = noteType.animReplace != "" ? noteType.animReplace : null;
		noteType.bob = noteType.bob != null ? noteType.bob : 0;
		noteType.glitch = noteType.glitch != null ? noteType.glitch : false;
		noteType.guitar = Options.playstate_guitar || (noteType.guitar == true);
		noteType.guitarOpen = noteType.guitarOpen != null ? noteType.guitarOpen && !noteType.guitar : false;
		noteType.guitarHopo = noteType.guitarHopo != null ? noteType.guitarHopo : false;
		if (noteType.characterName != null && noteType.characterName != "") {
			if (noteType.charNames == null) {
				noteType.charNames == [noteType.characterName];
			}
			noteType.characterNum = Character.findSuitableCharacterNum(noteType.characterName);
			if (noteType.charNames == null) {
				noteType.charNames = [noteType.characterName];
			} else if (!noteType.charNames.contains(noteType.characterName)) {
				noteType.charNames.push(noteType.characterName);
			}
		}
		noteType.charNums = noteType.characterNum != null ? [noteType.characterNum] : noteType.charNums;
		if (noteType.charNames != null) {
			if (noteType.charNames.length == 0) {
				noteType.charNames = null;
			} else {
				recalculateCharsForNote(noteType);
			}
		} else if (noteType.charNums != null && noteType.charNums.length == 0) {
			noteType.charNums = null;
		}
		noteType.confused = noteType.confused == true;
		noteType.hasPressNote = noteType.hasPressNote != false;
		noteType.hasReleaseNote = noteType.hasReleaseNote == true;
		trace('loaded notetype ${modName}:${name}');
		Note.loadedNoteTypes.set('${modName}:${putInto}', noteType);
		return noteType;
	}

	public static function recalculateNoteChars(name:Null<String>) {
		if (name != null) {
			return recalculateCharsForNote(Note.loadedNoteTypes.get(name));
		}
		for (nt in Note.loadedNoteTypes) {
			recalculateCharsForNote(nt);
		}
	}

	static inline function recalculateCharsForNote(nt:SwagNoteType) {
		if (nt.charNames != null) {
			if (nt.charNums == null) {
				nt.charNums = new Array<Int>();
			} else {
				FlxArrayUtil.clearArray(nt.charNums);
			}
			for (thing in nt.charNames) {
				var newnum = Character.findSuitableCharacterNum(thing, -1);
				if (newnum != -1 && !nt.charNums.contains(newnum)) {
					nt.charNums.push(newnum);
				}
			}
			if (nt.charNums.length == 0) {
				nt.charNums = null;
			}
		}
	}

	public static function clearLoadedNoteTypes() {
		Note.loadedNoteTypes.clear();
	}
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isReleaseNote:Bool = false;

	public var noteScore:Float = 1;
	
	public var noteType:Int = 0;

	public var maniaPart:Int = 0;
	public var maniaFract:Float = 0;
	public var strumLineNum:Int = 0;
	public var strumNoteNum:Int = 0;

	public static var loadedNoteSkins:Map<String, SwagNoteSkin> = new Map<String, SwagNoteSkin>();
	public static var loadedUIStyles:Map<String, SwagUIStyle> = new Map<String, SwagUIStyle>();
	public static var loadedNoteTypes:Map<String, SwagNoteType> = new Map<String, SwagNoteType>();
	
	static final quantThingy = [0,3,2,3,1,3,2,3];
	
	public static var baseRot:Float = 0;

	public static var noteAnimExclude:Array<String> = [
		"static",
		"pressed",
		"confirm",
		"appear"
	];

	//public var scrollDirection(default, set):Float = 0;

	/*function set_scrollDirection(n:Float) {
		if (isSustainNote) {
			angle += n - scrollDirection;
		}
		scrollDirection = n;
	}*/

	public static var swagWidth:Float = 160 * 0.7;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?mania:SwagMania, ?noteType:Int = 0, ?strumLineNum:Int = 0)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		if (mania == null)
			mania = PlayState.curManiaInfo;

		maniaFract = noteData / mania.keys;
		this.noteType = noteType;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y = -2000;
		this.strumTime = strumTime;

		this.noteData = noteData;
		strumNoteNum = noteData;

		var daStage:String = PlayState.curStage;

		var myArrow = mania.arrows[noteData];

		if (Options.downScroll) {
			//scrollDirection = 180;
		}
		
		switch (PlayState.SONG.noteSkin)
		{
			/*case 'school' | 'schoolEvil':
				loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				scale.x = PlayState.daPixelZoom * 1.5;*/

			case 'pixel':
				frames = Paths.getSparrowAtlas('pixelUI/NOTE_assets-pixel');
				
				animation.addByPrefix('${myArrow}Scroll', '${myArrow}0', 24);
				animation.addByPrefix('${myArrow}holdend', '${myArrow} hold end', 24);
				animation.addByPrefix('${myArrow}hold', '${myArrow} hold piece', 24);
				animation.addByPrefix('${myArrow}Release', '${myArrow} release', 24);
				animation.addByPrefix('${myArrow}holdstart', '${myArrow} hold start', 24);
				//animation.appendByPrefix('purpleholdend', 'pruple end hold'); //develop your spritesheets properly challenge (impossible)

				scale.x = PlayState.daPixelZoom * 1.5;
				antialiasing = false;

			case 'normal' | "" | null:
				frames = Paths.getSparrowAtlas('normal/NOTE_assets');
				
				animation.addByPrefix('${myArrow}Scroll', '${myArrow}0', 24);
				animation.addByPrefix('${myArrow}holdend', '${myArrow} hold end', 24);
				animation.addByPrefix('${myArrow}hold', '${myArrow} hold piece', 24);
				animation.addByPrefix('${myArrow}Release', '${myArrow} release', 24);
				animation.addByPrefix('${myArrow}holdstart', '${myArrow} hold start', 24);
				//animation.appendByPrefix('purpleholdend', 'pruple end hold'); //develop your spritesheets properly challenge (impossible)

				antialiasing = true;

			default:
				//load custom
				var noteSkin:SwagNoteSkin = SwagNoteSkin.loadNoteSkin(PlayState.SONG.noteSkin, PlayState.modName);
				frames = Paths.getSparrowAtlas(noteSkin.image);
				
				if (noteSkin.arrows == null) {
					animation.addByPrefix('${myArrow}Scroll', '${myArrow}0', 24);
					animation.addByPrefix('${myArrow}holdend', '${myArrow} hold end', 24);
					animation.addByPrefix('${myArrow}hold', '${myArrow} hold piece', 24);
					animation.addByPrefix('${myArrow}Release', '${myArrow} release', 24);
					animation.addByPrefix('${myArrow}holdstart', '${myArrow} hold start', 24);
				} else {
					for (anim in noteSkin.arrows[myArrow]) {
						if (noteAnimExclude.indexOf(anim.name) > -1) {
							continue;
						}
						animation.addByPrefix(
							'${myArrow}${anim.name}',
							'${anim.anim}',
							anim.framerate,
							anim.loop
						);
					}
				}
				antialiasing = noteSkin.antialias != false;
				scale.x = noteSkin.scale;
		}

		this.strumLineNum = strumLineNum;
		
		scale.x *= mania.scale;
		scale.y = scale.x;
		
		animation.play('${myArrow}Scroll');

		// trace(prevNote);

		if (isSustainNote && prevNote != null) {
			prevNote.nextNote = this;
			
			flipY = Options.downScroll;
			
			noteScore * 0.2;
			alpha = 0.6;

			animation.play(myArrow+"holdend");
			

			updateHitbox();

			if (prevNote.isSustainNote) {
				prevNote.animation.play(myArrow+"hold");

				prevNote.scale.y = ((Conductor.stepCrochet / 1) * PlayState.SONG.speed * 0.45) / prevNote.frameHeight;
				CoolUtil.CenterOffsets(prevNote);
				prevNote.offset.y = flipY ? frameHeight * scale.y : 0;
				//prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		} else if (!getNoteTypeData().hasPressNote) {
			//todo: make this look better
			animation.play('${myArrow}holdstart');
			isSustainNote = true;
			alpha = 0.6;
		}
		centerOffsets();
		updateHitbox();
		CoolUtil.CenterOffsets(this);
		if (isSustainNote) {
			//offset.y = flipY ? 0 : height;
			offset.y = height;
		}
		if (animation.curAnim == null) {
			trace("Note's animation is null. Fuck! Strum time is: " + strumTime + " And Note type is: "+getNoteType());
		}
		switch(getNoteType()) {
			case "Guitar Note":
				color = 0xFF0000; //todo: this is temporary
			case "Guitar Open Note":
				color = 0x0000FF; //todo: this is temporary
			case "Guitar HOPO Note":
				color = 0xFFFF00; //todo: this is temporary
			case "Guitar Open HOPO Note":
				color = 0x00FFFF; //todo: this is temporary
		}
	}
	
	public function noteSetArrow(type:String) {
		
	}

	public inline function getNoteType():String {
		return PlayState.SONG.usedNoteTypes[noteType];
	}

	public function setNoteType(t:String) {
		if (!PlayState.SONG.usedNoteTypes.contains(t)) {
			noteType = PlayState.SONG.usedNoteTypes.length;
			PlayState.SONG.usedNoteTypes.push(t);
			return;
		}
		noteType = PlayState.SONG.usedNoteTypes.indexOf(t);
	}

	public inline function getNoteTypeData():SwagNoteType {
		return SwagNoteType.loadNoteType(getNoteType(), PlayState.modName);
	}

	public function makeReleaseNote() {
		if (!isSustainNote) {
			return;
		}
		//todo: make this look better
		animation.play(PlayState.curManiaInfo.arrows[noteData]+"Release");
		isSustainNote = false;
		isReleaseNote = true;

		prevNote.scale.y = ((Conductor.stepCrochet / 1) * PlayState.SONG.speed * 0.45) / prevNote.frameHeight;
		CoolUtil.CenterOffsets(prevNote);
		prevNote.offset.y = flipY ? frameHeight * scale.y : 0;
	}

	public override function updateHitbox() {
		super.updateHitbox();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;
		}
		else
		{
			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (!tooLate && strumTime < Conductor.songPosition - Conductor.safeZoneOffset) {
			tooLate = true;
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
