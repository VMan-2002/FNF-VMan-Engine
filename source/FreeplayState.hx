package;

#if desktop
import Discord.DiscordClient;
#end
import CoolUtil;
import Translation;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;
#if polymod
import json2object.JsonParser;
import polymod.Polymod.Framework;
import polymod.Polymod;
#if !html5
import sys.FileSystem;
import sys.io.File;
#end
#end


class SwagFreeplayFolders {
	public var groupName:String;
	public var folderIcons:Map<String, String>;
	public var initFolder:String;
	public var categories:Map<String, Array<Array<String>>>;
	public var iAmCornflower:Bool;
}

class FreeplayState extends MusicBeatState
{
	public var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	public var scoreText:FlxText;
	public var scoreFCText:FlxText;
	public var scoreAccText:FlxText;
	public var diffText:FlxText;
	public var lerpScore:Int = 0;
	public var intendedScore:Int = 0;
	public var folderDirText:FlxText;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	private var icon2Array:Array<FolderIcon> = [];
	
	var categories:Map<Int, Array<SongMetadata>>;
	public static var inFolder:Array<Int> = [0];
	public var folderNames:Array<String> = [Translation.getTranslation("root folder", "freeplay", null, "Freeplay")];
	var nextCategoryInt:Int = 0;
	var nothingIncluded:Bool = false;

	var isCornflower:Bool = false; //too lazy to implement scripting right now, so it's hardcoded
	var cornflowerMenus:Array<Int> = new Array<Int>();
	var cornflowerClass:CornflowerFreeplay;

