package;

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

/**
	*DEBUG MODE
 */
class AnimationDebug extends MusicBeatState
{
	var bf:Boyfriend;
	var dad:Character;
	var char:Character;
	var charGhost:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	
	var nameTxtBox:FlxUIInputText;

	//why does this error?
	//var playHint:FlxText = new FlxText(8, 8, 0, 'Use your 4K binds: ${Options.controls.get("4k").map(function(a) {return ControlsSubState.ConvertKey(a[0], true)}).join(",")} to play sing anims\nHold Shift to play miss anims instead');

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		FlxG.sound.music.stop();

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

		if (daAnim == 'bf')
			isDad = false;

		if (isDad)
		{
			dad = new Character(xPositionThing, 0, daAnim);
			dad.debugMode = true;
			add(dad);

			char = dad;
		}
		else
		{
			bf = new Boyfriend(xPositionThing, 0);
			bf.debugMode = true;
			add(bf);

			char = bf;
		}

		charGhost = new Character(xPositionThing, 0, daAnim);
		charGhost.debugMode = true;
		charGhost.alpha = 0.5;
		charGhost.color = FlxColor.GRAY;
		charGhost.visible = false;
		add(charGhost);
		
		char.applyPositionOffset();

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);
		
		nameTxtBox = new FlxUIInputText(FlxG.width - 200, 10, 70, daAnim, 8);
		var UI_click:FlxUIButton = new FlxUIButton(FlxG.width - 120, 8, "Load", function() {
			FlxG.switchState(new AnimationDebug(nameTxtBox.text));
		});
		add(nameTxtBox);
		add(UI_click);

		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;
		if (!nameTxtBox.hasFocus) {
			var holdShift = FlxG.keys.pressed.SHIFT;
			var multiplier = 1;
			if (holdShift)
				multiplier = 10;
				
			if (FlxG.keys.justPressed.E)
				FlxG.camera.zoom += 0.25;
			if (FlxG.keys.justPressed.Q)
				FlxG.camera.zoom -= 0.25;

			if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
			{
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
			}
			else
			{
				camFollow.velocity.set();
			}

			if (FlxG.keys.justPressed.W)
			{
				curAnim -= 1;
			}

			if (FlxG.keys.justPressed.Z)
			{
				charGhost.playAnim(char.animation.curAnim.name, true);
				charGhost.offset.x = char.offset.x;
				charGhost.offset.y = char.offset.y;
				charGhost.x = char.x;
				charGhost.y = char.y;
				charGhost.visible = true;
			}

			if (FlxG.keys.justPressed.X)
			{
				charGhost.visible = false;
			}

			if (FlxG.keys.justPressed.S)
			{
				curAnim += 1;
			}

			if (curAnim < 0)
				curAnim = animList.length - 1;

			if (curAnim >= animList.length)
				curAnim = 0;

			if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
			{
				char.playAnim(animList[curAnim], true);

				updateTexts();
				genBoyOffsets(false);
			}
			var upP = FlxG.keys.anyJustPressed([UP]);
			var rightP = FlxG.keys.anyJustPressed([RIGHT]);
			var downP = FlxG.keys.anyJustPressed([DOWN]);
			var leftP = FlxG.keys.anyJustPressed([LEFT]);

			if (upP || rightP || downP || leftP)
			{
				updateTexts();
				if (upP)
					char.animOffsets.get(animList[curAnim])[1] += multiplier;
				if (downP)
					char.animOffsets.get(animList[curAnim])[1] -= multiplier;
				if (leftP)
					char.animOffsets.get(animList[curAnim])[char.flipX ? 2 : 1] += multiplier;
				if (rightP)
					char.animOffsets.get(animList[curAnim])[char.flipX ? 2 : 1] -= multiplier;

				updateTexts();
				genBoyOffsets(false);
				char.playAnim(animList[curAnim]);
			}
			
			if (controls.BACK) {
				FlxG.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}
}
