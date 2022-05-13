package;

import flixel.FlxSprite;

class FolderIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new()
	{
		super();
		loadGraphic(Paths.image('menu/folder'));
		antialiasing = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x - 15, sprTracker.y - 15);
			alpha = sprTracker.alpha;
		}
	}
}
