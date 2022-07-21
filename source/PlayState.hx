package;

import CoolUtil;
import ManiaInfo;
import Note.SwagUIStyle;
import Section.SwagSection;
import Song.SwagSong;
import Stage;
import WiggleEffect.WiggleEffectType;
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
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import sys.FileSystem;

using StringTools;
#if desktop
import Discord.DiscordClient;
#end
//import flixel.text.FlxTextBorderStyle;


class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:String = "week1";
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;
	public var stageCharacters:Array<Character>;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	public var camFollow:FlxObject;
	public var camFollowPos:FlxObject;
	public var camFollowOffset:FlxObject;
	public var camFollowSpeed:Float = 1;
	public var camOffset:FlxPoint = new FlxPoint(0, 0);
	public var camIsFollowing:Bool = true;

	public static var prevCamFollow:FlxObject;

	public var strumLineNotes = new Array<StrumNote>();
	public var strumLines:FlxTypedGroup<StrumLine>;
	public var playerStrums = new StrumLine();
	public var opponentStrums = new StrumLine();

	private var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var maxHealth:Float = 2;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueVMan:DialogueBoxVMan;

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundDancer;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	public var songScore:Int = 0;
	//var scoreTxt:FlxText;
	
	public var songMisses:Int = 0;
	public var songHits:Int = 0;
	
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;
	
	public var lastHitNoteTime:Float = 0;

	#if desktop
	// Discord RPC variables
	public var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	public var songLength:Float = 0;
	public var storyDifficultyText:String = "";
	
	public static var curManiaInfo:SwagMania = ManiaInfo.GetManiaInfo("4k");
	public static var instance:PlayState;
	public static var modName:String = "";
	
	public var hudThings = new FlxTypedGroup<HudThing>();
	
	public var currentSection:Int; //todo: So im making variable length sections (for example: with non 4/4 time signatures)
	public var focusCharacter:Character;
	public var currentStageFront:FlxTypedGroup<FlxSprite>;
	public var currentStageBack:FlxTypedGroup<FlxSprite>;
	public var currentStage:Stage;

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	var usedBotplay = false;

	var currentManiaPart:Int = 0;
	var currentManiaPartName:Array<String> = [];
	var maniaPartArr:Array<Array<String>> = [];

	public var currentUIStyle:SwagUIStyle;
	
	//Scripting funny lol
	//The only hscript your getting is me porting the basegame update's hscript support
	//todo: add the scripting

	override public function create()
	{
		instance = this;
		
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

		currentUIStyle = SwagUIStyle.loadUIStyle(SONG.uiStyle);
		var validUIStyle = currentUIStyle != null;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		
		var sn:String = Highscore.formatSong(SONG.song);
		switch (sn)
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up\nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
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
		if (FileSystem.exists(dialoguePath)) {
			trace('found start dialogue');
			dialogueVMan = new DialogueBoxVMan(dialoguePath);
		} else {
			trace('no start dialogue (it would be ' + dialoguePath + ')');
		}

		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyString();

		#if desktop
		//iconRPC = dad.curCharacter;
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
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
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
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
		
		var customStageCharPos:Array<Array<Float>> = null;

		switch (curStage)
		{
			case 'spooky': 
			{
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = Paths.getSparrowAtlas('halloween_bg');
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);

				isHalloween = true;
			}
		    case 'philly': 
            {
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
			case 'limo':
			{
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
			case 'mall':
			{
				defaultCamZoom = 0.80;

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('christmas/santa');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);
			}
			case 'mallEvil':
			{
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
				evilSnow.antialiasing = true;
				add(evilSnow);
			}
			case 'school':
			{
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

				bgGirls = new BackgroundDancer(-100, 190, "bgFreaks");
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (SONG.actions.indexOf("bgFreaksAngry") > -1) {
					bgGirls.getScared();
				}

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			}
			case 'schoolEvil':
			{
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
			/*case 'stage':
			{
				defaultCamZoom = 0.9;
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stage/stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stage/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stage/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				add(stageCurtains);
			}*/
			default: //load custom stage
			{
				trace('loading custom stage '+curStage);
				currentStage = new Stage(curStage, modName);
				currentStageBack = currentStage.elementsBack;
				currentStageFront = currentStage.elementsFront;
				add(currentStageBack);
				add(currentStageFront);
				defaultCamZoom = currentStage.defaultCamZoom;
				if (defaultCamZoom == 0) {
					trace("something went wrong with the stage loading");
					defaultCamZoom = 0.9;
				}
				customStageCharPos = currentStage.charPosition;
			}
		}

		var gfVersion:String = 'gf';
		
		if (SONG.gfVersion.length > 0) {
			gfVersion = SONG.gfVersion;
		} else {
			switch (curStage)
			{
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

		dad = new Character(100, 100, SONG.player2, false, modName);
		
		boyfriend = new Boyfriend(770, 100, SONG.player1, modName);

		gf = new Character(400, 130, gfVersion, false, modName);
		gf.scrollFactor.set(0.95, 0.95);
		
		if (customStageCharPos != null) {
			for (i in 0...Character.activeArray.length) {
				if (customStageCharPos.length <= i) {
					break;
				}
				var char:Character = Character.activeArray[i];
				char.x = customStageCharPos[i][0];
				char.y = customStageCharPos[i][1];
			}
		}
		
		boyfriend.applyPositionOffset();
		
		dad.applyPositionOffset();
		
		gf.applyPositionOffset();

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
			case 'senpai' | 'senpai-angry' | 'spirit':
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);
			case 'mall':
				boyfriend.x += 200;
			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		if (SONG.actions.indexOf("spookyEnemy") != -1) {
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			// evilTrail.changeValuesEnabled(false, false, false, false);
			// evilTrail.changeGraphic()
			add(evilTrail);
			// evilTrail.scrollFactor.set(1.1, 1.1);
		}
		if (SONG.actions.indexOf("spookyPlayer") != -1) {
			var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
			add(evilTrail);
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);
		
		if (SONG.moreCharacters != null && SONG.moreCharacters.length > 0) {
			trace('Adding ${SONG.moreCharacters.length} extra characters');
			for (i in SONG.moreCharacters) {
				var position = 
				add(new Character(0, 0, i, false, modName)); //these are also automatically put into Character.activeArray, so it's ok that they're not assigned to variables here
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
		
		if (Options.downScroll) {
			strumLine.y = FlxG.height - 100;
		}

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
			camFollow = prevCamFollow;
			camFollowPos = prevCamFollow;
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
		if (Options.downScroll) {
			healthBarBG.y = FlxG.height * 0.1;
		}
		add(healthBarBG);

		var healthBarSides:Array<Float> = validUIStyle ? currentUIStyle.healthBarSides : [4, 4, 4, 4];
		healthBarSides[3] += healthBarSides[1];
		healthBarSides[2] += healthBarSides[0];

		healthBar = new FlxBar(healthBarBG.x + healthBarSides[0], healthBarBG.y + healthBarSides[1], RIGHT_TO_LEFT, Std.int(healthBarBG.width - healthBarSides[2]), Std.int(healthBarBG.height - healthBarSides[3]), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		//healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.createFilledBar(dad.healthBarColor, boyfriend.healthBarColor);
		// healthBar
		add(healthBar);
		
		var hudThingLists:Array<Array<String>>;
		if (Std.isOfType(this, PlayStateOffsetCalibrate)) {
			hudThingLists = [
				["hits", "offset_avg", "offset_min", "offset_max", "offset_range"],
				["song"].concat(["engine"]),
				["hits", "misses", "totalnotes", "health"]
			];
		} else {
			hudThingLists = [
				["score", "misses", "fc", "accRating", "accSimple", "health"],
				["song", "difficulty"].concat(["engine"]),
				["hits", "sicks", "goods", "bads", "shits", "misses", "totalnotes"]
			];
		}
		hudThings.add(new HudThing(healthBarBG.x, healthBarBG.y + 30, hudThingLists[0]));
		hudThings.add(new HudThing(2, FlxG.height - 24, hudThingLists[1]));
		hudThings.add(new HudThing(2, (FlxG.height / 2) - 100, hudThingLists[2], true));

		iconP1 = new HealthIcon(boyfriend.healthIcon, true, modName);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false, modName);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		
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
		startingSong = true;
		if (SONG.actions.indexOf("loadLuaTest") > -1) {
			luaScripts.push(new LuaScript(Paths.txt('${Highscore.formatSong(SONG.song)}/test.lua'), this));
		}

		if (isStoryMode) {
			if (SONG.actions.indexOf("winterHorrorlandIntro") > -1) {
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
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
			}
			switch (curSong.toLowerCase())
			{
				case 'senpai' | 'thorns':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				default:
					if (SONG.actions.indexOf("winterHorrorlandIntro") <= -1) {
						startCountdown();
					}
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}
		
		stageCharacters = Character.activeArray;

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
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

		if (curSong.toLowerCase() == 'senpai') {
			add(black);
		}

		if (SONG.song.toLowerCase() == 'thorns') {
			add(red);
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer) {
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueVMan != null) {
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns') {
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
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		playerStrums.destroy();
		opponentStrums.destroy();
		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
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
				for (value in introAssets.keys())
				{
					if (value == curStage)
					{
						introAlts = introAssets.get(value);
						introAltsSounds = ["intro3-pixel", "intro2-pixel", "intro1-pixel", "introGo-pixel"];
						scale = daPixelZoom;
					}
				}
			}

			switch (swagCounter)

			{
				case 0:
					/*if (!Options.silentCountdown)
						FlxG.sound.play(Paths.sound('intro3'), 0.6);*/
					playCountdownSprite(introAlts[0], scale, introAltsSounds[0]);
				case 1:
					/*var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					if (!Options.silentCountdown)
						FlxG.sound.play(Paths.sound('intro2'), 0.6);*/
					playCountdownSprite(introAlts[1], scale, introAltsSounds[1]);
				case 2:
					/*var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					if (!Options.silentCountdown)
						FlxG.sound.play(Paths.sound('intro1'), 0.6);*/
					playCountdownSprite(introAlts[2], scale, introAltsSounds[2]);
				case 3:
					/*var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					if (!Options.silentCountdown)
						FlxG.sound.play(Paths.sound('introGo'), 0.6);*/
					playCountdownSprite(introAlts[3], scale, introAltsSounds[3]);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
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
			onComplete: function(twn:FlxTween)
			{
				ready.destroy();
			}
		});
		ready.visible = path != "";
		if (!Options.silentCountdown)
			FlxG.sound.play(Paths.sound(sound), 0.6);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		songLength = FlxG.sound.music.length;
		#if desktop
		// Song duration in a float, useful for the time left feature

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresenceSimple("playing");
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		//var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % curManiaInfo.keys);
				if (daNoteData < 0) {
					trace('Bad note data ${daNoteData} at ${daStrumTime}, skipping');
					continue;
				}

				var gottaHitNote:Bool = (section.mustHitSection) != (songNotes[1] >= curManiaInfo.keys);

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.mustPress = gottaHitNote;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function generateStaticArrows(player:Int) {
		var xPos:Float = 0;
		if (player == 1 || player == 0) {
			if (Options.middleScroll) {
				xPos = player == 1 ? FlxG.width / 2 : FlxG.width * 8;
			} else {
				xPos = player == 1 ? FlxG.width * 0.75 : FlxG.width * 0.25;
			}
		}
		var thing:StrumLine = new StrumLine(curManiaInfo, xPos, strumLine.y);

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
		return thing;
	}

	function tweenCamIn():Void {
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
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
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void {
		#if desktop
		if (health > 0 && !paused) {
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float) {
		#if !debug
		perfectMode = false;
		#end

		/*if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}*/

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
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

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / idfk chance for Gitaroo Man easter egg
			/*if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else*/
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (healthBar.percent < 20) { //enemy winning
			iconP1.setState(1);
			iconP2.setState(2);
		} else if (healthBar.percent > 80) { //player winning
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

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
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

		if (generatedMusic && SONG.notes[currentSection] != null) 	{
			/*if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}*/

			var newFocus:Character = SONG.notes[currentSection].mustHitSection ? boyfriend : dad;

			if (focusCharacter != newFocus) {
				camFollowSetOnCharacter(newFocus);
				focusCharacter = newFocus;
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh') {
			switch (curBeat)
			{
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

		if (curSong == 'Bopeebo') {
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
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

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null) {
			while (unspawnNotes[0].strumTime - Conductor.songPosition < 1500) {
				var dunceNote:Note = unspawnNotes.shift();
				dunceNote.visible = dunceNote.visible && !Options.invisibleNotes;
				notes.add(dunceNote);
				if (unspawnNotes.length <= 0) {
					break;
				}
			}
		}

		if (generatedMusic) {
			var speed = (0.45 * FlxMath.roundDecimal(SONG.speed, 3));
			if (Options.downScroll) {
				speed = 0 - speed;
			}
			var strumlineLengthX:Array<Float> = [];
			var strumlineLengthY:Array<Float> = [];
			strumLines.forEach(function(aStrumLine:StrumLine) {
				strumlineLengthX.push(aStrumLine.members[aStrumLine.members.length - 1].x - aStrumLine.members[0].x);
				strumlineLengthY.push(aStrumLine.members[aStrumLine.members.length - 1].y - aStrumLine.members[0].y);
			});
			notes.forEachAlive(function(daNote:Note) {
				/*if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}*/
				/*if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}*/
				
				var strumNumber = daNote.mustPress ? 1 : 0;
				//todo: i guess
				var isInManiaChange:Bool = false; //currentManiaPartName[strumNumber] == maniaPartArr[daNote.maniaPart][strumNumber];
				var daStrum:StrumNote = strumLines.members[strumNumber].members[isInManiaChange ? 0 : daNote.noteData];
				daNote.y = (daStrum.y - (Conductor.songPosition - daNote.strumTime) * speed);
				daNote.x = daStrum.x;
				if (isInManiaChange) {
					daNote.y += strumlineLengthX[strumNumber] * daNote.maniaFract;
					daNote.x += strumlineLengthY[strumNumber] * daNote.maniaFract;
				}
				var isComputer = (!daNote.mustPress) || Options.botplay;
				var isPass = daNote.strumTime <= Conductor.songPosition;

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					//&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& isPass
					&& (isComputer || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					//todo: make this better in downscroll
					var since = Conductor.songPosition - daNote.strumTime;
					var clipEnd = daNote.strumTime + Conductor.crochet;
					var clipFraction = (clipEnd - since) / Conductor.crochet;
					var swagRect = new FlxRect(0, clipFraction * daNote.height / daNote.scale.x, daNote.width / daNote.scale.x, daNote.height * daNote.scale.x);
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				//todo: sometimes the opponent misses notes. why is this
				if (isComputer && isPass) {
					if (daNote.mustPress) {
						goodNoteHit(daNote);
					} else {
						opponentNoteHit(daNote);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				//if (daNote.y < -daNote.height)
				//{
					if (daNote.tooLate)
					{
						if (daNote.mustPress && !daNote.wasGoodHit) {
							noteMiss(daNote.noteData);
							if (Options.noteMissAction_Vocals[Options.noteMissAction])
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
		}

		if (camIsFollowing) {
			var speed = Math.min(camFollowSpeed * 2 * elapsed, 1);
			camFollowPos.x = FlxMath.lerp(camFollowPos.x, camFollow.x + camFollowOffset.x, speed);
			camFollowPos.y = FlxMath.lerp(camFollowPos.y, camFollow.y + camFollowOffset.y, speed);
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	public function camFollowSetOnCharacter(char:Character) {
		if (char == dad) {
			focusCharacter = dad;
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

			if (SONG.song.toLowerCase() == 'tutorial') {
				tweenCamIn();
			}
		}

		if (char == boyfriend) {
			focusCharacter = boyfriend;
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
			case 'senpai' | 'senpai-angry':
				camFollow.y = char.getMidpoint().y - 430;
				camFollow.x = char.getMidpoint().x - 100;
		}
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore && !(Options.botplay || usedBotplay)) {
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (Std.isOfType(this, PlayStateOffsetCalibrate)) {
			var nextState = new OptionsMenu();
			return FlxG.switchState(nextState);
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				CoolUtil.playMenuMusic();

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				//StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore && !Options.botplay)
				{
					//NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = CoolUtil.difficultyPostfixString();

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.actions.indexOf("lightsOffEnding") > -1) {
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
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(daNote:Note):Void
	{
		var strumtime:Float = daNote.strumTime;

		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
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
			grpNoteSplashes.recycle(NoteSplash, NoteSplash.new).playNoteSplash(playerStrums.members[daNote.noteData]);
		}
		if (Options.botplay) {
			usedBotplay = true;
		}

		songScore += Options.botplay ? 350 : score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var validUIStyle = currentUIStyle != null;

		var pixelShitPart1:String = "normal/";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school')) {
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(validUIStyle ? currentUIStyle.ratings.get(daRating) : pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(validUIStyle ? currentUIStyle.combo : pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(comboSpr);
		add(rating);

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

		if (combo >= 10 || combo == 0 || Options.botplay) {
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

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
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

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				//coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		if (Options.botplay) {
			return;
		}

		var controlArray = new Array<Bool>();
		var keyHolding = new Array<Bool>();
		for (i in curManiaInfo.control_set) {
			controlArray.push(FlxG.keys.anyJustPressed(i));
			keyHolding.push(FlxG.keys.anyPressed(i));
		}
		
		var hitNotes = 0;

		// FlxG.watch.addQuick('asdfa', upP);
		if (FlxG.keys.anyJustPressed(curManiaInfo.control_any) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});
			//even i can make a input system
			for (daNote in possibleNotes) {
				if (controlArray[daNote.noteData]) {
					hitNotes += 1;
					controlArray[daNote.noteData] = false;
					goodNoteHit(daNote);
				}
			}
			for (k in 0...controlArray.length) {
				if (controlArray[k] && (!(Options.ghostTapping) || (((hitNotes + possibleNotes.length > 0) || (songHits > 0 && Math.abs(Conductor.songPosition - lastHitNoteTime) <= Conductor.horizontalThing)) && Options.tappingHorizontal))) {
					noteMiss(k);
				}
			}
		}

		if (FlxG.keys.anyPressed(curManiaInfo.control_any) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					if (keyHolding[daNote.noteData])
						goodNoteHit(daNote);
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !FlxG.keys.anyPressed(curManiaInfo.control_any))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}
		
		for (i in 0...playerStrums.members.length) {
			var spr = playerStrums.members[i];
			var press = FlxG.keys.anyJustPressed(curManiaInfo.control_set[i]);
			var rel = FlxG.keys.anyJustReleased(curManiaInfo.control_set[i]);
			
			if (press) {
				spr.isHeld = true;
			}
			if (rel) {
				spr.isHeld = false;
			}
		};
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.0475;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;
			songMisses += 1;

			if (Options.noteMissAction_MissSound[Options.noteMissAction])
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/
			
			boyfriend.playAnim('sing${ManiaInfo.Dir[curManiaInfo.arrows[direction]]}miss', true);
		}
	}

	function goodNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			if (!note.isSustainNote) {
				popUpScore(note);
				combo += 1;
				songHits += 1;
				lastHitNoteTime = note.strumTime;
			}

			//if (note.noteData >= 0)
			if (health < maxHealth)
				health = Math.min(health + 0.023, maxHealth);
			//else
			//	health += 0.004;

			boyfriend.playAnim('sing${ManiaInfo.Dir[curManiaInfo.arrows[note.noteData]]}', true);

			playerStrums.members[note.noteData].playAnim('confirm', true);

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function opponentNoteHit(note:Note):Void {
		if (!note.wasGoodHit) {
			if (SONG.song != 'Tutorial')
				camZooming = true;

			var altAnim:String = "";

			if (SONG.notes[currentSection] != null) {
				if (SONG.notes[currentSection].altAnim)
					altAnim = '-alt';
			}

			if (health > SONG.healthDrainMin) {
				health = Math.max(health - SONG.healthDrain, SONG.healthDrainMin);
			}

			dad.playAnim('sing${ManiaInfo.Dir[curManiaInfo.arrows[note.noteData]]}${altAnim}', true);

			dad.holdTimer = 0;

			var spr = opponentStrums.members[note.noteData];
			if (spr != null) {
				spr.playAnim('confirm', true);
				spr.returnTime = (Conductor.crochet / 3750) + 0.1;
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			
			#if VMAN_DEMO
			var crochetThing = Conductor.crochet / 1000;
			if (curSong == "vasegames") {
				var intensity = 1;
				if (!Options.cameraShake) {
					intensity = 0.2; //shut your damn up
				}
				camGame.shake(0.025 * intensity, crochetThing);
				camHUD.shake(0.01 * intensity, crochetThing);
			}
			#end
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void {
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive() {
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(510, 660) / FlxG.elapsed);
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

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

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit() {
		super.beatHit();

		if (generatedMusic) {
			notes.sort(FlxSort.byY, Options.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		currentSection = Math.floor(curStep / 16);
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
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0) {
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing")) {
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo') {
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48) {
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage) {
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer) {
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0) {
					phillyCityLights.forEach(function(light:FlxSprite)
					{
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

	var curLight:Int = 0;
}
