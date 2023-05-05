package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionsPracticeSubState extends OptionsSubStateBasic
{
	override function optionList() {
		backSubState = 1;
		return [
			'Enable Practice Tools',
			'Pre-play popup',
			'No Death',
			'No Mechanics'
		];
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "enable practice tools":
				return ["Enable usage of all toggles listed below, also disables saving highscores.", Options.saved.practice_enabled ? "Enabled" : "Disabled"];
			case "pre-play popup":
				return ["Enable pre-play popup so you can skip time and practice a difficult part.", Options.saved.practice_preplay_menu ? "Enabled" : "Disabled"];
			case "no death":
				return ["Disable game over after losing all health.", Options.saved.practice_disable_death ? "Enabled" : "Disabled"];
			case "no mechanics":
				return ["Disable special song mechanics.", Options.saved.practice_disable_mechanics ? "Enabled" : "Disabled"];
		}
		return ["Unknown option.", name, 'unknownOption'];
	}

	override function optionUpcoming(name:String) {
		switch (name) {
			case "no mechanics":
				return true;
		}
		return false;
	}

	override function optionAccept(name:String) {
		switch (name) {
			case "enable practice tools":
				Options.saved.practice_enabled = !Options.saved.practice_enabled;
			case "pre-play popup":
				Options.saved.practice_preplay_menu = !Options.saved.practice_preplay_menu;
			case "no death":
				Options.saved.practice_disable_death = !Options.saved.practice_disable_death;
			case "no mechanics":
				Options.saved.practice_disable_mechanics = !Options.saved.practice_disable_mechanics;
			default:
				trace("Tried to accept unknown option: " + name);
		}
		return true;
	}
}
