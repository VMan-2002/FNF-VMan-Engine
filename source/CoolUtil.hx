package;

import Paths;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxArrayUtil;
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


class CoolUtil
{
	public static var defaultDifficultyArray:Array<String> = ['Easy', "Normal", "Hard"];
	public static var difficultyArray:Array<String> = defaultDifficultyArray;

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
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	/**
		Returns an array containing values from `min` to `max`
	**/
	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
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
	public inline static function playMusic(name:String, ?volume:Float = 1) {
		playMusicRaw(Paths.music(name), name, volume);
	}

	/**
		Plays music using a sound asset
	**/
	public static function playMusicRaw(sndAsset, name:String, ?volume:Float = 1, ?bpm:Null<Float>) {
		FlxG.sound.playMusic(sndAsset, volume);
		//var musicInfo = CoolUtil.coolTextFile('music/${name}');
		//if (musicInfo.length > 0 && bpm == null)
		//	Conductor.changeBPM(Std.parseFloat(musicInfo[0]));
	}

	/**
		Plays menu music
	**/
	public static inline function playMenuMusic(?volume:Float = 1) {
		playMusic("freakyMenu", volume);
	}

	/**
		Create menu background as FlxSprite
	**/
	public static inline function makeMenuBackground(type:String = "", x:Float = 0, y:Float = 0):FlxSprite {
		var bg:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image('menuBG${type}'));
		bg.antialiasing = true;
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
		Parse JSON from file
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
	public static function useJson2Object(parser:Dynamic, input:String) {
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
		if (FileSystem.exists(modName + "/" + path)) {
			return File.getContent(modName + "/" + path);
		} else
		#end
		if (Assets.exists("assets/" + path)) {
			return Assets.getText("assets/" + path);
		}
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
		Clear members from a FlxTypeGroup or FlxSpriteGroup.

		Also sets the Group's `length` value to 0 (unless the group is already empty)
	**/
	public static function clearMembers(grp:OneOfTwo<FlxTypedGroup<Dynamic>, FlxSpriteGroup>) {
		var memb:Array<Dynamic> = Reflect.field(grp, "members"); //Typesafe is fucking my ass so i cant use grp.members
		if (memb == null || memb.length == 0) {
			return;
		}
		for (i in memb) {
			i.destroy();
		}
		memb.resize(0);
		@:privateAccess
		Reflect.setField(grp, "length", 0); //why
	}

	/**
		Push `val` to `arr` if it exists, otherwise return array containing `val`
	**/
	public static function addToArrayPossiblyNull<T>(arr:Array<T>, val:T) { //putting <T> there just works, interesting
		if (arr == null) {
			return [val];
		}
		arr.push(val);
		return arr;
	}

	/**
		Is it a letter
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
}
