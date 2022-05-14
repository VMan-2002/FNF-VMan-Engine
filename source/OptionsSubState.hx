package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import Translation;

class OptionsSubState extends OptionsSubStateBasic
{
	override function optionList() {
		return [
			/*'Master Volume',
			'Sound Volume',
			'Instrumental Volume',
			'Vocals Volume',*/
			#if !switch
			'Controls',
			#end
			'Scroll direction',
			"Middlescroll",
			"Ghost Tapping",
			"Invisi-Notes",
			"Instant Respawn",
			"Botplay",
			"Freeplay Folders",
			#if MODS
			"Activate New Mods",
			#end
			"Skip Title",
			//"Enable modcharts",
			"Language",
			"Exit Without Saving"
		];
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "master volume":
				return ["Volume of everything.", Std.string(Options.masterVolume)];
			case "sound volume":
				return ["Volume of sound effects.", "idk"];
			case "instrmental volume":
				return ["Volume of song instrumentals.", "idk"];
			case "vocals volume":
				return ["Volume of song vocals.", "idk"];
			case "controls":
				return ["Change your controls."];
			case "scroll direction":
				return ["The direction the notes move.", Options.downScroll ? "Downscroll" : "Upscroll"];
			case "middlescroll":
				return ["Move your notes to the middle of the screen, and hide the opponent's notes.", Options.middleScroll ? "Enabled" : "Disabled"];
			case "ghost tapping":
				var text = "Whether or not pressing the wrong arrow loses you health.";
				var value = "Always antimash";
				if (Options.ghostTapping) {
					value = Options.tappingHorizontal ? "Horizontal antimash" : "No antimash";
				}
				return [text, value];
			case "instant respawn":
				return ["Respawn immediately upon dying.", Options.instantRespawn ? "Enabled" : "Disabled"];
			case "botplay":
				return ["Watch the game go brrr", Options.botplay ? "Enabled" : "Disabled"];
			case "kade health":
				//text = "Gain and lose more health for hitting notes, dont gain health while holding notes.";
				//value = Options.playstyle == "kade" ? "Enabled" : "Disabled";
			case "input offset":
				//text = "More = you have to hit notes later, in milliseconds.";
				//value = Std.string(Options.offset);
			case "freeplay folders":
				return ["Categorize the songs in the Freeplay menu.\nContent Warning: may scare some players.", Options.freeplayFolders ? "Enabled" : "Disabled"];
			case "activate new mods":
				return ["The state that any new mods in the mods folder have if they hadn't been added before.", Options.newModsActive ? "Enabled" : "Disabled"];
			case "skip title":
				return ["Skip the title screen when the game starts.", Options.skipTitle ? "Enabled" : "Disabled"];
			case "invisi-notes":
				return ["Bad idea. Makes the notes invisible.", Options.invisibleNotes ? "Enabled" : "Disabled"];
			case "language":
				return ["Change the language. Some mods may make use of this option.", Translation.getTranslation("native language name")];
			case "enable modcharts":
				return ["Enable modcharts", "idk"];
			case "antialiasing":
				return ["Whether or not stuff gets a bit of smoothing, disabling this can boost framerates", "idk"];
			case "exit without saving":
				return ["Exit the options menu, and discard your changes.", '', 'unknownOption'];
		}
		return ["Unknown option.", '', 'unknownOption'];
	}

	override function optionAccept(name:String) {
		switch (name)
		{
			case "controls":
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new ControlsSubState());
				return false;
			case "scroll direction":
				Options.downScroll = !Options.downScroll;
			case "middlescroll":
				Options.middleScroll = !Options.middleScroll;
			case "ghost tapping":
				//Logic!!!!!!!!!!!!!!!!
				if (Options.ghostTapping) {
					//tappingHorizontal on: currently horizontal antimash -> change to no antimash
					//tappingHorizontal off: currently no antimash -> change to full antimash
					Options.ghostTapping = Options.tappingHorizontal;
					Options.tappingHorizontal = false;
				} else {
					//currently full antimash -> change to horizontal antimash
					Options.ghostTapping = true;
					Options.tappingHorizontal = true;
				}
			case "instant respawn":
				Options.instantRespawn = !Options.instantRespawn;
			case "kade health":
				Options.playstyle = Options.playstyle != "kade" ? "kade" : "default";
			case "botplay":
				Options.botplay = !Options.botplay;
			case "freeplay folders":
				Options.freeplayFolders = !Options.freeplayFolders;
			case "skip title":
				Options.skipTitle = !Options.skipTitle;
			case "invisi-notes":
				Options.invisibleNotes = !Options.invisibleNotes;
			case "language":
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new LanguageOptionSubState());
				return false;
			case "exit without saving":
				var oldLang:String = Options.language;
				Options.LoadOptions();
				if (Options.language != oldLang) {
					Translation.setTranslation(Options.language);
				}
				goBack();
				return false;
			case "activate new mods":
				Options.newModsActive = !Options.newModsActive;
		}
		return true;
	}
}
