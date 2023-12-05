package net;

import flixel.math.FlxMath;
import sys.thread.Thread;

using StringTools;

typedef FlxGameJolt = flixel.addons.api.FlxGameJolt; //dont mess with this!!!!!!

class VeGameJolt {
	public static var loggedIn:Bool = false;

	static inline function canRun() {
		return VeAPIKeys.valid && loggedIn;
	}

	public static function submitScore() {
		if (!canRun())
			return;
		var song = Highscore.formatSong(PlayState.modName + ":" + PlayState.SONG.song + CoolUtil.difficultyPostfixString()) + Highscore.getModeString(false, true);
		@:privateAccess var scoreboard = Std.parseInt(VeAPIKeys.get('score:' + song));
		if (scoreboard == null) {
			trace("no gamejolt scoreboard for "+song);
			return;
		}
		trace("Uploading gamejolt score for "+song);
		var score = '${PlayState.instance.songScore} (${FlxMath.roundDecimal(Highscore.accuracyCalc(PlayState.instance) * 100, 3)}% / ${Highscore.getPlayStateFC(PlayState.instance)})';
		var scoreSort = CoolUtil.clamp(Highscore.accuracyCalc(PlayState.instance) * 100, 0, 200) + (Highscore.getPlayStateFCStore(PlayState.instance) * 1000);
		var extras:String = [Std.string(PlayState.instance.songMisses), Std.string(PlayState.instance.songHits), Std.string(PlayState.instance.songMisses - PlayState.instance.songHittableMisses), Std.string(Highscore.getPlayStateFCStore(PlayState.instance))].join(",");
		FlxGameJolt.addScore(score, scoreSort, scoreboard, false, null, extras, function(result:Map<String, String>) {
			/*if (result["success"] == true)
				trace("Score submitted successfully")
			else
				trace("Score submit fail: "+Std.string(result["message"]))*/
			trace("Attempted to submit score");
		});
	}

	public static function syncAchievements() {
		if (!canRun())
			return;
		Thread.create(() -> {
			for (thing in Achievements.achievements) {
				if (syncOneAchievement(thing))
					Sys.sleep(0.2);
			}
		});
	}

	public static function syncOneAchievement(name:String) {
		if (!Achievements.achievements.contains(name) || !canRun())
			return false;
		@:privateAccess var id = VeAPIKeys.get("achievement:"+name);
		if (id == null)
			return false;
		FlxGameJolt.addTrophy(Std.parseInt(id));
		return true;
	}
}