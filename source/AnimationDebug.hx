package;

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
class AnimationDebug extends MusicBeatState {
	var char:Character;
	var charGhost:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String;
	var camFollow:FlxObject;

	var colorBar:FlxSprite;
	var healthIcon:HealthIcon;
	
	var nameTxtBox:FlxUIInputText;
	var modName:String;

	//why does this error?
	//var playHint:FlxText = new FlxText(8, 8, 0, 'Use your 4K binds: ${Options.controls.get("4k").map(function(a) {return ControlsSubState.ConvertKey(a[0], true)}).join(",")} to play sing anims\nHold Shift to play miss anims instead');

	public function new(daAnim:String = 'bf') {
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
		
		var floorLine = new FlxSprite(xPositionThing + 50, 725).makeGraphic(10, 10);
		floorLine.color = FlxColor.BLUE;
		floorLine.scale.x = 25;
		floorLine.alpha = 0.5;
		add(floorLine);
		
		var originThing = new FlxSprite(xPositionThing, 0).makeGraphic(5, 5, FlxColor.RED);
		originThing.alpha = 0.5;
		add(originThing);

		//get char origin mod
		modName = CoolUtil.getFileOriginMod("objects/characters/" + daAnim + ".json", "");
		//
		char = new Character(xPositionThing, 0, daAnim, false, modName);
		char.debugMode = true;
		add(char);
		//

		if (char.isGirlfriend) {
			floorLine.x += 107;
			floorLine.y -= 72;
			floorLine.color = FlxColor.RED;
			floorLine.scale.x = 38.6;
		}

		charGhost = new Character(xPositionThing, 0, daAnim);
		charGhost.debugMode = true;
		charGhost.alpha = 0.5;
		charGhost.realcolor = FlxColor.GRAY;
		charGhost.visible = false;
		add(charGhost);
		
		char.applyPositionOffset();

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		updateTexts();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		var animThing = Character.loadCharacterJson(daAnim, modName);
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
		var UI_save:FlxUIButton = new FlxUIButton(FlxG.width - 120, UI_click.y + 24, "Save", function() {
			var anims = new Array<SwagCharacterAnim>();
			var validFile = fileAnims.keys().hasNext();
			var emptyIntArr = validFile ? null : new Array<Int>();
			for (anim in char.animation.getAnimationList()) {
				if (anim.name.endsWith("miss") && !char.hasMissAnims)
					continue;
				var note_cam_offset = char.noteCameraOffset.exists(anim.name) ? [char.noteCameraOffset[anim.name].x, char.noteCameraOffset[anim.name].y] : null;
				var validAnim = validFile && fileAnims.exists(anim.name);
				var newAnim = {
					name: anim.name,
					anim: !validAnim ? "<from hardcode>" : fileAnims[anim.name].anim,
					framerate: Std.int(anim.frameRate),
					offset: char.animOffsets[anim.name],
					indicies: !validAnim ? emptyIntArr : fileAnims[anim.name].indicies,
					loop: anim.looped,
					noteCameraOffset: note_cam_offset,
					nextAnim: !validAnim ? null : fileAnims[anim.name].nextAnim,
					flipX: !validAnim ? false : fileAnims[anim.name].flipX,
					flipY: !validAnim ? false : fileAnims[anim.name].flipY
				};
				if (Options.dataStrip) {
					if (newAnim.nextAnim == null)
						Reflect.deleteField(newAnim, "nextAnim");
					if (newAnim.noteCameraOffset == null)
						Reflect.deleteField(newAnim, "noteCameraOffset");
					if (newAnim.indicies == null || newAnim.indicies.length == 0)
						Reflect.deleteField(newAnim, "indicies");
					if (newAnim.flipX != true)
						Reflect.deleteField(newAnim, "flipX");
					if (newAnim.flipY != true)
						Reflect.deleteField(newAnim, "flipY");
				}
				anims.push(newAnim);
			}
			var savedChar:SwagCharacter = {
				image: imageFile,
				healthIcon: Character.getHealthIcon(char.curCharacter, null),
				deathChar: char.deathChar,
				deathSound: char.deathSound,
				initAnim: validFile && initAnim != null ? initAnim : ["danceLeft", "idle", "firstDeath"].filter(function(a) {return char.hasAnim(a);})[0],
				antialias: char.antialiasing,
				animations: anims,
				position: char.positionOffset,
				isPlayer: char.isPlayer,
				scale: char.scale.x,
				danceModulo: char.moduloDances,
				cameraOffset: char.cameraOffset,
				healthBarColor: [char.healthBarColor.red, char.healthBarColor.green, char.healthBarColor.blue],
				animNoSustain: char.animNoSustain,
				isGirlfriend: char.isGirlfriend,
				substitutable: validFile ? substitutable : (char.curCharacter.startsWith("bf_") || char.curCharacter == "bf" || char.curCharacter.startsWith("gf_") || char.curCharacter == "gf"),
				singTime: char.singTime,
				singBeats: char.singBeats
			};
			if (Options.dataStrip) {
				if (savedChar.substitutable != true)
					Reflect.deleteField(savedChar, "substitutable");
				if (savedChar.deathSound == null)
					Reflect.deleteField(savedChar, "deathSound");
				if (savedChar.deathChar == null)
					Reflect.deleteField(savedChar, "deathChar");
				if (savedChar.antialias != false)
					Reflect.deleteField(savedChar, "antialias");
				if (savedChar.isGirlfriend != true)
					Reflect.deleteField(savedChar, "isGirlfriend");
				if (savedChar.isPlayer != true)
					Reflect.deleteField(savedChar, "isPlayer");
				if (savedChar.scale == null || savedChar.scale == 1)
					Reflect.deleteField(savedChar, "scale");
				if (savedChar.position == null || (savedChar.position[0] == 0 && savedChar.position[1] == 0))
					Reflect.deleteField(savedChar, "position");
				if (savedChar.danceModulo == null || savedChar.danceModulo == 1)
					Reflect.deleteField(savedChar, "danceModulo");
				if (savedChar.cameraOffset == null || (savedChar.cameraOffset[0] == 0 && savedChar.cameraOffset[1] == 0))
					Reflect.deleteField(savedChar, "cameraOffset");
				if (savedChar.animNoSustain != true)
					Reflect.deleteField(savedChar, "animNoSustain");
				if (savedChar.healthBarColor == null)
					Reflect.deleteField(savedChar, "healthBarColor");
				if (savedChar.singTime == null || savedChar.singTime == 0)
					Reflect.deleteField(savedChar, "singTime");
				if (savedChar.singBeats == null || savedChar.singBeats == 0)
					Reflect.deleteField(savedChar, "singBeats");
			}
			var _file = new FileReference();
			_file.save(Json.stringify(savedChar), char.curCharacter + ".json");
		});
		add(nameTxtBox);
		add(UI_click);
		add(UI_save);
		nameTxtBox.scrollFactor.set();

		var text:FlxText = new FlxText(10, UI_save.y + 24, FlxG.width - 20, [
			"E/Q: Zoom in/out",
			"IJKL: Move camera",
			"W/S: Prev/Next Anim",
			"Arrow keys: Move offset",
			"Shift: Move offset/camera faster",
			"Z: Set ghost to current anim",
			"X: Remove ghost",
			"C: Toggle flip",
			//Options.getUIControlName("gtstrum") + ": Toggle anim gameplay test",
			Options.getUIControlName("back") + ": Exit"
		].join("\n"), 15);
		text.alignment = FlxTextAlign.RIGHT;
		text.scrollFactor.set();
		add(text);

		var barSprite:FlxSprite = new FlxSprite(20, FlxG.height - 80, Paths.image("normal/healthBarShorter2"));
		colorBar = new FlxSprite(barSprite.x + 4, barSprite.y + 4).makeGraphic(barSprite.frameWidth - 8, barSprite.frameHeight - 8);
		colorBar.color = char.healthBarColor;
		barSprite.scrollFactor.set();
		colorBar.scrollFactor.set();
		add(barSprite);
		add(colorBar);

		healthIcon = new HealthIcon(char.healthIcon, modName);
		healthIcon.y = colorBar.y - (healthIcon.height / 2);
		healthIcon.x = colorBar.x + colorBar.width + 26 - 150;
		add(healthIcon);

		updateAnimNameText();
		super.create();
	}

