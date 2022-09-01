package;

import Character.SwagCharacterAnim;
import CoolUtil;
import ManiaInfo.SwagMania;
import ThingThatSucks.ErrorReportSubstate;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
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
	public var scale:Null<Float>;
	public var antialias:Null<Bool>;
	public var arrows:Map<String, Array<SwagCharacterAnim>>;
	public var arrowColors:Map<String, Array<Int>>;
	public var noteSplashImage:String;
	public var noteSplashScale:Null<Float>;
	public var noteSplashFramerate:Null<Int>;

	public static function loadNoteSkin(name:String, ?modName:String) {
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
		noteSkin.scale = noteSkin.scale != null ? noteSkin.scale : 1.0;
		noteSkin.antialias = noteSkin.antialias != null ? noteSkin.antialias : false;
		noteSkin.arrowColors = noteSkin.arrowColors != null ? noteSkin.arrowColors : new Map<String, Array<Int>>();
		noteSkin.noteSplashScale = noteSkin.noteSplashScale != null ? noteSkin.noteSplashScale : 1.0;
		noteSkin.noteSplashFramerate = noteSkin.noteSplashFramerate != null ? noteSkin.noteSplashFramerate : 24;
		noteSkin.noteSplashImage = noteSkin.noteSplashImage != null ? noteSkin.noteSplashImage : "normal/notesplash";
		Note.loadedNoteSkins.set('${modName}:${name}', noteSkin);
		trace('loaded noteskin ${modName}:${name}');
		return noteSkin;
	}

	public static function clearLoadedNoteSkins() {
		Note.loadedNoteSkins.clear();
	}
}

class SwagUIStyle {
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

