package;

import CoolUtil;
import ManiaInfo.SwagMania;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;
/*#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end*/

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;
	
	public var noteType:Int = -1;

	//public var scrollDirection(default, set):Float = 0;

	/*function set_scrollDirection(n:Float) {
		if (isSustainNote) {
			angle += n - scrollDirection;
		}
		scrollDirection = n;
	}*/

	public static var swagWidth:Float = 160 * 0.7;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?mania:SwagMania)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		if (mania == null)
			mania = PlayState.curManiaInfo;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y = -2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		var myArrow = mania.arrows[noteData];

		if (Options.downScroll) {
			//scrollDirection = 180;
		}
		
		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				scale.x = PlayState.daPixelZoom * 1.5;

			default:
				frames = Paths.getSparrowAtlas('normal/NOTE_assets');
				
				animation.addByPrefix('${myArrow}Scroll', '${myArrow}0', 24);
				animation.addByPrefix('${myArrow}holdend', '${myArrow} hold end', 24);
				animation.addByPrefix('${myArrow}hold', '${myArrow} hold piece', 24);
				//animation.appendByPrefix('purpleholdend', 'pruple end hold'); //develop your spritesheets properly challenge (impossible)

				antialiasing = true;
		}
		
		scale.x *= mania.scale;
		scale.y = scale.x;
		
		animation.play('${myArrow}Scroll');

		// trace(prevNote);

		if (isSustainNote && prevNote != null) {
			prevNote.nextNote = this;
			
			flipY = Options.downScroll;
			
			noteScore * 0.2;
			alpha = 0.6;

			animation.play(myArrow+"holdend");

			updateHitbox();

			if (prevNote.isSustainNote) {
				prevNote.animation.play(myArrow+"hold");

				prevNote.scale.y = ((Conductor.stepCrochet / 1) * PlayState.SONG.speed * 0.45) / prevNote.frames.frames[prevNote.animation.curAnim.frames[0]].sourceSize.y;
				CoolUtil.CenterOffsets(prevNote);
				prevNote.offset.y = 0;
				//prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
		centerOffsets();
		updateHitbox();
		CoolUtil.CenterOffsets(this);
		if (isSustainNote) {
			//offset.y = flipY ? 0 : height;
			offset.y = height;
		}
	}
	
	public function noteSetArrow(type:String) {
		
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !tooLate) {
				tooLate = true;
				if (alpha > 0.3)
					alpha = 0.3;
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}
	}
}
