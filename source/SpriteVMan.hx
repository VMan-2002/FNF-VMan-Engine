package;

import flixel.FlxSprite;

using StringTools;

class SpriteVMan extends FlxSprite {
	public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		animation.play(AnimName, Force, Reversed, Frame);

		if (animOffsets.exists(AnimName)) {
			var daOffset = animOffsets.get(AnimName);
			offset.set(daOffset[flipX ? 2 : 0], daOffset[1]);
			/*if (flipX) {
				//todo: this needs work
				var framewidth = frames.frames[animation.curAnim.curFrame].sourceSize.x;
				offset.x = (framewidth * scale.x) - offset.x;
			}*/
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y, -x];
	}

	public function generateFlipOffsets() {
		var referenceAnimName = ["idle", "danceLeft", "danceRight", animation.getNameList()[0]].filter(hasAnim)[0];
		var referenceFrameWidth = frames.frames[animation.getByName(referenceAnimName).frames[0]].frame.width;
		for (thing in animOffsets.keys()) {
			var thisFrameWidth = frames.frames[animation.getByName(thing).frames[0]].frame.width;
			animOffsets[thing][2] = animOffsets[thing][0] + thisFrameWidth - referenceFrameWidth;
		}
	}

	public function hasAnim(animname:String) {
		return animation.exists(animname);
	}

	public function playAvailableAnim(animname:Array<String>, ?force = false) {
		for (anim in animname) {
			if (hasAnim(anim)) {
				return playAnim(anim, force);
			}
		}
	}

	public inline function animStartsWith(start:String) {
		return animation.name.startsWith(start);
	}

	public function copyAnimation(from:String, to:String) {
		if (hasAnim(to) || !hasAnim(from)) {
			return;
		}
		var old = animation.getByName(from);
		animation.add(to, old.frames, old.frameRate, old.looped);
		animOffsets[to] = animOffsets[from];
	}

	public function swapAnimations(from:String, to:String) {
		var oldRight = animation.getByName('singRIGHT').clone(animation);
		
		@:privateAccess(FlxAnimationController._animations) //private variables suck sometimes
		animation._animations.set(from, animation.getByName(to));
		@:privateAccess(FlxAnimationController._animations) //WHY do i have to do this twice
		animation._animations.set(to, oldRight);
		var oldOffset = animOffsets[from].copy();
		animOffsets[from] = animOffsets[to];
		animOffsets[to] = oldOffset;
	}
}
