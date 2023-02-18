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
			#if debug
			"Freeplay Folders",
			#end
			#if MODS
			"Activate New Mods",
			#end
			"Skip Title",
			"Language",
			"Flashing Lights",
			"Silent Countdown",
			"Show FPS",
			"Audio On Miss",
			"Reset Button",
			"Note Camera Movement",
			"Input Offset Calibrate",
			"Self Awareness",
			#if MODS
			"Song Restart Reloads UI",
			#end
			"Save Data Management",
			"Exit Without Saving",
			"Gameplay Changes",
			#if debug
			"Options Warning Test"
			#end
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
				return ["Move your notes to the middle of the screen, and hide the opponent's notes.", Options.middleScroll ? (Options.middleLarge ? "Large Middlescroll" : "Enabled") : "Disabled"];
			case "ghost tapping":
				var value = "Always antimash";
				if (Options.ghostTapping)
					value = Options.tappingHorizontal ? "Horizontal antimash" : "No antimash";
				return ["Whether or not pressing the wrong arrow loses you health.", value];
			case "instant respawn":
				return ["Respawn immediately upon dying.", Options.instantRespawn ? "Enabled" : "Disabled"];
			case "botplay":
				return ["Watch the game go brrr", Options.botplay ? "Enabled" : "Disabled"];
			//case "kade health":
				//text = "Gain and lose more health for hitting notes, dont gain health while holding notes.";
				//value = Options.playstyle == "kade" ? "Enabled" : "Disabled";
			//case "input offset":
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
				return ["Change the language. Some mods may make use of this option.", Translation.getTranslation("native language name", "lang")];
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
			case "input offset calibrate":
				return ["Do a short song to see what input offset is good.", "NYI, but "+Translation.getTranslation("offset ms", "optionsMenu", [Std.string(Options.offset)], Options.offset+"ms")];
			case "exit without saving":
				return ["Exit the options menu, and discard your changes.", '', 'unknownOption'];
			case "gameplay changes":
				return ["Toggle gameplay changes.", Highscore.getModeString(true)];
			case "reset button":
				return ["Press R to die during a song.", Options.resetButton ? "Enabled" : "Disabled"];
			case "note camera movement":
				return ["That thing that's in every FNF mod nowadays. The camera will move around depending on the notes.", Options.noteCamMovement ? "Enabled" : "Disabled"];
			case "self awareness":
				return ["The mod might know your name. Scary... Bad for livestreamers, though. Only applies when the mod uses it.", Options.selfAware ? "Enabled" : "Disabled"];
			case "song restart reloads ui":
				return ["Reload UI style when restarting song.", Options.uiReloading ? "Enabled" : "Disabled"];
			#if debug
			case "options warning test":
				return ["Test the options warning"];
			#end
			case "save data management":
				return ["Look at your save data, and if necessary, kill it to death."];
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
				#if debug
			case "save data management":
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new SaveDeleteSubState());
				return false;
				#end
			case "scroll direction":
				Options.downScroll = !Options.downScroll;
			case "middlescroll":
				if (Options.middleScroll) {
					//middlescroll On: turn on large if not active
					Options.middleScroll = !Options.middleLarge;
					Options.middleLarge = Options.middleScroll; //this looks weird lmao
				} else {
					Options.middleScroll = true;
					Options.middleLarge = false;
				}
				//Options.middleScroll = !Options.middleScroll;
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
			case "playstyle preset":
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
			case "input offset calibrate":
				FlxG.state.closeSubState();
				FlxG.switchState(new PlayStateOffsetCalibrate());
			case "gameplay changes":
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new PlayStateChangesSubState());
				return false;
			case "note camera movement":
				Options.noteCamMovement = !Options.noteCamMovement;
			case "reset button":
				Options.resetButton = !Options.resetButton;
			case "self awareness":
				Options.selfAware = !Options.selfAware;
			case "song restart reloads ui":
				Options.uiReloading = !Options.uiReloading;
			case "options warning test":
				FlxG.switchState(new OptionsWarningState());
			default:
				trace("Tried to accept unknown option: " + name);
		}
		return true;
	}

	override function optionDescriptionTranslationArgs(name) {
		switch (name) {
			case "reset button":
				return [Options.getUIControlName("reset")];
		}
		return null;
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
			case "input offset calibrate":
				if (pressLeftRight) {
					Options.offset += controls.LEFT_P ? -1 : 1;
					updateDescription();
				}
		}
	}

	override function optionUpcoming(name:String) {
		switch (name) {
			case "master volume" | "sound volume" | "instrumental volume" | "vocals volume" | "enable modcharts" | "flashing lights" | "input offset calibrate" | "self awareness":
				return true;
		}
		return false;
	}
}
