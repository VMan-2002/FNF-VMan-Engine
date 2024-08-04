package new_editors;

import Character.SwagCharacter;
import Character.SwagCharacterAnim;
import Stage.SwagStage;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.net.FileReference;
import openfl.net.IDynamicPropertyOutput;
import sys.FileSystem;
import MusicBeatState;

using StringTools;

/**
	*DEBUG MODE
 */
class StageEditorState extends MusicBeatState
{
	var char:Character;
	var charGhost:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'stage';
	var camFollow:FlxObject;

	var stageObj:Stage;
	var objectGroups = new Array<FlxTypedGroup<Dynamic>>();

	var colorBar:FlxSprite;
	var healthIcon:HealthIcon;
	
	var nameTxtBox:FlxUIInputText;

	//why does this error?
	//var playHint:FlxText = new FlxText(8, 8, 0, 'Use your 4K binds: ${Options.controls.get("4k").map(function(a) {return ControlsSubState.ConvertKey(a[0], true)}).join(",")} to play sing anims\nHold Shift to play miss anims instead');

	public function new(daAnim:String = 'stage')
	{
		super();
		this.daAnim = daAnim;
	}

	public static var imageFile:String;
	var fileAnims = new Map<String, SwagCharacterAnim>();
	var substitutable:Bool = false;
	var initAnim:Null<String> = null;

	var stageData:SwagStage;

	final charModes = ["Characters invisible", "Characters visible", "Characters moveable"];
	final charNames = ["Boyfriend", "Dad", "Girlfriend"];
	final charPuts = ["bf", "dad", "gf", "pico"];
	final layerNames = ["Back Layer", "Between Layer", "Front Layer", "Characters"];

	var textObjMode:FlxText;
	var textCamMode:FlxText;
	var curMode:Int = 1;
	var curSelected:Int = 0;
	var selectedGroup:FlxTypedGroup<SpriteVMan>;
	var selectedObjectAnimCount:Int = 0;
	var selectedGroupNum:Int = 0;
	var isDragging = false;
	var dragOffset = new FlxPoint();
	var draggingObject:SpriteVMan;

	override function create() {
		FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);
		gridBG.alpha = 1/16;

		//because of how stages are loaded it's crucial we figure out what mod it's from
		var modStageIsFrom = "";
		for (n in ModLoad.enabledMods) {
			if (FileSystem.exists('mod/${n}/objects/stages/${daAnim}.json')) {
				modStageIsFrom = n;
				trace(daAnim+" Stage belongs to mod: "+n);
				break;
			}
		}
		PlayState.modName = modStageIsFrom;

		stageObj = new Stage(daAnim, modStageIsFrom, true);

		objectGroups.push(new FlxTypedGroup<FlxTypedGroup<FlxSprite>>());
		objectGroups.push(stageObj.elementsBack);
		objectGroups.push(new FlxTypedGroup<Character>()); //Girlfriend group
		objectGroups.push(stageObj.elementsBetween);
		objectGroups.push(new FlxTypedGroup<Character>()); //Other characters
		objectGroups.push(stageObj.elementsFront);
		objectGroups.push(new FlxTypedGroup<Character>()); //All characters
		for (i in CoolUtil.numberArray(5, 1)) {
			objectGroups[0].add(objectGroups[i]);
		}
		add(objectGroups[0]);

		for (i in 0...stageObj.charPosition.length) {
			var charToAdd = new Character(stageObj.charPosition[i][0], stageObj.charPosition[i][1], charPuts[i < charPuts.length ? i : charPuts.length - 1], stageObj.charFacing.contains(i));
			charToAdd.debugMode = true;
			charToAdd.dance();
			charToAdd.alpha = 0.75;
			charToAdd.applyPositionOffset();
			objectGroups[stageObj.charBetween.contains(i) ? 2 : 4].add(charToAdd);
			objectGroups[6].add(charToAdd);
		}

		selectedGroup = cast objectGroups[1];
		
		var xPositionThing = FlxG.width / 2;
		xPositionThing -= 150;

		/*//
		var dad = new Character(xPositionThing, 0, daAnim);
		dad.debugMode = true;
		add(dad);

		char = dad;
		//

		charGhost = new Character(xPositionThing, 0, daAnim);
		charGhost.debugMode = true;
		charGhost.alpha = 0.5;
		charGhost.realcolor = FlxColor.GRAY;
		charGhost.visible = false;
		add(charGhost);
		
		char.applyPositionOffset();*/

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		stageData = Stage.getStage(daAnim, modStageIsFrom);
		if (stageData == null) {
			//Stage is invalid so let's load the default
			trace("stage "+daAnim+" of "+modStageIsFrom+" is null");
			super.create();
			FlxTransitionableState.skipNextTransOut = true;
			new StageEditorState().switchToThis();
			return;
		}

