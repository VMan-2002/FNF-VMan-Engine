package;

import CoolUtil;
import ManiaInfo;
import Note.SwagNoteType;
import Note.SwagUIStyle;
import Section.SwagSection;
import Song.SwagSong;
import Stage;
import ThingThatSucks.ErrorReportSubstate;
import WiggleEffect.WiggleEffectType;
import cpp.Int8;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKeyboard;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.OneOfTwo;
import haxe.Json;
import haxe.ds.ArraySort;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.GraphicsEndFill;
import openfl.display.StageQuality;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import sys.io.File;

using StringTools;
#if !html5
import sys.FileSystem;
#end

#if desktop
import Discord.DiscordClient;
#end
//import flixel.text.FlxTextBorderStyle;

typedef SwagEvent = {
	time:Float,
	values:Array<Dynamic>
}

typedef CamShake = {
	timemult:Float,
	prog:Float,
	gameMoveX:Float,
	gameMoveY:Float,
	classic:Bool
}

typedef NoteRow = {
	time:Float,
	notes:Array<Int>,
	releaseNotes:Array<Int>
}

typedef BobBleed = {
	timeLeft:Float,
	mult:Float,
	maxHealth:Float
}

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;
	public static var modName:String = "";
	public var allowGameplayChanges:Bool;
	
	////::..
	//Song / Audio
	public static var SONG:SwagSong;
	public static var curStage:String = '';
	public var curSong:String = "";
	public var songLength:Float = 0;
	public var vocals:FlxSound;

	public var voicesName:String = "Voices";
	public var instName:String = "Inst";
	public var songTitle:String = "pewdiepie";
	
	public var currentSection:Int; //todo: So im making variable length sections (for example: with non 4/4 time signatures)
	
	private var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	#if desktop
	// Discord RPC variables
	public var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	////::..
	//Story Mode / Difficulty
	public static var isStoryMode:Bool = false;
	public static var storyWeek:String = "week1";
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var storyDifficultyText:String = "";

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;

	////::..
	//Characters
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;
	public var stageCharacters:Array<Character>;
	
	public var gfSpeed:Int = 1;

	////::..
	//Notes / Strumlines / Mania
	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var funnyNotes:Array<Note> = [];
	private var funnyManias:Array<SwagMania> = [];
	public var lastHitNoteTime:Float = 0;
	
	public var strumLineNotes = new Array<StrumNote>();
	public var strumLines:FlxTypedGroup<StrumLine>;
	public var playerStrums = new StrumLine();
	public var opponentStrums = new StrumLine();
	
	public var strumLine:FlxSprite;
	
	public static var curManiaInfo:SwagMania;
	
	public var notesCanBeHit = true;
	var usedBotplay = false;
	//todo: implement these
	var currentManiaPart:Int = 0;
	var currentManiaPartName:Array<String> = [];
	var maniaPartArr:Array<Array<String>> = [];

	////::..
	//Health / Health Bar
	public var health:Float = 1;
	public var maxHealth:Float = 2;
	public var bobBleeds = new Array<BobBleed>();

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	////::..
	//Statistics
	public var combo:Int = 0;
	public var maxCombo:Int = 0;
	
	public var songMisses:Int = 0;
	public var songHits:Int = 0;
	public var songHittableMisses:Int = 0;
	public var songScore:Int = 0;
	public var possibleMoreScore:Int = 0;
	
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	public var songFC:Int = 0; //todo: Not yet used in Highscore.hx
	public static final fcTypes:Array<String> = ["sfc", "gfc", "fc", "sdcb", "clear"];

	////::..
	//Background Stuff
	public var currentStageFront:FlxTypedGroup<SpriteVMan>;
	public var currentStageBack:FlxTypedGroup<SpriteVMan>;
	public var currentStageBetween:FlxTypedGroup<SpriteVMan>;
	public var currentStage:Stage;

	var isHalloween:Bool = false;
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var fastCarCanDrive:Bool = true;
	
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	var curLight:Int = 0;
	
	var bgGirls:BackgroundDancer;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	////::..
	//Camera / Zoom
	public var camGame:FlxCamera;
	
	public var camFollow:FlxObject;
	public var camFollowPos:FlxObject;
	public var camFollowOffset:FlxObject;
	public var camFollowSpeed:Float = 1;
	public var camOffset:FlxPoint = new FlxPoint(0, 0);
	public var camIsFollowing:Bool = true;

	public var camZooming:Bool = false;
	public var zoomBeats:Int = 4;
	public var camShakes:Array<CamShake> = new Array<CamShake>();

	public static var prevCamFollow:FlxObject;
	var defaultCamZoom:Float = 1.05;
	public var useStageCharZooms:Bool = true;
	public var focusCharacter:Character;

	////::..
	//HUD
	public var camHUD:FlxCamera;

	public var hudThings = new FlxTypedGroup<HudThing>();
	public var ratingsGroup = new FlxTypedGroup<FlxSprite>();
	public var currentUIStyle:SwagUIStyle;
	public var isMiddlescroll:Bool = Options.instance.middleScroll;
	
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	
	public var timerThing:HudThing;
	public var timerThingText:FlxText;

	////::..
	//Dialogue / Cutscenes
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueVMan:DialogueBoxVMan;
	var inCutscene:Bool = false;

	////::..
	//Events
	public var events:Array<SwagEvent>;
	public var cinematicBars:FlxTypedGroup<FlxSprite>;

	////::..
	//Unsorted
	//var talking:Bool = true;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	//Starpower
	public var starActive:Bool = false;

	////::..
	//Scripting funny lol
	//The only hscript your getting is ~~me porting the basegame update's hscript support~~ hscript.
	//I have since decided lua (Not the plantoid!!!) support is too hard to be worth it (also inspired by forever engine. thanks u lullaby)
	//todo: add the scripting
	//part of this will be handled in MusicBeatState

	override public function create() {	
		Options.instance = Options.saved.copy();
		ErrorReportSubstate.initReport();

		instance = this;
		allowGameplayChanges = !Std.isOfType(this, PlayStateOffsetCalibrate);
		NoteSplash.noteSplashColors = NoteSplash.noteSplashColorsDefault;
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];
		//FlxG.cameras.setDefaultDrawTarget(camGame, false); //this doesn't work correctly.

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
		
		curManiaInfo = ManiaInfo.GetManiaInfo(SONG.maniaStr);
		if (Options.instance.playstate_bothside && allowGameplayChanges) {
			var newKeys = curManiaInfo.keys * 2;
			var newMania = ManiaInfo.GetManiaInfo(newKeys + "k");
			if (newMania.keys != newKeys) {
				Options.instance.playstate_bothside = false;
				trace("Tried to use mania " + newKeys + "k but it don't exist. So I disabled bothside mode.");
			} else {
				curManiaInfo = newMania;
				isMiddlescroll = true;
			}
		}
		if (isStoryMode)
			Options.instance.playstate_endless = false;
		if (SONG.actions.contains("noBothSide"))
			Options.instance.playstate_bothside = false;
		if (SONG.actions.contains("noOpponentMode"))
			Options.instance.playstate_opponentmode = false;
		
		if (SONG.instName != null)
			instName = SONG.instName;
		
		if (SONG.voicesName != null)
			voicesName = SONG.voicesName;

		trace("load UI style");
		currentUIStyle = SwagUIStyle.loadUIStyle(SONG.uiStyle, modName);
		trace("end load UI style");
		var validUIStyle = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		
		var sn:String = Highscore.formatSong(SONG.song);
		switch (sn) {
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up\nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go\nthrough ME first!"
				];
			case 'fresh':
				dialogue = [
					"Not too shabby boy."
				];
			case 'dad-battle':
				dialogue = [
					"Gah, you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			//case 'senpai' | "roses" | "thorns":
			//	dialogue = CoolUtil.coolTextFile('data/${sn}/${sn}Dialogue');
		}

		var dialoguePath:String = Paths.getModOrGamePath('data/${sn}/dialogue/start.json', modName, null);
		if (
			#if !html5
			FileSystem.exists(dialoguePath)
			#else
			Assets.exists(dialoguePath)
			#end
		) {
			trace('found start dialogue');
			dialogueVMan = new DialogueBoxVMan(dialoguePath);
			dialogueVMan.finishThing = startCountdown;
			dialogueVMan.cameras = [camHUD];
		} else {
			trace('no start dialogue (it would be ' + dialoguePath + ')');
		}

		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyString();

		#if desktop
		//iconRPC = dad.curCharacter;
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC) {
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
			case 'bf-car' | 'bf-christmas':
				iconRPC = 'bf';
			case 'gf-car' | 'gf-christmas' | 'gf-pixel':
				iconRPC = 'gf';
			case 'mr_placeholder_guy':
				iconRPC = 'face';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = isStoryMode ? "Story Mode: " + storyWeek : "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresenceSimple("not_playing");
		#end
		
		Character.nextId = 0;
		Character.activeArray = new Array<Character>();
		
		StrumLine.nextId = 0;
		StrumLine.activeArray = new Array<StrumLine>();
		
		if (SONG.stage == null || SONG.stage.length == 0) {
			switch(sn) {
				case 'spookeez' | 'monster' | 'south': 
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly-nice': 
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				default:
					curStage = 'stage';
			}
		} else {
			curStage = SONG.stage;
		}
		songTitle = SONG.newtitle == null ? SONG.song : SONG.newtitle;
		
		var customStageCharPos:Array<Array<Float>> = null;

		switch (curStage) {
		    case 'philly':  {
				Paths.setCurrentLevel("week3");
				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				var lightColors = CoolUtil.uncoolTextFile('data/phillyWindowColors');
				for (i in 0...5) {
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/window'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.color = FlxColor.fromString(lightColors[i]);
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
				add(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
				add(street);
		    }
			case 'limo': {
				Paths.setCurrentLevel("week4");
				defaultCamZoom = 0.90;

				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				skyBG.scale.set(2, 2);
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5) {
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400, "limoDancer");
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}

				//var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
				//overlayShit.alpha = 0.5;
				// add(overlayShit);

				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

				// overlayShit.shader = shaderBullshit;

				var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
				// add(limo);
			}
			case 'school': {
				Paths.setCurrentLevel("week6");
				// defaultCamZoom = 0.9;

				var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundDancer(-100, 190, SONG.actions.contains("bgFreaksAngry") ? "bgFreaksAngry" : "bgFreaks");
				bgGirls.scrollFactor.set(0.9, 0.9);

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			}
			case 'schoolEvil': {
				Paths.setCurrentLevel("week6");
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

				var posX = 400;
				var posY = 200;

				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);

				/* 
				var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
				bg.scale.set(6, 6);
				// bg.setGraphicSize(Std.int(bg.width * 6));
				// bg.updateHitbox();
				add(bg);

				var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
				fg.scale.set(6, 6);
				// fg.setGraphicSize(Std.int(fg.width * 6));
				// fg.updateHitbox();
				add(fg);

				wiggleShit.effectType = WiggleEffectType.DREAMY;
				wiggleShit.waveAmplitude = 0.01;
				wiggleShit.waveFrequency = 60;
				wiggleShit.waveSpeed = 0.8;
				*/

				// bg.shader = wiggleShit.shader;
				// fg.shader = wiggleShit.shader;

				/* 
				var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
				var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

				// Using scale since setGraphicSize() doesnt work???
				waveSprite.scale.set(6, 6);
				waveSpriteFG.scale.set(6, 6);
				waveSprite.setPosition(posX, posY);
				waveSpriteFG.setPosition(posX, posY);

				waveSprite.scrollFactor.set(0.7, 0.8);
				waveSpriteFG.scrollFactor.set(0.9, 0.8);

				// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
				// waveSprite.updateHitbox();
				// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
				// waveSpriteFG.updateHitbox();

				add(waveSprite);
				add(waveSpriteFG);
				*/
			}
			default: { //load custom stage
				trace('loading custom stage '+curStage);
				currentStage = new Stage(curStage);
				currentStageBack = currentStage.elementsBack;
				currentStageFront = currentStage.elementsFront;
				currentStageBetween = currentStage.elementsBetween;
				add(currentStageBack);
				defaultCamZoom = currentStage.defaultCamZoom;
				if (defaultCamZoom == 0) {
					trace("something went wrong with the stage loading");
					defaultCamZoom = 0.9;
				}
				customStageCharPos = currentStage.charPosition;
			}
		}
		if (currentStage == null)
			currentStage = new Stage();

		isHalloween = SONG.actions.contains("isHalloween");

		if (SONG.actions.contains("mustBeMiddlescroll"))
			isMiddlescroll = true;

		if (currentStage == null)
			currentStage = new Stage();

		var gfVersion:String = 'gf';
		
		if (SONG.gfVersion.length > 0) {
			gfVersion = SONG.gfVersion;
		} else {
			switch (curStage) {
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school':
					gfVersion = 'gf-pixel';
				case 'schoolEvil':
					gfVersion = 'gf-pixel';
			}
		}
		
		boyfriend = new Boyfriend(770, 100, SONG.player1, modName, currentStage.charFacing.contains(0));
		dad = new Character(100, 100, SONG.player2, currentStage.charFacing.contains(1), modName);
		gf = new Character(400, 130, gfVersion, currentStage.charFacing.contains(2), modName);
		
		boyfriend.visible = !SONG.actions.contains("hideBoyfriend");
		dad.visible = !SONG.actions.contains("hideDad");
		gf.visible = !SONG.actions.contains("hideGf");

		gf.scrollFactor.set(0.95, 0.95);
		
		boyfriend.applyPositionOffset();
		
		dad.applyPositionOffset();
		
		gf.applyPositionOffset();

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2) {
			/*case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}*/
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
			case 'senpai' | 'senpai-angry' | 'spirit':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		if (dad.isGirlfriend && gf != null && gf.alive) {
			Character.activeArray[Character.activeArray.indexOf(dad)] = gf;
			remove(dad);
			dad.destroy();
			dad = gf; //REPLACE THE BINCH
			gf.moduloDances *= 2; //fix dances
		}

		if (SONG.picospeaker != null && SONG.picospeaker.length > 0)
			gf.loadMappedAnims(Highscore.formatSong(SONG.song), SONG.picospeaker);

		// REPOSITIONING PER STAGE
		switch (curStage) {
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		if (SONG.actions.contains("spookyEnemy")) {
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			// evilTrail.changeValuesEnabled(false, false, false, false);
			// evilTrail.changeGraphic()
			add(evilTrail);
			// evilTrail.scrollFactor.set(1.1, 1.1);
		}
		if (SONG.actions.contains("spookyPlayer")) {
			var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		

		if (currentStageBetween != null)
			add(currentStageBetween);
		else if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);
		
		if (SONG.moreCharacters != null && SONG.moreCharacters.length != 0) {
			trace('Adding ${SONG.moreCharacters.length} extra characters');
			var bullShit:Int = 3;
			for (i in SONG.moreCharacters) {
				add(new Character(0, 0, i, currentStage.charFacing.contains(bullShit), modName)); //these are automatically put into Character.activeArray, so it's ok that they're not assigned to variables here
				bullShit++;
			}
		}
		
		if (customStageCharPos != null) {
			for (i in 0...Character.activeArray.length) {
				if (customStageCharPos.length <= i) {
					break;
				}
				var char:Character = Character.activeArray[i];
				char.x = customStageCharPos[i][0];
				char.y = customStageCharPos[i][1];
				if (i > 2) {
					//char.dance();
				}
				char.applyPositionOffset();
			}
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 100).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (Options.instance.downScroll)
			strumLine.y = FlxG.height - 100;

		strumLines = new FlxTypedGroup<StrumLine>();
		add(strumLines);

		// startCountdown();

		generateSong(SONG.song);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
	
		add(grpNoteSplashes);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowOffset = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null) {
			camFollow.setPosition(prevCamFollow.x, prevCamFollow.y);
			camFollowPos.setPosition(prevCamFollow.x, prevCamFollow.y);
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image(validUIStyle ? currentUIStyle.healthBar : 'normal/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (Options.instance.downScroll)
			healthBarBG.y = FlxG.height * 0.1;
		if (validUIStyle)
			CoolUtil.mapPositionObjectWithin(healthBarBG, currentUIStyle.hudThingPos, Options.instance.downScroll ? "healthBarDown" : "healthBarUp");
		add(healthBarBG);

		var healthBarSides:Array<Float> = validUIStyle ? currentUIStyle.healthBarSides.copy() : [4, 4, 4, 4];
		healthBarSides[3] += healthBarSides[1];
		healthBarSides[2] += healthBarSides[0];

		healthBar = new FlxBar(healthBarBG.x + healthBarSides[0], healthBarBG.y + healthBarSides[1], RIGHT_TO_LEFT, Std.int(healthBarBG.width - healthBarSides[2]), Std.int(healthBarBG.height - healthBarSides[3]), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		//healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		if (Options.instance.playstate_opponentmode && allowGameplayChanges) {
			healthBar.createFilledBar(boyfriend.healthBarColor, dad.healthBarColor);
		} else {
			healthBar.createFilledBar(dad.healthBarColor, boyfriend.healthBarColor);
		}
		// healthBar
		healthBar.flipX = allowGameplayChanges && Options.instance.playstate_opponentmode;
		add(healthBar);
		
		var hudThingLists:Array<Array<String>>;
		if (Std.isOfType(this, PlayStateOffsetCalibrate)) {
			hudThingLists = [
				["hits", "offset_avg", "offset_min", "offset_max", "offset_range"],
				["song"],
				["hits", "misses", "totalnotes", "health"]
			];
		} else {
			hudThingLists = [
				["score", "misses", "fc", "accRating", "accSimple", "health"],
				["song", "difficulty"],
				["hits", "sicks", "goods", "bads", "shits", "misses", "totalnotes"]
			];
		}
		hudThingLists[1].push("engine");
		hudThings.add(new HudThing(healthBarBG.x, healthBarBG.y + 30, hudThingLists[0]));
		hudThings.add(new HudThing(2, FlxG.height - 24, hudThingLists[1]));
		hudThings.add(new HudThing(2, (FlxG.height / 2) - 100, hudThingLists[2], true));
		
		timerThing = cast add(new HudThing(0, !Options.instance.downScroll ? 10 : FlxG.height - 34, ["timer_down_notitle"]));
		timerThing.autoUpdate = true;
		timerThingText = cast timerThing.members[0];
		timerThingText.alignment = CENTER;
		timerThingText.fieldWidth = FlxG.width;
		timerThing.cameras = [camHUD];

		if (validUIStyle) {
			CoolUtil.mapPositionObjectWithin(cast hudThings.members[0].members[0], currentUIStyle.hudThingPos, Options.instance.downScroll ? "textHealthDown" : "textHealthUp");
			CoolUtil.mapPositionObjectWithin(cast hudThings.members[1].members[0], currentUIStyle.hudThingPos, Options.instance.downScroll ? "textSideDown" : "textSideUp");
			CoolUtil.mapPositionObjectWithin(cast hudThings.members[2].members[0], currentUIStyle.hudThingPos, Options.instance.downScroll ? "textCornerDown" : "textCornerUp");
			CoolUtil.mapPositionObjectWithin(cast timerThing.members[0], currentUIStyle.hudThingPos, Options.instance.downScroll ? "textTimerDown" : "textTimerUp");
		}

		iconP1 = new HealthIcon(boyfriend.healthIcon, true, modName);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false, modName);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		iconP1.addChildrenToScene();
		iconP2.addChildrenToScene();
		
		add(hudThings);

		strumLines.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		hudThings.cameras = [camHUD];
		doof.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];

		if (currentStageFront != null)
			add(currentStageFront);
		if ((currentStage.hide_girlfriend || SONG.hide_girlfriend) && SONG.hide_girlfriend != false)
			gf.visible = false;

		if (((sn == "monster" || sn == "winter-horrorland") && modName == "friday_night_funkin") || SONG.actions.contains("alternateHud")) {
			for (thing in hudThings) {
				thing.doSpoop(); //limited information is spoopy!!!!
			}
			var topThing:FlxText = cast hudThings.members[0].members[0];
			topThing.x = 0;
			topThing.fieldWidth = FlxG.width;
			topThing.alignment = FlxTextAlign.CENTER;
			topThing.size = Math.round(topThing.size * 1.5);
		}

		startingSong = true;
		
		if (SONG.actions.contains("underConstruction")) {
			var pos = currentStage.charPosition[currentStage.charPosition.length > 1 ? 1 : 0];
			var underConstruction:FlxSprite = new FlxSprite(pos[0], pos[1], Paths.image('underConstruction'));
			add(underConstruction);
		}

		if (SONG.actions.contains("loadLuaTest")) {
			#if !html5 //todo: i should implement some alternative to lua scripts for html5
			//luaScripts.push(new LuaScript(Paths.txt('${Highscore.formatSong(SONG.song)}/test').replace(".txt", ".lua"), this));
			luaScripts.push(new LuaScript('data/${Highscore.formatSong(SONG.song)}/test.lua', this));
			#end
		}

		if (isStoryMode) {
			if (SONG.actions.contains("winterHorrorlandIntro")) {
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer) {
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				});
			} else {
				switch (curSong) {
					case 'senpai' | 'thorns':
						schoolIntro(doof);
					case 'roses':
						FlxG.sound.play(Paths.sound('ANGRY'));
						schoolIntro(doof);
					default:
						if (!SONG.actions.contains("winterHorrorlandIntro")) {
							startCountdown();
						}
				}
			}
		} else {
			if (dialogueVMan != null && dialogueVMan.dialogueFile.usedInFreeplay || isStoryMode) {
				schoolIntro(doof);
			} else {
				startCountdown();
			}
		}
		
		stageCharacters = Character.activeArray;

		super.create();

		ErrorReportSubstate.displayReport();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void {
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (curSong == 'senpai')
			add(black);
		else if (curSong == 'thorns')
			add(red);

		new FlxTimer().start(0.3, function(tmr:FlxTimer) {
			black.alpha -= 0.15;

			if (black.alpha > 0) {
				tmr.reset(0.3);
			} else {
				if (dialogueVMan != null) {
					inCutscene = true;

					if (curSong == 'thorns') {
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer) {
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1) {
								swagTimer.reset();
							} else {
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function() {
										add(dialogueVMan);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					} else {
						add(dialogueVMan);
					}
				} else startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	//var perfectMode:Bool = false;

	function startCountdown():Void {
		inCutscene = false;

		playerStrums.destroy();
		opponentStrums.destroy();
		generateStaticArrows(0);
		generateStaticArrows(1);
		var i = 0;
		while (i < SONG.moreStrumLines) {
			generateStaticArrows(2 + i);
			i++;
		}

		//talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0 - Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['', 'normal/ready', "normal/set", "normal/go"]);
			introAssets.set('school', ['', 'pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['', 'pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var introAltsSounds:Array<String> = ["intro3", "intro2", "intro1", "introGo"];
			var altSuffix:String = "";
			var scale:Float = 1;

			if (currentUIStyle != null) {
				introAlts = [currentUIStyle.three, currentUIStyle.two, currentUIStyle.one, currentUIStyle.go];
				introAltsSounds = [currentUIStyle.threeSound, currentUIStyle.twoSound, currentUIStyle.oneSound, currentUIStyle.goSound];
				scale = currentUIStyle.countdownScale;
			} else {
				for (value in introAssets.keys()) {
					if (value == curStage) {
						introAlts = introAssets.get(value);
						introAltsSounds = ["intro3-pixel", "intro2-pixel", "intro1-pixel", "introGo-pixel"];
						scale = daPixelZoom;
					}
				}
			}

			if (swagCounter <= 3) {
				playCountdownSprite(introAlts[swagCounter], scale, introAltsSounds[swagCounter]);
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		
		if (SONG.actions.contains("showSongCredit")) {
			var creditText = new FlxText(0, FlxG.height, FlxG.width, Assets.getText('data/${Highscore.formatSong(SONG.song)}/songCredit.txt').replace("\r\n", "\n"));
			creditText.setFormat("vcr.ttf", 24, 0xFFFFFFFF, FlxTextAlign.CENTER);
			creditText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
			creditText.y -= ((creditText.textField.height * 2) + 4);
			creditText.cameras = [camHUD];
			add(creditText);
			timerThingText.alpha = 0.25;
			FlxTween.tween(creditText, {y: FlxG.height + 4}, 1, {startDelay: 2.5, ease: FlxEase.quartIn, onComplete: function(tw:FlxTween) {
				remove(creditText);
				creditText.destroy();
			}});
			FlxTween.tween(timerThingText, {alpha: 1}, 0.5, {startDelay: 3, ease: FlxEase.cubeInOut});
		}
	}

	public function playCountdownSprite(path:String, scale:Float, sound:String) {
		var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(path));
		ready.scrollFactor.set();
		ready.updateHitbox();

		ready.scale.x = scale;
		ready.scale.y = scale;

		ready.screenCenter();
		add(ready);
		FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween) {
				ready.destroy();
			}
		});
		ready.visible = path != "";
		if (!Options.instance.silentCountdown)
			FlxG.sound.play(Paths.sound(sound), 0.6);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void {
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.getSongPathThing(PlayState.SONG.song, instName), 1, false);
		FlxG.sound.music.onComplete = preEndSong;
		vocals.play();

		songLength = FlxG.sound.music.length;
		// Song duration in a float, useful for the time left feature
		var i = 0;
		while (FileSystem.exists(Paths.getSongPathThing(PlayState.SONG.song, 'part{i}/${instName}'))) {
			//this is probably not good but it's accurate i guess
			var aud = new FlxSound().loadEmbedded(Paths.getSongPathThing(PlayState.SONG.song, 'part{i}/${instName}'));
			songLength += aud.length;
			aud.destroy();
			i++;
		}
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresenceSimple("playing");
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void {
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song.toLowerCase();

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.getSongPathThing(PlayState.SONG.song, voicesName));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		checkNextSongAudio();
		
		if (!Std.isOfType(this, PlayStateOffsetCalibrate)) {
			add(ratingsGroup);
			ratingsGroup.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		//var playerCounter:Int = 0;

		SwagNoteType.clearLoadedNoteTypes();
		for (thing in songData.usedNoteTypes) {
			SwagNoteType.loadNoteType(thing, modName);
		}

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData) {
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			generateNotes(section, section.sectionNotes, 0);
			if (section.notesMoreLayers != null) {
				var layerThing = 1;
				for (thing in section.notesMoreLayers) {
					generateNotes(section, thing, layerThing++);
				}
			}
			daBeats += 1;
		}

		for (thing in 0...songData.vmanEventOrder.length) {
			if (songData.vmanEventTime[thing] == -999) {
				//-999 means event is run at the start
				runEvent(songData.vmanEventData[songData.vmanEventOrder[thing]]);
			} else {
				events[thing] = {
					time: songData.vmanEventTime[thing],
					values: songData.vmanEventData[songData.vmanEventOrder[thing]]
				};
			}
		}
		ArraySort.sort(events, function(a:SwagEvent, b:SwagEvent):Int {
			var d = Math.floor(a.time) - Math.floor(b.time);
			if (d == 0)
				return a.time > b.time ? 1 : -1;
			return d;
		});

		if (SONG.picocharts != null) {
			for (i in 0...SONG.picocharts.length) {
				//todo: picocharts
				if (SONG.picocharts[i].length > 0) {
					var swagshit = Song.loadFromJson(Highscore.formatSong(SONG.song), SONG.picocharts[i]);
					for (section in swagshit.notes) {
						//we need to remap Note Types !!
						for (note in section.sectionNotes) {
							var t = swagshit.usedNoteTypes[note[3]];
							if (!SONG.usedNoteTypes.contains(t))
								SONG.usedNoteTypes.push(t);
							note[3] = SONG.usedNoteTypes.indexOf(t);
						}
						generateNotes(section, section.sectionNotes, -1, funnyNotes);
					}
					funnyManias[i] = ManiaInfo.GetManiaInfo(swagshit.maniaStr);
				}
			}
			funnyNotes.sort(sortByShit);
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function generateNotes(section:SwagSection, sectionNotes:Array<Dynamic>, layer:Int, ?addTo:Array<Note> = null) {
		if (addTo == null)
			addTo = unspawnNotes;
		for (songNotes in sectionNotes) {
			var daStrumTime:Float = songNotes[0];
			var daNoteData:Int = Std.int(songNotes[1] % curManiaInfo.keys);
			if (daNoteData < 0) {
				trace('Bad note data ${daNoteData} at ${daStrumTime}, skipping');
				continue;
			}

			var gottaHitNote:Bool = false;
			if (layer == 0) {
				gottaHitNote = (section.mustHitSection != false) != (songNotes[1] >= curManiaInfo.keys);
				if (allowGameplayChanges) {
					if (Options.instance.playstate_opponentmode) {
						gottaHitNote = !gottaHitNote;
					}
					if (Options.instance.playstate_bothside && !gottaHitNote) {
						gottaHitNote = true;
						daNoteData = (daNoteData + Math.floor(curManiaInfo.keys / 2)) % curManiaInfo.keys;
					}
				}
			}

			var oldNote:Note;
			if (unspawnNotes.length > 0)
				oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
			else
				oldNote = null;

			var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, null, songNotes[3], layer < 0 ? layer : (layer == 0 ? (gottaHitNote ? 1 : 0) : layer + 1));
			swagNote.sustainLength = songNotes[2];
			swagNote.scrollFactor.set(0, 0);
			if (((swagNote.getNoteTypeData().confused) || (allowGameplayChanges && Options.instance.playstate_confusion && Math.random() <= 0.3)) && curManiaInfo.keys > 1) {
				//swagNote.strumNoteNum = Math.floor(Math.random() * strumLines.members[swagNote.strumLineNum].thisManiaInfo.keys);
				while (swagNote.strumNoteNum == swagNote.noteData) {
					swagNote.strumNoteNum = Math.floor(Math.random() * curManiaInfo.keys);
				}
			}

			var susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
			unspawnNotes.push(swagNote);

			swagNote.mustPress = gottaHitNote;

			for (susNote in 0...Math.floor(susLength)) {
				oldNote = unspawnNotes[unspawnNotes.length - 1];

				var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, null, swagNote.noteType, swagNote.strumLineNum);
				sustainNote.scrollFactor.set();
				sustainNote.strumNoteNum = swagNote.strumNoteNum;
				unspawnNotes.push(sustainNote);

				sustainNote.mustPress = gottaHitNote;
			}

			if (swagNote.getNoteTypeData().hasReleaseNote) {
				unspawnNotes[unspawnNotes.length - 1].makeReleaseNote();
			}
		}
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function generateStaticArrows(player:Int) {
		var xPos:Float = 0;
		var scale:Float = 1;
		if (player == 1) {
			xPos = isMiddlescroll ? FlxG.width / 2 : FlxG.width * 0.75;
		} else {
			xPos = isMiddlescroll || SONG.actions.contains("hideOpponentNotes") ? FlxG.width * 8 : FlxG.width * 0.25;
			if (SONG.moreStrumLines > 0 && !isMiddlescroll) {
				if (!SONG.actions.contains("dontResizeStrumlines"))
					scale /= SONG.moreStrumLines + 1;
				var myNum = player == 0 ? 0.5 : player - 0.5;
				xPos = (myNum * FlxG.width / 2) / (SONG.moreStrumLines + 1);
			}
		}
		var thing:StrumLine = new StrumLine(curManiaInfo, xPos, strumLine.y, scale);

		if (player == 1) {
			members[members.indexOf(playerStrums)] = thing;
			if (playerStrums != null)
				playerStrums.destroy();
			playerStrums = thing;
		} else if (player == 0) {
			members[members.indexOf(opponentStrums)] = thing;
			if (opponentStrums != null)
				opponentStrums.destroy();
			opponentStrums = thing;
		}
		if (strumLines.members.indexOf(thing) <= -1) {
			strumLines.add(thing);
		}
		for (i in 0 ... curManiaInfo.keys) {
			if (thing.members[i] == null) {
				trace('Null member of strumline ${player} at ${i}. This is really bad.');
			}
		}
		return thing;
	}

	function tweenCamIn():Void {
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null && !startingSong) {
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			DiscordClient.changePresenceSimple(startTimer.finished ? "playing" : "not_playing");
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void {
		#if desktop
		if (health > 0 && !paused) {
			DiscordClient.changePresenceSimple(Conductor.songPosition > 0 ? "playing" : "not_playing");
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void {
		#if desktop
		if (health > 0 && !paused) {
			DiscordClient.changePresenceSimple("paused");
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void {
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPositionAudio = FlxG.sound.music.time;
		vocals.time = Conductor.songPositionAudio;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float) {
		#if !debug
		//perfectMode = false;
		#end

		/*if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}*/

		for (thing in bobBleeds) {
			var nextHealth = health - thing.mult * Math.min(elapsed, thing.timeLeft);
			if (thing.mult < 0) {
				if (health < thing.maxHealth)
					health = Math.min(nextHealth, thing.maxHealth);
			} else {
				health = nextHealth;
			}
			thing.timeLeft -= elapsed;
			if (thing.timeLeft <= 0)
				bobBleeds.remove(thing);
		}

		switch (curStage) {
			case 'philly':
				if (trainMoving) {
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24) {
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		for (i in hudThings.members) {
			i.updateInfo();
		}

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause && !isSubStateActive) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresenceSimple("paused");
			#end
		}

		if (FlxG.keys.justPressed.SEVEN && !isSubStateActive) {
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (currentUIStyle.iconEaseFunc != null) {
			var prog = (Conductor.songPosition / Conductor.crochet) % 1;
			iconP1.scale.x = FlxMath.lerp(1.2, 1, currentUIStyle.iconEaseFunc(prog));
			iconP1.scale.y = iconP1.scale.x;
			iconP2.scale.x = iconP1.scale.x;
			iconP2.scale.y = iconP2.scale.y;
		} else {
			var iconScaleMove2 = 25 * elapsed * currentUIStyle.iconEase;
			iconP1.scale.set(FlxMath.lerp(iconP1.scale.x, 1, iconScaleMove2), FlxMath.lerp(iconP1.scale.y, 1, iconScaleMove2));
			iconP2.scale.set(FlxMath.lerp(iconP2.scale.x, 1, iconScaleMove2), FlxMath.lerp(iconP2.scale.y, 1, iconScaleMove2));
		}

		var iconOffset:Int = 26;
		var healthSub = healthBar.flipX ? healthBar.percent : 100 - healthBar.percent;
		iconP1.x = healthBar.x + (healthBar.width * (healthSub * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (healthSub * 0.01)) - (150 - iconOffset);

		if (healthSub > 80) { //enemy winning
			iconP1.setState(1);
			iconP2.setState(2);
		} else if (healthSub < 20) { //player winning
			iconP1.setState(2);
			iconP2.setState(1);
		} else {
			iconP1.setState(0);
			iconP2.setState(0);
		}

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPositionAudio >= 0)
					startSong();
			}
		} else {
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && SONG.notes[currentSection] != null) {
			/*if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}*/

			var newFocus:Character = SONG.notes[currentSection].mustHitSection != false ? boyfriend : dad;
			var focusNum:Null<Int> = SONG.notes[currentSection].focusCharacter;
			if (focusNum != null && focusNum > 0 && focusNum <= Character.activeArray.length) {
				newFocus = Character.activeArray[focusNum - 1];
			}

			if (focusCharacter != newFocus) {
				camFollowSetOnCharacter(newFocus);
				focusCharacter = newFocus;
			}
		}

		if (camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'fresh') {
			switch (curBeat) {
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'bopeebo') {
			switch (curBeat) {
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && Options.instance.resetButton) {
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT) {
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0) {
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			var daChar = Options.instance.playstate_opponentmode ? dad : boyfriend;

			openSubState(new GameOverSubstate(daChar.getScreenPosition().x, daChar.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null) {
			while (unspawnNotes[0].strumTime - Conductor.songPosition < 1500) {
				var dunceNote:Note = unspawnNotes.shift();
				dunceNote.visible = dunceNote.visible && !Options.instance.invisibleNotes;
				var scaleThing = strumLines.members[dunceNote.strumLineNum].scale;
				dunceNote.scale.x *= scaleThing;
				if (!dunceNote.animation.curAnim.name.endsWith("hold"))
					dunceNote.scale.y *= scaleThing;
				notes.insert(0, dunceNote);
				onSpawnNote(dunceNote);
				if (unspawnNotes.length == 0)
					break;
			}
		}

		if (generatedMusic) {
			var speed = (0.45 * FlxMath.roundDecimal(SONG.speed, 3));
			if (Options.instance.downScroll) {
				speed = 0 - speed;
			}
			notes.forEachAlive(function(daNote:Note) {
				/*if (daNote.y > FlxG.height) {
					daNote.active = false;
					daNote.visible = false;
				} else {
					daNote.visible = true;
					daNote.active = true;
				}*/
				/*if (daNote.tooLate) {
					daNote.active = false;
					daNote.visible = false;
				}*/
				
				var strumNumber = daNote.strumLineNum;

				var isComputer = (!daNote.mustPress) || Options.instance.botplay;
				var isPass = daNote.strumTime <= Conductor.songPosition;
				
				if (strumLines.members[strumNumber] != null) { //Do nothing if strumline not found
					//todo: i guess. It's fine if you disallow both side mode when a song has mania changes
					var isInManiaChange:Bool = false; //currentManiaPartName[strumNumber] == maniaPartArr[daNote.maniaPart][strumNumber];
					var daStrum:StrumNote = strumLines.members[strumNumber].members[(isInManiaChange || daNote.center) ? 0 : daNote.strumNoteNum];
					daNote.y = (daStrum.y - (Conductor.songPosition - daNote.strumTime) * speed * daStrum.speedMult);
					daNote.x = daStrum.x;
					if (isInManiaChange || daNote.center) {
						daNote.y += strumLines.members[strumNumber].spanY * daNote.maniaFract;
						daNote.x += strumLines.members[strumNumber].spanX * daNote.maniaFract;
					}

					// i am so fucking sorry for this if condition
					if (daNote.isSustainNote
						//&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
						&& isPass
						&& (isComputer || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)))
					) {
						//todo: make this better in downscroll
						var since = Conductor.songPosition - daNote.strumTime;
						var clipEnd = daNote.strumTime + Conductor.crochet;
						var clipFraction = (clipEnd - since) / Conductor.crochet;
						var swagRect = new FlxRect(0, clipFraction * daNote.height / daNote.scale.x, daNote.width / daNote.scale.x, daNote.height * daNote.scale.x);
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				//todo: sometimes the opponent misses notes. why is this
				if (isComputer && isPass) {
					if (daNote.mustPress) {
						goodNoteHit(daNote);
					} else {
						//opponentNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				//if (daNote.y < -daNote.height) {
					if (daNote.tooLate) {
						if (daNote.mustPress && !daNote.wasGoodHit) {
							noteMiss(daNote.noteData, daNote);
							if (Options.noteMissAction_Vocals[Options.instance.noteMissAction])
								vocals.volume = 0;
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				//}
			});
			if (funnyNotes.length != 0) {
				while (funnyNotes[0].strumTime <= Conductor.songPosition) {
					var haha = funnyNotes.shift();
					opponentNoteHit(haha);
					haha.destroy();
				}
			}
		}

		if (camIsFollowing) {
			var speed = Math.min(camFollowSpeed * 2 * elapsed, 1);
			var targetX = camFollow.x + camFollowOffset.x;
			var targetY = camFollow.y + camFollowOffset.y;
			if (Options.instance.noteCamMovement && focusCharacter.noteCameraOffset.exists(focusCharacter.animation.curAnim.name)) {
				var thing = focusCharacter.noteCameraOffset.get(focusCharacter.animation.curAnim.name);
				targetX += thing.x;
				targetY += thing.y;
			}
			camFollowPos.x = FlxMath.lerp(camFollowPos.x, targetX, speed);
			camFollowPos.y = FlxMath.lerp(camFollowPos.y, targetY, speed);
			if (camShakes.length != 0) {
				FlxG.camera.targetOffset.set(0, 0);
				var i = camShakes.length - 1;
				while (i != -1) {
					var thing = camShakes[i];
					thing.prog += elapsed * thing.timemult;
					if (thing.prog >= 1) {
						camShakes.pop();
					} else {
						var shkInt = thing.classic ? 1 : 1 - thing.prog;
						FlxG.camera.targetOffset.x += FlxMath.remapToRange(Math.random() * shkInt, 0, 1, -thing.gameMoveX, thing.gameMoveX);
						FlxG.camera.targetOffset.y += FlxMath.remapToRange(Math.random() * shkInt, 0, 1, -thing.gameMoveY, thing.gameMoveY);
					}
					i--;
				}
			}
		}

		//handle events

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}
	
	public function onSpawnNote(dunceNote:Note) {
		
	}

	public function camFollowSetOnCharacter(char:Character) {
		focusCharacter = char;
		
		if (char == dad) {
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

			if (SONG.song.toLowerCase() == 'tutorial') {
				tweenCamIn();
			}
		}

		if (char == boyfriend) {
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = char.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = char.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = char.getMidpoint().x - 200;
					camFollow.y = char.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial') {
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}

		switch (char.curCharacter) {
			case 'mom':
				camFollow.y = char.getMidpoint().y;
				vocals.volume = 1;
		}

		camFollow.x += char.cameraOffset[0];
		camFollow.y += char.cameraOffset[1];

		var guyId = Math.floor(Math.min(Character.activeArray.indexOf(char), currentStage.cameraOffset.length - 1));
		camFollow.x += currentStage.cameraOffset[guyId][0];
		camFollow.y += currentStage.cameraOffset[guyId][1];
		
		if (useStageCharZooms && currentStage.charZoom != null && currentStage.charZoom.length > guyId && currentStage.charZoom[guyId] != null) {
			defaultCamZoom = currentStage.charZoom[guyId];
		}
	}

	function preEndSong() {
		if (hasNextSongAudio) {
			songPositionOffset += FlxG.sound.music.length;
			FlxG.sound.music.stop();
			vocals.stop();
			
			FlxG.sound.music.destroy();
			vocals.destroy();
			FlxG.sound.list.remove(vocals, true);

			FlxG.sound.music = nextSongAudio;
			vocals = nextSongAudioVoices;
			FlxG.sound.list.add(vocals);

			FlxG.sound.music.onComplete = preEndSong;
			resyncVocals();
			curSongAudioPart += 1;
			checkNextSongAudio();
			return;
		}
		endSong();
	}

	function endSong():Void {
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore && !(Options.instance.botplay || usedBotplay)) {
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (Std.isOfType(this, PlayStateOffsetCalibrate)) {
			var nextState = new OptionsMenu();
			return FlxG.switchState(nextState);
		}

		if (!isStoryMode && Options.instance.playstate_endless && allowGameplayChanges) {
			var newState = new PlayState();
			newState.songScore = songScore;
			newState.songMisses = songMisses;
			newState.songHittableMisses = songHittableMisses;
			newState.songHits = songHits;
			newState.sicks = sicks;
			newState.goods = goods;
			newState.bads = bads;
			newState.shits = shits;
			newState.combo = combo;
			newState.maxCombo = maxCombo;
			newState.possibleMoreScore = possibleMoreScore;
			newState.songFC = songFC;
			return FlxG.switchState(newState);
		}

		Achievements.giveAchievement("anyClear");
		if (songMisses <= 9 && songHits > 0) {
			Achievements.giveAchievement("anySDCB");
			if (songMisses <= 0) {
				Achievements.giveAchievement("anyFC");
				if (shits == 0 && bads == 0) {
					Achievements.giveAchievement("anyGFC");
					if (goods == 0) {
						Achievements.giveAchievement("anySFC");
					}
				}
			}
		}
		if (allowGameplayChanges) {
			if (Options.instance.playstate_bothside) {
				Achievements.giveAchievement("anyBothPlay");
			} else if (Options.instance.playstate_opponentmode) {
				Achievements.giveAchievement("anyOpponentPlay");
			}
			if (Options.instance.playstate_guitar) {
				Achievements.giveAchievement("anyGuitarPlay");
			}
			if (Options.instance.playstate_confusion) {
				Achievements.giveAchievement("anyConfusionPlay");
			}
			if ([Options.instance.playstate_bothside || Options.instance.playstate_opponentmode, Options.instance.playstate_guitar, Options.instance.playstate_confusion].filter(function(a) {return a;}).length > 1) {
				Achievements.giveAchievement("anyMultiModifierPlay");
			}
		}

		if (isStoryMode) {
			campaignScore += songScore;
			campaignMisses += songMisses;

			storyPlaylist.shift();

			if (storyPlaylist.length <= 0) {
				CoolUtil.playMenuMusic();

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				//todo: make this do anything
				// if ()
				//StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore && !Options.instance.botplay) {
					//NGio.unlockMedal(60961);
					Highscore.saveWeekScore('${modName}:${storyWeek}', campaignScore, storyDifficulty);
					Achievements.giveAchievement("anyWeekClear");
					if (campaignMisses == 0) {
						Achievements.giveAchievement("anyWeekFC");
					}
					Weeks.setWeekCompleted(storyWeek, modName);
				}

				//FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			} else {
				var difficulty:String = CoolUtil.difficultyPostfixString();

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.actions.contains("lightsOffEnding")) {
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.storyPlaylist[0], PlayState.storyDifficulty), PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;
	//private var ratingPositioner:FlxPoint = new FlxPoint(FlxG.width * 0.55, FlxG.height * 0.5);

	private function popUpScore(daNote:Note):String {
		var strumtime:Float = daNote.strumTime;

		//var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		var noteDiff:Float = Math.abs(strumtime - (FlxG.sound.music.time + Conductor.offset));
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9) {
			daRating = 'shit';
			score = 50;
			shits += 1;
		} else if (noteDiff > Conductor.safeZoneOffset * 0.75) {
			daRating = 'bad';
			score = 100;
			bads += 1;
		} else if (noteDiff > Conductor.safeZoneOffset * 0.2) {
			daRating = 'good';
			score = 200;
			goods += 1;
		} else {
			sicks += 1;
			//todo: sometimes notesplashes are the wrong color
			//todo: sometimes notesplashes crash.
			//grpNoteSplashes.recycle(NoteSplash, NoteSplash.new).playNoteSplash(playerStrums.members[daNote.strumNoteNum], daNote);
		}
		if (daRating != "sick" && songFC < 2) {
			if (daRating == "good") {
				if (songFC == 0)
					songFC = 1;
			} else if (songFC < 2) {
				songFC = 2;
			}
		}
		if (Options.instance.botplay)
			usedBotplay = true;

		songScore += Options.instance.botplay ? 350 : score;

		var validUIStyle = true;

		var pixelShitPart1:String = "normal/";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school')) {
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		var daRatingImg = (songMisses == 0 && shits == 0 && bads == 0 && goods == 0) ? 'sick-cool' : daRating;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(validUIStyle ? currentUIStyle.combo : pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		ratingsGroup.add(comboSpr);

		if (!Options.instance.botplay) {
			rating.loadGraphic(Paths.image(validUIStyle ? currentUIStyle.ratings.get(daRatingImg) : '${pixelShitPart1 + daRatingImg + pixelShitPart2}'));
			//trace("path "+Paths.image(validUIStyle ? currentUIStyle.ratings.get(daRatingImg) : '${pixelShitPart1 + daRatingImg + pixelShitPart2}'));
			rating.screenCenter();
			rating.x = coolText.x - 40;
			rating.y -= 60;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			ratingsGroup.add(rating);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					rating.destroy();
					ratingsGroup.remove(rating, true);
				},
				startDelay: Conductor.crochet * 0.001
			});
		}

		if (validUIStyle) {
			rating.scale.x = currentUIStyle.ratingScale;
			rating.scale.y = currentUIStyle.ratingScale;
			comboSpr.scale.x = currentUIStyle.ratingScale;
			comboSpr.scale.y = currentUIStyle.ratingScale;
			comboSpr.antialiasing = currentUIStyle.antialias;
			coolText.antialiasing = currentUIStyle.antialias;
		} else {
			if (!curStage.startsWith('school')) {
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			} else {
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		if (combo >= 10 || combo == 0 || Options.instance.botplay) {
			var seperatedScore:Array<String> = Std.string(combo).split("");

			/*seperatedScore.push(Math.floor(combo / 100));
			seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
			seperatedScore.push(combo % 10);*/
			
			while (seperatedScore.length < 3) {
				seperatedScore.unshift("0");
			}

			for (i in 0...seperatedScore.length) {
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(validUIStyle ? currentUIStyle.numbers[Std.parseInt(seperatedScore[i])] : '${pixelShitPart1}num${seperatedScore[i] + pixelShitPart2}'));
				numScore.screenCenter();
				numScore.x = coolText.x + ((validUIStyle ? currentUIStyle.comboSpacing : 43) * i) - 90;
				numScore.y += 80;

				if (validUIStyle) {
					numScore.scale.x = currentUIStyle.comboScale;
					numScore.scale.y = currentUIStyle.comboScale;
					numScore.antialiasing = currentUIStyle.antialias;
				} else {
					if (!curStage.startsWith('school')) {
						numScore.antialiasing = true;
						numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					} else {
						numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
					}
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				ratingsGroup.add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween) {
						ratingsGroup.remove(numScore, true);
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
		}
		/* 
		trace(combo);
		trace(seperatedScore);
		*/

		//coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				//coolText.destroy();
				comboSpr.destroy();
				//rating.destroy();
				//ratingsGroup.remove(rating, true);
				ratingsGroup.remove(comboSpr, true);
			},
			startDelay: Conductor.crochet * 0.001
		});

		//curSection += 1;
		
		if (ratingsGroup.length > 60) {
			var clears:Array<FlxSprite> = ratingsGroup.members.splice(0, 30 - ratingsGroup.length);
			ratingsGroup.length = ratingsGroup.members.length;
			while (clears.length > 0) {
				var destroyNext = clears.pop();
				FlxTween.cancelTweensOf(destroyNext);
				destroyNext.destroy();
			}
		}

		return daRating;
	}

	//New input system that's very cool (not the week 7 one actually.)
	public inline function getNotesInRange(hold:Bool, release:Bool) {
		var possibleNotes = new Array<Note>();
		notes.forEachAlive(function(daNote:Note) {
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && (daNote.isSustainNote == hold && daNote.isReleaseNote == release))
				possibleNotes.push(daNote);
		});
		possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		return possibleNotes;
	}

	public inline function filterNotesInRange(hold:Bool, release:Bool, func:Note->Bool) {
		return getNotesInRange(hold, release).filter(func);
	}

	public function getNoteDataFromArray(arr:Array<Note>, noteData:Int) {
		var i = 0;
		while (true) {
			if (arr[i].noteData == noteData)
				return arr[i];
			if (i++ == arr.length)
				return null;
		}
	}

	public var openHopoStuff:NoteRow = {
		time: -8000,
		notes: [],
		releaseNotes: []
	};

	inline function preOpenHopoCheck(note:Note) {
		return openHopoStuff.time - note.strumTime < (Conductor.stepCrochet * 0.02);
	}

	//and then the actual key event stuff
	public function eventKeyPressed(evnt:KeyboardEvent) {
		if (inCutscene || boyfriend.stunned || !generatedMusic)
			return;
		if (!curManiaInfo.control_any.contains(evnt.keyCode)) {
			//Guitar Notes
			if (Options.uiControls.get("gtstrum").contains(evnt.keyCode)) {
				var possibleNotes = filterNotesInRange(false, false, function(note) {
					return note.getNoteTypeData().guitar;
				});
				if (possibleNotes.length == 0)
					return;
				//Hit an open note
				if (possibleNotes[0].getNoteTypeData().guitarOpen) {
					if (!FlxG.keys.anyPressed(curManiaInfo.control_any))
						goodNoteHit(possibleNotes[0]);
					return;
				}
				//Hit standard guitar notes
				for (i in 0...curManiaInfo.control_set.length) {
					if (FlxG.keys.anyPressed(curManiaInfo.control_set[i])) {
						goodExistsNoteHit(getNoteDataFromArray(possibleNotes, i));
					}
				}
			}
			return;
		}
		var possibleNotes = filterNotesInRange(false, false, function(note) {
			var ntd = note.getNoteTypeData();
			return !ntd.guitar || (ntd.guitarHopo && !ntd.guitarOpen && combo != 0);
		});
		if (possibleNotes.length == 0) {
			if ((!Options.instance.ghostTapping) || (Options.instance.tappingHorizontal && (songHits != 0 && Math.abs(Conductor.songPosition - lastHitNoteTime) <= Conductor.horizontalThing))) {
				for (i in 0...curManiaInfo.control_set.length) {
					if (curManiaInfo.control_set[i].contains(evnt.keyCode)) {
						noteMiss(i);
						return;
					}
				}
				noteMiss(0); //you shouldn't get here tho
			}
			return;
		}
		//Note rows for open hopos
		if (!preOpenHopoCheck(possibleNotes[0])) {
			openHopoStuff.time = possibleNotes[0].strumTime;
			openHopoStuff.notes = new Array<Int>();
			openHopoStuff.releaseNotes = new Array<Int>();
			for (note in possibleNotes.filter(preOpenHopoCheck)) {
				openHopoStuff.notes.push(note.noteData);
			}
		}
		//Finally hit a note
		for (i in 0...curManiaInfo.control_set.length) {
			if (curManiaInfo.control_set[i].contains(evnt.keyCode)) {
				playerStrums.strumNotes[i].isHeld = true;
				if (goodExistsNoteHit(getNoteDataFromArray(possibleNotes, i))) {
					openHopoStuff.notes.remove(i);
					openHopoStuff.releaseNotes.push(i);
				} else if ((!Options.instance.ghostTapping) || (Options.instance.tappingHorizontal && (songHits != 0 && Math.abs(Conductor.songPosition - lastHitNoteTime) <= Conductor.horizontalThing))) {
					noteMiss(i);
				}
				return;
			}
		}
	}

	public function eventKeyReleased(evnt:KeyboardEvent) {
		if (inCutscene || boyfriend.stunned || !generatedMusic)
			return;
		if (!curManiaInfo.control_any.contains(evnt.keyCode)) {
			if (Options.uiControls.get("gtstrum").contains(evnt.keyCode)) {
				//Hit an Open Release Note
				//This is new so i can decide what they do
				var possibleNotes = getNotesInRange(false, true);
				if (possibleNotes.length == 0)
					return;
				var ntd = possibleNotes[0].getNoteTypeData();
				if (ntd.guitar && ntd.guitarOpen)
					goodNoteHit(possibleNotes[0]);
			}
			return;
		}
		var possibleNotes = filterNotesInRange(false, true, function(note) {
			var ntd = note.getNoteTypeData();
			return (!ntd.guitarHopo && !ntd.guitarOpen);
		});
		//Finally hit a note
		var yeezys = openHopoStuff.releaseNotes.length != 0;
		for (i in 0...curManiaInfo.control_set.length) {
			if (curManiaInfo.control_set[i].contains(evnt.keyCode)) {
				openHopoStuff.releaseNotes.remove(i);
				if (goodExistsNoteHit(getNoteDataFromArray(possibleNotes, i))) {
					playerStrums.strumNotes[i].isHeld = false;
					return;
				}
				playerStrums.strumNotes[i].isHeld = false;
			}
		}
		//Hit open hopo note
		if (yeezys && openHopoStuff.releaseNotes.length == 0) {
			goodExistsNoteHit(filterNotesInRange(false, false, function(note) {
				var ntd = note.getNoteTypeData();
				return (ntd.guitarHopo && ntd.guitarOpen && combo != 0);
			})[0]); //this statement looks funny
		}
	}

	public function keyHolds() {
		var gtHold = !FlxG.keys.anyPressed(Options.uiControls.get("gtstrum"));
		if (inCutscene || boyfriend.stunned || !generatedMusic || (!FlxG.keys.anyPressed(curManiaInfo.control_any) && gtHold))
			return;
		var possibleNotes = filterNotesInRange(true, false, function(note) {
			return note.isSustainNote;
		});
		if (possibleNotes.length == 0)
			return;
		var keyHolding = new Array<Bool>();
		for (i in curManiaInfo.control_set) {
			keyHolding.push(FlxG.keys.anyPressed(i));
		}
		for (note in possibleNotes) {
			if (note.getNoteTypeData().guitarOpen) {
				if (gtHold)
					goodNoteHit(note);
			} else if (keyHolding[note.noteData]) {
				goodNoteHit(note);
			}
		}
	}

	//old input system
	private function keyShit():Void {
		if (Options.instance.botplay)
			return;

		var controlArray = new Array<Bool>();
		var keyHolding = new Array<Bool>();
		var keyReleasing = new Array<Bool>();
		for (i in curManiaInfo.control_set) {
			controlArray.push(FlxG.keys.anyJustPressed(i));
			keyHolding.push(FlxG.keys.anyPressed(i));
			keyReleasing.push(FlxG.keys.anyJustReleased(i));
		}
		var keyHoldingAny = FlxG.keys.anyPressed(curManiaInfo.control_any);
		
		var hitNotes = 0;
		//var possibleGuitarNotes:Array<Note> = [];

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic) {
			//Standard hit notes
			if ((FlxG.keys.anyJustPressed(curManiaInfo.control_any) && (!Options.instance.playstate_guitar && allowGameplayChanges))) {
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = [];

				//var ignoreList:Array<Int> = [];

				notes.forEachAlive(function(daNote:Note) {
					var noteTypeData = daNote.getNoteTypeData();
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && (!noteTypeData.guitar || (noteTypeData.guitarHopo && combo > 0)) && !daNote.isReleaseNote) {
						possibleNotes.push(daNote);

						//ignoreList.push(daNote.noteData);
					}
				});
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				//even i can make a input system
				for (daNote in possibleNotes) {
					if (controlArray[daNote.noteData]) {
						hitNotes += 1;
						controlArray[daNote.noteData] = false;
						goodNoteHit(daNote);
					}
				}
				for (k in 0...controlArray.length) {
					if (controlArray[k] && (!(Options.instance.ghostTapping) || (((hitNotes + possibleNotes.length > 0) || (songHits > 0 && Math.abs(Conductor.songPosition - lastHitNoteTime) <= Conductor.horizontalThing)) && Options.instance.tappingHorizontal))) {
						noteMiss(k);
					}
				}
			}

			//Guitar notes
			if (controls.GTSTRUM) {
				if (keyHoldingAny) {
					var possibleNotes:Array<Note> = [];
					var possibleNoteDatas:Array<Bool> = [];

					notes.forEachAlive(function(daNote:Note) {
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && ((Options.instance.playstate_guitar && allowGameplayChanges) || daNote.getNoteTypeData().guitar) && !daNote.isReleaseNote) {
							possibleNotes.push(daNote);
							possibleNoteDatas[daNote.noteData] = true;
						}
					});
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
					//even i can make a input system
					for (daNote in possibleNotes) {
						if (keyHolding[daNote.noteData] && possibleNoteDatas[daNote.noteData] == true) {
							hitNotes += 1;
							possibleNoteDatas[daNote.noteData] = false;
							goodNoteHit(daNote);
						}
					}
					for (k in 0...controlArray.length) {
						if (possibleNoteDatas[k] && (!(Options.instance.ghostTapping) || (((hitNotes + possibleNotes.length > 0) || (songHits > 0 && Math.abs(Conductor.songPosition - lastHitNoteTime) <= Conductor.horizontalThing)) && Options.instance.tappingHorizontal))) {
							noteMiss(k);
						}
					}
				} else { //Open notes
					var possibleNote:Null<Note> = null;

					notes.forEachAlive(function(daNote:Note) {
						if ((possibleNote == null || (daNote.strumTime < possibleNote.strumTime)) && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && ((Options.instance.playstate_guitar && allowGameplayChanges) || daNote.getNoteTypeData().guitarOpen) && !daNote.isReleaseNote) {
							possibleNote = daNote;
						}
					});
					//even i can make a input system
					if (possibleNote != null) {
						hitNotes += 1;
						goodNoteHit(possibleNote);
					} else if (!Options.instance.ghostTapping) {
						noteMiss(0);
					}
				}
			}

			//Release notes
			if (FlxG.keys.anyJustReleased(curManiaInfo.control_any)) {
				var possibleNotes:Array<Note> = [];
				var possibleNoteDatas:Array<Bool> = [];

				notes.forEachAlive(function(daNote:Note) {
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.isReleaseNote) {
						possibleNotes.push(daNote);
						possibleNoteDatas[daNote.noteData] = true;
					}
				});
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
				//even i can make a input system
				for (daNote in possibleNotes) {
					if (keyReleasing[daNote.noteData] && possibleNoteDatas[daNote.noteData] == true) {
						hitNotes += 1;
						possibleNoteDatas[daNote.noteData] = false;
						goodNoteHit(daNote);
					}
				}
				for (k in 0...controlArray.length) {
					if (possibleNoteDatas[k] && (!(Options.instance.ghostTapping) || (((hitNotes + possibleNotes.length > 0) || (songHits > 0 && Math.abs(Conductor.songPosition - lastHitNoteTime) <= Conductor.horizontalThing)) && Options.instance.tappingHorizontal))) {
						noteMiss(k);
					}
				}
			}

			//Hold notes
			if (FlxG.keys.anyPressed(curManiaInfo.control_any)) {
				notes.forEachAlive(function(daNote:Note) {
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote) {
						if (daNote.getNoteTypeData().guitarOpen) {
							if (FlxG.keys.anyPressed(Options.uiControls.get("gtstrum")))
								goodNoteHit(daNote);
						} else if (keyHolding[daNote.noteData]) {
							goodNoteHit(daNote);
						}
					}
				});
			}
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !FlxG.keys.anyPressed(curManiaInfo.control_any)) {
			if (boyfriend.animStartsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.playAnim('idle');
			}
		}
		
		for (i in 0...playerStrums.members.length) {
			var spr = playerStrums.members[i];
			var press = FlxG.keys.anyJustPressed(curManiaInfo.control_set[i]);
			var rel = FlxG.keys.anyJustReleased(curManiaInfo.control_set[i]);
			
			if (press)
				spr.isHeld = true;
			if (rel)
				spr.isHeld = false;
		};
	}

	function noteMiss(direction:Int = 1, ?note:Note):Void {
		if (!boyfriend.stunned) {
			if (starActive) {
				//Idk how i should star power lol! So im doing it like this (For now at least)
				starActive = false;
				songScore -= 5000;

				if (Options.noteMissAction_MissSound[Options.instance.noteMissAction])
					FlxG.sound.play(Paths.soundRandom('badnoise', 1, 3), FlxG.random.float(0.15, 0.25));
			}
			var validNote = note != null;
			var noteTypeData = validNote ? note.getNoteTypeData() : Note.SwagNoteType.loadNoteType(Note.SwagNoteType.normalNote, PlayState.modName);
			health += noteTypeData.healthMiss;
			if (combo > 5)
				gf.playAvailableAnim(Options.instance.playstate_opponentmode ? ["sad_opponent", "sad"] : ["sad"]);
			combo = 0;

			songScore -= 10;
			songMisses += 1;
			if (validNote)
				if (!note.isSustainNote) {
					songHittableMisses += 1;
				if (noteTypeData.bob != 0 && noteTypeData.glitch)
					bobBleeds.push({
						timeLeft: 3,
						mult: noteTypeData.bob * 1.5,
						maxHealth: 2 * noteTypeData.healthMaxMult
					});
			}

			if (songFC != 4)
				songFC = songMisses > 9 ? 4 : 3;

			if (Options.noteMissAction_MissSound[Options.instance.noteMissAction])
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/
			
			animateForNote(note, true, direction, true);
		}
	}

	public inline function goodExistsNoteHit(note:Null<Note>) {
		if (note != null) {
			goodNoteHit(note);
			return true;
		}
		return false;
	}

	public function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			var noteTypeData = note.getNoteTypeData();
			var rating = "sick";
			if (!note.isSustainNote) {
				rating = popUpScore(note);
				combo += 1;
				songHits += 1;
				if (combo > maxCombo)
					maxCombo = combo;
				lastHitNoteTime = note.strumTime;
				
				/*notes.forEachAlive(function(daNote:Note) {
					if (daNote.noteData == note.noteData && note != daNote && daNote.canBeHit && daNote.mustPress && Math.abs(daNote.strumTime - note.strumTime) < 10) {
						trace("Found stacked note at " + daNote.strumTime);
						goodNoteHit(daNote); //Prevent stacked notes
					}
				});*/
			}
			
			if (health < maxHealth * noteTypeData.healthMaxMult) {
				if (note.isSustainNote) {
					health = Math.min(health + noteTypeData.healthHold, maxHealth * noteTypeData.healthMaxMult);
				} else {
					health = Math.min(health + switch(rating) {
						case "sick":
							noteTypeData.healthHitSick;
						case "good":
							noteTypeData.healthHitGood;
						case "bad":
							noteTypeData.healthHitBad;
						default: 
							noteTypeData.healthHitShit;
					}, maxHealth * noteTypeData.healthMaxMult); //peculiar Haxe moment
				}
				if (noteTypeData.bob != 0 && !noteTypeData.glitch)
					bobBleeds.push({
						timeLeft: 3,
						mult: noteTypeData.bob * 1.5,
						maxHealth: 2 * noteTypeData.healthMaxMult
					});
			}
			
			animateForNote(note);

			playerStrums.members[note.noteData].playAnim('confirm', true);

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function opponentNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			if (SONG.song != 'Tutorial')
				camZooming = true;

			animateForNote(note);

			if (health > SONG.healthDrainMin) {
				health = Math.max(health - SONG.healthDrain, SONG.healthDrainMin);
			}

			var spr = strumLines.members[note.strumLineNum].members[note.noteData];
			if (spr != null) {
				spr.playAnim('confirm', true);
				spr.returnTime = (Conductor.crochet / 3750) + 0.1;
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			
			#if VMAN_DEMO
			var crochetThing = Conductor.crochet / 1000;
			if (curSong == "vasegames") {
				var intensity = 1;
				//if (!Options.cameraShake) {
				//	intensity = 0.2; //shut your damn up
				//}
				camGame.shake(0.025 * intensity, crochetThing);
				camHUD.shake(0.01 * intensity, crochetThing);
			}
			#end
		}
	}

	function animateForNote(?note:Note, ?isBoyfriend:Bool = true, ?noteData:Int = 0, ?isMiss:Bool = false):Void {
		if (note != null) {
			isBoyfriend = note.mustPress;
			if (allowGameplayChanges) {
				if (Options.instance.playstate_bothside)
					isBoyfriend = (note.noteData >= curManiaInfo.keys / 2) == Options.instance.playstate_opponentmode;
				else if (Options.instance.playstate_opponentmode)
					isBoyfriend = !isBoyfriend;
			}
		}
		var noteTypeData = note != null ? note.getNoteTypeData() : Note.SwagNoteType.loadNoteType("Normal Note", modName);
		if (noteTypeData.noAnim)
			return;
		var char:Character = (note != null && note.charNum != -1) ? Character.activeArray[note.charNum] : (noteTypeData.charNums != null ? Character.activeArray[noteTypeData.charNums[0]] : (isBoyfriend ? boyfriend : dad));
		var color = (note.strumLineNum < 0 ? funnyManias[-1 - note.strumLineNum] : curManiaInfo).arrows[note == null ? noteData : note.noteData];
		var colorNote = "sing" + color.toUpperCase();
		if (isMiss)
			return char.playAvailableAnim(['${colorNote}miss', 'sing${ManiaInfo.Dir[color]}miss'], true);
		char.holdTimer = 0;
		if (note.isSustainNote && char.animNoSustain)
			return;
		var postfix = (noteTypeData.animPostfix != "-alt" && (!isBoyfriend && SONG.notes[currentSection] != null && SONG.notes[currentSection].altAnim)) ? '-alt' : "";
		if (noteTypeData.animPostfix != null)
			postfix += noteTypeData.animPostfix;
		var defaultAnim = 'sing${ManiaInfo.Dir[color]}';
		if (noteTypeData.animReplace == null) {
			var anim = defaultAnim + postfix;
			var colorAnim = colorNote + postfix;
			return char.playAvailableAnim(note.isSustainNote ? 
				//Hold notes
				['${colorAnim}-hold', colorAnim, anim+'-hold', anim, defaultAnim+'-hold', defaultAnim] :
				//Non holds
				[colorAnim, anim, colorNote, defaultAnim],
			true);
		}
		var anim = noteTypeData.animReplace + postfix;
		return char.playAvailableAnim(note.isSustainNote ? 
			//Hold notes
			[anim+'-hold', anim, defaultAnim+'-hold', defaultAnim] :
			//Non holds
			[colorNote, defaultAnim],
		true);
	}

	//inline function getFastCar():SpriteVMan {
	//	return currentStage.elementsNamed.get("fastCar");
	//}

	function resetFastCar():Void {
		//var fastCar = getFastCar();
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive() {
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		//var fastCar = getFastCar();
		fastCar.velocity.x = (FlxG.random.int(510, 660) / FlxG.elapsed);
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	//inline function getTrain():SpriteVMan {
	//	return currentStage.elementsNamed.get("phillyTrain");
	//}

	function trainStart():Void {
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	function updateTrainPos():Void {
		if (trainSound.time >= 4700) {
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving) {
			phillyTrain.x -= 400;

			if (!trainFinishing && phillyTrain.x < -2000) {
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
				return;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void {
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void {
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		//halloweenBG.animation.play('lightning');
		currentStage.playAnim("lightning");

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit() {
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20) {
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2) {
			// dad.dance();
		}
	}

	override function beatHit() {
		super.beatHit();

		//if (generatedMusic) {
			//notes.sort(FlxSort.byY, Options.instance.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING); //I think we *don't* need this
		//}

		var newSection = Math.floor(curStep / 16);
		if (newSection != currentSection) {
			currentSection = newSection;
			trace("now in section " + currentSection);
		}
		var thisSection = SONG.notes[currentSection];

		if (thisSection != null) {
			if (thisSection.changeBPM) {
				Conductor.changeBPM(thisSection.bpm);
				FlxG.log.add('CHANGED BPM! to ' + thisSection.bpm);
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			//if (SONG.notes[currentSection].mustHitSection)
		}
		dad.dance();
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (zoomBeats != 0 && camZooming && FlxG.camera.zoom < 1.35 && curBeat % zoomBeats == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.scale.set(iconP1.scale.x * 1.2, iconP1.scale.y * 1.2);
		iconP2.scale.set(iconP2.scale.x * 1.2, iconP2.scale.y * 1.2);

		if (curBeat % gfSpeed == 0) {
			gf.dance();
		}

		if (!boyfriend.animStartsWith("sing")) {
			boyfriend.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'bopeebo') {
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && curSong == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48) {
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		if (Character.activeArray.length > 3) {
			var i = 3;
			while (i < Character.activeArray.length) {
				Character.activeArray[i++].dance();
			}
		}
		
		currentStage.beatHit();

		switch (curStage) {
			case 'school':
				bgGirls.dance();

			case 'limo':
				grpLimoDancers.forEachAlive(function(dancer:BackgroundDancer) {
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0) {
					phillyCityLights.forEach(function(light:FlxSprite) {
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
			lightningStrikeShit();
		}
	}

	public function setStage(stage:String):Void {
		//todo: this isnt finished yet
		curStage = stage;
		FlxG.log.add('SET STAGE TO ' + stage);
	}

	public function runEvent(event:Array<Dynamic>) {
		switch(event[0]) {
			case "Hey":
				if (event[1] == true) {
					boyfriend.playAnim('hey', true);
				}
				if (event[2] == true) {
					gf.playAnim('cheer', true);
				}
			case "Scared":
				if (event[1] == true) {
					boyfriend.playAnim('scared', true);
				}
				if (event[2] == true) {
					gf.playAnim('scared', true);
				}
			case "Play Animation":
				var charNum = Std.parseInt(event[1]);
				if (charNum == null) {
					charNum = Character.findSuitableCharacterNum(event[1], 1);
				}
				Character.activeArray[charNum].playAnim(event[2], true);
			case "Zoom Hit":
				FlxG.camera.zoom += event[1];
				camHUD.zoom += event[2];
			case "Set GF Speed":
				gfSpeed = event[1];
			case "Voices Volume 0":
				vocals.volume = 0;
			case "Set Zoom Beats":
				zoomBeats = event[1];
			case "Camera Shake":
				camShakes.push({
					timemult: 1 / event[1],
					prog: 0,
					gameMoveX: event[2],
					gameMoveY: event[3],
					classic: event[4] == true
				});
			case "Cinematic Bars":
				var halfy = FlxG.height / 2;
				var opo = [-halfy, FlxG.height];
				var move = [-halfy * event[1], halfy * event[1]];
				if (cinematicBars == null) {
					cinematicBars = new FlxTypedGroup<FlxSprite>();
					for (i in 0...2) {
						cinematicBars.add(new FlxSprite(0, opo[i]).makeGraphic(Math.ceil(FlxG.width / 16), Math.ceil(halfy / 4), FlxColor.BLACK));
						cinematicBars.members[i].scale.set(16, 4);
					}
					insert(0, cinematicBars);
					cinematicBars.cameras = [camHUD];
				}
				for (i in 0...2) {
					FlxTween.cancelTweensOf(cinematicBars.members[i], ["y"]);
					FlxTween.tween(cinematicBars.members[i], {y: opo[i] + move[i]}, event[2], {ease:FlxEase.cubeOut});
				}
			case "Star Power State":
				starActive = event[1];
			case "Psych Engine Event": //event from an imported chart from Psych Engine
				switch(event[1]) {
					//case "Dadbattle Spotlight" | "Philly Glow" | "Kill Henchmen" | "Trigger BG Ghouls":
						//probably wont be implemented
					case "Hey!":
						var bf:Bool = true;
						var gf:Bool = true;
						switch(event[2].toLowerCase().trim()) {
							case "bf" | "boyfriend" | "0":
								gf = false;
							case "gf" | "girlfriend" | "1":
								bf = false;
						}
						runEvent(["Hey", bf, gf]);
					case "Add Camera Zoom":
						var cz = Std.parseFloat(event[2]);
						var hz = Std.parseFloat(event[3]);
						runEvent(["Zoom Hit", Math.isNaN(cz) ? 0.015 : cz, Math.isNaN(hz) ? 0.03 : hz]);
					case "Set Property":
						switch(event[2]) {
							case "defaultCamZoom":
								defaultCamZoom = Std.parseFloat(event[3]);
							default:
								trace("Mimic psych event Set Property can't handle "+event[2]);
						}
					case "Play Animation":
						var char:Int = 1;
						switch(event[2].toLowerCase().trim()) {
							case "bf" | "boyfriend":
								char = 0;
							case "gf" | "girlfriend":
								char = 2;
							default:
								var numThing = Std.parseInt(event[2]);
								if (numThing != null) {
									switch(numThing) {
										case 1:
											char = 0;
										case 2:
											char = 2;
									}
								}
						}
						runEvent(["Play Animation", char, event[3]]);
					case "BG Freaks Expression":
						if (bgGirls != null) {
							bgGirls.swapDanceType();
						}
					default:
						trace("Dunno how to handle psych event "+event[1]+". This might be a bad thing, but it isn't always!");
				}
		}
	}

	public function addBleed(time:Float, health:Float, ?maxHealth:Float = 2, ?replaceSame:Bool = false) {
		if (replaceSame) {
			for (thing in bobBleeds) {
				if (thing.mult == health && thing.maxHealth == maxHealth) {
					thing.timeLeft = time;
					return false;
				}
			}
		}
		bobBleeds.push({
			timeLeft: time,
			mult: health,
			maxHealth: maxHealth
		});
		return true;
	}

	//Really long songs
	var songPositionOffset:Float = 0;
	var hasNextSongAudio:Bool = false;
	var curSongAudioPart:Int = 0;
	var nextSongAudio:FlxSound;
	var nextSongAudioVoices:FlxSound;

	function checkNextSongAudio() {
		var nextPart = curSongAudioPart + 1;
		hasNextSongAudio = FileSystem.exists(Paths.getSongPathThing(SONG.song, 'part${nextPart}/${instName}'));
		if (hasNextSongAudio) {
			nextSongAudio = new FlxSound().loadEmbedded(Paths.getSongPathThing(SONG.song, 'part${nextPart}/${instName}'));
			if (FileSystem.exists(Paths.getSongPathThing(SONG.song, 'part${nextPart}/${voicesName}'))) {
				nextSongAudioVoices = new FlxSound().loadEmbedded(Paths.getSongPathThing(SONG.song, 'part${nextPart}/${voicesName}'));
			} else {
				nextSongAudioVoices = new FlxSound();
			}
		}
	}
}
