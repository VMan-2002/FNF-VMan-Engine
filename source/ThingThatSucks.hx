package;

import Controls.Control;
import OptionsMenu;
import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ResetControlsSubState extends MusicBeatSubstate
{
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(0, 15, FlxG.width - 20, Translation.getTranslation("reset controls desc", "mainmenu", null, "Oops, that's kinda embarrassing.\nPress ENTER to reset your controls,\nor press ESCAPE to dismiss."), 32);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
		Translation.setObjectFont(levelInfo, "vcr font");
		levelInfo.updateHitbox();
		add(levelInfo);

		levelInfo.alpha = 0;

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER) {
			Options.uiControls = Options.uiControlsDefault;
			Options.SaveOptions();
			FlxG.switchState(new OptionsMenu(new ControlsSubState()));

			close();
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			close();
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}
