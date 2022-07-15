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
	public static var x:Float;
	public static var y:Float;
	
	public function new(?mania:SwagMania, ?xPos:Float, ?yPos:Float) {
		super();
		x = xPos;
		y = yPos;
		if (mania == null) {
			return;
		}
		SwitchMania(mania);
	}
	
	public function SwitchMania(mania:SwagMania) {
		thisManiaInfo = mania;
		while (members.length > 1) {
			members.pop().destroy();
		}
		var left:Float = ((thisManiaInfo.spacing) * (thisManiaInfo.keys - 1)) / 2;
		for (i in 0...thisManiaInfo.keys) {
			// FlxG.log.add(i);
			var style = PlayState.SONG.noteSkin;
			var babyArrow:StrumNote = new StrumNote(x, y, i, style);
			
			babyArrow.x += ((thisManiaInfo.spacing) * i);
			babyArrow.x -= left;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.visible = babyArrow.visible && !Options.invisibleNotes;
			babyArrow.parent = this;

			if (!PlayState.isStoryMode && PlayState.instance.startingSong) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				var delay = 0.5 + (1.6 * i / Math.max(thisManiaInfo.keys, 8));
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10}, 1, {ease: FlxEase.circOut, startDelay: delay});
				babyArrow.playAppearAnim(delay);
			}

			babyArrow.animation.play('static');

			add(babyArrow);
		}
	}
	
	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
