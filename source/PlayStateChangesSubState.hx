package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayStateChangesSubState extends OptionsSubStateBasic
{
	override function optionList() {
		backSubState = 1;
		return [
			'Opponent Mode',
			'Both Side Play',
			'Endless Mode',
			'Guitar Mode',
			'Clear'
		];
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "opponent mode":
				return ["Play the opponent's notes.", Options.playstate_opponentmode ? "Enabled" : "Disabled"];
			case "both side play":
				return ["Play both sides' notes.", Options.playstate_bothside ? "Enabled" : "Disabled"];
			case "endless mode":
				return ["The song repeats forever!", Options.playstate_endless ? "Enabled" : "Disabled"];
			case "guitar mode":
				return ["Guitar Hero, basically. Hold the arrow key down and use square bracket keys to hit notes.", Options.playstate_guitar ? "Enabled" : "Disabled"];
			case "clear":
				var any = [Options.playstate_bothside, Options.playstate_opponentmode, Options.playstate_endless, Options.playstate_guitar].indexOf(true) != -1;
				return ["Disable all currently enabled changes.", any ? "Not cleared" : "Cleared"];
		}
		return ["Unknown option.", name, 'unknownOption'];
	}

	override function optionAccept(name:String) {
		switch (name)
		{
			case "opponent mode":
				Options.playstate_opponentmode = !Options.playstate_opponentmode;
			case "both side play":
				Options.playstate_bothside = !Options.playstate_bothside;
			case "endless mode":
				Options.playstate_endless = !Options.playstate_endless;
			case "guitar mode":
				Options.playstate_guitar = !Options.playstate_guitar;
			case "clear":
				Options.playstate_bothside = false;
				Options.playstate_opponentmode = false;
				Options.playstate_endless = false;
				Options.playstate_guitar = false;
			default:
				trace("Tried to accept unknown option: " + name);
		}
		return true;
	}
}
