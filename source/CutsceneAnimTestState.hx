package;

import animate.FlxAnimate;
// import animateAtlasPlayer.assets.AssetManager;
// import animateAtlasPlayer.core.Animation;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
class CutsceneAnimTestState extends MusicBeatState
{
	var cutsceneGroup:CutsceneCharacter;

	var curSelected:Int = 0;
	var debugTxt:FlxText;
	var frameTxt:FlxText;
	
	var camFollow:FlxObject;
	var animated:FlxAnimate;

	public function new()
	{
		super();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		debugTxt = new FlxText(900, 20, 0, "", 20);
		debugTxt.color = FlxColor.BLUE;
		add(debugTxt);

		var text:FlxText = new FlxText(10, 10, FlxG.width - 20, [
			"E/Q: Zoom in/out",
			"IJKL: Move camera",
			"F/G: Change selected cutsceneGroup member",
			"R: Reset animation to first frame",
			"SPACE: Toggle animation playback",
			",/.: Frame advance",
			"Arrow keys: Move selected cutsceneGroup member",
			"Hold SHIFT: Move cutsceneGroup member faster",
			Options.getUIControlName("back") + ": Exit"
		].join("\n"), 15);
		text.alignment = FlxTextAlign.RIGHT;
		text.scrollFactor.set();
		add(text);

		frameTxt = new FlxText(10, FlxG.height - 22, FlxG.width - 20, "", 15);
		frameTxt.alignment = FlxTextAlign.RIGHT;
		frameTxt.scrollFactor.set();
		add(frameTxt);

		animated = new FlxAnimate(600, 200);
		add(animated);

		// createCutscene(0);
		// createCutscene(1);
		// createCutscene(2);
		// createCutscene(3);
		// createCutscene(4);
	}

	override function update(elapsed:Float) {
		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = holdShift ? 10 : 1;
			
		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L) {
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90 * multiplier;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90 * multiplier;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90 * multiplier;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90 * multiplier;
			else
				camFollow.velocity.x = 0;
		} else {
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.SPACE) {
			animated.playingAnim = !animated.playingAnim;
		}
		
		if (FlxG.keys.justPressed.R) {
			animated.daFrame = 0;
			animated.frameTickTypeShit = 0;
		}
		
		if (FlxG.keys.justPressed.COMMA != FlxG.keys.justPressed.PERIOD) {
			animated.daFrame += FlxG.keys.justPressed.COMMA ? -1 : 1;
		}

		frameTxt.text = "Frame "+animated.daFrame;

		/*if (FlxG.keys.justPressed.R != FlxG.keys.justPressed.F) {
			if (FlxG.keys.justPressed.R)
				curSelected -= 1;
			else
				curSelected += 1;

			if (curSelected < 0)
				curSelected = cutsceneGroup.members.length - 1;
			else if (curSelected >= cutsceneGroup.members.length)
				curSelected = 0;
		}

		if (FlxG.keys.justPressed.UP)
			cutsceneGroup.members[curSelected].y -= multiplier;
		if (FlxG.keys.justPressed.DOWN)
			cutsceneGroup.members[curSelected].y += multiplier;
		if (FlxG.keys.justPressed.LEFT)
			cutsceneGroup.members[curSelected].x -= multiplier;
		if (FlxG.keys.justPressed.RIGHT)
			cutsceneGroup.members[curSelected].x += multiplier;

		debugTxt.text = curSelected + " : " + cutsceneGroup.members[curSelected].getPosition();*/
			
		if (controls.BACK) {
			FlxG.mouse.visible = false;

			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}
