package;

import CoolUtil;
import NoteColor;
import Options;
import Translation;
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
import lime.app.Application;
import openfl.Assets;

using StringTools;
#if html5
import ThingThatSucks.HtmlModSelectMenu;
#end
#if desktop
import Discord.DiscordClient;
//import sys.thread.Thread;
#end
//import io.newgrounds.NG;
#if polymod
import polymod.Polymod.Framework;
import polymod.Polymod;
#if !html5
import sys.io.File;
#end
#end


class TitleState extends MusicBeatState {
	var stageObject:Stage;
	
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var titleGroup:FlxGroup;
	var vmanThing:FlxText;

	var curWacky:Array<String>;

	var wackyImage:FlxSprite;
	
	public static var doCoolText = true;
	public var introTexts:Array<String>;
	
	public static var enabledMods = new Array<String>();

	override public function create():Void {
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
		#if !html5
		var modListThing:Array<String> = File.getContent("mods/modList.txt").split("\n");
		#else
		var modListThing:Array<String> = [ModLoad.primaryMod];
		#end
		for (i in modListThing) {
			i = i.trim().replace("\r", "");
		}
		ModLoad.loadMods(modListThing);
		//polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end
		//polymod.Polymod.init({
		//	modRoot: "./mods/",
		//	dirs: ["example"]
		//});

		PlayerSettings.init();
		
		PlayerSettings.player1.controls.setKeyboardScheme(Custom);

		curWacky = FlxG.random.getObject(getIntroTextShit());
		introTexts = Assets.getText(Paths.txt("mainIntroText")).split("\n");

		// DEBUG BULLSHIT

		super.create();

		/*NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end*/

		FlxG.save.bind('funkin', 'ninjamuffin99');

		Highscore.load();
		
		stageObject = new Stage("_FnfTitle");

		if (FlxG.save.data.weekUnlocked != null) {
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
			initialized = true;
			#end
			Translation.setTranslation(Options.language);
			#if VMAN_DEMO
			return FlxG.switchState(new OptionsMenu(new HtmlModSelectMenu()));
			#end
			#if !html5
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
			#end
		}
		
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

		titleGroup.add(stageObject.elementsBack);
		titleGroup.add(stageObject.elementsFront);

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1/6, function(tmr:FlxTimer) {
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

	function startIntro() {
		
		if (!initialized) {
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

	function getIntroTextShit():Array<Array<String>> {
		var firstArray:Array<String> = CoolUtil.uncoolTextFile("data/introText");
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray) {
			swagGoodArray.push(i.split('--'));
		}
		
		swagGoodArray.push("This intro text--is Hardcoded Lmao".split("--"));

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F) {
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro) {
			#if !switch
			//NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5) {
				trace("It's Friday! swag");
				//NGio.unlockMedal(61034);
			}
			#end

			//titleText.animation.play('press');
			stageObject.playAnim("press");

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer) {
				// Check if version is outdated

				var version:String = "v" + Application.current.meta.get('version');

				if (/*version.trim() != NGio.GAME_VER_NUMS.trim() &&*/ !OutdatedSubState.leftState && false) {//Todo: Update checker
					FlxG.switchState(new OutdatedSubState());
					trace('OLD VERSION!');
					trace('old ver');
					trace(version.trim());
					trace('cur ver');
					//trace(NGio.GAME_VER_NUMS.trim());
				} else {
					FlxG.switchState(new MainMenuState());
				}
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro) {
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			/*var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);*/
			addMoreText(textArray[i]);
			//textGroup.add(money);
		}
	}

	function addMoreText(text:String) {
		var coolText:Alphabet = new Alphabet(0, (credGroup.length * 60) + 200, text, true, false);
		coolText.screenCenter(X);
		credGroup.add(coolText);
		//textGroup.add(coolText);
	}

	function deleteCoolText() {
		while (credGroup.length > 0) {
			credGroup.remove(credGroup.members[0], true);
			//textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit() {
		super.beatHit();

		FlxG.log.add(curBeat);
		
		stageObject.beatHit();
		
		if (skippedIntro || !doCoolText)
			return;

		if (curBeat >= introTexts.length) {
			return skipIntro();
		}
		var rawLine:String = introTexts[curBeat].trim();
		var splittedColons:Array<String> = rawLine.split("::");
		switch(splittedColons[1]) {
			case "del":
				deleteCoolText();
				ngSpr.visible = false;
			case "ng":
				ngSpr.visible = true;
			case "wacky0":
				addMoreText(curWacky[0]);
			case "wacky1":
				if (curWacky.length >= 3)
					addMoreText(curWacky[1]);
			case "wacky2":
				if (curWacky.length >= 2)
					addMoreText(curWacky[curWacky.length >= 3 ? 2 : 1]);
			case "newWacky":
				curWacky = FlxG.random.getObject(getIntroTextShit());
			case "skipIntro":
				skipIntro();
		}
		createCoolText(splittedColons[0].split("--").filter(function(a) {return a.length > 0;}));

		/*switch (curBeat) {
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
				addMoreText('Newgrounds');
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
		}*/
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void {
		if (!skippedIntro) {
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
			doCoolText = false;
		}
	}
	
	inline function MainMenuThing() {
		if (!OptionsWarningState.leftState && !Options.seenOptionsWarning) {
			return FlxG.switchState(new OptionsWarningState());
		}
		FlxG.switchState(new MainMenuState());
	}
}
