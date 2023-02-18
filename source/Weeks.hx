package;
import flixel.FlxG;
import flixel.util.FlxSave;

using StringTools;
#if !html5
import sys.FileSystem;
import sys.io.File;
#end


typedef SwagWeek = {
	var songs:Array<String>;
	var displaySongs:Array<String>;
	var title:String;
	var name:String;
	var menuChars:Array<String>;
	//var visibleStoryMenu:Null<Bool>;
	var previous:Null<String>;
	var requiredToUnlock:Null<Array<String>>;
	var requirementsNeeded:Null<Int>;
	var id:String;
	var modName:String;
	var bgColor:String;
	var difficulties:Null<Array<String>>;
	var weekUnlocked:Bool;
}

class Weeks { //we REALYL gettin in the deep stuff!
	public static var weekCompletion:Map<String, Array<String>> = new Map<String, Array<String>>();

	inline static function EmptyThing(a:Null<String>):Null<String> {
		return a == "" ? null : a;
	}
	
	static function SortWeeks(a:SwagWeek, b:SwagWeek, ?fail:Bool = false):Int {
		if (EmptyThing(a.previous) == EmptyThing(b.previous) || a.id == b.id) {
			return 0;
		}
		if (a.id == b.previous) {
			return 1;
		}
		if (EmptyThing(a.previous) == null && b.previous != null) {
			return -1;
		}
		if (fail) {
			return 0;
		}
		return -SortWeeks(b, a, true);
	}
	
	public static function getAllWeeks():Array<SwagWeek> {
		//for every mod folder, read the weeks folder
		//add the weeks an array
		//todo: i think this can be made a little cleaner
		var weeks:Array<SwagWeek> = new Array<SwagWeek>();
		var weekPrevs:Map<String, String> = new Map<String, String>();
		var weeksNamed:Map<String, SwagWeek> = new Map<String, SwagWeek>();
		var weekLists = new Map<String, Array<SwagWeek>>();
		var portedOld = false;
		for (thing in ModLoad.enabledMods) {
			var path = "mods/" + thing + "/weeks/";
			//if the folder exists, read it
			if (FileSystem.exists(path)) {
				var files = FileSystem.readDirectory(path);
				for (file in files) {
					if (file.endsWith(".json")) {
						var week = CoolUtil.loadJsonFromString(File.getContent(path + file));
						week.id = file.substring(0, file.length - 5);
						week.name = week.name == null ? week.id : week.name;
						week.title = week.title == null ? week.name : week.title;
						//week.visibleStoryMenu = week.visibleStoryMenu == true;
						week.songs = week.songs == null ? new Array<String>() : week.songs;
						week.modName = thing;
						weekPrevs.set(week.id, week.previous);
						weeksNamed.set(thing+":"+week.id, week);
						week.weekUnlocked = isWeekUnlocked(week);
						if (weekLists.exists(week.modName))
							weekLists.get(week.modName).push(week);
						else
							weekLists.set(week.modName, [week]);
						if (Highscore.weekScores.exists(week.id)) { //keep my scores :>
							trace("Ported old score for "+week.id+" from "+week.modName);
							Highscore.weekScores.set('${week.modName}:${week.id}', Highscore.weekScores.get(week.id));
							Highscore.weekScores.remove(week.id);
							portedOld = true;
						}
						weeks.push(week);
					}
				}
			}
		}
		if (portedOld) {
			trace("Saving ported scores");
			FlxG.save.data.weekScores = Highscore.weekScores;
			FlxG.save.flush();
		}

		//Index the stuff
		var sortValue = new Map<String, Int>();
		var sortRoots = new Map<String, String>();
		var rootList = new Array<String>();
		for (week in weeks) {
			var chain:Array<String> = new Array<String>(); //Detect if we're in an infinite loop. :)
			var anWeek = week;
			while ( //there are a lot of conditions lol
				anWeek.previous != null
				&& anWeek.previous.length > 0
				&& anWeek.id != anWeek.previous
				&& !chain.contains(anWeek.previous)
				&& weeksNamed.exists(anWeek.previous)
			) {
				chain.push(anWeek.previous);
				anWeek = weeksNamed.get('${anWeek.modName}:${anWeek.previous}');
			}
			sortRoots.set('${week.modName}:${week.id}', '${anWeek.modName}:${anWeek.id}');
			sortValue.set('${week.modName}:${week.id}', chain.length);
			if (!rootList.contains('${anWeek.modName}:${anWeek.id}')) {
				rootList.push('${anWeek.modName}:${anWeek.id}');
			}
		}
		//todo: credit https://ashes999.github.io/learnhaxe/sorting-an-array-of-strings-in-haxe.html (and some others hopefully)
		rootList.sort(function(a:String, b:String):Int {
			a = a.toUpperCase();
			b = b.toUpperCase();

			if (a < b) {
				return -1;
			}
			else if (a > b) {
				return 1;
			} else {
				return 0;
			}
		});

		//Then do some Epic Sorting!!!
		var finalList = new Array<SwagWeek>();
		for (thing in ModLoad.enabledMods) {
			if (weekLists.exists(thing)) {
				trace('${weekLists.get(thing).length} weeks from ${thing}');
				haxe.ds.ArraySort.sort(weekLists.get(thing), function(a, b) {
					var fullIdA = '${a.modName}:${a.id}';
					var fullIdB = '${b.modName}:${b.id}';
					if (sortRoots.get(fullIdA) != sortRoots.get(fullIdB)) {
						return sortRoots.get(fullIdA) > sortRoots.get(fullIdB) ? 999 : -999; //do the bigger numbers even matter :thinking:
					}
					if (sortValue.get(fullIdA) != sortValue.get(fullIdB)) {
						return sortValue.get(fullIdA) > sortValue.get(fullIdB) ? 199 : -199; //do the bigger numbers even matter :thinking:
					}
					return a.id > b.id ? 1 : -1;
				});
				finalList = finalList.concat(weekLists.get(thing));
			}
		}

		//haxe.ds.ArraySort.sort(weeks, function(a, b) {return SortWeeks(a, b);});
		trace(finalList);
		return finalList;
	}
	