	public static function loadUIStyle(name:String, ?modName:String) {
		if (Note.loadedUIStyles.exists('${modName}:${name}')) {
			return Note.loadedUIStyles.get('${modName}:${name}');
		}
		var parser = new JsonParser<SwagUIStyle>();
		var uiStyle:SwagUIStyle;
		uiStyle = parser.fromJson(CoolUtil.tryPathBoth('objects/uiStyles/${name}.json', modName));
		if (uiStyle == null) {
			ErrorReportSubstate.addError('failed to load ui style ${modName}:${name}');
			return null;
		}
		uiStyle.three = uiStyle.three != null ? uiStyle.three : "";
		uiStyle.two = uiStyle.two != null ? uiStyle.two : "normal/ready";
		uiStyle.one = uiStyle.one != null ? uiStyle.one : "normal/set";
		uiStyle.go = uiStyle.go != null ? uiStyle.go : "normal/go";
		uiStyle.numbers = uiStyle.numbers != null ? uiStyle.numbers : ["normal/num0", "normal/num1", "normal/num2", "normal/num3", "normal/num4", "normal/num5", "normal/num6", "normal/num7", "normal/num8", "normal/num9"];
		uiStyle.combo = uiStyle.combo != null ? uiStyle.combo : "normal/combo";
		uiStyle.sick = uiStyle.sick != null ? uiStyle.sick : "normal/sick";
		uiStyle.good = uiStyle.good != null ? uiStyle.good : "normal/good";
		uiStyle.bad = uiStyle.bad != null ? uiStyle.bad : "normal/bad";
		uiStyle.shit = uiStyle.shit != null ? uiStyle.shit : "normal/shit";
		uiStyle.healthBar = uiStyle.healthBar != null ? uiStyle.healthBar : "normal/healthBar";
		uiStyle.threeSound = uiStyle.threeSound != null ? uiStyle.threeSound : "intro3";
		uiStyle.twoSound = uiStyle.twoSound != null ? uiStyle.twoSound : "intro2";
		uiStyle.oneSound = uiStyle.oneSound != null ? uiStyle.oneSound : "intro1";
		uiStyle.goSound = uiStyle.goSound != null ? uiStyle.goSound : "introGo";
		uiStyle.countdownScale = uiStyle.countdownScale != null ? uiStyle.countdownScale : 1.0;
		uiStyle.ratings = ["sick" => uiStyle.sick, "good" => uiStyle.good, "bad" => uiStyle.bad, "shit" => uiStyle.shit, "sick-cool" => (uiStyle.sickcool == null ? uiStyle.sick : uiStyle.sickcool)];
		uiStyle.ratingScale = uiStyle.ratingScale != null ? uiStyle.ratingScale : 0.7;
		uiStyle.comboScale = uiStyle.comboScale != null ? uiStyle.comboScale : 0.5;
		uiStyle.comboSpacing = uiStyle.comboSpacing != null ? uiStyle.comboSpacing : 43;
		uiStyle.antialias = uiStyle.antialias != null ? uiStyle.antialias : true;
		uiStyle.healthBarSides = uiStyle.healthBarSides != null ? uiStyle.healthBarSides : [4, 4, 4, 4];
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
	public var bob:Null<Bool>;
	public var glitch:Null<Bool>;
	public var guitar:Null<Bool>;
	public var guitarOpen:Null<Bool>;
	public var guitarHopo:Null<Bool>;
	public var characterName:Null<String>;
	public var characterNum:Null<Int>;
	public var confused:Null<Bool>;

	public static function loadNoteType(name:String, modName:String) {
		if (Note.loadedNoteTypes.exists('${modName}:${name}')) {
			return Note.loadedNoteTypes.get('${modName}:${name}');
		}
		var parser = new JsonParser<SwagNoteType>();
		var noteType:SwagNoteType;
		noteType = parser.fromJson(CoolUtil.tryPathBoth('objects/notetypes/${name}.json', modName));
		if (noteType == null) {
			if (name == "Normal Note") {
				throw 'Tried to load a nonexistant note type and normal note couldn\'t be loaded instead';
			}
			ErrorReportSubstate.addError('failed to load notetype ${modName}:${name}, loading normal note instead');
			return loadNoteType("Normal Note", modName); //a valid note type must be loaded!
		}
		noteType.healthHit = noteType.healthHit != null ? noteType.healthHit : 0.0475;
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
		noteType.bob = noteType.bob != null ? noteType.bob : false;
		noteType.glitch = noteType.glitch != null ? noteType.glitch : false;
		noteType.guitar = Options.playstate_guitar || (noteType.guitar != null ? noteType.guitar : false);
		noteType.guitarOpen = noteType.guitarOpen != null ? noteType.guitarOpen && !noteType.guitar : false;
		noteType.guitarHopo = noteType.guitarHopo != null ? noteType.guitarHopo : false;
		if (noteType.characterName != null && noteType.characterName != "") {
			noteType.characterNum = Character.findSuitableCharacterNum(noteType.characterName);
		}
		noteType.confused = noteType.confused != null ? noteType.confused : false;
		trace('loaded notetype ${modName}:${name}');
		Note.loadedNoteTypes.set('${modName}:${name}', noteType);
		return noteType;
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

	public var noteScore:Float = 1;
	
	public var noteType:Int = 0;

	public var maniaPart:Int = 0;
	public var maniaFract:Float = 0;
	public var strumLineNum:Int = 0;
	public var strumNoteNum:Int = 0;

	public static var loadedNoteSkins:Map<String, SwagNoteSkin> = new Map<String, SwagNoteSkin>();
	public static var loadedUIStyles:Map<String, SwagUIStyle> = new Map<String, SwagUIStyle>();
	public static var loadedNoteTypes:Map<String, SwagNoteType> = new Map<String, SwagNoteType>();

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
				//animation.appendByPrefix('purpleholdend', 'pruple end hold'); //develop your spritesheets properly challenge (impossible)

				scale.x = PlayState.daPixelZoom * 1.5;
				antialiasing = false;

			case 'normal' | "" | null:
				frames = Paths.getSparrowAtlas('normal/NOTE_assets');
				
				animation.addByPrefix('${myArrow}Scroll', '${myArrow}0', 24);
				animation.addByPrefix('${myArrow}holdend', '${myArrow} hold end', 24);
				animation.addByPrefix('${myArrow}hold', '${myArrow} hold piece', 24);
				//animation.appendByPrefix('purpleholdend', 'pruple end hold'); //develop your spritesheets properly challenge (impossible)

				antialiasing = true;

			default:
				//load custom
				var noteSkin:SwagNoteSkin = SwagNoteSkin.loadNoteSkin(PlayState.SONG.noteSkin, PlayState.modName);
				frames = Paths.getSparrowAtlas(noteSkin.image);

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
				antialiasing = noteSkin.antialias;
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

				prevNote.scale.y = ((Conductor.stepCrochet / 1) * PlayState.SONG.speed * 0.45) / prevNote.frames.frames[prevNote.animation.curAnim.frames[0]].sourceSize.y;
				CoolUtil.CenterOffsets(prevNote);
				prevNote.offset.y = 0;
				//prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
		centerOffsets();
		updateHitbox();
		CoolUtil.CenterOffsets(this);
		if (isSustainNote) {
			//offset.y = flipY ? 0 : height;
			offset.y = height;
		}
		if (animation.curAnim == null) {
			trace("Note's animation is null. Fuck! Strum time is: " + strumTime);
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

	public inline function getNoteTypeData():SwagNoteType {
		return SwagNoteType.loadNoteType(getNoteType(), PlayState.modName);
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
