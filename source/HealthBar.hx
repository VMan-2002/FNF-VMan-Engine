package;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.ui.FlxBar;

using StringTools;

class HealthBar extends FlxTypedSpriteGroup<FlxSprite> {
	public var sprite:FlxSprite;
	public var bar:FlxBar;

	public function new(x:Float, y:Float, ?image:String, ?barSides:Array<Float>, ?fillDirection:FlxBarFillDirection = FlxBarFillDirection.LEFT_TO_RIGHT) {
		super();
		sprite = new FlxSprite(0, 0, image == null ? Paths.image("normal/healthBar") : image);
		bar = new FlxBar(barSides[0], barSides[1], fillDirection, width - (barSides[0] + barSides[2]), height - (barSides[1] + barSides[3]));

		if (width > 100) {
			bar.numDivisions = Math.ceil(width);
		}

		add(sprite);
		add(bar);

		this.x = x;
		this.y = y;
	}
}
