package;

import openfl.display.FPS;

class VeFPS extends FPS {
	private override function __enterFrame(deltaTime:Float):Void {
        super.__enterFrame(deltaTime);
        //text += "\nVersion " + Main.gameVersionNoSubtitle;
	}
}
