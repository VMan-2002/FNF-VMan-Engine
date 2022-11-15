package;

import sys.FileSystem;

using StringTools;
#if polymod
import polymod.Polymod.Framework;
import polymod.Polymod;
#end


class ModLoad
{
	public static var enabledMods = new Array<String>();
	public static var primaryMod:String = "friday_night_funkin";
	
	//copied from polymod flixel sample

	public static function loadMods(dirs:Array<String>) {
		trace('Loading mods: ${dirs}');
		Character.charHealthIcons = new Map<String, String>();
		enabledMods = new Array<String>();
		for (i in dirs) {
			var f = i.replace("\r", "");
			var flashFolder = f+"/noflashing";
			var string = "Mod: "+f;
			if (!Options.flashingLights) {
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
		primaryMod = enabledMods[0];
		PlayState.modName = primaryMod;
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
		trace('[${error.severity}] (${error.code.toUpperCase()}): ${error.message}');
	}
}
