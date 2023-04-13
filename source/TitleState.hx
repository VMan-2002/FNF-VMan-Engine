package;

import CoolUtil;
import Note.SwagNoteSkin;
import Note.SwagNoteType;
import Note.SwagUIStyle;
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
import haxe.Http;
// import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

using StringTools;
#if html5
import ThingThatSucks.HtmlModSelectMenu;
#end
#if desktop
import Discord.DiscordClient;

// import sys.thread.Thread;
#end
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

	var replayTitle:Bool = false;
	var reloadingMods:Bool = false;
	var fromOptions:Bool = false;
	var toPlayState:Bool = false;

	public var updateCheck:String = initialized ? "NO_CHECK" : Http.requestUrl("https://raw.githubusercontent.com/VMan-2002/FNF-VMan-Engine/master/version/vman_engine.txt").replace("\r", "");
	public var needsUpdate:Bool = false;

	override public function new(?replayTitle:Bool = false, ?reloadingMods:Bool = false, ?fromOptions:Bool = false, ?toPlayState:Bool = false) {
		//todo: this doesn't always work
		//this.replayTitle = replayTitle;
		this.reloadingMods = reloadingMods;
		this.fromOptions = fromOptions;
		this.toPlayState = toPlayState;

		if (reloadingMods) {
			SwagNoteType.clearLoadedNoteTypes();
			SwagNoteSkin.clearLoadedNoteSkins();
			SwagUIStyle.clearLoadedUIStyles();
			Character.charHealthIcons.clear();
		}

		super();
	}

	override public function create():Void {
		if (!initialized) {
			var stuffThings = updateCheck.split("\n");
			if (stuffThings.length != 0 && Std.parseInt(stuffThings[0]) != null)
				needsUpdate = Std.parseInt(stuffThings[0]) > Main.gameVersionInt;
		}
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
			//We don't need this anymore
			Reflect.deleteField(FlxG.save.data, "weekUnlocked");
			FlxG.save.data.weekUnlocked = null;
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
		titleGroup.add(stageObject.elementsBetween);
		titleGroup.add(stageObject.elementsFront);

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1/6, function(tmr:FlxTimer) {
			if ((!initialized && Options.skipTitle) || (reloadingMods && !replayTitle)) {
				initialized = true;
				CoolUtil.playMenuMusic(1); //todo: If we're reloading mods, only restart the menu music if it's now different
				initTransitionShit();
				FlxTransitionableState.skipNextTransOut = true;
				if (toPlayState) {
					switchTo(new PlayState());
					return;
				}
				if (reloadingMods) {
					MainMenuState.returnToMenuFocusOn(fromOptions ? "options" : "mods");
					return;
				}
				if (needsUpdate) {
					FlxG.switchState(new OutdatedSubState(updateCheck.split("\n")[1]));
					return trace("outdated but you're have skip title enabled");
				}
				return MainMenuThing();
			}
			skippedIntro = false;
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
		
		if (!initialized || replayTitle) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.stop();
			}
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

		if (initialized && !replayTitle)
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
				if (Achievements.giveAchievement("fridayNight")) {
					Achievements.SaveOptions();
				};
			}
			#end

			//titleText.animation.play('press');
			stageObject.playAnim("press");

			if (Options.flashingLights)
				FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer) {
				// Check if version is outdated

				if (needsUpdate) {
					FlxG.switchState(new OutdatedSubState(updateCheck.split("\n")[1]));
					trace('OLD VERSION detected! make nerd emojis in chat');
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
		if (credGroup == null) {
			return;
		}
		var coolText:Alphabet = new Alphabet(0, (credGroup.length * 60) + 200, text, true, false);
		coolText.screenCenter(X);
		credGroup.add(coolText);
		//textGroup.add(coolText);
	}

	function deleteCoolText() {
		if (credGroup == null) {
			return;
		}
		while (credGroup.length > 0) {
			credGroup.remove(credGroup.members[0], true);
			//textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit() {
		super.beatHit();

		FlxG.log.add(curBeat);
		
		stageObject.beatHit();
		
		if (skippedIntro || !doCoolText || reloadingMods)
			return;

		if (curBeat >= introTexts.length) {
			return skipIntro();
		}
		var rawLine:String = introTexts[curBeat].trim();
		var splittedColons:Array<String> = rawLine.split("::");
		for (thing in splittedColons.slice(1)) {
		switch(thing) {
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
		}
		if (splittedColons[0] != "") {
			createCoolText(splittedColons[0].split("--"));
		}

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
			
			var theText = Translation.getTranslation("vman engine", "game");
			vmanThing = new FlxText(8, FlxG.height - 30, theText != "VMan Engine" ? '${theText} (VMan Engine)' : "VMan Engine");
			titleGroup.add(vmanThing);
			titleGroup.visible = true;
			vmanThing.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT);
			Translation.setObjectFont(vmanThing, "vcr font");

			skippedIntro = true;
			doCoolText = false;
		}
	}
	
	inline function MainMenuThing() {
		if (!OptionsWarningState.leftState && Options.seenOptionsWarning != OptionsWarningState.latestOptionsWarning) {
			return FlxG.switchState(new OptionsWarningState());
		}
		FlxG.switchState(new MainMenuState());
	}
}
