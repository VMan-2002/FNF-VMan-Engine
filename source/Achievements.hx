package;
import ModsMenuState.ModInfo;
import flixel.util.FlxSave;
import net.VeGameJolt;

class Achievements {
	//todo: Actual custom achievements will come soon
	public static var achievements:Array<String> = new Array<String>();
	public static var achievementsChanged:Bool = false;
	//public static var modAchievements:Map<String, Array<String>> = new Map<String, Array<String>>();
	public static var vanillaAchievements:Array<String> = [
		"anyClear",
		"anySDCB",
		"anyFC",
		"anyGFC",
		"anySFC",
		"anyMFC",
		"anyWeekComplete",
		"anyWeekFC",
		"anyOpponentPlay",
		"anyBothPlay",
		"anyGuitarPlay",
		"anyConfusionPlay",
		"anyMultiModifierPlay",
		//"6kBothPlay", //Dunno lol
		"fridayNight",
		"calibrateDeath",
		"gamejoltLinked",
		"modFunkboxPlay",
		"modRegGuitPlay",
		"modPastTimePlay"
	];

	public static function giveAchievement(name:String, ?modName:Null<String>) {
		if (modName != null) {
			return false; //do nothing since mod achievements dont exist yet
		}
		if (!vanillaAchievements.contains(name) || achievements.contains(name)) {
			return false;
		}
		achievementsChanged = true;
		achievements.push(name);
		VeGameJolt.syncOneAchievement(name);
		return true;
	}

	public static function checkAchievement(name:String, ?modName:Null<String>) {
		if (modName != null) {
			return false; //do nothing since mod achievements dont exist yet
		}
		return vanillaAchievements.contains(name) && achievements.contains(name);
	}

	public static function achievementDescription(name:String, ?modName:Null<String>) {
		if (modName != null) {
			return ["Mod Achievement: "+name, "Achievement from "+modName+"."]; //do nothing since mod achievements dont exist yet
		}
		switch(name) {
			case "anyClear":
				return ["Beginning Rapper", "Complete any song."];
			case "anySDCB":
				return ["Rising Star", "Complete any song with less than 10 misses. (SDCB/Single Digit Combo Breaks)"];
			case "anyFC":
				return ["Got 'Em", "Complete any song with no misses. (FC, aka Full Combo)"];
			case "anyGFC":
				return ["That's Epic", "Complete any song with no misses, and you hit only \"Good\" or better. (GFC, aka Good Full Combo)"];
			case "anySFC":
				return ["Perfect Combo", "Complete any song with no misses, and you hit only \"Sick!\". (SFC, aka Sick Full Combo)"];
			case "anyMFC":
				return ["Superpower", "Complete any song with no misses, and you hit only \"Marvelous!\". (MFC, aka Marvelous Full Combo)"];
			case "anyWeekComplete":
				return ["Storytold", "Complete any week in Story Mode."];
			case "anyWeekFC":
				return ["Star of the Show", "Complete any week in Story Mode with no misses."];
			case "anyOpponentPlay":
				return ["Countermelody Competency", "Complete any song with Opponent Mode (but not Both Side Play) active."];
			case "anyBothPlay":
				return ["Coalition Fruition", "Complete any song with Both Side Play active."];
			case "anyGuitarPlay":
				return ["Strum Divine", "Complete any song with Guitar Mode active."];
			case "anyConfusionPlay":
				return ["Walking Slick", "Complete any song with Confusion active."];
			case "anyMultiModifierPlay":
				return ["Musical Multitasking", "Complete any song with multiple gameplay modifiers active (Endless isn't counted, Opponent/Bothside count as one)."];
			case "11kPlay":
				return ["Overfinger", "Complete a song with 11 or more keys."];
			case "6kBothPlay":
				return ["Six Fingered", "Complete a song with 6 or more keys with Both Side Play active."];
			case "fridayNight":
				return ["Just Like The Game", "Funk on a Friday (real time)."];
			case "calibrateDeath":
				return checkAchievement("calibrateDeath") ? ["???", "Hidden Achievement"] : ["Out Of Time", "Die during Input Offset Calibrate."];
			case "gamejoltLinked":
				return ["Jolt", "Connect your Game Jolt account."];
			//hmm should i do this
			case "modFunkboxPlay":
				return ["Beepy on a Friday Night", "Complete a Story Mode week from `Friday Night Funkbox`."];
			case "modRegGuitPlay":
				return ["Very regular indeed", "Complete a song from `Regular Guitar Song`."];
			case "modPastTimePlay":
				return ["Time Travel", "Complete story mode from `The Past Time`."];
		}
		return ["Unknown Achievement: "+name, "This is likely a bug, tell VMan about this."];
	}

	public static function awardModPlay(category:String, mod:ModInfo, state:PlayState) {
		if (mod.devMode)
			return false;
		var thing:Array<Dynamic> = [mod.gamebananaId, mod.id];
		switch(thing) {
			case [428567, "funny_nep_mod"]:
				return category == "storyModeWeek" && giveAchievement("modFunkboxPlay");
			case [437809, "regular_guitar_song"]:
				return giveAchievement("modRegGuitPlay");
			case [459798, "vmans_past_time"]:
				return category == "storyModeWeek" && giveAchievement("modPastTimePlay");
			default:
				return false;
		}
	}
	
	public static function SaveOptions(?seen:Array<String>, ?force:Bool = false) {
		if (!achievementsChanged && !force) {
			return false;
		}
		var svd = GetSaveObj();
		svd.data.achievements = achievements;
		if (seen != null)
			svd.data.seen = seen;

		svd.flush();
		achievementsChanged = false;
		return true;
	}
	
	public static function LoadOptions() {
		var svd = GetSaveObj();
		achievements = ifNotNull(svd.data.achievements, achievements);
		achievementsChanged = false;
		var seen:Null<Array<String>> = svd.data.achievementsSeen;

		svd.destroy();
		return ["" => seen];
	}

	public static function getUnseenCount() {
		var seen = LoadOptions();
		if (seen[""] == null)
			return achievements.length;
		return (vanillaAchievements.length - achievements.length) - seen[""].length;
	}
	
	static inline function ifNotNull(a:Any, b:Any):Null<Any> {
		return a == null ? b : a;
	}
	
	public static function GetSaveObj() {
		var svd = new FlxSave();
		svd.bind("Achievements");
		return svd;
	}
}