	override function create()
	{
		var uncategorized:Array<SongMetadata> = [];
		var initSonglist = CoolUtil.coolTextFile("data/freeplaySonglist");

		for (i in 0...initSonglist.length)
		{
			if (initSonglist[i].length > 0) {
				trace('added song ${initSonglist[i]} to uncat');
				uncategorized.push(new SongMetadata(initSonglist[i], 1, 'face'));
			} else {
				trace('there are no 0-char song names allowed!');
			}
		}
		
		
		var categoryList = new Array<SongMetadata>();
		
		categories = new Map<Int, Array<SongMetadata>>();
		
		var noFolders = new Array<SongMetadata>();
		
		nextCategoryInt = 1;
		
		#if !html5
		for (iathing in ModLoad.enabledMods) {
			var parser = new JsonParser<SwagFreeplayFolders>();
			//load it manually so it wont conflict with other mods!
			var filelol = 'mods/${iathing}/folders_freeplay.json';
			if (FileSystem.exists(filelol)) {
				trace('adding folder structure for $filelol');
				var rawJson:String = File.getContent(filelol);
				if (!rawJson.endsWith("}")) {
					rawJson = rawJson.substr(0, rawJson.lastIndexOf("}"));
				}
				
				var folderStructure:SwagFreeplayFolders = parser.fromJson(rawJson);
				var iAmCornflower = folderStructure.iAmCornflower;
				
				var folderIds = new Map<String, Int>();
				var folderRootPut = 0;
				//find where folders should go in the int-based system
				for (cat in folderStructure.categories.keys()) {
					folderIds.set(cat, nextCategoryInt);
					folderNames[nextCategoryInt] = cat;
					if (cat == folderStructure.initFolder) {
						folderRootPut = nextCategoryInt;
					}
					nextCategoryInt += 1;
				}
				//then make the the
				for (cat in folderStructure.categories.keys()) {
					var items:Array<Array<String>> = folderStructure.categories.get(cat);
					var resultItems = new Array<SongMetadata>();
					for (thing in items) {
						switch(thing[1]) {
							case "folder":
								resultItems.push(new SongMetadata(thing[0], folderIds[thing[0]], Character.getHealthIcon(folderStructure.folderIcons.get(thing[0]), iathing), 1, iathing));
							default:
								var icon = "face";
								var songStuffPath = 'mods/${iathing}/data/${Highscore.formatSong(thing[0])}/song.txt';
								var diffAdd = "";
								if (FileSystem.exists(songStuffPath)) {
									var thing = File.getContent(songStuffPath).split("\n");
									var charstuff:Array<String> = thing[2].split("::");
									icon = Character.getHealthIcon(charstuff[charstuff.length > 1 ? 1 : 0].trim(), iathing);
									if (thing.length > 4) {
										diffAdd = thing[4];
									}
								}
								var justAdd = new SongMetadata(thing[0], 0, icon, 0, iathing, diffAdd);
								resultItems.push(justAdd);
								noFolders.push(justAdd);
						}
					}
					categories.set(folderIds[cat], resultItems);
				}
				
				//add to category list
				trace('added ${iathing} (name ${folderStructure.groupName}) to category list');
				categoryList.push(new SongMetadata(folderStructure.groupName, folderRootPut, folderStructure.folderIcons.get(folderStructure.initFolder), 1, iathing));
				folderNames[folderRootPut] = folderStructure.groupName;
				if (iAmCornflower) {
					cornflowerMenus.push(folderRootPut);
					if (!Options.freeplayFolders) {
						iAmCornflower = true; //if you're not using folders, you're a cornflower
					}
				}
			} else {
				trace('not adding folder structure for $filelol');
			}
		}
		#end
		
		if (Options.freeplayFolders) {
			if (uncategorized.length > 0) {
				categories.set(nextCategoryInt, uncategorized);
				categoryList.push(new SongMetadata(Translation.getTranslation("Uncategorized", "freeplay"), nextCategoryInt, "face", 1));
			}
			
			nextCategoryInt += 1;
			
			categories.set(0, categoryList);
			
			if (!categories.exists(inFolder[inFolder.length - 1])) {
				inFolder = [0];
			}
			if (inFolder.length == 1 && !categories.keys().hasNext()) {
				while (categories.get(inFolder[0]).length == 1 && categories.get(inFolder[0])[0].type == 1) {
					inFolder[0] = categories.get(inFolder[0])[0].week;
				}
			}
		} else {
			/*//if (StoryMenuState.weekUnlocked[6] || isDebug)
			if (inFolder.length > 1) {
				//todo: put an achievement here? when i implement achievemnets anyway
				//name "when ur bad at office"
				//description "How can you fail at folders!?"
				categories.set(-4, [new SongMetadata('oof', 0, 'face', 1)]);
				inFolder = [-1, -4]; //Yes, there's otherwise a crash when you have folders enabled, enter a song in a folder in freeplay, enter options, disable folders, exit options, then exit the song.
			} else {
				categories = [
					-1 => uncategorized
					.concat(returnWeek(['Tutorial'], 0, ['gf']))
					.concat(returnWeek(['Bopeebo', 'Fresh', 'Dad Battle'], 1, ['dad']))
					.concat(returnWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky']))
					.concat(returnWeek(['Pico', 'Philly Nice', 'Blammed'], 3, ['pico']))
					.concat(returnWeek(['Satin Panties', 'High', 'Milf'], 4, ['mom']))
					.concat(returnWeek(['Cocoa', 'Eggnog', 'Winter Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']))
					.concat(returnWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']))
				];
				inFolder = [-1]; //Yes, there's otherwise a crash when you have folders enabled, enter a song in a folder in freeplay, enter options, disable folders, exit options, then exit the song.
			}*/
		}
		

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresenceSimple("freeplay");
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = CoolUtil.makeMenuBackground('Blue');
		add(bg);

		folderDirText = new FlxText(2, 2, FlxG.width - 4, "hi :)", 12);
		if (Options.freeplayFolders) {
			add(folderDirText);
		}
		if (Options.showFPS) {
			folderDirText.y += 16; //so it's not on top of the fps counter
		}
		
		makeSonglist(Options.freeplayFolders ? categories.get(inFolder[inFolder.length-1]) : noFolders);
		
		nothingIncluded = songs.length <= 0;
		
		if (nothingIncluded) {
			var txt:FlxText = new FlxText(0, 0, FlxG.width,
				Translation.getTranslation("no songs", "freeplay"),
			32);
			txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
			txt.screenCenter();
			add(txt);
			return;
		}

		scoreText = new FlxText(FlxG.width, 5, FlxG.width, Translation.getTranslation("personal best", "freeplay", ["1234567890"]), 32);
		scoreText.x -= scoreText.textField.textWidth + 2;
		scoreText.fieldWidth -= scoreText.x;
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		Translation.setObjectFont(scoreText, "vcr font");
		// scoreText.alignment = RIGHT;
		
		folderDirText.font = scoreText.font;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0);
		scoreBG.makeGraphic(Std.int(FlxG.width + 1 - scoreBG.x), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		var scoreBG2:FlxSprite = new FlxSprite(0, scoreBG.height);
		add(scoreBG2);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, scoreText.fieldWidth, "", 24);
		diffText.font = scoreText.font;
		diffText.alignment = scoreText.alignment;
		add(diffText);

