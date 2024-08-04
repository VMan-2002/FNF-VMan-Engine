package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class FolderIcon extends FlxTypedSpriteGroup<FlxSprite>
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new() {
		super();
		moves = false;
		add(new FlxSprite().loadGraphic(Paths2.image('menu/folder')));
		members[0].antialiasing = true;
	}

	public function setTheme(?name:String = "") {
		members[0].loadGraphic(Paths.image(name == "" ? 'menu/folder' : 'menu/folder-' + name));
		if (length >= 2) {
			members[0].antialiasing = members[1].antialiasing;
		}
		members[0].offset.set((members[0].frameWidth - 180) * -0.5, (members[0].frameHeight - 180) * -0.5);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 5, sprTracker.y - 45);
			alpha = sprTracker.alpha;
		}
	}
}
