package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import sys.FileSystem;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;
	public var redFlash:Int = 0;
	public var flashColor:Int = 0xFF33ffff;

	public function new(x:Float, y:Float, weekNum:String = "week0", ?modName:String = "") {
		moves = false;
		super(x, y);
		week = new FlxSprite().loadGraphic(Paths2.image('storymenu/' + weekNum, "shared/images/", modName));
		/*var assetsPath = 'assets/shared/images/storymenu/${weekNum}.png';
		var modsPath = 'mods/${modName}/images/storymenu/${weekNum}.png';
		trace("Assets Folder Path "+assetsPath);
		trace("Mod Folder Path "+modsPath);
		trace("Image exists in Assets Folder: "+FileSystem.exists(assetsPath));
		trace("Image exists in Mod Folder: "+FileSystem.exists(modsPath));*/
		/*
		var path:String = CoolUtil.tryPathBothReturnPath('images/storymenu/' + weekNum +".png", modName, 'shared/');
		trace(path);
		week = new FlxSprite().loadGraphic(path);*/
		antialiasing = true;
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void {
		isFlashing = true;
	}

	public function startRedFlashing():Void {
		if (isFlashing) return;
		isFlashing = true;
		redFlash = Math.round(0.75 * FlxG.updateFramerate);
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round(FlxG.updateFramerate / 10);

	override function update(elapsed:Float) {
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17);

		if (isFlashing) {
			flashingInt += 1;

			if (flashingInt % fakeFramerate > Math.floor(fakeFramerate / 2))
				week.color = redFlash > 0 ? FlxColor.RED : flashColor;
			else
				week.color = FlxColor.WHITE;
		}
		
		if (redFlash > 0) {
			redFlash -= 1;
			if (redFlash <= 0) {
				isFlashing = false;
				flashingInt = 0;
				week.color = FlxColor.WHITE;
			}
		}
	}
}
