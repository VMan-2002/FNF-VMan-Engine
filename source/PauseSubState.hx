package;

import OptionsMenu;
import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public function new()
	{
		super();
		if (Std.isOfType(FlxG.state, PlayStateOffsetCalibrate)) {
			menuItems.remove("Exit to menu");
		}
		var pauseMusicName = 'breakfast';
		if (CoolUtil.isInPlayState()) {
			var thingy:PlayState = cast FlxG.state;
			if (thingy.currentUIStyle.pauseMusic != null) {
				pauseMusicName = thingy.currentUIStyle.pauseMusic;
			}
		}

		//Dont use CoolUtil.playMusic here
		pauseMusic = new FlxSound().loadEmbedded(Paths.music(pauseMusicName), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, Math.random() * pauseMusic.length / 2);

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		Translation.setObjectFont(levelInfo, "vcr font");
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += Translation.getTranslation(CoolUtil.difficultyString(), "difficulty") + Highscore.getModeString(true, true);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(levelInfo.font, 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, Translation.getTranslation("pause_"+menuItems[i], "playstate"), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		Scripting.runOnScripts("substatePostInit", ["PauseSubState", CoolUtil.isInPlayState() ? PlayState.instance.curSong : "", this]);
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (accepted) {
			var daSelected:String = menuItems[curSelected].toLowerCase();

			Scripting.clearScriptResults();
			Scripting.runOnScripts("onAccept", ["PauseSubState", daSelected, true]);
			if (!Scripting.scriptResultsContains(false)) {
				switch (daSelected) {
					case "resume":
						close();
					case "restart song":
						if (Options.instance.uiReloading) {
							Note.SwagNoteSkin.clearLoadedNoteSkins();
							Note.SwagUIStyle.clearLoadedUIStyles();
							Note.SwagNoteType.clearLoadedNoteTypes();
						}
						FlxG.resetState();
					case "exit to menu":
						if (Std.isOfType(FlxG.state, PlayState) && cast(FlxG.state, PlayState).exitState != null)
							FlxG.switchState(cast(FlxG.state, PlayState).exitState);
						else if (PlayState.isStoryMode)
							FlxG.switchState(new StoryMenuState());
						else
							FlxG.switchState(new FreeplayState());
					case "options":
						if (Std.isOfType(FlxG.state, PlayStateOffsetCalibrate)) {
							CoolUtil.playMenuMusic();
						}
						FlxG.state.closeSubState();
						OptionsMenu.wasInPlayState = !Std.isOfType(FlxG.state, PlayStateOffsetCalibrate);
						FlxG.switchState(new OptionsMenu());
				}
			}
		}

		/*if (FlxG.keys.justPressed.J) {
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}*/
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
