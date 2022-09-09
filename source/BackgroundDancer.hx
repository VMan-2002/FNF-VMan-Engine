package;

import cpp.abi.ThisCall;
import cpp.vm.Debugger.ThreadInfo;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundDancer extends FlxSprite {
	public var dancerType:String;
	public function new(x:Float, y:Float, ?type:String = "limoDancer") {
		super(x, y);
		
		setType(type);
		animation.play('danceLeft');
		antialiasing = true;
	}

	public function getScared():Void {
		setType("bgFreaksAngry");
		dance();
	}

	public inline function swapDanceType() {
		setType(dancerType == "bgFreaks" ? "bgFreaksAngry" : "bgFreaks");
	}

	public function setType(t:String) {
		dancerType = t;
		switch(t) {
			case "limoDancer":
				frames = Paths.getSparrowAtlas("limo/limoDancer");
				animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			case "bgFreaks":
				// BG fangirls dissuaded
				frames = Paths.getSparrowAtlas('weeb/bgFreaks');
		
				animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
				animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);
			case "bgFreaksAngry":
				// BG fangirls dissuaded
				frames = Paths.getSparrowAtlas('weeb/bgFreaks');
		
				animation.addByIndices('danceLeft', 'BG girls dissuaded', CoolUtil.numberArray(14), "", 24, false);
				animation.addByIndices('danceRight', 'BG girls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		}
	}

	var danceDir:Bool = false;

	public function dance():Void {
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