	public static function isWeekUnlocked(w:SwagWeek) {
		if (w.requiredToUnlock == null || w.requiredToUnlock.length == 0 || w.requirementsNeeded == 0) {
			return true; //theres no requirement
		}
		var left = w.requirementsNeeded == null ? 0 : w.requiredToUnlock.length - w.requirementsNeeded;
		for (i in w.requiredToUnlock) {
			if (!checkWeekCompleted(i, w.modName)) {
				left--;
				if (left <= 0) {
					return false;
				}
			}
		}
		return true;
	}

	public static function setWeekCompleted(name:String, modName:String) {
		if (!weekCompletion.exists(modName)) {
			weekCompletion.set(modName, [name]);
		} else if (weekCompletion.get(modName).contains(name)) {
			return false;
		} else {
			weekCompletion.get(modName).push(name);
		}
		SaveOptions();
		return true;
	}

	public static function checkWeekCompleted(name:String, modName:String) {
		return weekCompletion.exists(modName) && weekCompletion.get(modName).contains(name);
	}

	public static function resetWeekCompleted(name:String, modName:String) {
		if (!weekCompletion.exists(modName) || !weekCompletion.get(modName).contains(name)) {
			return false;
		} else {
			weekCompletion.get(modName).remove(name);
			if (weekCompletion.get(modName).length == 0) {
				weekCompletion.remove(modName);
			}
		}
		SaveOptions();
		return true;
	}
	
	/**
		Calling this manually is unnecessary since it's automatically done so when completing or resetting a week
	**/
	public static function SaveOptions() {
		var svd = GetSaveObj();
		svd.data.weekCompletion = weekCompletion;

		svd.flush();
		return true;
	}
	
