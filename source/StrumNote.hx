package;

import CoolUtil;
import Note.SwagNoteSkin;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

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
			if (returnTime < 0) {
				returnTime = 0;
			}
		}
		isHeld = invar;
		return invar;
	}
	public var curStyle:String;
	public var myArrow:String;
	
	public var returnTime:Float = -60;

	public function new(x:Float, y:Float, noteData:Int, style:String, parent:StrumLine) {
		super(x, y);
		this.noteData = noteData;
		this.parent = parent;
		setStyle(style);
		scrollFactor.set();
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (returnTime == -60) {
			CoolUtil.CenterOffsets(this);
			return;
		}
		if (!isHeld && returnTime >= 0) {
			returnTime -= elapsed;
			if (returnTime < 0) {
				playAnim("static");
			}
		}
		if (animation.curAnim.name == "appear" && animation.curAnim.finished) {
			playAnim(isHeld ? "press" : "static");
		}
	}
	
	public function setStyle(style:String) {
		myArrow = parent.thisManiaInfo.arrows[noteData];
		var myStrumArrow = ManiaInfo.StrumlineArrow[myArrow];
		curStyle = style;
		switch(style) {
			/*case "pixel":
				loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);
				//animation.add('green', [6]);
				//animation.add('red', [7]);
				//animation.add('blue', [5]);
				//animation.add('purplel', [4]); //what does this even do, if anything

				scale.x = PlayState.daPixelZoom * 1.5;
				antialiasing = false;
				
				var i = noteData; //todo: It dont work properly in >4k! Lol
				var wide = 4;
				animation.add('static', [i]);
				animation.add('pressed', [wide+i, (wide * 2)+i], 12, false);
				animation.add('confirm', [(wide * 3)+i, (wide * 4)+i], 24, false);*/
			
			case "pixel":
				frames = Paths.getSparrowAtlas('pixelUI/NOTE_assets-pixel');

				scale.x = PlayState.daPixelZoom * 1.5;
				antialiasing = false;
				
				animation.addByPrefix('appear', "appear"+myStrumArrow, 6, false);
				animation.addByPrefix('static', "arrow"+myStrumArrow, 24, true);
				animation.addByPrefix('pressed', myArrow+' press', 12, false);
				animation.addByPrefix('confirm', myArrow+' confirm', 24, false);
			
			case "normal" | "" | null:
				frames = Paths.getSparrowAtlas('normal/NOTE_assets');

				antialiasing = true;
				
				animation.addByPrefix('static', "arrow"+myStrumArrow, 24, true);
				animation.addByPrefix('pressed', myArrow+' press', 24, false);
				animation.addByPrefix('confirm', myArrow+' confirm', 24, false);

			default:
				//load custom
				var noteSkin:SwagNoteSkin = SwagNoteSkin.loadNoteSkin(PlayState.SONG.noteSkin, PlayState.modName);
				frames = Paths.getSparrowAtlas(noteSkin.image);

				if (noteSkin.arrows == null) {
					animation.addByPrefix('static', "arrow"+myStrumArrow, 24, true);
					animation.addByPrefix('pressed', myArrow+' press', 24, false);
					animation.addByPrefix('confirm', myArrow+' confirm', 24, false);
				} else {
					for (anim in noteSkin.arrows[myArrow]) {
						animation.addByPrefix(
							'${anim.name}',
							'${anim.anim}',
							anim.framerate,
							anim.loop
						);
						trace('strum arrow ${myArrow} add animation ${anim.name}');
					}
				}
				antialiasing = noteSkin.antialias != false;
				scale.x = noteSkin.scale;
		}
		
		scale.x *= parent.thisManiaInfo.scale * parent.scale;
		scale.y = scale.x;
		scrollFactor.set();
		animation.play("static");
		dirty = true; //i dont care
		CoolUtil.CenterOffsets(this);
	}

	public function playAppearAnim(?delay:Float = 0) {
		alpha = 0;
		new FlxTimer().start(delay, function(timer) {
			if (animation.getNameList().indexOf("appear") != -1) {
				playAnim("appear");
				alpha = 1;
			} else {
				playAnim("static");
				alpha = 0;
				FlxTween.tween(this, {alpha: 1}, 1, {ease: FlxEase.circOut});
			}
		});
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