		updateTexts();
		
		nameTxtBox = new FlxUIInputText(FlxG.width - 200, 10, 70, daAnim, 8);
		var UI_click:FlxUIButton = new FlxUIButton(FlxG.width - 120, 8, "Load", function() {
			FlxG.switchState(new StageEditorState(nameTxtBox.text));
		});
		var UI_save:FlxUIButton = new FlxUIButton(FlxG.width - 120, UI_click.y + 24, "Save", function() {
			/*var savedChar:SwagStage = {
				charPosition
			};
			var _file = new FileReference();
			_file.save(Json.stringify(savedChar), char.curCharacter + ".json");*/
		});
		add(nameTxtBox);
		add(UI_click);
		add(UI_save);
		nameTxtBox.scrollFactor.set();

		textObjMode = new FlxText(10, UI_save.y + 24, FlxG.width - 20, [
			"[Object Mode] (1/2)",
			"U: Switch mode",
			"E/Q: Zoom in/out",
			"IJKL: Move camera",
			"W/S: Prev/Next Stage Layer",
			"A/D: Prev/Next Stage Element",
			"Arrow keys/Right-click drag: Move element",
			"SHIFT: Move element/camera faster",
			"Hold CTRL: Move scrollFactor instead of position",
			"Hold SHIFT+CTRL: Move scale instead of position",
			"Z/C: Prev/Next anim of selected",
			"X: Replay anim of selected",
			"F: Toggle characters",
			Options.getUIControlName("back") + ": Exit"
		].join("\n"), 15);
		textObjMode.alignment = FlxTextAlign.RIGHT;
		textObjMode.scrollFactor.set();
		add(textObjMode);

		textCamMode = new FlxText(10, UI_save.y + 24, FlxG.width - 20, [
			"[Camera Mode] (2/2)",
			"U: Switch mode",
			"E/Q: Zoom in/out",
			"IJKL/Right-click drag: Move camera",
			"W/S: Prev/Next Character",
			"A/D: Prev/Next Extra Cam Pos",
			"Z/C: Set/Remove Zoom for this char",
			"X: Set default cam zoom",
			"SHIFT: Move camera faster",
			Options.getUIControlName("back") + ": Exit"
		].join("\n"), 15);
		textCamMode.alignment = FlxTextAlign.RIGHT;
		textCamMode.scrollFactor.set();
		add(textCamMode);

		switchMode(0);

