package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if MODS
import sys.io.File;
import sys.FileSystem;
import flash.display.BitmapData;
import flash.media.Sound;
#end
import Options;
import flixel.system.FlxAssets.FlxSoundAsset;
import lime.utils.Assets;
import lime.graphics.Image;
import flash.display.BitmapData;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}
	
	#if MODS
	static function doesModHaveThing(path:String):String {
		for (i in modsActive) {
			var p = 'mods/${i}/${path}';
			if (FileSystem.exists(p)) {
				//trace('found ${path} in ${i}');
				return p;
			}
		}
		return "";
	}
	#else
	inline function doesModHaveThing(path:String):String {
		return "";
	}
	#end

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		var levelPath = getLibraryPathForce(file, "shared");
		if (OpenFlAssets.exists(levelPath, type))
			return levelPath;

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${Highscore.formatSong(song)}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${Highscore.formatSong(song)}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
	
	/*mod shit*/
	
	#if MODS
	public static var modsAvailable:Array<String> = [];
	public static var modsActiveStor:Array<String> = [];
	#else
	public static var modsActiveStor:Array<String> = ["friday_night_funkin", "fnf_cornflower_week"];
	#end
	public static var modsActive:Array<String> = modsActiveStor;
	
	//awer[spc]789+
	//idk lol
	
	public static function setPrimaryMod(name:String) {
		if (modsActiveStor.indexOf(name) >= 0) {
			modsActive = [name].concat(modsActiveStor.filter(function(a) {
				return a != name;
			}));
		}
		return modsActive[0];
	}
	
	#if !MODS
	inline
	#end
	public static function getModsList():Array<String> {
		#if MODS
		//check for txt exists
		var txtThing:Array<String>;
		var listChanged:Bool = false;
		if (FileSystem.exists("modsActive.txt")) {
			txtThing = File.getContent("modsActive.txt").split("\n");
			listChanged = (txtThing.length == 1 && txtThing[0].length == 0);
			if (listChanged) {
				txtThing = [];
			}
		} else {
			txtThing = new Array<String>();
			listChanged = true;
		}
		var modsThing = new Map<String, Bool>();
		modsActiveStor = [];
		//understand it
		for (i in txtThing) {
			var a = i.split(":");
			modsThing.set(a[1], a[0] == "1");
			if (a[0] == "1") {
				modsActiveStor.push(a[1]);
			}
		}
		for (i in modsAvailable) {
			if (!modsThing.exists(i)) {
				modsThing.set(i, Options.newModsActive);
				listChanged = true;
			}
		}
		//be cool as fuck
		if (listChanged) {
			var newTxtThing = new Array<String>();
			for (k in modsThing.keys()) {
				newTxtThing.push('${modsThing.get(k) ? "1" : "0"}:${k}');
			}
			File.saveContent("modsActive.txt", newTxtThing.join("\n"));
		}
		#end
		return modsActiveStor;
	}
	
	#if MODS
	public static function updateModsList() {
		modsAvailable = FileSystem.readDirectory("mods").filter(function(a) {
			return FileSystem.isDirectory('mods/$a');
		});
		return getModsList();
	}
	#else
	public inline function updateModsList() {
		return getModsList();
	}
	#end
}