	inline function genBoyOffsets():Void {
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
	}

	function updateTexts():Void {
		/*dumbTexts.forEach(function(text:FlxText) {
			text.destroy();
			dumbTexts.remove(text, true);
		});*/
		CoolUtil.clearMembers(dumbTexts);
		genBoyOffsets();
	}

	public function updateAnimNameText() {
		textAnim.text = char.animation.curAnim.name;
	}

	override function update(elapsed:Float) {
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
			if (FlxG.keys.justPressed.W)
				curAnim -= 1;

			if (FlxG.keys.justPressed.S)
				curAnim += 1;

			if (curAnim < 0)
				curAnim = animList.length - 1;
	
			if (curAnim >= animList.length)
				curAnim = 0;
			
			offsetTextCol();
		}

		if (FlxG.keys.justPressed.Z) {
			charGhost.playAnim(char.animation.curAnim.name, true);
			charGhost.offset.x = char.offset.x;
			charGhost.offset.y = char.offset.y;
			charGhost.x = char.x;
			charGhost.y = char.y;
			charGhost.visible = true;
			charGhost.flipX = char.flipX;
		}

		if (FlxG.keys.justPressed.X)
			charGhost.visible = false;

		if (FlxG.keys.justPressed.C) {
			char.flipX = !char.flipX;
			char.playAnim(char.animation.curAnim.name, true);
		}

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE) {
			char.playAnim(animList[curAnim], true);

			updateAnimNameText();
			updateTexts();
		}
		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		if (upP || rightP || downP || leftP) {
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
			offsetTextCol();
		}
		
		if (controls.BACK) {
			FlxG.mouse.visible = false;

			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}
