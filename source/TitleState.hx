package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
import Options;

import CoolUtil;
import NoteColor;
import Translation;
#if polymod
import polymod.Polymod;
import polymod.Polymod.Framework;
import sys.io.File;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var titleGroup:FlxGroup;
	var vmanThing:FlxText;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	
	var doCoolText = true;

	override public function create():Void
	{
		//Paths.updateModsList();
		/*#if MODS
		var modListThing:Array<String> = File.getContent("mods/modList.txt").split("\n");
		for (i in modListThing) {
			i = i.trim();
		}
		polymod.Polymod.init({
			modRoot: "./mods/",
			dirs: modListThing,
			framework: Framework.FLIXEL
		});
		#end*/
		
		
		#if polymod
		loadMods(['example']);
		//polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end
		//polymod.Polymod.init({
		//	modRoot: "./mods/",
		//	dirs: ["example"]
		//});

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		/*NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end*/

		FlxG.save.bind('funkin', 'ninjamuffin99');

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}
		trace('starting lmao');
		if (!initialized) {
			#if desktop
			Main.launchArguments = Sys.args();
			#elseif html5
			//todo: see MultiWindow.hx for details
			#end
			if (Main.launchArguments.length > 0) {
				var colonpos:Int;
				for (i in Main.launchArguments) {
					colonpos = i.indexOf(":");
					if (colonpos == -1) {
						Main.launchArgumentsParsed.set(i, -1);
						trace('arg parse failed: ${i}');
					} else {
						var parsedInt = Std.parseInt(i.substr(colonpos + 1));
						Main.launchArgumentsParsed.set(i.substr(0, colonpos), parsedInt == null ? -1 : parsedInt);
						trace('arg parse succeeded: ${i}');
					}
				}
				for (i in Main.launchArgumentsParsed.keys()) {
					trace('arg ${i} = ${Main.launchArgumentsParsed.get(i)}');
					if (i == "multiWindowType") {
						MultiWindow.thisWindowId = Main.launchArgumentsParsed.get(i);
					}
				}
			} else {
				trace('no launch args');
			}
		}
		
		Translation.setTranslation(Options.language);
		
		if (Main.launchArgumentsParsed.get("multiWindowType") > 0) {
			initialized = true;
			CoolUtil.playMenuMusic(1);
			initTransitionShit();
			return FlxG.switchState(new FreeplayState());
		}
		
		titleGroup = new FlxGroup();
		add(titleGroup);
		titleGroup.visible = false;
		
		persistentUpdate = true;

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('title/logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('title/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		titleGroup.add(gfDance);
		titleGroup.add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('title/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		titleGroup.add(titleText);
		
		if (initialized) {
			doCoolText = false;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1/6, function(tmr:FlxTimer)
		{
			if (!initialized && Options.skipTitle) {
				initialized = true;
				CoolUtil.playMenuMusic(1);
				initTransitionShit();
				FlxTransitionableState.skipNextTransOut = true;
				return MainMenuThing();
			}
			startIntro();
		});
		#end

		#if desktop
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	
	inline function initTransitionShit() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// HAD TO MODIFY SOME BACKEND SHIT
		// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
		// https://github.com/HaxeFlixel/flixel-addons/pull/348
	}

	function startIntro()
	{
		
		if (!initialized)
		{
			initTransitionShit();

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			CoolUtil.playMenuMusic(0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
			
			//todo: this is testing reason.
			//NoteColor.TestThing();
		}

		//var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		//add(bg);
		
		

		/*var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;*/
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		//textGroup = new FlxGroup();

		//blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		//add(blackScreen);

		//credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		//credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		//credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('title/newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		//FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var firstArray:Array<String> = CoolUtil.uncoolTextFile("data/introText");
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}
		
		swagGoodArray.push(["This intro text", "is Hardcoded Lmao"]);

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			//NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				//NGio.unlockMedal(61034);
			#end

			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated

				var version:String = "v" + Application.current.meta.get('version');

				if (/*version.trim() != NGio.GAME_VER_NUMS.trim() &&*/ !OutdatedSubState.leftState && false) //Todo: Update checker
				{
					FlxG.switchState(new OutdatedSubState());
					trace('OLD VERSION!');
					trace('old ver');
					trace(version.trim());
					trace('cur ver');
					//trace(NGio.GAME_VER_NUMS.trim());
				}
				else
				{
					FlxG.switchState(new MainMenuState());
				}
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			//textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (credGroup.length * 60) + 200;
		credGroup.add(coolText);
		//textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (credGroup.members.length > 0)
		{
			credGroup.remove(credGroup.members[0], true);
			//textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		FlxG.log.add(curBeat);
		
		if (skippedIntro || !doCoolText)
			return;

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('newgrounds');
				ngSpr.visible = true;
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 10:
				if (curWacky.length >= 3)
					addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 11:
				if (curWacky.length >= 2)
					addMoreText(curWacky[curWacky.length >= 3 ? 2 : 1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			//remove(blackScreen);
			
			vmanThing = new FlxText(8, FlxG.height - 30, "VMan Engine");
			var theText = Translation.getTranslation("vman engine", "game");
			if (theText != "VMan Engine") {
				vmanThing.text = '${theText} (${vmanThing})';
			}
			titleGroup.add(vmanThing);
			titleGroup.visible = true;
			vmanThing.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT);
			Translation.setObjectFont(vmanThing, "vcr font");
			skippedIntro = true;
		}
	}
	
	inline function MainMenuThing() {
		if (!OptionsWarningState.leftState) {
			return FlxG.switchState(new OptionsWarningState());
		}
		FlxG.switchState(new MainMenuState());
	}
	
	//copied from polymod flixel sample

	private function loadMods(dirs:Array<String>)
	{
		trace('Loading mods: ${dirs}');
		/*var modRoot = '../../../mods/';
		#if mac
		// account for <APPLICATION>.app/Contents/Resources
		var modRoot = '../../../../../../mods';
		#end*/
		var modRoot = './mods/';
		var results = Polymod.init({
			modRoot: modRoot,
			dirs: dirs,
			errorCallback: onError,
			ignoredFiles: Polymod.getDefaultIgnoreList(),
			frameworkParams: {
				assetLibraryPaths: [
					"default" => "./assets",
					"shared" => "./assets/shared",
					"week1" => "./assets/week1",
					"week2" => "./assets/week2",
					"week3" => "./assets/week3",
					"week4" => "./assets/week4",
					"week5" => "./assets/week5",
					"week6" => "./assets/week6",
					"songs" => "./assets/songs"
				]
			}
		});
		// Reload graphics before rendering again.
		if (results == null) {
			return;
		}
		var loadedMods = results.map(function(item:ModMetadata)
		{
			return item.id;
		});
		trace('Loaded mods: ${loadedMods}');
	}

	private function onError(error:PolymodError)
	{
		trace('[${error.severity}] (${error.code.toUpperCase()}): ${error.message}');
	}
}
