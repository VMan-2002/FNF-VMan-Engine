package;

import ManiaInfo;
import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class StrumLine extends FlxTypedGroup<FlxSprite> {
	public var thisManiaInfo:SwagMania;
	//todo: should this be used
	//var notes:Array<Note>;
	
	public static var nextId:Int;
	public static var activeArray:Array<StrumLine>;
	public var x:Float;
	public var y:Float;
	public var scale:Float;
	public var curManiaChangeNum:Int = 0;
	public var strumNotes:Array<StrumNote>;
	public var spanX:Float = 0;
	public var spanY:Float = 0;
	public var inManiaChange:Bool = false;
	public var playManiaChangeAnim:Bool = true;
	
	public function new(?mania:SwagMania, ?xPos:Float, ?yPos:Float, ?scale:Float = 1) {
		super();
		x = xPos;
		y = yPos;
		var oldScale = this.scale;
		this.scale = scale;
		if (mania == null) {
			return;
		}
		SwitchMania(mania, false, oldScale);
	}
	
	public function SwitchMania(mania:SwagMania, ?anim:Bool = false, oldScale:Float) {
		thisManiaInfo = mania;
		var oldStrumNotes:Null<Array<StrumNote>> = null;
		var oldArrows:Null<Array<String>> = null;
		if (strumNotes != null) {
			oldStrumNotes = strumNotes.copy();
			oldArrows = new Array<String>();
			for (i in 0...oldStrumNotes.length) {
				oldArrows[i] = thisManiaInfo.arrows[oldStrumNotes[i].noteData];
				oldStrumNotes[i].destroyKeybindReminder();
			}
		}
		members.resize(0);
		length = 0;
		strumNotes = new Array<StrumNote>();
		var left:Float = ((thisManiaInfo.spacing) * (thisManiaInfo.keys - 1) * scale) / 2;
		for (i in 0...thisManiaInfo.keys) {
			// FlxG.log.add(i);
			var style = PlayState.SONG.noteSkin;
			var babyArrow:StrumNote = new StrumNote(x, y, i, style, this);
			
			babyArrow.x += ((thisManiaInfo.spacing) * i) * scale;
			babyArrow.x -= left;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.visible = babyArrow.visible && !Options.instance.invisibleNotes;

			babyArrow.animation.play('static');

			if (oldStrumNotes != null && playManiaChangeAnim) {
				//if this is a mania change, tween this arrow's position from an existing arrow
				var i = 0;
				while (i < oldArrows.length) {
					if (thisManiaInfo.arrows[i] == oldArrows[i] && oldStrumNotes[i].alive) {
						inManiaChange = true;
						oldStrumNotes[i].alive = false;
						var putX = babyArrow.x;
						babyArrow.x = oldStrumNotes[i].x;
						babyArrow.scale.set(oldScale, oldScale);
						FlxTween.tween(babyArrow, {x: putX, "scale.x": scale, "scale.y": scale}, 0.5, {ease: FlxEase.cubeOut, onComplete: function(a) {
							setX(i, putX);
						}});
						break;
					}
					i += 1;
				}
				if (inManiaChange)
					new FlxTimer().start(0.501, function(a) {
						inManiaChange = false;
						a.destroy();
					});
			}

			add(babyArrow);
			strumNotes.push(babyArrow);
		}
		if (oldStrumNotes != null) {
			for (a in oldStrumNotes)
				a.destroy();
		}
		updateSpan();

		if (anim || (((PlayState.instance.startingSong && !PlayState.isStoryMode) || PlayState.SONG.actions.contains("forceStrumAppearAnim")) && !PlayState.SONG.actions.contains("noStrumAppearAnim"))) {
			trace("play appear anim");
			playAppearAnim();
		}
	}

	public function playAppearAnim(?makeVisible:Bool = false) {
		for (i in 0...length) {
			var babyArrow = strumNotes[i];
			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			var delay = 0.5 + (1.6 * i / Math.max(thisManiaInfo.keys, 8));
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10}, 1, {ease: FlxEase.circOut, startDelay: delay});
			babyArrow.playAppearAnim(delay);
			if (!Options.instance.invisibleNotes && makeVisible) {
				babyArrow.visible = true;
			}
		}
	}
	
	public function setX(num:Int, result:Float) {
		strumNotes[num].x = result;
		updateSpan(num);
	}
	
	public function setY(num:Int, result:Float) {
		strumNotes[num].y = result;
		updateSpan(num);
	}
	
	public inline function updateSpan(?hitNum:Int = 0) {
		if (hitNum == 0 || hitNum + 1 == members.length) {
			spanX = strumNotes[strumNotes.length - 1].x - strumNotes[0].x;
			spanY = strumNotes[strumNotes.length - 1].y - strumNotes[0].y;
		}
	}

	public function setSpeedMult(num:Float) {
		for (i in strumNotes) {
			i.speedMult = num;
		}
	}

	public function setDownscroll(num:Bool) {
		for (i in strumNotes) {
			i.downScroll = num;
		}
	}
	
	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
	
	public function showKeybindReminder() {
		for (i in strumNotes) {
			i.showKeybindReminder();
		}
	}
}
