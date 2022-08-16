package;

import ManiaInfo;
import MultiWindow;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
#if html5
import js.Browser;
#end
#if desktop
import Sys;
#end

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fps:FPS;
	
	#if (debug && !html5)
	public static var debug:debugger.Local;
	#end
	public static var launchArguments:Array<String> = new Array<String>();
	public static var launchArgumentsParsed:Map<String, Int> = new Map<String, Int>();

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		#if (debug && !html5)
		debug = new debugger.Local(false);
		#end

		NoteSplash.noteSplashColors = NoteSplash.noteSplashColorsDefault;
		
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		Options.LoadOptions();

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1) {
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end
		
		fps = new FPS(10, 3, 0xFFFFFF);
		fps.visible = Options.showFPS;
		
		#if html5
		var stupid:String = Browser.location.href;
		//trace(stupid);
		if (false) {
			addChild(new FlxGame(gameWidth, gameHeight, RedirectState, zoom, framerate, framerate, skipSplash, startFullscreen));
		} else
		#end
		{
			addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
		}
		addChild(fps);
	}
}
