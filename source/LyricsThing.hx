package;

import Translation;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

typedef LyricsItem {
	text:Array<String>;
	timing:Array<Float>;
}

class LyricsThing extends FlxGroup {
	public var items = new Array<String>();
	public var lyricsItems:Array<LyricsItem>;

	public static function readLyricsFile(path:String) {
		
	}

	public static function readLyricsFromSong(mod:String, song:String, ?fname:String = "lyrics") {
		return readLyricsFile(mod == "" ? 'assets/data/${song}/${fname}.txt' : 'mods/${mod}/data/${song}/${fname}.txt');
	}
	
	public function new(x:Float, y:Float, list:Array<String>, ?vertical:Bool = false) {
		super();
	}

	override function update(elapsed:Float) {

	}

	public function step(num:Int) {
		
	}
	
	public inline function getPlayState():Dynamic {
		return PlayState.instance;
	}
}