		add(scoreText);

		scoreFCText = new FlxText(FlxG.width, 60, FlxG.width, "Clear (1000)", 32);
		scoreFCText.x -= scoreFCText.textField.textWidth + 2;
		scoreFCText.fieldWidth -= scoreFCText.x;
		// scoreFCText.autoSize = false;
		scoreFCText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		Translation.setObjectFont(scoreFCText, "vcr font");

		scoreAccText = new FlxText(FlxG.width, 90, FlxG.width, "99.99%", 32);
		scoreAccText.x -= scoreAccText.textField.textWidth + 2;
		scoreAccText.fieldWidth -= scoreAccText.x;
		// scoreAccText.autoSize = false;
		scoreAccText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);
		Translation.setObjectFont(scoreAccText, "vcr font");
		
		scoreFCText.x = Math.min(scoreFCText.x, scoreAccText.x);
		scoreAccText.x = scoreFCText.x;
		add(scoreFCText);
		add(scoreAccText);

		scoreBG2.makeGraphic(Std.int(FlxG.width + 1 - scoreFCText.x), 66, 0xFF000000);
		scoreBG2.x = FlxG.width - scoreBG2.width;
		scoreBG2.alpha = 0.6;

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		//selector = new FlxText();

		//selector.size = 40;
		//selector.text = ">";
		// add(selector);

		//var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */
		if (Options.freeplayFolders && cornflowerMenus.indexOf(inFolder[1]) > -1) {
			isCornflower = true;
		}
		
		if (isCornflower) {
			updateIsCornflower();
			cornflowerClass.makeSonglist(this);
		}

		super.create();
	}
	
	public function makeSonglist(list:Array<SongMetadata>) {
		songs = list;
		
		remove(grpSongs);
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);
		
		while (iconArray.length != 0) {
			remove(iconArray.pop());
		}
		
		while (icon2Array.length != 0) {
			remove(icon2Array.pop());
		}

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			var folder:FolderIcon = new FolderIcon();

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter, false, songs[i].mod);
			icon.sprTracker = songText;
			folder.sprTracker = icon;
			if (songs[i].type == 1) {
				icon2Array.push(folder);
				folder.x = icon.x;
				folder.y = icon.y;
				folder.setTheme(icon.folderType);
				add(folder);
			}

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
			icon.addChildrenToScene();

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		var slash = Translation.getTranslation("folder seperator", "freeplay", null, "/");
		folderDirText.text = inFolder.map(function(a:Int):String {return folderNames[a];}).join(slash)+slash;
		if (isCornflower) {
			cornflowerClass.makeSonglist(this);
		}
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null || songCharacters.length <= 0)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (num + 1 < songCharacters.length)
				num++;
		}
	}

	public function returnWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		var result = new Array<SongMetadata>();
		if (songCharacters == null || songCharacters.length <= 0)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			result.push(new SongMetadata(song, weekNum, songCharacters[num]));

			if (num + 1 < songCharacters.length)
				num++;
		}
		return result;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		if (nothingIncluded) {
			if (controls.BACK) {
				MainMenuState.returnToMenuFocusOn("freeplay");
			}
			return;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (scoreText.visible) {
			scoreText.text = Translation.getTranslation("personal best", "freeplay", [Std.string(lerpScore)]);
		}
		
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK) {
			if (inFolder.length > 1) {
				if (cornflowerMenus.indexOf(inFolder[inFolder.length-1]) > -1) {
					isCornflower = false; //you are no longer Corn flower
					updateIsCornflower();
				}
				var was = inFolder.pop();
				makeSonglist(categories.get(inFolder[inFolder.length-1]));
				curSelected = 0;
				for (i in 0...songs.length) {
					if (songs[i].week == was && songs[i].type == 1) {
						curSelected = i;
						break;
					}
				}
				changeSelection();
			} else {
				if (cornflowerClass != null) {
					cornflowerClass.destroy();
				}
				MainMenuState.returnToMenuFocusOn("freeplay");
			}
		}

		if (accepted) {
			if (songs[curSelected].type == 1) {
				//a folder
				if (cornflowerMenus.indexOf(songs[curSelected].week) > -1) {
					isCornflower = true; //This is corn flower
					updateIsCornflower();
				}

				inFolder.push(songs[curSelected].week);
				makeSonglist(categories.get(songs[curSelected].week));
				curSelected = 0;
				changeSelection();
			} else {
				//a song
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

				trace(poop);
				
				ModLoad.primaryMod = songs[curSelected].mod;

				PlayState.modName = ModLoad.primaryMod;
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				//PlayState.storyWeek = songs[curSelected].week;
				PlayState.storyWeek = "week1";
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
	}

	function updateIsCornflower() {
		if (isCornflower) {
			if (cornflowerClass == null) {
				cornflowerClass = new CornflowerFreeplay(this);
			} else {
				cornflowerClass.enable();
			}
		} else {
			if (cornflowerClass != null) {
				cornflowerClass.disable();
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		var was = curDifficulty;
		curDifficulty += change;
		
		var diffAmnt = CoolUtil.difficultyArray.length;

		if (curDifficulty < 0)
			curDifficulty = diffAmnt - 1;
		if (curDifficulty >= diffAmnt)
			curDifficulty = 0;

		updateScoreDisp();

		trace('change diff from ${was} to ${curDifficulty}');
		
		diffText.text = Translation.getTranslation(CoolUtil.difficultyString(curDifficulty), "difficulty") + Highscore.getModeString();
	}

	function updateScoreDisp()
	{
		#if !switch
		var songSel = songs[curSelected];
		if (songSel.type == 0) {
			var songId = '${songSel.mod}:${songSel.songName}';
			intendedScore = Highscore.getScore(songId, curDifficulty, true);
			if (scoreFCText == null) {
				return;
			}
			scoreFCText.text = Highscore.getFCFormatted(songId, curDifficulty, true);
			scoreAccText.text = HudThing.trimPercent(Highscore.getAcc(songId, curDifficulty, true));
		}
		#end
		if (isCornflower) {
			cornflowerClass.changeDifficulty(this);
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		//NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var songSel = songs[curSelected];
		PlayState.modName = songSel.mod;

		updateScoreDisp();

		#if PRELOAD_ALL
		if (songSel.type == 0) {
			CoolUtil.playSongMusic(songSel.songName, 0);
		}
		#end
		if (songSel.type == 0) {
			scoreText.visible = true;
			//load difficulty stuf
			var songDiff = songSel.difficulties.length == 0 ? CoolUtil.defaultDifficultyArray : songSel.difficulties;
			if (songDiff != CoolUtil.difficultyArray) {
				var prevDifficulty = CoolUtil.difficultyString(curDifficulty).toLowerCase();
				CoolUtil.difficultyArray = songDiff;
				curDifficulty = songDiff.map(function(a) return a.toLowerCase()).indexOf(prevDifficulty);
				if (curDifficulty < 0) {
					curDifficulty = 0;
				}
				trace('difficulty arr is now ${CoolUtil.difficultyArray.join(",")}');
				changeDiff(0);
			}
		} else {
			scoreText.visible = false;
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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
		if (isCornflower) {
			cornflowerClass.changeSelection(this);
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var type:Int = 0; //0: song, 1: folder
	public var mod:String;
	public var difficulties:Array<String> = new Array<String>();

	public function new(song:String, week:Int, songCharacter:String, ?type:Int = 0, ?mod:String = "", ?diffInput:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.type = type;
		this.mod = mod;
		this.difficulties = diffInput.trim() == "" ? [] : diffInput.split(",").map(function(a) return a.trim()).filter(function(a) return a != "");
	}
}
