package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BlendMode;

class CornflowerFreeplay {
	//this is the cornflower theme for freeplay menu
	//hardcoded cuz im lazy

	var background:FlxSprite;
	var backgroundDuel:FlxSprite;
	var bossOverlay:FlxSprite;
	var icon:HealthIcon;
	var songTitle:FlxText;
	var songStats:FlxText;
	var songComment:FlxText;

	var isEnabled:Bool = false;
	var duelEnabled:Bool = false;
	var bossEnabled:Bool = false;

	var bgDuelTween:FlxTween;
	var songNameTween:FlxTween;
	var bossOverlayTween:FlxTween;

	var songListTexts:FlxTypedGroup<FlxText>;

	var songTweens = new Array<FlxTween>();

	var unlockText:FlxText;

	public function new(menu:FreeplayState) {
		background = new FlxSprite(0, 0, Paths.image("cornflower_menu/bg_freeplay"));
		backgroundDuel = new FlxSprite(0, 0, Paths.image("cornflower_menu/bg_freeplay_rodz"));
		icon = new HealthIcon("bf", false);
		songTitle = new FlxText(0, 550, FlxG.width - 180, "a very cool song!");
		songStats = new FlxText(0, 675, FlxG.width, "1 million points");
		songComment = new FlxText(0, 675, FlxG.width, "lmao");
		bossOverlay = new FlxSprite(0, 0, Paths.image("cornflower_menu/bg_boss_shade"));
		bossOverlay.blend = BlendMode.SUBTRACT;
		
		bossOverlay.alpha = 0;
		backgroundDuel.alpha = 0;

		//todo: Why does the font not work
		songTitle.setFormat(Paths.font("mont-regular.ttf"), 120, 0xffffffff, "right");
		songStats.setFormat(Paths.font("mont-regular.ttf"), 32, 0xffffffff, "right");
		songComment.setFormat(Paths.font("mont-regular.ttf"), 32, 0xffffffff, "left");
		songTitle.setBorderStyle(FlxTextBorderStyle.OUTLINE, 5, 0xff000000);
		songStats.setBorderStyle(FlxTextBorderStyle.OUTLINE, 3, 0xff000000);
		songComment.setBorderStyle(FlxTextBorderStyle.OUTLINE, 3, 0xff000000);
		Translation.setObjectFont(songTitle, "font");
		Translation.setObjectFont(songStats, "font");
		Translation.setObjectFont(songComment, "font");

		songListTexts = new FlxTypedGroup<FlxText>();
		icon.sprTracker = songTitle;
		icon.sprTrackerY = 30;

		background.color = 0xff62c2ff; //until i implement the color changing thingy

		unlockText = new FlxText(16, 18, FlxG.width, "unlock");
		unlockText.setFormat(Paths.font("mont-regular.ttf"), 32, 0xffffffff, "left");
		Translation.setObjectFont(unlockText, "font");

		menu.add(background);
		menu.add(backgroundDuel);
		menu.add(icon);
		menu.add(songTitle);
		menu.add(songStats);
		menu.add(songComment);
		menu.add(songListTexts);
		menu.add(unlockText);
		menu.add(bossOverlay);

		enable();
	}

	public function enable() {
		background.visible = true;
		backgroundDuel.visible = false;
		icon.visible = true;
		songTitle.visible = true;
		songStats.visible = true;
		songComment.visible = true;
		songListTexts.visible = true;
		isEnabled = true;
	}
	
	public function disable() {
		background.visible = false;
		backgroundDuel.visible = false;
		icon.visible = false;
		songTitle.visible = false;
		songStats.visible = false;
		songComment.visible = false;
		songListTexts.visible = false;
		isEnabled = false;
	}

	public function destroy() {
		background.destroy();
		backgroundDuel.destroy();
		icon.destroy();
		songTitle.destroy();
		songStats.destroy();
		songComment.destroy();
		songListTexts.destroy();
	}

