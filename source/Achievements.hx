package;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import lime.ui.ScanCode;

class Achievements
{
	public static var achievements:Array<String> = new Array<String>();
	public static var achievementsChanged:Bool = false;
	//public static var modAchievements:Map<String, Array<String>> = new Map<String, Array<String>>();
	public static var vanillaAchievements:Array<String> = [
		"anyClear",
		"anySDCB",
		"anyFC",
		"anyGFC",
		"anySFC",
		"anyWeekComplete",
		"anyWeekFC",
		"anyOpponentPlay",
		"anyBothPlay",
		"anyGuitarPlay",
		"anyConfusionPlay",
		"anyMultiModifierPlay",
		//"6kBothPlay", //Dunno lol
		"fridayNight",
		"calibrateDeath"
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
			return ["Mod Achievement: "+name, "Achievement from a mod."]; //do nothing since mod achievements dont exist yet
		}
		switch(name) {
			case "anyClear":
				return ["Beginning Rapper", "Complete any song."];
			case "anySDCB":
				return ["Rising Star", "Complete any song with less than 10 misses. (SDCB/Single Digit Combo Breaks)"];
			case "anyFC":
				return ["Got 'Em", "Complete any song with no misses. (FC/Full Combo)"];
			case "anyGFC":
				return ["That's Epic", "Complete any song with no misses, and you hit only \"Good\" or better. (GFC/Good Full Combo)"];
			case "anySFC":
				return ["Perfect Combo", "Complete any song with no misses, and you hit only \"Sick!\". (SFC/Sick Full Combo)"];
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
				return ["Musical Multitasking", "Complete any song with multiple gameplay modifiers active (no Endless, Opponent/Bothside count as one.)."];
			case "6kBothPlay":
				return ["Six Fingered", "Complete a song with 6 or more keys with Both Side Play active."];
			case "fridayNight":
				return ["Just Like The Game", "Funk on a Friday (real time)."];
			case "calibrateDeath":
				return checkAchievement("calibrateDeath") ? ["???", "Hidden Achievement"] : ["Out Of Time", "Die during Input Offset Calibrate."];
		}
		return ["Unknown Achievement: "+name, "This is likely a bug, tell VMan about this."];
	}
	
	public static function SaveOptions() {
		if (!achievementsChanged) {
			return false;
		}
		var svd = GetSaveObj();
		svd.data.achievements = achievements;

		svd.flush();
		achievementsChanged = false;
		return true;
	}
	
	public static function LoadOptions() {
		var svd = GetSaveObj();
		achievements = ifNotNull(svd.data.achievements, achievements);
		achievementsChanged = false;

		svd.destroy();
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
