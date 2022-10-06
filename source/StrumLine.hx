package;

import ManiaInfo;
import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class StrumLine extends FlxTypedGroup<StrumNote>
{
	public var thisManiaInfo:SwagMania;
	var notes:Array<Note>;
	
	public static var nextId:Int;
	public static var activeArray:Array<StrumLine>;
	public var x:Float;
	public var y:Float;
	public var scale:Float;
	public var curManiaChangeNum:Int = 0;
	
	public function new(?mania:SwagMania, ?xPos:Float, ?yPos:Float, ?scale:Float = 1) {
		super();
		x = xPos;
		y = yPos;
		this.scale = scale;
		if (mania == null) {
			return;
		}
		SwitchMania(mania);
	}
	
	public function SwitchMania(mania:SwagMania, ?anim:Bool = true) {
		thisManiaInfo = mania;
		CoolUtil.clearMembers(this);
		var left:Float = ((thisManiaInfo.spacing) * (thisManiaInfo.keys - 1) * scale) / 2;
		for (i in 0...thisManiaInfo.keys) {
			// FlxG.log.add(i);
			var style = PlayState.SONG.noteSkin;
			var babyArrow:StrumNote = new StrumNote(x, y, i, style, this);
			
			babyArrow.x += ((thisManiaInfo.spacing) * i) * scale;
			babyArrow.x -= left;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.visible = babyArrow.visible && !Options.invisibleNotes;

			if (!PlayState.isStoryMode && anim) {
				playAppearAnim();
			}

			babyArrow.animation.play('static');

			add(babyArrow);
		}
	}

	public function playAppearAnim(?makeVisible:Bool = false) {
		for (i in 0...length) {
			var babyArrow = members[i];
			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			var delay = 0.5 + (1.6 * i / Math.max(thisManiaInfo.keys, 8));
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10}, 1, {ease: FlxEase.circOut, startDelay: delay});
			babyArrow.playAppearAnim(delay);
			if (!Options.invisibleNotes && makeVisible) {
				babyArrow.visible = true;
			}
		}
	}
	
	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
