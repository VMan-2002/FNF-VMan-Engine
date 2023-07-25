package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if !html5
import sys.FileSystem;
#end
#if polymod
import polymod.backends.PolymodAssets;
#end

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:Null<String>) {
		currentLevel = name.toLowerCase();
	}

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

	public static function getModPath(path:String, modName:String, type:AssetType):String {
		return modName == "" ? getPath(path, type, null) : 'mods/${modName}/' + path;
	}

	public static function getModOrGamePath(path:String, modName:String, type:AssetType):String {
		var modThing = getModPath(path, modName, type);
		#if !html5
		if (FileSystem.exists(modThing))
			return modThing;
		#else
		if (OpenFlAssets.exists(modThing, type))
			return modThing;
		#end
		return getPath(path, type, null);
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

	inline static public function voices(song:String) {
		return getSongPathThing(song, 'Voices');
	}

	inline static public function inst(song:String) {
		return getSongPathThing(song, 'Inst');
	}

	inline static public function getSongPathThing(song:String, type:String, ?repl:Null<String>) {
		return 'songs:assets/songs/${Highscore.formatSong(song)}/${repl != null && repl != "" ? repl : type}.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return getPath('fonts/$key', FONT, null);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String) {
		return getSparrowAtlasManual(key, key, library);
	}

	inline static public function getSparrowAtlasManual(key:String, xml:String, ?library:String) {
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$xml.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String) {
		return getPackerAtlasManual(key, key, library);
	}

	inline static public function getPackerAtlasManual(key:String, txt:String, ?library:String) {
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$txt.txt', library));
	}

	public static inline function exists(key:String) {
		#if !html5
		return FileSystem.exists(key);
		#else
		return Assets.exists(key);
		#end
	}
}
