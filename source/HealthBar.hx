package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;

using StringTools;

class HealthBar extends FlxTypedSpriteGroup<FlxSprite> {
	public var sprite:FlxSprite;
	public var bar:FlxBar;
	public var leftIcon:HealthIcon;
	public var rightIcon:HealthIcon;

	public function setIcon(side:Bool, ?name:Null<String>, ?icon:HealthIcon) {
		if (icon == null) {
			if ((side ? rightIcon : leftIcon) != null)
				return (side ? rightIcon : leftIcon).changeCharacter(name, side);
			icon = new HealthIcon(name, true);
		} else if (icon.isPlayer != side || icon.curCharacter != name) {
			icon.changeCharacter(name, side);
		}
		if (side) {
			remove(leftIcon, true);
			leftIcon = icon;
		} else {
			remove(rightIcon, true);
			rightIcon = icon;
		}
		if (!members.contains(icon))
			add(icon);
	}

	public function removeIcon(side:Bool) {
		remove(side ? rightIcon : leftIcon, true);
		if (side)
			rightIcon = null;
		else
			leftIcon = null;
	}

	public function new(x:Float, y:Float, ?image:String, ?barSides:Array<Float>, ?fillDirection:FlxBarFillDirection = FlxBarFillDirection.LEFT_TO_RIGHT) {
		super(x, y);
		sprite = new FlxSprite(0, 0, image == null ? Paths.image("normal/healthBar") : image);
		bar = new FlxBar(barSides[0], barSides[1], fillDirection, width - (barSides[0] + barSides[2]), height - (barSides[1] + barSides[3]));

		/*if (width > 100) {
			bar.numDivisions = Math.ceil(width);
		}*/

		add(sprite);
		add(bar);
	}

	public function setHealth(num:Float) {
		//amount = num / 2;
		//we like tweens
		if (amountTween != null)
			amountTween.cancel();
		amountTween = FlxTween.tween(this, {amount: num / 2}, 0.08);
	}

	public var amountTween:FlxTween;
	public var amount(default, set):Float = 0.5;

	public function set_amount(value:Float):Float {
		final iconOffset:Float = 26;
		final iconOffset2:Float = 150 - iconOffset;
		
		var healthSub:Float = flipX ? bar.percent : 100 - bar.percent;
		if (leftIcon != null)
			leftIcon.x = bar.x + (bar.width * (healthSub * 0.01) - iconOffset);
		if (rightIcon != null)
			rightIcon.x = bar.x + (bar.width * (healthSub * 0.01) - iconOffset2);

		return amount = value;
	}
}
