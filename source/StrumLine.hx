package;

import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import ManiaInfo;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Options;

using StringTools;

class StrumLine extends FlxTypedGroup<StrumNote>
{
	var ThisManiaInfo:SwagMania;
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
		ThisManiaInfo = mania;
		while (members.length > 1) {
			members.pop().destroy();
		}
		for (i in 0...ThisManiaInfo.keys) {
			// FlxG.log.add(i);
			var style = PlayState.curStage.startsWith('school') ? 'pixel' : 'normal';
			var babyArrow:StrumNote = new StrumNote(x, y, i, style);
			
			babyArrow.x += ((ThisManiaInfo.spacing) * i);
			babyArrow.x -= ((ThisManiaInfo.spacing) * (ThisManiaInfo.keys - 1)) / 2;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.visible = babyArrow.visible && !Options.invisibleNotes;

			if (!PlayState.isStoryMode && PlayState.instance.startingSong) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			babyArrow.animation.play('static');

			add(babyArrow);
		}
	}
	
	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
