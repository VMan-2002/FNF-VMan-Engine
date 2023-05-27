package atlas;

import Character.SwagCharacter;
import Character.SwagCharacterAnim;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.net.FileReference;

using StringTools;

/**
	*DEBUG MODE
 */
class AtlasTestState extends MusicBeatState {
	var char:AtlasTest;
	var animList:Array<Dynamic> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	
	var nameTxtBox:FlxUIInputText;
	
	var frameTxt:FlxText;

	//why does this error?
	//var playHint:FlxText = new FlxText(8, 8, 0, 'Use your 4K binds: ${Options.controls.get("4k").map(function(a) {return ControlsSubState.ConvertKey(a[0], true)}).join(",")} to play sing anims\nHold Shift to play miss anims instead');

	public function new(daAnim:String = 'spooky') {
		super();
		this.daAnim = daAnim;
	}

	public static var imageFile:String;
	var fileAnims = new Map<String, SwagCharacterAnim>();
	var substitutable:Bool = false;
	var initAnim:Null<String> = null;

	override function create() {
		FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);
		
		var xPositionThing = FlxG.width / 2;
		xPositionThing -= 150;
		
		var floorLine = new FlxSprite(xPositionThing + 50, 725).makeGraphic(250, 10, FlxColor.BLUE);
		floorLine.alpha = 0.5;
		add(floorLine);
		
		var originThing = new FlxSprite(xPositionThing, 0).makeGraphic(5, 5, FlxColor.RED);
		originThing.alpha = 0.5;
		add(originThing);

		//
		var dad = new AtlasTest(xPositionThing, 0, daAnim);
		add(dad);

		char = dad;
		//

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		var animThing = Character.loadCharacterJson(daAnim, null);
		if (animThing != null && animThing.animations != null) {
			for (anim in animThing.animations) {
				fileAnims.set(anim.name, anim);
			}
			substitutable = animThing.substitutable == true;
			initAnim = animThing.initAnim;
		}
		
		nameTxtBox = new FlxUIInputText(FlxG.width - 200, 10, 70, daAnim, 8);
		var UI_click:FlxUIButton = new FlxUIButton(FlxG.width - 120, 8, "Load", function() {
			FlxG.switchState(new AnimationDebug(nameTxtBox.text));
		});
		add(nameTxtBox);
		add(UI_click);
		nameTxtBox.scrollFactor.set();

		var text:FlxText = new FlxText(10, UI_click.y + 24, FlxG.width - 20, [
			"E/Q: Zoom in/out",
			"IJKL: Move camera",
			"W/S: Prev/Next Anim",
			"Arrow keys: Move offset",
			"Shift: Move offset/camera faster",
			"Z: Set ghost to current anim",
			"X: Remove ghost",
			"C: Toggle flip",
			Options.getUIControlName("back") + ": Exit"
		].join("\n"), 15);
		text.alignment = FlxTextAlign.RIGHT;
		text.scrollFactor.set();
		add(text);

		frameTxt = new FlxText(10, FlxG.height - 22, FlxG.width - 20, "", 15);
		frameTxt.alignment = FlxTextAlign.RIGHT;
		frameTxt.scrollFactor.set();
		add(frameTxt);

		super.create();
	}

	/*inline function genBoyOffsets():Void {
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets) {
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			dumbTexts.add(text);

			if (!animList.contains(anim))
				animList.push(anim);

			daLoop++;
		}

		offsetTextCol();
	}

	public function offsetTextCol() {
		for (i in 0...animList.length) {
			dumbTexts.members[i].color = curAnim == i ? FlxColor.YELLOW : FlxColor.BLUE;
		}
	}*/

	function updateTexts():Void {
		frameTxt.text = "Current anim: "+char.myAnims[curAnim];
		/*dumbTexts.forEach(function(text:FlxText) {
			text.destroy();
			dumbTexts.remove(text, true);
		});*/
		//CoolUtil.clearMembers(dumbTexts);
		//genBoyOffsets();
	}

	override function update(elapsed:Float) {
		//textAnim.text = char.animation.curAnim.name;
		if (nameTxtBox.hasFocus)
			return super.update(elapsed);
		
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
		
		if (FlxG.keys.justPressed.W != FlxG.keys.justPressed.S) {
			if (FlxG.keys.justPressed.S)
				curAnim += FlxG.keys.justPressed.W ? -1 : 1;
			
			//offsetTextCol();
		}

		/*if (FlxG.keys.justPressed.Z) {
			charGhost.playAnim(char.animation.curAnim.name, true);
			charGhost.offset.x = char.offset.x;
			charGhost.offset.y = char.offset.y;
			charGhost.x = char.x;
			charGhost.y = char.y;
			charGhost.visible = true;
			charGhost.flipX = char.flipX;
		}*/

		/*if (FlxG.keys.justPressed.X)
			charGhost.visible = false;*/

		if (FlxG.keys.justPressed.C)
			char.flipX = !char.flipX;

		if (curAnim < 0)
			curAnim = char.myAnims.length - 1;

		if (curAnim >= char.myAnims.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE) {
			char.playAnim(char.myAnims[curAnim], true);

			updateTexts();
		}
		/*var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);*/

		/*if (upP || rightP || downP || leftP) {
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[char.flipX ? 2 : 0] += multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[char.flipX ? 2 : 0] -= multiplier;

			updateTexts();
			char.playAnim(animList[curAnim]);
			//offsetTextCol();
		}*/
		
		if (controls.BACK) {
			FlxG.mouse.visible = false;

			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}
