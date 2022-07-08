package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionsSubState extends OptionsSubStateBasic
{
	override function optionList() {
		return [
			'Master Volume',
			'Sound Volume',
			'Instrumental Volume',
			'Vocals Volume',
			#if !switch
			'Controls',
			#end
			'Scroll direction',
			"Middlescroll",
			"Ghost Tapping",
			"Enable modcharts",
			"Invisi-Notes",
			"Instant Respawn",
			"Botplay",
			"Freeplay Folders",
			#if MODS
			"Activate New Mods",
			#end
			"Skip Title",
			"Language",
			"Flashing Lights",
			"Silent Countdown",
			"Show FPS",
			"Audio On Miss",
			"Exit Without Saving"
		];
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "master volume":
				return ["Volume of everything.", "NYI, but "+Std.string(Options.masterVolume)];
			case "sound volume":
				return ["Volume of sound effects.", "NYI, but "+Std.string(Options.soundVolume)];
			case "instrumental volume":
				return ["Volume of song instrumentals.", "NYI, but "+Std.string(Options.instrumentalVolume)];
			case "vocals volume":
				return ["Volume of song vocals.", "NYI, but "+Std.string(Options.vocalsVolume)];
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
				return ["Enable fancy movements for notes, in supported songs only.", Options.modchartEnabled ? "Enabled" : "Disabled"];
			case "antialiasing":
				return ["Whether or not stuff gets a bit of smoothing, disabling this can boost framerates", "idk"];
			case "flashing lights":
				return ["Turn this off if you suffer from epilepsy or similar conditions.", Options.flashingLights ? "Enabled" : "Disabled"];
			case "silent countdown":
				return ["Silence the countdown, that's about it.", Options.silentCountdown ? "Enabled" : "Disabled"];
			case "show fps":
				return ["Show the framerate in the top left corner.", Options.showFPS ? "Enabled" : "Disabled"];
			case "audio on miss":
				var values = ["Miss sound + Mute vocals", "Miss sound only", "Mute vocals only", "Do nothing"];
				return ["Change what you hear when you miss a note.", values[Options.noteMissAction]];
			case "exit without saving":
				return ["Exit the options menu, and discard your changes.", '', 'unknownOption'];
		}
		return ["Unknown option.", name, 'unknownOption'];
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
			case "enable modcharts":
				Options.modchartEnabled = !Options.modchartEnabled;
			case "antialiasing":
				Options.antialiasing = !Options.antialiasing;
			case "flashing lights":
				Options.flashingLights = !Options.flashingLights;
			case "silent countdown":
				Options.silentCountdown = !Options.silentCountdown;
			case "show fps":
				Options.showFPS = !Options.showFPS;
				Main.fps.visible = Options.showFPS;
			case "audio on miss":
				Options.noteMissAction = (Options.noteMissAction + 1) % 4;
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
			default:
				trace("Tried to accept unknown option: " + name);
		}
		return true;
	}

	function moveVolume(a, isLeft):Float {
		var newValue:Float = a + (isLeft ? -0.1 : 0.1);
		if (newValue < 0) return 0;
		if (newValue > 1) return 1;
		return newValue;
	}

	override function optionUpdate(name:String) {
		var pressLeftRight = (controls.LEFT_P != controls.RIGHT_P);
		switch(name) {
			case "instrumental volume":
				if (pressLeftRight) {
					Options.instrumentalVolume = moveVolume(Options.instrumentalVolume, controls.LEFT_P);
					updateDescription();
				}
			case "vocals volume":
				if (pressLeftRight) {
					Options.vocalsVolume = moveVolume(Options.vocalsVolume, controls.LEFT_P);
					updateDescription();
				}
			case "master volume":
				if (pressLeftRight) {
					Options.masterVolume = moveVolume(Options.masterVolume, controls.LEFT_P);
					updateDescription();
				}
			case "sound volume":
				if (pressLeftRight) {
					Options.soundVolume = moveVolume(Options.soundVolume, controls.LEFT_P);
					updateDescription();
				}
		}
	}
}
