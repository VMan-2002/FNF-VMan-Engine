package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.filters.DisplacementMapFilterMode;
import sys.FileSystem;

typedef ModOptionItem = {
	id:String,
	name:String,
	desc:String,
	type:String,
	/*
		types:
			string
			int
			float
			bool
			stringChoice
			intChoice
			floatChoice
			script
	*/
	options:Array<Dynamic>,
	optionNames:Array<String>,
	defaultValue:Dynamic,
	minValue:Float,
	maxValue:Float,
	increment:Float,
	enableStr:String,
	disableStr:String,
	allowLoadInvalidChoice:Bool,
	icon:String,
}

typedef ModOptionFile = {
	title:String,
	options:Array<ModOptionItem>
}

class ModOptionSubState extends OptionsSubStateBasic {
	var hasAny:Bool;
	var modName:String;
	var options:Array<ModOptionItem>;
	var optionValues:Array<Dynamic>;

	public override function new(mod:String) {
		modName = mod;
		super();
	}

	override function optionList() {
		var result:Array<String> = [];
		options = CoolUtil.loadJsonFromString('mods/${modName}/options.json').options;
		for (i in 0...options.length)
			result[i] = options[i].name;
		hasAny = result.length != 0;
		return hasAny ? result : ["None"];
	}
	
	override function optionDescription(name:String) {
		if (!hasAny)
			return ["No customizable options are found.", name, 'unknownOption'];
		return [options[curSelected].desc, "wip", 'unknownOption'];
	}

	override function optionAccept(name:String) {
		return hasAny ? changeOptionMenu(new ControlsSubState()) : false;
	}

	override function optionDescriptionTranslationArgs(name) {
		return [name];
	}
}