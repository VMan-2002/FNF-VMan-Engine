package;

import flixel.FlxSprite;

using StringTools;

class SpriteVMan extends FlxSprite {
	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName)) {
			offset.set(daOffset[0], daOffset[1]);
			if (flipX) {
				//todo: this needs work
				var framewidth = frames.frames[animation.curAnim.curFrame].sourceSize.x;
				offset.x = (framewidth * scale.x) - offset.x;
			}
		} else {
			//offset.set(0, 0);
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}

	public function hasAnim(animname:String) {
		return animation.exists(animname);
	}

	public function playAvailableAnim(animname:Array<String>) {
		for (anim in animname) {
			if (hasAnim(anim)) {
				return playAnim(anim);
			}
		}
	}

	public inline function animStartsWith(start:String) {
		return animation.name.startsWith(start);
	}
}
