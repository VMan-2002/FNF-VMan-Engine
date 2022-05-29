package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
import Options;

import CoolUtil;
import NoteColor;
import Translation;
#if polymod
import polymod.Polymod;
import polymod.Polymod.Framework;
import sys.io.File;
#end

using StringTools;

class ModLoad
{
	public static var enabledMods = new Array<String>();
	public static var primaryMod:String;
	
	//copied from polymod flixel sample

	private function loadMods(dirs:Array<String>) {
		trace('Loading mods: ${dirs}');
		enabledMods = new Array<String>();
		for (i in dirs) {
			enabledMods.push(i.replace("\r", ""));
		}
		primaryMod = enabledMods[0];
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

	private function onError(error:PolymodError) {
		trace('[${error.severity}] (${error.code.toUpperCase()}): ${error.message}');
	}
}
