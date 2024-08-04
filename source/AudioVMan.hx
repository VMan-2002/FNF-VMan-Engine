package;

import Translation;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class AudioVMan
{
	//the goal here is to bypass the FlxSound length limit with an entire new audio class
	//not sure what to do here tho
	public var sound:Dynamic;
	/*public var rate(get, set):Float;
	function get_rate() {
		return 1;
	}
	function set_rate(newRate:Float) {
		return 1;
	}*/

	/**
		`inp`: Audio buffer
		`streaming`: If true, only like 20 seconds of the audio is loaded at a time
	**/

	public function new(inp:Dynamic, streaming:Bool) {
		
	}
}
