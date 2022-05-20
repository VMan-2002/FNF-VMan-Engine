package;

import lime.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxG;
import Paths;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.format.JsonParser;
import haxe.Json;
#if polymod
import polymod.backends.PolymodAssets;
#end

using StringTools;

class CoolUtil
{
	public static var defaultDifficultyArray:Array<String> = ['Easy', "Normal", "Hard"];
	public static var difficultyArray:Array<String> = defaultDifficultyArray;

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function difficultyPostfixString(?diff:Null<Int> = null):String
	{
		var d = difficultyArray[diff == null ? PlayState.storyDifficulty : diff].toLowerCase();
		if (d == "normal") {
			return "";
		}
		return '-${d}';
	}

	inline public static function uncoolTextFile(path:String):Array<String>
	{
		//return Paths.getTextAsset('${path}.txt', TEXT, null).trim().split('\n');
		var thing = Assets.getText('assets/'+path+'.txt').trim().split('\n');
		trace('uncool text file');
		trace(thing.length);
		trace(thing[0]);
		return thing;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = uncoolTextFile(path);
		
		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	
	public static function playSongMusic(name:String, ?volume:Float = 1) {
		playMusicRaw(Paths.inst(name), name, volume);
	}
	
	public static function playMusic(name:String, ?volume:Float = 1) {
		playMusicRaw(Paths.music(name), name, volume);
	}
	
	public static function playMusicRaw(sndAsset, name:String, ?volume:Float = 1, ?bpm:Null<Float>) {
		FlxG.sound.playMusic(sndAsset, volume);
		//var musicInfo = CoolUtil.coolTextFile('music/${name}');
		//if (musicInfo.length > 0 && bpm == null)
		//	Conductor.changeBPM(Std.parseFloat(musicInfo[0]));
	}
	
	public static inline function playMenuMusic(?volume:Float = 1) {
		playMusic("freakyMenu", volume);
	}
	
	public static inline function makeMenuBackground(type:String = "", x:Float = 0, y:Float = 0):FlxSprite {
		var bg:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image('menuBG${type}'));
		bg.antialiasing = true;
		return bg;
	}
	
	public static function CenterOffsets(spr:FlxSprite) {
		var fun = spr.frames.frames[spr.animation.curAnim.frames[0]].sourceSize;
		spr.offset.x = fun.x/2;
		spr.offset.y = fun.y/2;
	}
	
	public static function loadJsonFromString(rawJson:String):Dynamic {
		rawJson = rawJson.trim();
		if (!rawJson.endsWith("}")) {
			return Json.parse(rawJson.substr(0, rawJson.lastIndexOf("}")));
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}
		return Json.parse(rawJson);
	}
	
	public static function loadJsonFromFile(thing:String) {
		return loadJsonFromString(Assets.getText(thing));
	}
}
