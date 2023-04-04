package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.filters.DisplacementMapFilterMode;
import sys.FileSystem;

class ModOptionSelectSubState extends OptionsSubStateBasic {
	var hasAny:Bool;

	override function optionList() {
		var result:Array<String> = [];
		for (i in FileSystem.readDirectory("mods")) {
			if (FileSystem.exists('mods/${i}/options.json')) {
				result.push(i);
			}
		}
		hasAny = result.length != 0;
		return hasAny ? result : ["None"];
	}
	
	override function optionDescription(name:String) {
		if (!hasAny)
			return ["No mods are found containing options.", name, 'unknownOption'];
		return ["Customize a mod's options.", name, 'unknownOption'];
	}

	override function optionAccept(name:String) {
		if (hasAny)
			return changeOptionMenu(new ModOptionSubState(textMenuItems[curSelected]));
		return false;
	}

	override function optionDescriptionTranslationArgs(name) {
		return [name];
	}
}