	public static function LoadOptions() {
		var svd = GetSaveObj();
		weekCompletion = ifNotNull(svd.data.weekCompletion, weekCompletion);

		svd.destroy();
	}
	
	static inline function ifNotNull(a:Any, b:Any):Null<Any> {
		return a == null ? b : a;
	}
	
	public static function GetSaveObj() {
		var svd = new FlxSave();
		svd.bind("WeekCompletion");
		return svd;
	}
	
	/*
	public function getWeek(name:String) {
		switch(name) {
			case "tutorial":
				return {
					songs: [["Tutorial", "gf"]],
					name: "Tutorial",
					title: "Learn to Funk",
					menuChars: ["gf", "bf", ""],
					visibleFreeplay: true,
					visibleStoryMenu: true,
					previous: null,
					requiredToUnlock: null,
					id: "tutorial"
				}
			case "week1":
				return {
					songs: [["Bopeebo", "dad"], ["Fresh"], ["Dad Battle"]],
					name: "Week 1",
					title: "Daddy Dearest",
					menuChars: ["gf", "bf", "dad"],
					visibleFreeplay: true,
					visibleStoryMenu: true,
					previous: "tutorial",
					requiredToUnlock: null,
					id: "week1"
				}
			case "week2":
				return {
					songs: [["Spookeez", "spooky"], ["South", "spooky"], ["Monster", "monster"]],
					name: "Week 2",
					title: "Spooky Month",
					menuChars: ["gf", "bf", "spooky"],
					visibleFreeplay: true,
					visibleStoryMenu: true,
					previous: "week1",
					requiredToUnlock: null,
					id: "week2"
				}
			case "week3":
				return {
					songs: [["Pico", "spooky"], ["Philly Nice", "spooky"], ["Blammed", "monster"]],
					name: "Week 2",
					title: "Pico",
					menuChars: ["gf", "bf", "pico"],
					visibleFreeplay: true,
					visibleStoryMenu: true,
					previous: "week2",
					requiredToUnlock: null,
					id: "week3"
				}
			case "week4":
				return {
					songs: [["Satin Panties", "mom"], ["High"], ["Milf"]],
					name: "Week 2",
					title: "Mommy Must Murder",
					menuChars: ["gf", "bf", "mom"],
					visibleFreeplay: true,
					visibleStoryMenu: true,
					previous: "week3",
					requiredToUnlock: null,
					id: "week4"
				}
			case "week5":
				return {
					songs: [["Cocoa", "parents-christmas"], ["Eggnog", "parents-christmas"], ["Winter Horrorland", "monster-christmas"]],
					name: "Week 5",
					title: "Red Snow",
					menuChars: ["gf", "bf", "parents-christmas"],
					visibleFreeplay: true,
					visibleStoryMenu: true,
					previous: "week4",
					requiredToUnlock: null,
					id: "week5"
				}
			case "week6":
				return {
					songs: [["Senpai", "senpai"], ["Roses", "senpai-angry"], ["Thorns", "spirit"]],
					name: "Week 6",
					title: "Hating Simulator ft. Moawling",
					menuChars: ["gf", "bf", "senpai"],
					visibleFreeplay: true,
					visibleStoryMenu: true,
					previous: "week5",
					requiredToUnlock: null,
					id: "week6"
				}
			default:
				//check that a week file exists.
				//load it
				//run a script or smth
		}
		trace('Week $name is not real');
		return {
			songs: [["My Song 1", "dad"], ["My Song 2", "dad"], ["My Song 3", "dad"]],
			name: "My Week",
			title: "My New Week",
			menuChars: ["gf", "bf", "dad"],
			visibleFreeplay: false,
			visibleStoryMenu: false,
			previous: null,
			requiredToUnlock: null,
			id: "my_week"
		}
	}
	*/
}
