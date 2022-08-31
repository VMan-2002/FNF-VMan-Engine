package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class LuaCustomState extends MusicBeatSubstate
{
	public function new(path:String) {
		super();
		thing("onPostInit");
	}

	inline function thing(name) {
		//todo: make this call lua.
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		thing("onUpdate");
		if (controls.ACCEPT) {
			thing("onAccept");
		}
		if (controls.BACK) {
			thing("onCancel");
		}
		thing("onPostUpdate");
	}
}
