package;
#if !html5
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef SwagWeek = {
	var songs:Array<String>;
	var title:String;
	var name:String;
	var menuChars:Array<String>;
	var visibleStoryMenu:Bool;
	var previous:Null<String>;
	var requiredToUnlock:Null<Array<String>>;
	var id:String;
	var modName:String;
}

class Weeks { //we REALYL gettin in the deep stuff!
	inline function EmptyThing(a:Null<String>):Null<String> {
		return a == "" ? null : a;
	}
	
	function SortWeeks(a:SwagWeek, b:SwagWeek, ?Fail:Bool = false):Int {
		if (EmptyThing(a.previous) == EmptyThing(b.previous) || a.id == b.id) {
			return 0;
		}
		if (a.id == b.previous) {
			return 1;
		}
		if (EmptyThing(a.previous) == null && b.previous != null) {
			return -1;
		}
		if (Fail) {
			return 0;
		}
		return -SortWeeks(b, a, true);
	}
	
	public function getAllWeeks():Array<SwagWeek> {
		//for every mod folder, read the weeks folder
		//add the weeks an array
		var weeks:Array<SwagWeek> = new Array<SwagWeek>();
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
						week.menuChars = week.menuChars == null ? new Array<String>() : week.menuChars;
						week.visibleStoryMenu = week.visibleStoryMenu == null ? false : week.visibleStoryMenu;
						week.previous = week.previous == null ? null : week.previous;
						week.requiredToUnlock = week.requiredToUnlock == null ? null : week.requiredToUnlock;
						week.songs = week.songs == null ? new Array<String>() : week.songs;
						week.modName = thing;
						weeks.push(week);
					}
				}
			}
		}
		haxe.ds.ArraySort.sort(weeks, function(a, b) {return SortWeeks(a, b);});
		trace(weeks);
		return weeks;
	}
	
	public function isWeekUnlocked(w:SwagWeek) {
		if (w.requiredToUnlock == null || w.requiredToUnlock.length == 0) {
			return true; //theres no requirement
		}
		return true; //todo: make week unlocks Real
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
