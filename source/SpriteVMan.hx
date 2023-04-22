package;

import ThingThatSucks.ErrorReportSubstate;
import WiggleEffect.WiggleEffectType;
import flixel.FlxSprite;

using StringTools;

class SpriteVMan extends FlxSprite {
	public var animOffsets:Map<String, Array<Null<Float>>> = new Map<String, Array<Null<Float>>>();

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
		var oldRight = animation.getByName(from).clone(animation);
		
		@:privateAccess(FlxAnimationController._animations) //private variables suck sometimes
		animation._animations.set(from, animation.getByName(to));
		@:privateAccess(FlxAnimationController._animations) //WHY do i have to do this twice
		animation._animations.set(to, oldRight);
		var oldOffset = animOffsets[from].copy();
		animOffsets[from] = animOffsets[to];
		animOffsets[to] = oldOffset;
	}
	
	var wiggleShit:WiggleEffect;
	
	/*public function makeWobbly(?amp:Float = 0.01, ?freq:Float = 60, ?speed:Float = 0.8, ?waveType:String = "dreamy") {
		//idk what do :shrug:
		//currently this is just stuff copied from unused evilSchool stage code
		var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		bg.scale.set(6, 6);
		// bg.setGraphicSize(Std.int(bg.width * 6));
		// bg.updateHitbox();
		add(bg);

		wiggleShit = new WiggleEffect();
		switch(waveType.toLowerCase()) {
			case "wavy":
				wiggleShit.effectType = WiggleEffectType.WAVY;
				break;
			case "horizontal":
				wiggleShit.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
				break;
			case "vertical":
				wiggleShit.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL
				break;
			case "flag":
				wiggleShit.effectType = WiggleEffectType.FLAG;
				break;
			default:
				wiggleShit.effectType = WiggleEffectType.DREAMY;
		}
		wiggleShit.waveAmplitude = amp;
		wiggleShit.waveFrequency = freq;
		wiggleShit.waveSpeed = speed;

		// bg.shader = wiggleShit.shader;

		var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);

		// Using scale since setGraphicSize() doesnt work???
		waveSprite.scale.set(6, 6);
		waveSprite.setPosition(posX, posY);

		waveSprite.scrollFactor.set(0.7, 0.8);

		// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		// waveSprite.updateHitbox();

		add(waveSprite);
	}*/
}
