package;

import CoolUtil;
import Note.SwagNoteSkin;
import Note.SwagUIStyle;
import OptionsMenu;
import ThingThatSucks.ResetControlsSubState;
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
//import io.newgrounds.NG;
#if desktop
import Discord.DiscordClient;
#end

class HudThingMenu extends MusicBeatState {
	public var hudThingArrays:Array<Array<String>> = new Array<Array<String>>();
	public var texts:Array<FlxTypedGroup<FlxText>>;
	public var dragging:Bool;
	public var grabbedName:String;
	public var grabber:FlxSprite;
	public var grabbedText:FlxText;
	public var curRow:Int = 0;
	public var curSel:Int = 0;
	public var titles = ["Available", "Health Bar", "Left Side", "Bottom Corner"];

	override function create() {
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresenceSimple("menu");
		#end

		hudThingArrays.push(HudThing.hudThingDispTypes);
		for (i in Options.saved.hudThingInfo.split("\n"))
			hudThingArrays.push(i.split(","));

		var textThingy = new FlxTypedGroup<FlxText>();
		for (tx in titles)
			textThingy.add(new FlxText(FlxG.width * 0.25 * textThingy.length, 0, FlxG.width * 0.25, tx).setFormat("VCR OSD Mono", 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK));
		add(textThingy);

		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.BACK) {
			switchTo(new OptionsMenu());
			return;	
		}
		if (controls.UP_P) {
			curSel -= 1;
			if (curSel < 0)
				curSel = hudThingArrays[curRow].length - 1;
		}
		if (controls.DOWN_P) {
			curSel += 1;
			if (curSel >= hudThingArrays[curRow].length)
				curSel = 0;
		}
		if (controls.LEFT_P) {
			curRow -= 1;
			if (curRow < 0)
				curRow = 3;
		}
		if (controls.RIGHT_P) {
			curRow += 1;
			if (curRow > 3)
				curRow = 0;
		}
		super.update(elapsed);
	}

	public function updateItems() {
		
	}

	public function updateSel() {
		
	}
}
