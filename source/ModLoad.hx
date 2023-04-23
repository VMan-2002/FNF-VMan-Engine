package;

import ModsMenuState.ModInfo;
import sys.FileSystem;
import sys.io.File;

using StringTools;
#if polymod
import polymod.Polymod.Framework;
import polymod.Polymod;
#end


class ModLoad {
	public static var enabledMods = new Array<String>();
	public static var primaryMod:ModInfo = null;

	#if FEATURE_STATIC_MOD_LIST
	static final staticModList = [
		"friday_night_funkin"
	];
	#end
	
	//copied from polymod flixel sample

	public static function loadMods(dirs:Array<String>, ?doModCheck:Bool = true) {
		if (doModCheck)
			checkNewMods();
		trace('Loading mods: ${dirs}');
		Character.charHealthIcons = new Map<String, String>();
		enabledMods = new Array<String>();
		for (i in dirs) {
			var f = i.replace("\r", "");
			if (f.startsWith("0::"))
				continue;
			else if (f.startsWith("1::"))
				f = f.substr(3);
			if (!modLoadAllowed(f))
				continue;
			var flashFolder = "mods/"+f+"/noflashing";
			var string = "Mod: "+f;
			if (!Options.flashingLights) {
				//todo: this doesn't seem to work
				if (FileSystem.exists(flashFolder) && FileSystem.isDirectory(flashFolder)) {
					enabledMods.push(flashFolder);
					string += " (loading with noflash)";
				} else {
					string += " (doesnt have noflash)";
				}
			}
			trace(string);
			enabledMods.push(f);
		}
		primaryMod = ModsMenuState.quickModJsonData(enabledMods[0]);
		PlayState.modName = enabledMods[0];
		/*var modRoot = '../../../mods/';
		#if mac
		// account for <APPLICATION>.app/Contents/Resources
		var modRoot = '../../../../../../mods';
		#end*/
		var modRoot = './mods/';
		var polymodDirs = enabledMods.copy();
		polymodDirs.reverse();
		var results = Polymod.init({
			modRoot: modRoot,
			dirs: polymodDirs,
			errorCallback: onError,
			ignoredFiles: Polymod.getDefaultIgnoreList(),
			framework: Framework.FLIXEL,
			frameworkParams: {
				assetLibraryPaths: [
					"default" => "./assets",
					"shared" => "./assets/shared",
					"week1" => "./assets/week1",
					"week2" => "./assets/week2",
					"week3" => "./assets/week3",
					"week4" => "./assets/week4",
					"week5" => "./assets/week5",
					"week6" => "./assets/week6",
					"songs" => "./assets/songs"
				]
			}
		});
		// Reload graphics before rendering again.
		if (results == null) {
			return;
		}
		var loadedMods = results.map(function(item:ModMetadata) {
			return item.id;
		});
		trace('Loaded ${loadedMods.length} mods');
	}

	public static function onError(error:PolymodError) {
		trace('[${error.severity}] (${Std.string(error.code).toUpperCase()}): ${error.message}');
	}

	public static function modLoadAllowed(name:String) {
		var path = 'mods/${name}/mod.json';
		trace("check if "+path+" is allowed to load");
		if (!FileSystem.exists(path))
			return FileSystem.exists('mods/${name}');
		var modInfo:ModInfo = CoolUtil.loadJsonFromString(File.getContent(path));
		return modInfo.loadableGameVer == null || modInfo.loadableGameVer <= Main.gameVersionInt;
	}

	/**
		Get all folders in the mods folder, even ones that are inactive
	**/
	public static inline function getAllModFolders() {
		#if FEATURE_STATIC_MOD_LIST
		return staticModList;
		#else
		return FileSystem.readDirectory("mods/").filter(function(a) {return FileSystem.isDirectory("mods/"+a);});
		#end
	}

	/**
		Get mods list file as an array.
	**/
	public static inline function getModsListFileArr():Array<String> {
		#if FEATURE_STATIC_MOD_LIST
		return staticModList.map(function(a) {return "1::" + a;});
		#else
		return FileSystem.exists("mods/modList.txt") ? File.getContent("mods/modList.txt").replace("\r", "").split("\n") : ["0::work_folder", "0::example", "1::friday_night_funkin"];
		#end
	}

	public static inline function normalizeModsListFileArr(arr:Array<String>) {
		return arr.map(function(a) {
			if (a.startsWith("1::") || a.startsWith("0::"))
				return a.substr(3);
			return a;
		});
	}

	/**
		Check if any new mods have been added to the mods folder
	**/
	public static function checkNewMods() {
		#if FEATURE_STATIC_MOD_LIST
		return false
		#else
		var folderList = getAllModFolders();
		trace(folderList.length+" Mod folders available: "+folderList.join(","));
		var modsListFile = getModsListFileArr();
		var listyMods = normalizeModsListFileArr(modsListFile);
		var toAdd = new Array<String>();
		for (folder in folderList) {
			if (!listyMods.contains(folder)) {
				toAdd.push((Options.newModsActive ? "1::" : "0::") + folder);
			}
		}
		if (toAdd.length == 0)
			return false;
		var newModsListFile = modsListFile.map(function(a) {
			if (a.startsWith("1::") || a.startsWith("0::"))
				return a;
			return "1::" + a;
		}).concat(toAdd);
		trace('Adding ${toAdd.length} new mods to modlist file');
		File.saveContent("mods/modList.txt", newModsListFile.join("\n"));
		return true;
		#end
	}
}
