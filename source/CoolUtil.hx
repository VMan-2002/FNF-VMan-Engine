package;

import Paths;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.OneOfTwo;
import haxe.Json;
import haxe.format.JsonParser;
import json2object.JsonParser;
import lime.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

#if !html5
import sys.FileSystem;
import sys.io.File;
#end

#if polymod
import polymod.backends.PolymodAssets;
#end

typedef TwoStrings = {
	one:String,
	two:String
}

class CoolUtil
{
	public static var defaultDifficultyArray:Array<String> = ['Easy', "Normal", "Hard"];
	public static var difficultyArray:Array<String> = defaultDifficultyArray;
	public static var mainMusicTime:Float = 0;
	public static var playingMainMusic:Bool = false;

	/**
		Switch difficulty array, and keep the current difficulty if possible. Assumes the difficulty is stored on `object` as an `Int` as an index in `CoolUtil.difficultyArray`.
		
		If the current difficulty can't be kept, switch to Normal if possible.

		Returns true if the current difficulty was successfully retained, regardless of whether or not the difficulty number changed.
	**/
	public static function setNewDifficulties(newDiffs:Null<Array<String>>, object:Dynamic, diffVar:String) {
		if (newDiffs == null || newDiffs.length == 0)
			newDiffs = defaultDifficultyArray;
		if (difficultyArray.map(function(a) {return a.toLowerCase();}) != newDiffs.map(function(a) {return a.toLowerCase();})) {
			var oldDiff = CoolUtil.difficultyArray[Reflect.getProperty(object, diffVar)].toLowerCase();
			CoolUtil.difficultyArray = newDiffs;
			var normalPos:Int = 0;
			for (aDiff in CoolUtil.difficultyArray) {
				if (aDiff.toLowerCase() == oldDiff) {
					Reflect.setProperty(object, diffVar, CoolUtil.difficultyArray.indexOf(aDiff));
					return true;
				} else if (aDiff.toLowerCase() == "normal") {
					normalPos = CoolUtil.difficultyArray.indexOf(aDiff);
				}
			}
			Reflect.setProperty(object, diffVar, normalPos);
			return false;
		}
		return true;
	}

	/**
		Returns difficulty from number to string
	**/
	public static function difficultyString(?num:Null<Int> = null):String {
		return difficultyArray[num == null ? PlayState.storyDifficulty : num];
	}

	/**
		Returns difficulty from number to string as a postfix
	**/
	public static function difficultyPostfixString(?diff:Null<Int> = null):String
	{
		var d = difficultyArray[diff == null ? PlayState.storyDifficulty : diff].toLowerCase();
		if (d == "normal") {
			return "";
		}
		return '-${d}';
	}

	/**
		Returns lines from a text file
	**/
	inline public static function uncoolTextFile(path:String):Array<String>
	{
		//return Paths.getTextAsset('${path}.txt', TEXT, null).trim().split('\n');
		var thing = Assets.getText('assets/'+path+'.txt').trim().split('\n');
		trace('uncool text file');
		trace(thing.length);
		trace(thing[0]);
		return thing;
	}

	/**
		Returns trimmed lines from a text file
	**/
	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = uncoolTextFile(path);
		
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	/**
		Returns an array containing `Int` values from `min` to `max`
	**/
	public static function numberArray(max:Int, ?min:Int = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
			dumbArray.push(i);
		return dumbArray;
	}

	/**
		Plays a song instrumental
	**/
	public inline static function playSongMusic(name:String, ?volume:Float = 1) {
		playMusicRaw(Paths.inst(name), name, volume);
	}

	/**
		Plays audio from music folder
	**/
	public inline static function playMusic(name:String, ?volume:Float = 1, ?bpm:Null<Float> = null) {
		if (playingMainMusic) {
			mainMusicTime = FlxG.sound.music.time;
			playingMainMusic = false;
		}
		playMusicRaw(Paths.music(name), name, volume);
		if (Assets.exists(Paths.music(name).replace(Paths.SOUND_EXT, "txt"))) {
			var musicInfo = CoolUtil.coolTextFile('music/${name}');
			if (musicInfo.length > 0 && bpm == null)
				Conductor.changeBPM(Std.parseFloat(musicInfo[0]));
		}
	}

	/**
		Plays music using a sound asset
	**/
	public static function playMusicRaw(sndAsset, name:String, ?volume:Float = 1, ?bpm:Null<Float> = null) {
		FlxG.sound.playMusic(sndAsset, volume);
	}

