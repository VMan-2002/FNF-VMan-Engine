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

	public function setTheme(?name:String = "") {
		loadGraphic(Paths.image(name == "" ? 'menu/folder' : 'menu/folder-' + name));
		antialiasing = sprTracker.antialiasing;
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
