package;

import Paths;
import Scripting.MyFlxColor;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BitmapData;

using StringTools;

#if !html5
import sys.FileSystem;
import sys.io.File;
#end

#if polymod
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
	public static function playMusicRaw(sndAsset, name:String, ?volume:Float = 1, ?loop:Bool = true) {
		FlxG.sound.playMusic(sndAsset, volume, loop);
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
	public static function clearMembers(grp:OneOfThree<FlxTypedGroup<Dynamic>, FlxSpriteGroup, FlxTypedSpriteGroup<Dynamic>>) {
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
		Does the string contain 1 or more letters (chars that uppercase/lowercase forms)
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

	//todo: Which one of these is fastest (and also works properly)
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

	/**
		Interpret string as bool
	**/
	public static function stringToBool(n:String) {
		return !(n == null || n.toLowerCase() == "false" || n == "" || n == "0");
	}

	/**
		Get a map value. If the specified key doesn't exist, use another value.
	**/
	public static function getMapKeyWithDefault<T1, T2>(map:Map<T1, T2>, key:T1, ?def:T2 = null):T2 {
		return map.exists(key) ? map.get(key) : def;
	}

	public function zag(num:Float) {
		return num % 2 > 1 ? -1 : 1;
	}

	public function lerp(a:Float, b:Float, t:Float) {
		return a + (b - a) * t;
	}

	/**
		Get average of 2 numbers
	**/
	public function centerof2(a:Float, b:Float) {
		return (a + b) / 2;
	}

	/**
		Get average of multiple numbers
	**/
	public function centerofmany(a:Array<Float>) {
		var result:Float = 0;
		for (thing in a)
			result += thing;
		return result / a.length;
	}

	/**
		If `num > 0`, return `1`. If `num < 0`, return `-1`. Otherwise, return `def`.
	**/
	public function sign(num:Float, ?def:Float = 0) {
		if (num == 0)
			return def;
		return num > 0 ? 1 : -1;
	}

	/**
		Self Aware

		Returns `"User"` if Self Awareness is disabled in options menu.

		Please use this responsibly, don't save or share it anywhere you sneaky fart. We want the players to trust us.
	**/
	public static function getComputerUsername() {
		if (Options.selfAware)
			return "User";
		//todo: this
		return "User";
	}

	/**
		Returns true if you're in playstate or any of it's variants

		`state` The state to check. If not specified, uses current state (`FlxG.state`)
	**/
	public static function isInPlayState(?state:FlxState = null) {
		switch(Type.getClass(state != null ? state : FlxG.state)) {
			case PlayState | PlayStateOffsetCalibrate | PlayStateMulti:
				return true;
			default:
				return false;
		}
	}

	public static function makeGradientRect(color1:FlxColor, color2:FlxColor, ?tilt:Float = 0) { //todo
		tilt = 0; //unimplemented
		var bitmap = new BitmapData(tilt == 0 ? 8 : 64, tilt == 0 ? 32 : 64, true, color1);
		
	}
	
	public static function parseColor(input:Null<String>):Null<Int> {
		if (input == null)
			return null;
		var col:Null<Int> = Std.parseInt(input.startsWith("0x") ? input : '0xff${input}');
		if (col == null || Math.isNaN(col))
			return MyFlxColor.d.exists(input) ? MyFlxColor.d.get(input) : null;
		return col;
	}

	public static function putInCamera(camera:FlxCamera, items:Array<FlxBasic>, ?replace:Bool = true) {
		for (thing in items) {
			if (replace)
				thing.cameras = [camera];
			else
				thing.cameras.push(camera);
		}
	}
}

class MultiStepResult {
	/**
		Array of all steps. You can use this to check if a specific step is fulfilled.
	**/
	public var steps:Array<Bool>;
	
	/**
		Function called when all steps are fulfilled.
	**/
	public var then:()->(Void);

	/**
		Wait until multiple steps are fulfilled (via `.fulfillStep` or `.fulfillNextStep`) and finish by calling a function. For example, this can be used for preloading and displaying assets.

		`steps`: How many steps need to be fulfilled before `then` is called.
		
		`then`: Function to run when all steps are fulfilled.
	**/
	public function new(steps:Int, then:()->(Void)) {
		this.steps = new Array<Bool>();
		while (this.steps.length < steps)
			this.steps.push(false);
		this.then = then;
	}

	/**
		Fulfill a step of index `num`. Returns `false` if that step or all steps are already fulfilled, `true` otherwise.
	**/
	public function fulfillStep(num:Int) {
		if (steps[num])
			return false;
		steps[num] = true;
		return checkCompleted();
	}

	/**
		Fulfill the first available unfulfilled step. Returns `false` if all steps are already fulfilled, `true` otherwise.
	**/
	public function fulfillNextStep() {
		var falseInd = steps.indexOf(false);
		if (falseInd == -1)
			return false;
		steps[falseInd] = true;
		return checkCompleted();
	}

	/**
		If all steps in this `MultiStepResult` are fulfilled, call `.then()` and return `true`, otherwise return `false`.
	**/
	public function checkCompleted() {
		if (steps.contains(false))
			return false;
		then();
		return true;
	}
}

class ScriptHelper {
	
	//CUSTOM EASINGSGS
	static var jumpThing:Float = 1.291;

	public static inline function jumpOut(t:Float) {
		return Math.sin(t * Math.PI) + t;
	}
	public static inline function jumpIn(t:Float) {
		return 1 - jumpOut(t);
	}
	public static inline function jumpInOut(t:Float) {
		return (Math.sin(t*Math.PI*2)*jumpThing)+t;
	}

	public static function getEaseFromString(name:String) {
		switch(name.toLowerCase().trim().replace(" ", "")) {
			case "sinein":
				return FlxEase.sineIn;
			case "sineout":
				return FlxEase.sineOut;
			case "sineinout" | "sine":
				return FlxEase.sineInOut;
			case "cubein":
				return FlxEase.cubeIn;
			case "cubeout":
				return FlxEase.cubeOut;
			case "cubeinout" | "cube":
				return FlxEase.cubeInOut;
			case "quadin":
				return FlxEase.quadIn;
			case "quadout":
				return FlxEase.quadOut;
			case "quadinout" | "quad":
				return FlxEase.quadInOut;
			case "quartin":
				return FlxEase.quartIn;
			case "quartout":
				return FlxEase.quartOut;
			case "quartinout" | "quart":
				return FlxEase.quartInOut;
			case "quintin":
				return FlxEase.quintIn;
			case "quintout":
				return FlxEase.quintOut;
			case "quintinout" | "quint":
				return FlxEase.quintInOut;
			case "smoothstepin":
				return FlxEase.smoothStepIn;
			case "smoothstepout":
				return FlxEase.smoothStepOut;
			case "smoothstepinout" | "smoothstep":
				return FlxEase.smoothStepInOut;
			case "smootherstepin":
				return FlxEase.smootherStepIn;
			case "smootherstepout":
				return FlxEase.smootherStepOut;
			case "smootherstepinout" | "smootherstep":
				return FlxEase.smootherStepInOut;
			case "bouncein":
				return FlxEase.bounceIn;
			case "bounceout" | "bounce":
				return FlxEase.bounceOut;
			case "bounceinout":
				return FlxEase.bounceInOut;
			case "circin":
				return FlxEase.circIn;
			case "circout":
				return FlxEase.circOut;
			case "circinout" | "circ":
				return FlxEase.circInOut;
			case "backin":
				return FlxEase.backIn;
			case "backout":
				return FlxEase.backOut;
			case "backinout" | "back":
				return FlxEase.backInOut;
			case "elasticin":
				return FlxEase.elasticIn;
			case "elasticout":
				return FlxEase.elasticOut;
			case "elasticinout" | "elastic":
				return FlxEase.elasticInOut;
			case "jumpin":
				return jumpIn;
			case "jumpout" | "jump":
				return jumpOut;
			case "jumpinout":
				return jumpInOut;
			case "linear":
				return FlxEase.linear;
		}
		trace("Lua: Cant find ease for \""+name+"\", using linear");
		return FlxEase.linear;
	}

	public static function getObjectSimple(name:String, state:MusicBeatState) {
		return Reflect.getProperty(state, name);
	}

	public static function getObject(name:String, state:MusicBeatState) {
		var thing:Dynamic = state;
		for (step in name.split(".")) {
			if (step.endsWith("]")) {
				thing = Reflect.getProperty(thing, step.substring(0, step.indexOf("[") - 1));
				while (true) {
					var ind:Dynamic = step.substring(step.indexOf("[") + 1, step.indexOf("]") - 1);
					thing = thing[ind];
					if (step.indexOf("]") == step.length) {
						break;
					}
					step = step.substr(step.indexOf("]") + 1);
				}
			} else {
				thing = Reflect.getProperty(thing, step);
			}
		}
		return thing;
	}
}