	/**
		Plays menu music
	**/
	public static inline function playMenuMusic(?volume:Float = 1) {
		if (!playingMainMusic) {
			playMusic("freakyMenu", volume);
			FlxG.sound.music.time = mainMusicTime;
			playingMainMusic = true;
		}
	}

	/**
		Reset menu music
	**/
	public static inline function resetMenuMusic() {
		playingMainMusic = false;
		mainMusicTime = 0;
	}

	/**
		Create menu background as FlxSprite
	**/
	public static function makeMenuBackground(type:String = "", x:Float = 0, y:Float = 0):FlxSprite {
		var bg:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image('menuBG${type}'));
		bg.antialiasing = true;
		bg.moves = false;
		return bg;
	}
	
	/**
		Set the offset on center of sprite
	**/
	public static function CenterOffsets(spr:FlxSprite) {
		if (spr.animation.curAnim == null) {return;}
		var fun = spr.frames.frames[spr.animation.curAnim.frames[0]].sourceSize;
		spr.offset.x = fun.x/2;
		spr.offset.y = fun.y/2;
	}
	
	/**
		Parse JSON string
	**/
	public static function loadJsonFromString(rawJson:String):Dynamic {
		rawJson = rawJson.trim();
		if (!rawJson.endsWith("}")) {
			return Json.parse(rawJson.substr(0, rawJson.lastIndexOf("}")));
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}
		return Json.parse(rawJson);
	}
	
	/**
		Parse JSON from text file asset
	**/
	public static function loadJsonFromFile(thing:String) {
		return loadJsonFromString(Assets.getText(thing));
	}
	
	/**
		Return `val` clamped between `min` and `max`
	**/
	public static function clamp(val:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, val));
	}
	
	/**
		Return a value using Json2Object
	**/
	public static function useJson2Object(parser:Dynamic, input:String):Dynamic {
		if (!input.endsWith("}")) {
			input = input.substr(0, input.lastIndexOf("}"));
		}
		var result = parser.fromJson(input);
		return result;
	}
	
	/**
		Attempt path from mod folder, then assets
	**/
	public static function tryPathBoth(path:String, modName:String) {
		#if !html5
		var modPath:String = "mods/" + modName + "/" + path;
		trace("tryPathBoth mod folder "+modPath);
		if (FileSystem.exists(modPath)) {
			trace("tryPathBoth use modfolder path");
			return File.getContent(modPath);
		} else
		#end
		{
			var anotherPath:String = "assets/" + path;
			if (Assets.exists(anotherPath)) {
				trace("tryPathBoth use assets path");
				return Assets.getText(anotherPath);
			}
		}
		trace("tryPathBoth not found");
		return null;
	}
	
	/**
		Attempt path from mod folder, then assets, returns path instead of asset
	**/
	public static function tryPathBothReturnPath(path:String, modName:String, ?assetLibPrefix:String = "") {
		#if !html5
		var modPath:String = "mods/" + modName + "/" + path;
		trace("tryPathBothReturnPath mod folder "+modPath);
		if (FileSystem.exists(modPath)) {
			trace("tryPathBothReturnPath use modfolder path");
			return modPath;
		} else
		#end
		{
			var anotherPath:String = "assets/" + assetLibPrefix + path;
			trace("tryPathBothReturnPath asset folder "+anotherPath);
			if (Assets.exists(anotherPath)) {
				return anotherPath;
			}
		}
		trace("tryPathBothReturnPath not found");
		return null;
	}
	
	/**
		Return directory items if the folder exists, otherwise return empty array
	**/
	public static function readDirectoryOptional(folder:String) {
		return (FileSystem.exists(folder) && FileSystem.isDirectory(folder)) ? FileSystem.readDirectory(folder) : new Array<String>();
	}
	
	/**
		If `string` starts with `sub`, cut `sub` from the start
	**/
	public static function trimFromStart(str:String, sub:String) {
		if (str.startsWith(sub)) {
			return str.substr(sub.length);
		}
		return str;
	}
	
	/**
		If `string` ends with `sub`, cut `sub` from the end
	**/
	public static function trimFromEnd(str:String, sub:String) {
		if (str.endsWith(sub)) {
			return str.substr(0, str.length - sub.length);
		}
		return str;
	}

	/**
		Clear members from a `FlxTypedGroup` or `FlxSpriteGroup`.

		Also sets the Group's `length` value to 0 (unless the group is already empty)
	**/
	public static function clearMembers(grp:OneOfTwo<FlxTypedGroup<Dynamic>, FlxSpriteGroup>) {
		var memb:Array<Dynamic> = Reflect.field(grp, "members"); //Typesafe is fucking my ass so i cant use grp.members
		if (memb == null || memb.length == 0)
			return;
		for (i in memb)
			i.destroy();
		memb.resize(0);
		@:privateAccess
		Reflect.setField(grp, "length", 0); //why
	}

	/**
		Push `val` to `arr` if it exists, otherwise return array containing `val`
	**/
	public static function addToArrayPossiblyNull<T>(arr:Array<T>, val:T) { //putting <T> there just works, interesting
		if (arr == null)
			return [val];
		arr.push(val);
		return arr;
	}

	/**
		Does the string contain 1 or more letters
	**/
	public static inline function isLetters(s:String) {
		return s.toUpperCase() != s.toLowerCase();
	}

	/**
		Split camelCase
	**/
	public static function splitCamelCase(s:String) {
		var p = isLetters(s) && s.charAt(0).toUpperCase() == s.charAt(0) ? 1 : 0;
		var r = new Array<String>();
		while (p < s.length) {
			if ((isLetters(s) && s.charAt(p).toUpperCase() == s.charAt(p)) || (isLetters(s.charAt(p - 1)) && !isLetters(s.charAt(p)))) {
				r.push(s.substring(0, p - 1));
				s = s.substr(p);
			}
		}
		r.push(s);
		return r;
	}

	/**
		Capitalize first letter of the string

		`s`: The string
		
		`restLowercase`: Make the rest lowercase
	**/
	public static inline function capitalizeFirstLetter(s:String, ?restLowercase:Bool = false) {
		return s.charAt(0).toUpperCase() + (restLowercase ? s.substr(1).toLowerCase() : s.substr(1));
	}

	/**
		Position something or whatever
	**/
	public static function positionValueWithin(width:Float, containerWidth:Float, fract:Float):Float {
		return (containerWidth - width) * fract;
	}

	/**
		Position a sprite within a container (default is game window size) using fraction and offset
	**/
	public static function positionObjectWithin(object:FlxSprite, ?fractWidth:Float = 0.5, ?fractHeight:Float = 0.5, ?offsetX:Float = 0, ?offsetY:Float = 0, ?containerWidth:Null<Float>, ?containerHeight:Null<Float>) {
		object.x = positionValueWithin(object.width, containerWidth == null ? FlxG.width : containerWidth, fractWidth) + offsetX;
		object.y = positionValueWithin(object.height, containerHeight == null ? FlxG.height : containerHeight, fractHeight) + offsetY;
	}

	/**
		Arr order: offsetx, offsety, fractx, fracty
	**/
	public static function arrPositionObjectWithin(object:FlxSprite, array:Array<Float>, ?containerWidth:Null<Float>, ?containerHeight:Null<Float>) {
		positionObjectWithin(object, array.length < 3 ? 0 : array[2], array.length < 4 ? 0 : array[3], array.length < 1 ? 0 : array[0], array.length < 2 ? 0 : array[1], containerWidth, containerHeight);
	}

	/**
		If the named array doesn't exist in the map, then position is not changed.
			
		Arr order: offsetx, offsety, fractx, fracty
	**/
	public static function mapPositionObjectWithin(object:FlxSprite, map:Map<String, Array<Float>>, name:String, ?containerWidth:Null<Float>, ?containerHeight:Null<Float>) {
		if (!map.exists(name))
			return;
		arrPositionObjectWithin(object, map.get(name), containerWidth, containerHeight);
	}

	/**
		If resource is formatted as `mod:resource`, `resource` and `mod` are returned from that instead.

		Return values:

		`one`: `resource`

		`two`: `mod`
	**/
	public static function splitNamespace(resource:String, mod:String):TwoStrings {
		var pos = resource.indexOf(":");
		if (pos == -1)
			return {one: resource, two: mod};
		return {one: resource.substring(pos + 1), two: resource.substring(0, pos - 1)};
	}

	/**
		Setup PlayState to play a song. Doesn't switch to the state immediately though.
		
		Calling this while PlayState is active is bound to cause weird behaviour, so please don't do that (or at least be VERY careful).
		
		Doesn't set `PlayState.storyDifficulty` or `PlayState.isStoryMode` variables, you should do those before calling this function!
	**/
	public static function setupPlayState(songName:String, ?modName:Null<String>, ?week:Null<String>, ?difficulty:Null<String>) {
		if (modName == null)
			PlayState.modName = modName;
		
		ModLoad.primaryMod = ModsMenuState.quickModJsonData(PlayState.modName);
		
		var songStuffPath = 'mods/${PlayState.modName}/data/${Highscore.formatSong(songName)}/song.txt';
		if (FileSystem.exists(songStuffPath)) {
			var thing = File.getContent(songStuffPath).split("\n");
			if (thing.length > 4) {
				CoolUtil.setNewDifficulties(thing[4].split(",").map(a -> a.trim()), PlayState, "storyDifficulty");
			} else {
				CoolUtil.setNewDifficulties(null, PlayState, "storyDifficulty");
			}
		}

		if (difficulty != null) {
			if (!CoolUtil.difficultyArray.contains(difficulty))
				difficulty = "Normal";
			PlayState.storyDifficulty = CoolUtil.difficultyArray.contains(difficulty) ? CoolUtil.difficultyArray.indexOf(difficulty) : 0;
		}

		var poop:String = Highscore.formatSong(songName, PlayState.storyDifficulty);

		trace(poop);

		PlayState.SONG = Song.loadFromJson(poop, songName);
		PlayState.usedBotplay = false;

		//PlayState.storyWeek = songs[curSelected].week;
		PlayState.storyWeek = week == null ? "" : week;
		trace('CUR WEEK' + PlayState.storyWeek);
		CoolUtil.resetMenuMusic();
	}

	/**
		Play a song in PlayState.
		
		Doesn't set `PlayState.storyDifficulty` or `PlayState.isStoryMode` variables, you should do those before calling this function!
	**/
	public static inline function playSongState(songName:String, ?modName:Null<String>, ?week:Null<String>, ?difficulty:Null<String>) {
		setupPlayState(songName, modName, week, difficulty);
		return LoadingState.loadAndSwitchState(new PlayState());
	}

	/**
		Rounding stuff that makes numbers cool
	**/
	public static function roundingStuff(num:Float) {
		final numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
		inline function addNumberS(a, b) {
			//return numbers[(numbers.indexOf(a) + b) % 10];
			return Std.string(Std.parseInt(a) + b);
		}
		var base:Int = num < 0 ? Math.ceil(num) : Math.floor(num);
		var decimal:Int = Math.floor(Math.abs(num - base) * 100000);
		var sDecimal = Std.string(decimal).split("");
		var i:Int = 3;
		while (i > 1) {
			switch(i) {
				case 3:
					if (numbers.indexOf(sDecimal[3]) >= 8) {
						sDecimal[2] = addNumberS(sDecimal[2], 1);
						sDecimal[3] = "0";
					}
				default:
					if (numbers.indexOf(sDecimal[i]) <= 2) {
						sDecimal[i] = "0";
					} else if (numbers.indexOf(sDecimal[i]) >= 7) {
						sDecimal[i - 1] = addNumberS(sDecimal[i], 1);
						sDecimal[i] = "0";
					}
			}
			i -= 1;
		}
		return Std.parseFloat(base + "." + sDecimal.join(""));
	}

	/**
		Rounding stuff that makes numbers cool (version 2)
	**/
	public static function roundingStuff2(num:Float) {
		var base:Int = num < 0 ? Math.ceil(num) : Math.floor(num);
		var decimal = Std.string(Math.floor(Math.abs(num - base))).split("");
		var resultDecimal:Int = 0;
		var i = decimal.length - 1;
		while (i > 1) {
			var n = Std.parseInt(decimal[i]);
			if (n <= 1)
				continue;
			if (n >= 9)
				n = 10;
			resultDecimal += n * (10 ^ (i + 1));
			i -= 1;
		}
		return Std.parseFloat(base + "." + decimal.join(""));
	}

	/**
		Rounding stuff that makes numbers cool (version 3)
	**/
	public static function roundingStuff3(num:Float) {
		var base:Int = num < 0 ? Math.ceil(num) : Math.floor(num);
		var decimal = Std.string(Math.floor(Math.abs(num - base))).split("");
		var i = decimal.length > 3 ? 3 : decimal.length - 1;
		while (i > 0) {
			var l = i <= 1;
			var n = Std.parseInt(decimal[i]);
			if (n > (l ? 1 : 2) && n < (l ? 8 : 9))
				return FlxMath.roundDecimal(num, i);
			i -= 1;
		}
		return base;
	}
}