	public function makeSonglist(menu:FreeplayState) {
		while (songListTexts.members.length > 0) {
			songListTexts.members.pop().destroy();
		}
		for (thing in menu.songs) {
			var text = new FlxText(0, 0, FlxG.width, thing.songName);
			text.setFormat(Paths.font("mont-regular.ttf"), 50, 0xffffffff, "left");
			Translation.setObjectFont(text, "font");
			songListTexts.add(text);
		}
		if (FreeplayState.inFolder.length > 2 && menu.folderNames[FreeplayState.inFolder[2]] == "Cornstupid Week") {
			unlockText.visible = true;
			var count = 0;
			var things = ["cornt-idk", "iddqd-extra", "stupid-trouble-extra"];
			for (i in 0...things.length) {
				if (Highscore.songScoreFC.exists('${menu.songs[0].mod}:${things[i]}')) {
					count++;
				}
			}
			if (count < 3) {
				unlockText.text = '???: ${count}/3';
			} else {
				unlockText.visible = false;
			}
		} else {
			unlockText.visible = false;
		}
	}

	public function changeSelection(menu:FreeplayState) {
		var song = menu.songs[FreeplayState.curSelected];
		songTitle.text = song.songName;
		var songFormatted = Highscore.formatSong(song.songName);
		switch(songFormatted) {
			case "uncalled-for" | 'vase-incident' | 'vasegames': //todo: add the others later
				setDuel(true);
			default:
				setDuel(false);
		}
		switch(songFormatted) {
			case "vasegames" | "iddqd" | 'stupid-trouble' | 'corkflubs': //todo: also add the others later
				setBoss(true);
			default:
				setBoss(false);
		}
		switch(songFormatted) {
			//Songs
			case 'vasegames':
				songComment.text = "nogames (vs /v/)";
			case 'vase-incident':
				songComment.text = "Technophobia (The Trollge Files)";
			case 'corkflubs':
				songComment.text = "Don't try this at home";
			//todo: also add the others later
			//Weeks
			case 'week-1':
				songComment.text = "Whom this guy be";
			case 'week-2':
				songComment.text = "This cant be good";
			case 'cornstupid-week':
				songComment.text = "I dunno man";
			//Extras
			case 'extras-1':
				songComment.text = "The past and present";
			case 'extras-2':
				songComment.text = "Seen differently";
			case 'extras-cornstupid':
				songComment.text = "Alternate universe";
			default:
				songComment.text = "";
		}
		icon.destroyChildren();
		icon.changeCharacter(song.songCharacter, false, song.mod);
		icon.addChildrenToScene();

		songTitle.x = FlxG.width;
		if (songNameTween != null) {
			songNameTween.cancel();
		}
		songNameTween = FlxTween.tween(songTitle, {x: 0}, 0.3, {ease: FlxEase.backOut});

		while (songTweens.length > 0) {
			var a = songTweens.pop();
			a.cancel();
		}
		for (thing in 0...songListTexts.members.length) {
			var text = songListTexts.members[thing];
			var isCurrent = thing == FreeplayState.curSelected;
			var newY:Float = 60 * (thing - FreeplayState.curSelected) + 240;
			songTweens[thing] = FlxTween.tween(text, {x: isCurrent ? 100 : 50, y: newY, alpha: CoolUtil.clamp((520 - newY) / 100, 0, 1)}, 0.5, {ease: FlxEase.cubeOut});
		}

		songStats.visible = song.type == 0;
	}

	public function changeDifficulty(menu:FreeplayState) {
		songStats.text = '${CoolUtil.difficultyString(FreeplayState.curDifficulty)}: ${menu.intendedScore} | ${menu.scoreFCText.text} - ${menu.scoreAccText.text}';
	}

	public function setDuel(enable:Bool) {
		if (duelEnabled == enable) {
			return;
		}
		if (bgDuelTween != null) {
			bgDuelTween.cancel();
		}
		duelEnabled = enable;
		bgDuelTween = FlxTween.tween(backgroundDuel, {alpha: enable ? 1 : 0}, 1, {ease: FlxEase.expoOut});
	}

	public function setBoss(enable:Bool) {
		if (bossEnabled == enable) {
			return;
		}
		if (bossOverlayTween != null) {
			bossOverlayTween.cancel();
		}
		bossEnabled = enable;
		bossOverlayTween = FlxTween.tween(bossOverlay, {alpha: enable ? 0.5 : 0}, 1, {ease: FlxEase.expoOut});
		/*if (!Translation.usesFont) {
			if (enable) {

			} else {
				songTitle.font = Paths.font("mont-regular.ttf");
			}
		}*/
	}
}
