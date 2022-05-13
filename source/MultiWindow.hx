package;

import flixel.FlxSprite;
import sys.io.Process;
import Sys;
import haxe.Json;
import flixel.FlxBasic;

class MultiWindow extends FlxBasic
{
	//Warning: It's cool but don't use it if you don't need to
	
	//todo: this is unfinished
	//also most likely needs a special case for it to work on html5
	
	//changing the stage size dynamically would be cool but it's READ ONYL fuck
	//oh wait there's https://api.haxeflixel.com/flixel/system/scaleModes/
	
	public var thisWindow:Process;
	public var isLoaded(default, null):Bool = false;
	public static var thisWindowId = 0;
	
	/**
	 * id must be greater or equal to 1!
	 */
	public function new(?id:Int = 1, ?startVisible:Bool = true) {
		thisWindow = new Process(Sys.programPath(), [
			'multiWindowType:${id <= 1 ? 1 : id}',
			'startVisible:${startVisible ? "1" : "0"}'
		], false);
		super();
	}
	
	override function destroy() {
		thisWindow.kill();
		thisWindow.close();
		super.destroy();
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
	}
	
	public function sendCommand(cmd:String) {
		
	}
}
