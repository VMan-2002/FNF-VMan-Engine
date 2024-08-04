package;

import CoolUtil;
import Options;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate {
	var bf:Character;
	var camFollow:FlxObject;

	public var gameOverMusicName:String = "gameOver";
	public var gameOverMusicEndName:String = "gameOverEnd";
	public var canConfirm:Bool = true;
	public var canExit:Bool = true;

	public function new(x:Float, y:Float) {
		var daStage = PlayState.curStage;
		var daBf:String = '';
		var stageSuffix:String = "";
		switch (daStage) {
			case 'school' | 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf-dead';
		}
		var daChar:Character = (Options.saved.playstate_opponentmode && PlayState.instance.dad.deathChar != null ? PlayState.instance.dad : PlayState.instance.boyfriend);
		if (daChar.deathChar != null)
			daBf = daChar.deathChar;
		else if (daChar.hasAnim("firstDeath"))
			daBf = daChar.curCharacter;
		var deathSound:String = "fnf_loss_sfx";
		if (daChar.deathSound != null)
			deathSound = daChar.deathSound;
		else
			deathSound += stageSuffix;
		gameOverMusicName += stageSuffix;
		gameOverMusicEndName += stageSuffix;
		if (CoolUtil.isInPlayState()) {
			var thingy:PlayState = cast FlxG.state;
			if (thingy.currentUIStyle.gameOverMusic != null) {
				gameOverMusicName = thingy.currentUIStyle.gameOverMusic;
			}
			if (thingy.currentUIStyle.gameOverMusic != null) {
				gameOverMusicEndName = thingy.currentUIStyle.gameOverMusicEnd;
			}
		}


		super();

		Conductor.songPosition = 0;

		bf = new Character(x, y, daBf, daChar.isPlayer, daChar.myMod, true, true);
		add(bf);

		camFollow = new FlxObject(daChar.getGraphicMidpoint().x + daChar.cameraOffset[0], daChar.getGraphicMidpoint().y + daChar.cameraOffset[1], 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound(deathSound));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		Scripting.initScriptsByContext("GameOverSubstate");

		if (Std.isOfType(FlxG.state, PlayStateOffsetCalibrate))
			Achievements.giveAchievement("calibrateDeath");

		Scripting.runOnScripts("substatePostInit", ["GameOverSubstate", CoolUtil.isInPlayState() ? PlayState.instance.curSong : "", this]);
		
		if (Options.instance.instantRespawn) {
			FlxTransitionableState.skipNextTransOut = true;
			gotoplaystate();
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.ACCEPT && canConfirm)
			endBullshit();

		if (controls.BACK && canExit) {
			FlxG.sound.music.stop();

			if (Std.isOfType(FlxG.state, PlayStateOffsetCalibrate)) {
				CoolUtil.playMenuMusic();
				FlxG.state.closeSubState();
				OptionsMenu.wasInPlayState = !Std.isOfType(FlxG.state, PlayStateOffsetCalibrate);
				FlxG.switchState(new OptionsMenu());
			} else if (PlayState.instance.exitState != null)
				FlxG.switchState(PlayState.instance.exitState);
			else if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animStartsWith("firstDeath")) {
			if (bf.animation.curAnim.curFrame == 12)
				FlxG.camera.follow(camFollow, LOCKON, 0.01);

			if (bf.animation.curAnim.finished)
				CoolUtil.playMusic(gameOverMusicName);
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;

		Scripting.runOnScripts("substateUpdate", [elapsed]);
	}

	override function beatHit() {
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	public inline function endBullshit():Void {
		if (!isEnding) {
			Scripting.runOnScripts("onAccept", ["GameOverSubstate", null, null]);
			isEnding = true;
			bf.playAvailableAnim(['deathConfirm' + bf.animation.curAnim.name.substr(bf.animStartsWith("deathLoop") ? 9 : 10), 'deathConfirm'], true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(gameOverMusicEndName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer) {
				FlxG.camera.fade(FlxColor.BLACK, 2, false, gotoplaystate);
			});
		}
	}
	
	public inline function gotoplaystate() {
		LoadingState.loadAndSwitchState(Std.isOfType(FlxG.state, PlayStateOffsetCalibrate) ? new PlayStateOffsetCalibrate() : new PlayState());
	}
}
