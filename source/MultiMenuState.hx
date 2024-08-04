package;

import CoolUtil;
import OptionsMenu;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;
#if !html5
import sys.FileSystem;
import sys.io.File;
#end

//import io.newgrounds.NG;
#if desktop
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var mayStart = false;
	public static var multiInfoThing:Array<String>;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing) {
			CoolUtil.playMenuMusic();
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = CoolUtil.makeMenuBackground('', -80);
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths2.image('menuBGDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		if (Options.flashingLights)
			add(magenta);
		// magenta.scrollFactor.set();

		var thing:FlxText = new FlxText(0, 0, 0, "", 40);
		thing.screenCenter();
		thing.scrollFactor.set();
		thing.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(thing);


		super.create();
		
		if (FileSystem.exists("multi.txt")) {
			multiInfoThing = File.getContent("multi.txt").split("\n");
			if (multiInfoThing.length <= 3) {
				thing.text = "Not enough options.\nAsk someone who knows how to use multiplayer.\nPress Esc to return.";
				return;
			}
			if (multiInfoThing[0] == "join") {
				thing.text = "You are about to join a server!\nPress Enter to confirm or Esc to cancel.";
				mayStart = true;
			} else if (multiInfoThing[0] == "host") {
				thing.text = "You are about to host a server!\nPress Enter to confirm or Esc to cancel.";
				mayStart = true;
			} else {
				thing.text = "Invalid option.\nPress Esc to return.";
				mayStart = false;
			}
			if (multiInfoThing[1].split("").filter(function(a) return Std.parseInt(a) != null || a == ".").join("") != multiInfoThing[1]) {
				thing.text = "Invalid IP.\nPress Esc to return.";
				mayStart = false;
				return;
			}
			if (Std.parseInt(multiInfoThing[2]) != null) {
				thing.text = "Invalid port.\nPress Esc to return.";
				mayStart = false;
				return;
			}
			if (multiInfoThing[3].trim().length <= 0) {
				thing.text = "You need to set your name.\nPress Esc to return.";
				mayStart = false;
				return;
			}
		} else {
			thing.text = "Ask someone who knows how to use multiplayer.\nPress Esc to return.";
			mayStart = false;
		}
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (!selectedSomethin) {
			if (controls.ACCEPT && mayStart) {
				selectedSomethin = true;
				PlayStateMulti.isOnline = true;
				if (multiInfoThing[0] == "host") {
					//host server.
					

					FlxG.switchState(new FreeplayState());
				} else {
					FlxG.switchState(new PlayStateMulti());
				}
			}
			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.switchState(new MainMenuState());
				PlayStateMulti.isOnline = false;
			}
		}

		super.update(elapsed);
	}
}
