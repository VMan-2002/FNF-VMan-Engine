package;

import CoolUtil;
import flixel.FlxSprite;

class StrumNote extends FlxSprite
{
	public var noteData:Int;
	public var isHeld(default, set):Bool = false;
	public var parent:StrumLine;
	function set_isHeld(invar:Bool):Bool {
		if (invar == isHeld) {
			return isHeld;
		}
		if (invar) {
			if (animation.curAnim.name == "static") {
				playAnim("pressed");
			}
			if (returnTime <= 0) {
				returnTime = 0.01;
			}
		}
		isHeld = invar;
		return invar;
	}
	
	public var returnTime:Float = -60;

	public function new(x:Float, y:Float, noteData:Int, style:String) {
		super(x, y);
		this.noteData = noteData;
		setStyle(style);
		scrollFactor.set();
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (returnTime == -60) {
			CoolUtil.CenterOffsets(this);
			return;
		}
		if (!isHeld && returnTime > 0) {
			returnTime -= elapsed;
			if (returnTime < 0) {
				playAnim("static");
			}
		}
	}
	
	public function setStyle(style:String) {
		switch(style) {
			case "pixel":
				loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);
				/*animation.add('green', [6]);
				animation.add('red', [7]);
				animation.add('blue', [5]);
				animation.add('purplel', [4]);*/ //what does this even do, if anything

				scale.x = PlayState.daPixelZoom * 1.5;
				antialiasing = false;
				
				var i = noteData; //todo: It dont work properly in >4k! Lol
				var wide = 4;
				animation.add('static', [i]);
				animation.add('pressed', [wide+i, (wide * 2)+i], 12, false);
				animation.add('confirm', [(wide * 3)+i, (wide * 4)+i], 24, false);
			
			default:
				frames = Paths.getSparrowAtlas('normal/NOTE_assets');

				antialiasing = true;
				
				animation.addByPrefix('static', "arrow"+ManiaInfo.StrumlineArrow[PlayState.curManiaInfo.arrows[noteData]]);
				animation.addByPrefix('pressed', PlayState.curManiaInfo.arrows[noteData]+' press', 24, false);
				animation.addByPrefix('confirm', PlayState.curManiaInfo.arrows[noteData]+' confirm', 24, false);
		}
		
		scale.x *= PlayState.curManiaInfo.scale;
		scale.y = scale.x;
		scrollFactor.set();
		animation.play("static");
		dirty = true; //i dont care
		CoolUtil.CenterOffsets(this);
	}
	
	public function playAnim(name:String, ?force:Bool = false) {
		if (name == animation.curAnim.name && !force) {
			return;
		}
		animation.play(name, force);
		updateHitbox();
		centerOffsets();
		CoolUtil.CenterOffsets(this);
	}
}
