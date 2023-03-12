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
			'Confusion',
			'Clear Gameplay Changes'
		];
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "opponent mode":
				return ["Play the opponent's notes.", Options.saved.playstate_opponentmode ? "Enabled" : "Disabled"];
			case "both side play":
				return ["Play both sides' notes.", Options.saved.playstate_bothside ? "Enabled" : "Disabled"];
			case "endless mode":
				return ["The song repeats forever! Freeplay Only", Options.saved.playstate_endless ? "Enabled" : "Disabled"];
			case "guitar mode":
				return ["Guitar Hero, basically. Hold the arrow key down and use square bracket keys to hit notes.", Options.saved.playstate_guitar ? "Enabled" : "Disabled"];
			case "confusion":
				return ["Notes may sometimes appear visually in wrong lanes.", Options.saved.playstate_confusion ? "Enabled" : "Disabled"];
			case "clear gameplay changes":
				var any = [Options.saved.playstate_bothside, Options.saved.playstate_opponentmode, Options.saved.playstate_endless, Options.saved.playstate_guitar, Options.saved.playstate_confusion].indexOf(true) != -1;
				return ["Disable all currently enabled changes.", any ? "Not cleared" : "Cleared"];
		}
		return ["Unknown option.", name, 'unknownOption'];
	}

	override function optionDescriptionTranslationArgs(name) {
		switch (name) {
			case "guitar mode":
				return [Options.getUIControlNameBoth("reset")];
		}
		return null;
	}

	override function optionAccept(name:String) {
		switch (name) {
			case "opponent mode":
				Options.saved.playstate_opponentmode = !Options.saved.playstate_opponentmode;
			case "both side play":
				Options.saved.playstate_bothside = !Options.saved.playstate_bothside;
			case "endless mode":
				Options.saved.playstate_endless = !Options.saved.playstate_endless;
			case "guitar mode":
				Options.saved.playstate_guitar = !Options.saved.playstate_guitar;
			case "confusion":
				Options.saved.playstate_confusion = !Options.saved.playstate_confusion;
			case "clear gameplay changes":
				Options.saved.playstate_bothside = false;
				Options.saved.playstate_opponentmode = false;
				Options.saved.playstate_endless = false;
				Options.saved.playstate_guitar = false;
				Options.saved.playstate_confusion = false;
			default:
				trace("Tried to accept unknown option: " + name);
		}
		Options.saved.updatePlayStateAny();
		return true;
	}
}
