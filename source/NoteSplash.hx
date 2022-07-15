package;

import CoolUtil;
import ManiaInfo.SwagMania;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;
/*#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end*/

class NoteSplash extends FlxSprite
{
	public function playNoteSplash(thing:StrumNote) {
		x = thing.x;
		y = thing.y;
		var skinColor = Note.loadedNoteSkins.exists(thing.curStyle) ? Note.loadedNoteSkins.get(thing.curStyle).arrowColors.get(thing.myArrow) : null;
		if (skinColor != null) {
			color.setRGB(skinColor[0], skinColor[1], skinColor[2]);
		} else {
			switch(thing.parent.thisManiaInfo.arrows[thing.noteData]) {
				case "purple": 
					color = 0xffC24B99;
				case "blue":
					color = 0xff00ffff;
				case "green":
					color = 0xff12FA05;
				case "red":
					color = 0xfff9393f;
				case "yellow":
					color = 0xffF2F20B;
				case "violet":
					color = 0xff823CFF;
				case "darkred":
					color = 0xffFF7700;
				case "dark":
					color = 0xff0033FF;
				case "white":
					color = 0xffCCCCCC;
				case "13a":
					color = 0xff76D7FF;
				case "13b":
					color = 0xff69FF3D;
				case "13c":
					color = 0xffE30000;
				case "13d":
					color = 0xffE14EFF;
				case "17a":
					color = 0xff76FFA4;
				case "17b":
					color = 0xffFF3D69;
				case "17c":
					color = 0xff5000E3;
				case "17d":
					color = 0xff4EA1FF;
			}
		}
		animation.play("splash", true);
		animation.finishCallback = function(name:String) {
			kill();
		}
	}

	public function new() {
		super();

		frames = Paths.getSparrowAtlas("normal/notesplash");
		animation.addByPrefix("splash", "NoteSplash", 24, false);
		animation.play("splash");
		updateHitbox();
		
		CoolUtil.CenterOffsets(this);
	}
}
