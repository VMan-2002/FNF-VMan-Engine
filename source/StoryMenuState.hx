package;

import CoolUtil;
import Translation;
import Weeks.SwagWeek;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
// import flixel.text.FlxTextFormat;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import lime.utils.Assets;
import sys.FileSystem;

using StringTools;
#if desktop
import Discord.DiscordClient;
#end

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;
	var curWeekName:String = "week0";

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var grpDifficultyText:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var difficultyTextSprites:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var difficultySprites:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var modifierText:FlxText;

	var weeks:Array<SwagWeek>;

	var yellowBG:FlxSprite;

	static var weekRember:String;
	var nothingAvailable:Bool = false;

	override function create() {
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null && !FlxG.sound.music.playing)
			CoolUtil.playMenuMusic();

		persistentUpdate = persistentDraw = true;

		weeks = Weeks.getAllWeeks(false);
		if (weeks.length == 0) {
			nothingAvailable = true;
			return NoSongsState.doThing("story mode", "storymenu");
		}

		//todo: using a script to switch to a different state from StoryMenuState softlocks on a black screen, why is that?
		Scripting.initScriptsByContext("StoryMenuState");
		weeks = Scripting.runCheckUnlocksOnScripts("storyMode", weeks, "id", "modName");
		
		var weekSkip = 0;
		for (week in weeks) {
			if (weekRember == '${week.modName}:${week.id}') {
				weekSkip = weeks.indexOf(week);
				break;
			}
		}

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		Translation.setObjectFont(scoreText, "vcr font");

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat(scoreText.font, 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.setFormat(scoreText.font, 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('menu/campaign_menu_UI_assets');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFFFFFFF);
		yellowBG.color = 0xFFF9CF51;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresenceSimple("story");
		#end

		for (i in 0...weeks.length) {
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weeks[i].id, weeks[i].modName);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;

			// Needs an offset thingie
			if (!weeks[i].weekUnlocked) {
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.addByPrefix('white', 'white lock');
				lock.animation.addByPrefix('outline', 'white outlined lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		for (char in 0...3) {
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char), weeks[curWeek].menuChars.length < char ? weeks[curWeek].menuChars[char] : "", char == 0);
			weekCharacterThing.y += 70;

			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		difficultySprites = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(870, 476);
		leftArrow.frames = ui_tex;
		leftArrow.antialiasing = true;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);
		
		difficultySelectors.add(difficultySprites);
		add(difficultySprites);

		rightArrow = new FlxSprite(leftArrow.x + 350, leftArrow.y);
		rightArrow.antialiasing = true;
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		modifierText = new FlxText(leftArrow.x + 20, rightArrow.y + rightArrow.height, 360, Highscore.getModeString(true), 24);
		modifierText.font = scoreText.font;
		modifierText.alignment = FlxTextAlign.RIGHT;

		add(modifierText);

		trace("Line 150 (not really)");

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks\n\nwe are\nplaying\nvideogames", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		var formatThing = new FlxTextFormat(0xFFe55777);
		if (Translation.usesFont) {
			formatThing.leading = -12;
		}
		txtTracklist.addFormat(formatThing);
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		curWeek = weekSkip;
		changeWeek(0);
		changeDifficulty(0);

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float) {
		if (nothingAvailable)
			return super.update(elapsed);
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = Translation.getTranslation("week score", "storymenu", [Std.string(lerpScore)]);

		txtWeekTitle.text = weeks[curWeek].title.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		grpLocks.forEach(function(lock:FlxSprite) {
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack) {
			if (!selectedWeek) {
				if (controls.UP_P)
					changeWeek(-1);

				if (controls.DOWN_P)
					changeWeek(1);

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
		Scripting.runOnScripts("update", [elapsed]);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;

	function selectWeek() {
		if (weeks[curWeek].weekUnlocked) {
			if (selectedWeek) {
				return;
			}
			FlxG.sound.play(Paths.sound('confirmMenu'));

			grpWeekText.members[curWeek].startFlashing();
			grpWeekCharacters.members[1].playAvailableAnim(['confirm']);

			PlayState.isStoryMode = true;
			selectedWeek = true;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = curWeekName;
			PlayState.campaignScore = 0;
			PlayState.usedBotplay = false;
			
			ModLoad.primaryMod = ModsMenuState.quickModJsonData(weeks[curWeek].modName);

			PlayState.modName = weeks[curWeek].modName;

			Scripting.runOnScripts("onAccept", ["StoryMode", curWeekName, weeks[curWeek].modName]);
			if (weeks[curWeek].songs.length > 0) {
				PlayState.storyPlaylist = weeks[curWeek].songs;
				PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.storyPlaylist[0], PlayState.storyDifficulty), PlayState.storyPlaylist[0]);
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					CoolUtil.resetMenuMusic();
					LoadingState.loadAndSwitchState(new PlayState(), true);
				});
			} else {
				trace("The week contains no songs, so if not otherwise handled, you're now softlocked. :^)");
			}
		} else {
			FlxG.sound.play(Paths.sound('buzzer'));
			grpWeekText.members[curWeek].startRedFlashing();
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyArray.length - 1;
		else if (curDifficulty >= CoolUtil.difficultyArray.length)
			curDifficulty = 0;
		
		var newDifficultyName:String = CoolUtil.difficultyString(curDifficulty).toLowerCase();

		if (!difficultyTextSprites.exists(newDifficultyName)) {
			var graphic = Paths2.image("menudifficulties/"+newDifficultyName);
			var xmlThing = CoolUtil.getFileOriginMod("images/menudifficulties/" + newDifficultyName + ".xml");
			var otherPath = "assets/images/menudifficulties" + newDifficultyName + ".xml";
			if (xmlThing == null && FileSystem.exists(otherPath)) {
				xmlThing = otherPath;
			}
			var diffSprite = new FlxSprite(0, leftArrow.y, graphic);
			if (xmlThing != null) {
				diffSprite.frames = Paths2.getSparrowAtlas("menudifficulties/" + newDifficultyName);
				diffSprite.animation.addByPrefix("idle", "idle", 24, true);
			}
			diffSprite.screenCenter(X);
			diffSprite.x += 430;
			diffSprite.antialiasing = true;
			diffSprite.visible = false;
			difficultyTextSprites.set(newDifficultyName, diffSprite);
			difficultySprites.add(diffSprite);
			trace("added sprite for " + newDifficultyName);
		}

		for (n in difficultyTextSprites.keys()) {
			if (n == newDifficultyName) {
				sprDifficulty = difficultyTextSprites.get(n);
			} else {
				difficultyTextSprites.get(n).visible = false;
			}
		}

		#if !switch
		setIntendedScore();
		#end

		if (CoolUtil.difficultyArray.length > 1 || sprDifficulty.visible == false) {
			sprDifficulty.visible = true;
			sprDifficulty.alpha = 0;
	
			// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
			sprDifficulty.y = leftArrow.y - 15;

			FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	inline function setIntendedScore() {
		intendedScore = Highscore.getWeekScore('${weeks[curWeek].modName}:${weeks[curWeek].id}', curDifficulty);
	}

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weeks.length - 1;

		curWeekName = weeks[curWeek].id;
		weekRember = '${weeks[curWeek].modName}:${weeks[curWeek].id}';

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weeks[curWeek].weekUnlocked)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();

		if (!CoolUtil.setNewDifficulties(weeks[curWeek].difficulties, this, "curDifficulty"))
			changeDifficulty(0);

		leftArrow.visible = CoolUtil.difficultyArray.length > 1;
		rightArrow.visible = leftArrow.visible;
	}

	function updateText() {
		var chars = weeks[curWeek].menuChars == null ? new Array<String>() : weeks[curWeek].menuChars;
		grpWeekCharacters.members[0].setCharacter(chars.length <= 1 ? "" : chars[1], weeks[curWeek].modName);
		grpWeekCharacters.members[1].setCharacter(chars.length <= 0 ? "" : chars[0], weeks[curWeek].modName);
		grpWeekCharacters.members[2].setCharacter(chars.length <= 2 ? "" : chars[2], weeks[curWeek].modName);
		yellowBG.color = weeks[curWeek].bgColor != null ? Std.parseInt(weeks[curWeek].bgColor) : 0xFFF9CF51;
		
		txtTracklist.text = (Translation.getTranslation("TRACKS", "storymenu")+"\n\n" + (weeks[curWeek].displaySongs != null ? weeks[curWeek].displaySongs : weeks[curWeek].songs).join("\n")+"\n");

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		setIntendedScore();
		#end
	}
}
