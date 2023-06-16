package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.filters.DisplacementMapFilterMode;

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
			#if debug
			"Save Data Management",
			#end
			"Customize HUD",
			"Gameplay Changes",
			"Exit Without Saving",
			#if debug
			"Options Warning Test"
			#end
		];
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "master volume":
				return ["Volume of everything.", Std.string(Options.masterVolume)];
			case "sound volume":
				return ["Volume of sound effects.", Std.string(Options.soundVolume)];
			case "instrumental volume":
				return ["Volume of song instrumentals.", Std.string(Options.instrumentalVolume)];
			case "vocals volume":
				return ["Volume of song vocals.", Std.string(Options.vocalsVolume)];
			case "controls":
				return ["Change your controls."];
			case "scroll direction":
				return ["The direction the notes move.", Options.saved.downScroll ? "Downscroll" : "Upscroll"];
			case "middlescroll":
				return ["Move your notes to the middle of the screen, and hide the opponent's notes.", Options.saved.middleScroll ? (Options.saved.middleLarge ? "Large Middlescroll" : "Enabled") : "Disabled"];
			case "ghost tapping":
				var value = "Always antimash";
				if (Options.saved.ghostTapping)
					value = Options.saved.tappingHorizontal ? "Horizontal antimash" : "No antimash";
				return ["Whether or not pressing the wrong arrow loses you health.", value];
			case "instant respawn":
				return ["Respawn immediately upon dying.", Options.saved.instantRespawn ? "Enabled" : "Disabled"];
			case "botplay":
				return ["Watch the game go brrr", Options.saved.botplay ? "Enabled" : "Disabled"];
			//case "kade health":
				//text = "Gain and lose more health for hitting notes, dont gain health while holding notes.";
				//value = Options.saved.playstyle == "kade" ? "Enabled" : "Disabled";
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
				return ["Bad idea. Makes the notes invisible.", Options.saved.invisibleNotes ? "Enabled" : "Disabled"];
			case "language":
				return ["Change the language. Some mods may make use of this option.", Translation.getTranslation("native language name", "lang")];
			case "enable modcharts":
				return ["Enable fancy movements for notes, in supported songs only.", Options.saved.modchartEnabled ? "Enabled" : "Disabled"];
			case "antialiasing":
				return ["Whether or not stuff gets a bit of smoothing, disabling this can boost framerates", "idk"];
			case "flashing lights":
				return ["Turn this off if you suffer from epilepsy or similar conditions.", Options.flashingLights ? "Enabled" : "Disabled"];
			case "silent countdown":
				return ["Silence the countdown, that's about it.", Options.saved.silentCountdown ? "Enabled" : "Disabled"];
			case "show fps":
				return ["Show the framerate in the top left corner.", Options.showFPS ? "Enabled" : "Disabled"];
			case "audio on miss":
				final values = ["Miss sound + Mute vocals", "Miss sound only", "Mute vocals only", "Do nothing"];
				return ["Change what you hear when you miss a note.", values[Options.saved.noteMissAction]];
			case "input offset calibrate":
				return ["Do a short song to see what input offset is good.", Translation.getTranslation("offset ms", "optionsMenu", [Std.string(Options.offset)], Options.offset+"ms")];
			case "exit without saving":
				return ["Exit the options menu, and discard your changes.", '', 'unknownOption'];
			case "gameplay changes":
				return ["Toggle gameplay changes.", Highscore.getModeString(true)];
			case "practice tools":
				return ["Toggle several tools to make practicing songs easier.", Options.saved.practice_enabled ? "Enabled" : "Disabled"];
			case "reset button":
				return ["Press R to die during a song.", Options.saved.resetButton ? "Enabled" : "Disabled"];
			case "note camera movement":
				return ["That thing that's in every FNF mod nowadays. The camera will move around depending on the notes.", Options.saved.noteCamMovement ? "Enabled" : "Disabled"];
			case "self awareness":
				return ["The mod might know your name. Scary... Bad for livestreamers, though. Only applies when the mod uses it.", Options.saved.selfAware ? "Enabled" : "Disabled"];
			case "song restart reloads ui":
				return ["Reload UI style when restarting song.", Options.saved.uiReloading ? "Enabled" : "Disabled"];
			case "options warning test":
				return ["Test the options warning"];
			case "save data management":
				return ["Look at your save data, and if necessary, kill it to death."];
			case "customize hud":
				return ["Modify hud meters"];
		}
		return ["Unknown option.", name, 'unknownOption'];
	}

	override function optionAccept(name:String) {
		switch (name)
		{
			case "controls":
				return changeOptionMenu(new ControlsSubState());
				#if debug
			case "save data management":
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new SaveDeleteSubState());
				return false;
				#end
			case "scroll direction":
				Options.saved.downScroll = !Options.saved.downScroll;
			case "middlescroll":
				#if debug
				if (Options.saved.middleScroll) {
					//middlescroll On: turn on large if not active
					Options.saved.middleScroll = !Options.saved.middleLarge;
					Options.saved.middleLarge = Options.saved.middleScroll; //this looks weird lmao
				} else {
					Options.saved.middleScroll = true;
					Options.saved.middleLarge = false;
				}
				#else
				Options.saved.middleScroll = !Options.saved.middleScroll;
				#end
			case "ghost tapping":
				//Logic!!!!!!!!!!!!!!!!
				if (Options.saved.ghostTapping) {
					//tappingHorizontal on: currently horizontal antimash -> change to no antimash
					//tappingHorizontal off: currently no antimash -> change to full antimash
					Options.saved.ghostTapping = Options.saved.tappingHorizontal;
					Options.saved.tappingHorizontal = false;
				} else {
					//currently full antimash -> change to horizontal antimash
					Options.saved.ghostTapping = true;
					Options.saved.tappingHorizontal = true;
				}
			case "instant respawn":
				Options.saved.instantRespawn = !Options.saved.instantRespawn;
			case "playstyle preset":
				Options.saved.playstyle = Options.saved.playstyle != "kade" ? "kade" : "default";
			case "botplay":
				Options.saved.botplay = !Options.saved.botplay;
			case "freeplay folders":
				Options.freeplayFolders = !Options.freeplayFolders;
			case "skip title":
				Options.skipTitle = !Options.skipTitle;
			case "invisi-notes":
				Options.saved.invisibleNotes = !Options.saved.invisibleNotes;
			case "language":
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new LanguageOptionSubState());
				return false;
			case "enable modcharts":
				Options.saved.modchartEnabled = !Options.saved.modchartEnabled;
			case "antialiasing":
				Options.saved.antialiasing = !Options.saved.antialiasing;
			case "flashing lights":
				Options.flashingLights = !Options.flashingLights;
			case "silent countdown":
				Options.saved.silentCountdown = !Options.saved.silentCountdown;
			case "show fps":
				Options.showFPS = !Options.showFPS;
				Main.fps.visible = Options.showFPS;
			case "audio on miss":
				Options.saved.noteMissAction = (Options.saved.noteMissAction + 1) % 4;
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
				if (OptionsMenu.wasInPlayState && PlayState.isStoryMode) {
					FlxG.sound.play(Paths.sound('buzzer'));
					return false;
				}
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new PlayStateChangesSubState());
				return false;
			case "practice tools":
				if (OptionsMenu.wasInPlayState && PlayState.isStoryMode) {
					FlxG.sound.play(Paths.sound('buzzer'));
					return false;
				}
				FlxG.state.closeSubState();
				FlxG.state.openSubState(new OptionsPracticeSubState());
				return false;
			case "note camera movement":
				Options.saved.noteCamMovement = !Options.saved.noteCamMovement;
			case "reset button":
				Options.saved.resetButton = !Options.saved.resetButton;
			case "self awareness":
				Options.saved.selfAware = !Options.saved.selfAware;
			case "song restart reloads ui":
				Options.saved.uiReloading = !Options.saved.uiReloading;
			#if debug
			case "options warning test":
				FlxG.switchState(new OptionsWarningState());
			#end
			case "customize hud":
				FlxG.switchState(new HudThingMenu());
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
				if (controls.RESET) {
					Options.offset = 0;
					updateDescription();
				} else if (pressLeftRight) {
					Options.offset += controls.LEFT_P ? -1 : 1;
					checkOffsetInRange();
					updateDescription();
				}
		}
	}

	inline function checkOffsetInRange() {
		if (Math.abs(Options.offset) > 500) {
			Options.offset = Options.offset > 0 ? 500 : -500;
		}
	}

	override function optionLeftRightHold(name:String, dir:Float) {
		switch(name) {
			case "input offset calibrate":
				Options.offset += Std.int(dir);
				checkOffsetInRange();
				return true;
				//i'll put the volume ones here when i actually make them work
		}
		return false;
	}

	override function optionUpcoming(name:String) {
		switch (name) {
			case "master volume" | "sound volume" | "instrumental volume" | "vocals volume" | "enable modcharts" | "flashing lights" | "input offset calibrate" | "self awareness" | "save data management":
				return true;
		}
		return false;
	}
}
