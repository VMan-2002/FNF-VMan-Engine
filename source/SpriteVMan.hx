package;

import ThingThatSucks.ErrorReportSubstate;
import flixel.FlxSprite;

using StringTools;

class SpriteVMan extends FlxSprite {
	public var animOffsets:Map<String, Array<Null<Float>>> = new Map<String, Array<Null<Float>>>();

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		animation.play(AnimName, Force, Reversed, Frame);

		if (animOffsets.exists(AnimName)) {
			var daOffset = animOffsets.get(AnimName);
			offset.x = daOffset[flipX ? 2 : 0];
			offset.y = daOffset[1];
			/*if (flipX) {
				//todo: this needs work
				var framewidth = frames.frames[animation.curAnim.curFrame].sourceSize.x;
				offset.x = (framewidth * scale.x) - offset.x;
			}*/
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0, ?xflipped:Null<Float> = null) {
		animOffsets[name] = [x, y, xflipped];
	}

	public function generateFlipOffsets() {
		var referenceAnimName = ["idle", "danceLeft", "danceRight", "firstDeath", animation.getNameList()[0]].filter(hasAnim)[0];
		if (referenceAnimName == null) {
			return ErrorReportSubstate.addError("Couldn't generate flip offsets for a sprite somehow.");
		}
		var referenceFrameWidth = frames.frames[animation.getByName(referenceAnimName).frames[0]].frame.width;
		for (thing in animOffsets.keys()) {
			if (animation.getByName(thing) == null) {
				trace("NULL ANIM "+thing+" when generate flip offsets");
				while (animOffsets[thing][2] == null || animOffsets[thing].length < 3) {
					animOffsets[thing].push(0);
				}
				continue;
			}
			var thisFrameWidth = frames.frames[animation.getByName(thing).frames[0]].frame.width;
			if (animOffsets[thing][2] == null) {
				animOffsets[thing][2] = -animOffsets[thing][0] + (thisFrameWidth - referenceFrameWidth);
			} else if (animOffsets[thing][0] == null) {
				animOffsets[thing][0] = animOffsets[thing][2] - (thisFrameWidth - referenceFrameWidth);
			}
		}
	}

	public inline function hasAnim(animname:String) {
		return animation.exists(animname);
	}
	public function playAvailableAnim(animname:Array<String>, ?force = false) {
		for (anim in animname) {
			if (hasAnim(anim)) {
				playAnim(anim, force);
			}
		}
	}

	public inline function animStartsWith(start:String) {
		return animation.curAnim.name.startsWith(start);
	}

	public inline function animEndsWith(end:String) {
		return animation.curAnim.name.endsWith(end);
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
		var oldRight = animation.getByName(from).clone(animation);
		
		@:privateAccess(FlxAnimationController._animations) { //private variables suck sometimes
			animation._animations.set(from, animation.getByName(to));
			animation._animations.set(to, oldRight);
		}
		var oldOffset = animOffsets[from].copy();
		animOffsets[from] = animOffsets[to];
		animOffsets[to] = oldOffset;
	}

	public function prefixFrameExists(name:String) {
		for (f in frames.frames) {
			if (frame.name.startsWith(name))
				return true;
		}
		return false;
	}
}
