package;

//this possibly will never exist in html5
#if !html5
import Sys;
import flixel.FlxBasic;
import flixel.FlxSprite;
import haxe.Json;
import sys.io.Process;

class MultiWindow extends FlxBasic
{
	//Warning: It's cool but don't use it if you don't need to
	
	//todo: this is unfinished
	//also most likely needs a special case for it to work on html5
	
	//changing the stage size dynamically would be cool but it's READ ONYL fuck
	//oh wait there's https://api.haxeflixel.com/flixel/system/scaleModes/

	//todo: This can probably (and should) be replaced with https://github.com/duckiewhy/Transparent-and-MultiWindow-FNF or one of it's potentially awesome forks. make sure it's controllable via scripting :)
	
	public static var supported:Bool = true;
	public var thisWindow:Process;
	public var isLoaded(default, null):Bool = false;
	public var thisWindowId = 0;
	
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

	public static function recieveCommand(cmd:String) {
		
	}
}

#end