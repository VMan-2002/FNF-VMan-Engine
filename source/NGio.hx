package;

import flixel.FlxG;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.display.Stage;

using StringTools;
#if !html5
import io.newgrounds.NG;
import io.newgrounds.components.ScoreBoardComponent.Period;
import io.newgrounds.objects.Medal;
import io.newgrounds.objects.Score;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result.GetCurrentVersionResult;
import io.newgrounds.objects.events.Result.GetVersionResult;
#end

/**
 * so what we want to do is nothing.
 */
class NGio
{
	public static var isLoggedIn:Bool = false;
	public static var scoreboardsLoaded:Bool = false;

	public static var scoreboardArray = new Array<Score>();

	public static var ngDataLoaded(default, null):FlxSignal = new FlxSignal();
	public static var ngScoresLoaded(default, null):FlxSignal = new FlxSignal();

	public static var GAME_VER:String = "";
	public static var GAME_VER_NUMS:String = '';
	public static var gotOnlineVer:Bool = false;

	inline public static function noLogin(api:String)
	{}

	public function new(api:String, encKey:String, ?sessionId:String)
	{}

	inline function onNGLogin():Void
	{}

	inline function onNGMedalFetch():Void
	{}

	inline function onNGBoardsFetch():Void
	{}

	inline static public function postScore(score:Int = 0, song:String)
	{}

	inline function onNGScoresFetch():Void
	{}

	inline static public function logEvent(event:String)
	{}

	inline static public function unlockMedal(id:Int)
	{}
}