		super.create();
	}

	function genBoyOffsets():Void {
		switch(curMode) {
			case 1: //Object mode
				var text:FlxText = new FlxText(10, 20, 0, layerNames[selectedGroupNum], 15);
				text.scrollFactor.set();
				dumbTexts.add(text);
				for (item in selectedGroup.members) {
					var num = dumbTexts.length - 1;
					var name = switch(selectedGroupNum) {
						case 3:
							Reflect.getProperty(item, "curCharacter") + ' (${num < 3 ? charNames[num] : 'Slot $num'})';
						default:
							Reflect.getProperty(stageData, ["elementsBack", "elementsBetween", "elementsFront"][selectedGroupNum])[num].name;
					}
					var text:FlxText = new FlxText(10, 20 + 18 * dumbTexts.length, 0, name + ": " + item.x + ", " + item.y, 15);
					text.scrollFactor.set();
					dumbTexts.add(text);

					/*if (!animList.contains(anim))
						animList.push(anim);*/
				}
			case 2: //Camera mode
				var text:FlxText = new FlxText(10, 20, 0, "Camera Positions", 15);
				text.scrollFactor.set();
				dumbTexts.add(text);
				//todo: this
		}

		offsetTextCol();
	}

	public function offsetTextCol() {
		for (i in 1...dumbTexts.length) {
			dumbTexts.members[i].color = (switch(curMode) {
				case 2: //Camera mode
					false; //todo: this
				default: //Object mode
					curSelected == i - 1;
			}) ? FlxColor.YELLOW : FlxColor.BLUE;
		}
	}

	function updateTexts():Void {
		/*dumbTexts.forEach(function(text:FlxText) {
			text.destroy();
			dumbTexts.remove(text, true);
		});*/
		CoolUtil.clearMembers(dumbTexts);
		genBoyOffsets();
	}

	function switchMode(?by:Int = 1) {
		if (curMode >= 2)
			curMode = 1;
		else
			curMode += by;
		
		textObjMode.visible = curMode == 1;
		textCamMode.visible = curMode == 2;

		updateTexts();
	}

	function flashItem(spr:SpriteVMan) {
		FlxTween.color(spr, 0.5, FlxColor.BLUE, spr.color, {ease: FlxEase.cubeOut});
	}

	override function update(elapsed:Float) {
		//textAnim.text = char.animation.curAnim.name;
		textAnim.text = "hi";
		if (nameTxtBox.hasFocus)
			return super.update(elapsed);
		
		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = holdShift ? 10 : 1;
		
		var zoomMove = curMode == 2 ? 0.05 : 0.25;
		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += zoomMove;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= zoomMove;

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

		if (FlxG.keys.justPressed.U)
			switchMode();

		//mode specific things
		switch(curMode) {
			case 1: //Object mode
				//Object anim
				if (FlxG.keys.justPressed.Z != FlxG.keys.justPressed.C) {
					curSelected += FlxG.keys.justPressed.Z ? -1 : 1;
		
					if (curAnim < 0)
						curAnim = selectedObjectAnimCount - 1;
			
					if (curAnim >= selectedObjectAnimCount)
						curAnim = 0;
					
					offsetTextCol();
				}
		
				if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.C || FlxG.keys.justPressed.X) {
					selectedGroup.members[curSelected].playAnim(animList[curAnim], true);
					updateTexts();
				}

				if (FlxG.keys.justPressed.W != FlxG.keys.justPressed.S) {
					selectedGroupNum += FlxG.keys.justPressed.W ? -1 : 1;
					if (selectedGroupNum > 3)
						selectedGroupNum = 0;
					else if (selectedGroupNum < 0)
						selectedGroupNum = 3;
					selectedGroup = cast objectGroups[[1, 3, 5, 6][selectedGroupNum]];
					if (curSelected >= selectedGroup.length)
						curSelected = 0;

					for (n in objectGroups[6].members)
						n.alpha = selectedGroupNum == 3 ? 1 : 0.75;
					
					flashItem(selectedGroup.members[curSelected]);
					updateTexts();
				}

				if (FlxG.keys.justPressed.F) {
					objectGroups[2].visible = !objectGroups[2].visible;
					objectGroups[4].visible = objectGroups[2].visible;
				}
				if (FlxG.keys.justPressed.A != FlxG.keys.justPressed.D) {
					curSelected += FlxG.keys.justPressed.A ? -1 : 1;
		
					if (curSelected < 0)
						curSelected = selectedGroup.length - 1;
			
					if (curSelected >= selectedGroup.length)
						curSelected = 0;

					selectedObjectAnimCount = selectedGroup.members[curSelected].animation.getAnimationList().length;

					flashItem(selectedGroup.members[curSelected]);
					offsetTextCol();
				}

				var upP = FlxG.keys.anyJustPressed([UP]);
				var rightP = FlxG.keys.anyJustPressed([RIGHT]);
				var downP = FlxG.keys.anyJustPressed([DOWN]);
				var leftP = FlxG.keys.anyJustPressed([LEFT]);
		
				if (upP || rightP || downP || leftP) {
					/*if (upP)
						char.animOffsets.get(animList[curAnim])[1] += multiplier;
					if (downP)
						char.animOffsets.get(animList[curAnim])[1] -= multiplier;
					if (leftP)
						char.animOffsets.get(animList[curAnim])[char.flipX ? 2 : 0] += multiplier;
					if (rightP)
						char.animOffsets.get(animList[curAnim])[char.flipX ? 2 : 0] -= multiplier;*/
		
					updateTexts();
					//char.playAnim(animList[curAnim]);
					offsetTextCol();
				}
				if (isDragging) {
					if (!FlxG.mouse.pressedRight) {
						isDragging = false;
					} else {
						draggingObject.x = FlxG.mouse.x + dragOffset.x;
						draggingObject.y = FlxG.mouse.y + dragOffset.y;
					}
				} else {
					if (FlxG.mouse.justPressedRight) {
						draggingObject = selectedGroup.members[curSelected];
						var weakRect = FlxRect.weak();
						var mousePos = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
						if (draggingObject.getScreenBounds(weakRect).containsPoint(mousePos)) {
							for (obj in selectedGroup) {
								if (obj.getScreenBounds(weakRect).containsPoint(mousePos)) {
									draggingObject = obj;
									isDragging = true;
									flashItem(obj);
								}
							}
						} else {
							isDragging = true;
						}
						dragOffset.x = mousePos.x;
						weakRect.put();
						mousePos.put();
					}
				}
			case 2: //Camera mode
				
		}
		
		if (controls.BACK) {
			FlxG.mouse.visible = false;

			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}
