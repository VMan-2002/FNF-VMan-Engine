package;

#if polymod
import polymod.Polymod.Framework;
import polymod.Polymod;
#end

using StringTools;

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
			enabledMods.push(i.replace("\r", ""));
		}
		primaryMod = enabledMods[0];
		PlayState.modName = primaryMod;
		/*var modRoot = '../../../mods/';
		#if mac
		// account for <APPLICATION>.app/Contents/Resources
		var modRoot = '../../../../../../mods';
		#end*/
		var modRoot = './mods/';
		var results = Polymod.init({
			modRoot: modRoot,
			dirs: enabledMods.copy(),
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
		var loadedMods = results.map(function(item:ModMetadata)
		{
			return item.id;
		});
		trace('Loaded mods: ${loadedMods}');
	}

	public static function onError(error:PolymodError) {
		trace('[${error.severity}] (${error.code.toUpperCase()}): ${error.message}');
	}
}
