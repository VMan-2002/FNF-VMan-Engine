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
// import io.newgrounds.NG;
import lime.app.Application;

using StringTools;
#if desktop
import Discord.DiscordClient;
#end

class HudThingMenu extends MusicBeatState {
	public var hudThingArrays:Array<Array<String>>;
	public var texts:Array<FlxTypedGroup<FlxText>>;
	public var dragging:Bool;
	public var grabbedName:String;
	public var grabber:FlxSprite;
	public var grabbedText:FlxText;
	public var curRow:Int = 0;
	public var curSel:Int = 0;
	public var textGrabPos:Int;
	final titles = ["Available", "Health Bar", "Left Side", "Bottom Corner"];
	public var textThings = new FlxTypedGroup<FlxText>();

	override function create() {
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresenceSimple("menu");
		#end

		hudThingArrays = [HudThing.hudThingDispTypes];

		var defl:Array<Array<String>> = [
			["score", "misses", "fc", "accRating", "accSimple", "health"],
			["hits", "sicks", "goods", "bads", "shits", "misses", "totalnotes"],
			["song", "difficulty"]
		];

		var inserts = Options.saved.hudThingInfo.split("\n");
		var inserts2 = [inserts[0], inserts[2], inserts[1]];
		for (i in 0...inserts2.length) { //the data for this option already exists but is ordered wrong, so i have to reorder it.
			hudThingArrays.push(inserts2[i] == null ? defl[i] : inserts2[i].split(","));
		}

		var textThingy = new FlxTypedGroup<FlxText>();
		for (tx in titles)
			textThingy.add(new FlxText(FlxG.width * 0.25 * textThingy.length, 0, FlxG.width * 0.25, Translation.getTranslation("hudthing_title_"+tx.toLowerCase(), "optionsMenu", null, tx)).setFormat("VCR OSD Mono", 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK));
		add(textThingy);

		add(textThings);
		updateItems();

		super.create();
	}

	public inline function maxRowPos(row:Int) {
		return hudThingArrays[curRow].length + (dragging && row != 0 ? 0 : -1);
	}

	public inline function combinify(abc:Int) {
		return hudThingArrays[abc].join(",");
	}

	override function update(elapsed:Float) {
		if (controls.BACK) {
			Options.saved.hudThingInfo = [combinify(1), combinify(3), combinify(2)].join("\n");
			switchTo(new OptionsMenu(null, "hudthing editor"));
			return;	
		}
		var update:Bool = controls.UP_P || controls.DOWN_P || controls.LEFT_P || controls.RIGHT_P || controls.ACCEPT;
		if (update) {
			if (controls.UP_P) {
				curSel -= 1;
				if (curSel < 0)
					curSel = maxRowPos(curRow);
			}
			if (controls.DOWN_P) {
				curSel += 1;
				if (curSel > maxRowPos(curRow))
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
			curSel = Std.int(Math.min(curSel, maxRowPos(curRow)));
			if (controls.ACCEPT) {
				var pullable:Bool = curRow != 0;
				if (dragging) {
					remove(grabbedText, true);
					if (pullable)
						hudThingArrays[curRow].insert(curSel, grabbedName);
					else if (curSel >= hudThingArrays[0].length)
						curSel = hudThingArrays[0].length - 1;
				} else if (hudThingArrays[curRow].length != 0) {
					grabbedName = hudThingArrays[curRow][curSel];
					if (textGrabPos != -1) {
						grabbedText = textThings.members.splice(textGrabPos, 1)[0];
						add(grabbedText);
						grabbedText.alpha = 0.75;
					}
					if (pullable)
						hudThingArrays[curRow].splice(curSel, 1);
				}
				dragging = !dragging;
			}
			updateItems(); 
		}
		super.update(elapsed);
	}

	public function updateItems() {
		CoolUtil.clearMembers(textThings);
		var w = FlxG.width * 0.25;
		textGrabPos = -1;
		for (i1 in 0...hudThingArrays.length) {
			var gap = Math.min(curSel, hudThingArrays[i1].length - 1);
			var xp = w * i1;
			for (i2 in 0...hudThingArrays[i1].length) {
				var shifty = (curRow == i1 && curSel <= i2 && dragging);
				var yp = 20 + ((curRow != 0 && shifty ? i2 + 1 : i2) * 16);
				var textObj = new FlxText(xp, yp, w, hudThingArrays[i1][i2], 16);
				textObj.moves = false;
				if (!dragging && curRow == i1 && curSel == i2) {
					textObj.color = FlxColor.YELLOW;
					textGrabPos = textThings.length;
				}
				textObj.alignment = FlxTextAlign.CENTER;
				textThings.add(textObj);
			}
			if (curRow == i1 && dragging) {
				FlxTween.cancelTweensOf(grabbedText);
				FlxTween.tween(grabbedText, {x: xp, y: 20 + (curSel * 16)}, 0.5, {ease:FlxEase.cubeOut});
			}
		}
	}

	public function updateSel() {
		
	}
}
