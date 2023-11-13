package;

import Character;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import json2object.JsonParser;
import lime.utils.Assets;
import sys.FileSystem;

using StringTools;
#if !html5
import cpp.abi.Abi;
import sys.io.File;
#end

//todo: The the and the talk

class DialogueFile {
	public var texts:Array<DialogueLine> = new Array<DialogueLine>();
	public var dontClose:Bool = false;
	public var usedInFreeplay:Bool = false;
	public var music:String;
	public var introSound:String;
	public var stopMusicOnEnd:Bool = true;
}

class DialogueLine {
	public var text:String = "Whats going on bros names pewdiepie";
	public var rate:Float = 0.04;
	public var boxMode:String = "normal";
	public var portraitEvents:Array<PortraitEvent>;
	public var boxStyle = "default";
	public var skippable:Bool = true;
	public var textMustPlay:Bool = false;
	public var autoNext:Bool = false;
	public var autoNextDelay:Float = 0.0;
	public var fontSize:Float = 1.0;
	public var font:String = "";
	public var choices:Array<String>;
	public var screenGraphic:String = "";
	public var screenGraphicAnim:String = "";
	public var screenGraphicLoop:Bool = true;
	public var music:String;
}

class PortraitEvent {
	public var number:Int = 0;
	public var character:String = "";
	public var expression:String = "";
	public var isTalking:Bool = true;
	public var flip:Bool = false;
	public var side:Float = 1; //-1 left, 0 middle, 1 right
	public var removeCharacter:Bool = false;
}

class DialogBoxStyle {
	public var image:String = "";
	public var imagePosition:Array<Float> = [-20, 45, 6];
	public var animations:Array<Character.SwagCharacterAnim>;
	public var textPosition:Array<Float> = [240, 500];
	public var textLines:Int = 3;
	public var textOverflowUp:Bool = false;
	public var font:String = "";
	public var fontSize:Int = 18;
	public var fontColor:String = "0xffffffff";
	public var fontShadowColor:String = "0xff000000";
	public var closeType:String = "pixel";

	public static function load(n:String, modName:String):DialogBoxStyle {
		var thing:DialogBoxStyle = cast CoolUtil.useJson2Object(new JsonParser<DialogBoxStyle>(), CoolUtil.tryPathBoth(n, modName));
		return thing;
	}
}

class DialogueBoxVMan extends FlxSpriteGroup {
	var box:SpriteVMan;

	var curCharacter:DialogueCharacter;

	//var dialogue:Alphabet;
	var dialogueList:Array<DialogueLine> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;
	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var curDialogBoxStyle:String = "";

	public var dialogueFile:DialogueFile;

	public var charList:Array<String> = [];
	public var charObjects:FlxTypedSpriteGroup<DialogueCharacter> = new FlxTypedSpriteGroup<DialogueCharacter>();

	public var screenGraphic:FlxSprite = new FlxSprite();

	public var overflowUp = false;
	public var closeType = "pixel";
	public var closeTime:Float = 1.2;
	public var dialogueLineCount:Int = 0;
	public var autoWait:Float = 0;
	public var curBoxStyle:Null<String> = null;
	public var stopMusicOnEnd:Bool = true;

	public function new(?file:Null<String>, ?dialogueFile:DialogueFile) {
		super();

		trace('loading vman dialogue');

		var parser = new JsonParser<DialogueFile>();
		if (file != null) {
			#if !html5
			this.dialogueFile = dialogueFile = parser.fromJson(File.getContent(file));
			#else
			this.dialogueFile = dialogueFile = parser.fromJson(Assets.getText(file));
			#end
		} else {
			this.dialogueFile = dialogueFile;
		}
		dialogueList = dialogueFile.texts;
		dialogueLineCount = dialogueFile.texts.length;

		trace(dialogueList[0].text);
		stopMusicOnEnd = dialogueFile.stopMusicOnEnd != false;

		if (dialogueList[0].music != "" && dialogueList[0].music != null) {
			FlxG.sound.playMusic(Paths.music(dialogueList[0].music), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(8, 8, 0xFFB3DFd8);
		bgFade.scale.set(FlxG.width * 0.1625, FlxG.height * 0.1625);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer) {
			bgFade.alpha += 0.7 / 5;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		add(charObjects);

		if (dialogueFile.introSound != "")
			FlxG.sound.play(Paths.sound(dialogueFile.introSound));

		box = new SpriteVMan(-20, 45);

		switch (dialogueFile.texts[0].boxStyle) {
			case 'senpai':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.animation.addByIndices('normalClose', 'Text Box Appear', [4, 3, 2, 1, 0], "", 24);
			case 'roses':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
				box.animation.addByIndices('normalClose', 'SENPAI ANGRY IMPACT SPEECH', [4, 3, 2, 1, 0], "", 24);
			case 'thorns':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
				box.animation.addByIndices('normalClose', 'Spirit Textbox spawn', [11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.scale.set(6, 6);
				add(face);
			case 'invisible':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByIndices('normalOpen', 'Text Box Appear', [4], "", 24);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.animation.addByIndices('normalClose', 'Text Box Appear', [4], "", 24);
				box.visible = false;
			default:
				//it's the same rn
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.animation.addByIndices('normalClose', 'Text Box Appear', [4, 3, 2, 1, 0], "", 24);
		}
		
		portraitLeft = new FlxSprite(-20, 40);
		portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
		portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		portraitLeft.scale.set(PlayState.daPixelZoom * 0.9, PlayState.daPixelZoom * 0.9);
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite(0, 40);
		portraitRight.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait');
		portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		portraitRight.scale.set(PlayState.daPixelZoom * 0.9, PlayState.daPixelZoom * 0.9);
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;
		
		box.playAnim('normalOpen');
		box.scale.set(PlayState.daPixelZoom * 0.9, PlayState.daPixelZoom * 0.9);
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('pixelUI/hand_textbox'));
		handSelect.scale.set(PlayState.daPixelZoom * 0.9, PlayState.daPixelZoom * 0.9);
		add(handSelect);

		if (dialogueFile.texts[0].boxStyle == "invisible") {
			portraitLeft.x = -4000;
			portraitRight.x = -4000;
			handSelect.x = -4000;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.color = 0xFFD89494;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(dropText.width), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);
		
		Translation.setObjectFont(swagDialogue, "pixel font");
		dropText.font = swagDialogue.font;

		// dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);

		Scripting.runOnScripts("dialogueStart", [this]);
	}

	public function setDialogueBoxStyle(style:DialogBoxStyle):Void {
		var keepAnim = box.animation.curAnim != null ? box.animation.curAnim.name : "normalOpen";
		box.animation.destroyAnimations();
		box.frames = Paths.getSparrowAtlas(style.image);
		box.setPosition(style.imagePosition[0], style.imagePosition[1]);
		box.scale.x = style.imagePosition.length <= 2 ? 1 : style.imagePosition[2];
		box.scale.y = style.imagePosition.length <= 3 ? box.scale.x : style.imagePosition[3];
		
		for (a in 0...style.animations.length)
			Character.loadAnimation(box, style.animations[a]);
		
		box.playAvailableAnim([keepAnim, 'normalOpen']);
		
		swagDialogue.setPosition(style.textPosition[0], style.textPosition[1]);
		swagDialogue.fieldWidth = Std.int(style.textPosition[2]);
		swagDialogue.setFormat(null, style.fontSize, style.fontColor);
		Translation.setObjectFont(swagDialogue, style.font, "vcr font");

		var offsetpos = [style.textPosition.length <= 2 ? 0 : style.textPosition[3]];
		offsetpos[1] = style.textPosition.length <= 3 ? offsetpos[0] : style.textPosition[4];
		dropText.setPosition(swagDialogue.x + offsetpos[0], swagDialogue.y + offsetpos[1]);
		dropText.fieldWidth = swagDialogue.fieldWidth;
		dropText.setFormat(swagDialogue.font, style.fontSize, style.fontColor);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float) {
		Scripting.runOnScripts("dialogueUpdate", [this, elapsed]);

		if (box.animation.curAnim != null) {
			if (box.animEndsWith('Open') && box.animation.curAnim.finished) {
				box.playAnim(box.animation.curAnim.name.substr(0, box.animation.curAnim.name.length - 4));
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted) {
			startDialogue();
			dialogueStarted = true;
		}

		if (dialogueStarted) {
			autoWait += elapsed;

			if (FlxG.keys.anyJustPressed(Options.uiControls.get("accept")) || (dialogueList[0].autoNext && autoWait >= dialogueList[0].autoNextDelay)) {
				//remove(dialogue);
					
				FlxG.sound.play(Paths.sound('clickText'), 0.8);

				@:privateAccess //Why is FlxTypeText._typing private i dont get it why is it needed
				if (swagDialogue._typing && dialogueList[0].skippable != false) {
					swagDialogue.skip();
					autoWait = 0;
				} else {
					if (dialogueList[1] == null && dialogueList[0] != null) {
						if (!isEnding) {
							isEnding = true;
							if (stopMusicOnEnd && FlxG.sound.music != null && FlxG.sound.music.playing)
								FlxG.sound.music.fadeOut(2.2, 0);
							
							if (dialogueFile.dontClose)
								finishThing();
							else if (closeType == "pixel")
								closeDialoguePixel(closeTime);
							else if (closeType == "custom" || closeType == "script")
								Scripting.runOnScripts("dialogueCloseAnim", [this, closeTime, finishThing]);
							else
								closeDialogue(closeTime);
						}
					} else {
						dialogueList.shift();
						startDialogue();
					}
				}
			}
		}
		
		super.update(elapsed);
	}

	public function closeDialoguePixel(?length:Float = 1.2) {
		new FlxTimer().start(length / 6, function(tmr:FlxTimer) {
			box.alpha -= 1 / 5;
			bgFade.alpha -= 0.7 / 5;
			swagDialogue.alpha -= 1 / 5;
			dropText.alpha -= 1 / 5;
			charObjects.forEach(function(dc:DialogueCharacter) {
				dc.alpha *= tmr.loopsLeft == 0 ? 0 : 1 / tmr.loopsLeft;
			});
		}, 5);

		new FlxTimer().start(length, function(tmr:FlxTimer) {
			finishThing();
			kill();
		});
	}

	public function closeDialogue(?length:Float = 1.2) {
		box.playAnim(box.animation.curAnim.name + "Close");
		FlxTween.tween(bgFade, {alpha: 0.0}, length);
		FlxTween.tween(swagDialogue, {alpha: 0.0}, length);
		FlxTween.tween(dropText, {alpha: 0.0}, length);
		charObjects.forEach(function(dc:DialogueCharacter) {
			dc.exit(length);
		});

		new FlxTimer().start(length, function(tmr:FlxTimer) {
			finishThing();
			kill();
		});
	}

	var isEnding:Bool = false;

	function startDialogue():Void {
		if (curBoxStyle != dialogueList[0].boxStyle && dialogueList[0].boxStyle != null && dialogueList[0].boxStyle != "") {
			setDialogueBoxStyle(DialogBoxStyle.load(dialogueList[0].boxStyle, PlayState.modName));
			Scripting.runOnScripts("dialogueBoxStyle", [this, dialogueList[0].boxStyle, curBoxStyle]);
			curBoxStyle = dialogueList[0].boxStyle;
		}

		Scripting.runOnScripts("dialogueLine", [this, dialogueList[0], dialogueList.length - dialogueLineCount]);
		if (dialogueList[0].portraitEvents != null) {
			for (ev in dialogueList[0].portraitEvents) {
				if (ev.character.length > 0) {
					charList[ev.number] = ev.character;
					if (charObjects.members[ev.number] != null)
						charObjects.members[ev.number].setCharacter(ev.character);
					else
						charObjects.add(new DialogueCharacter(ev.character, PlayState.modName, this));
				}
				var charObject = charObjects.members[ev.number];
				if (ev.isTalking)
					curCharacter = charObject;
				charObject.setExpression(ev.expression);
				charObject.setTalking(ev.isTalking);
				charObject.setFlip(ev.flip);
				charObject.setSide(ev.side);
				if (ev.removeCharacter)
					charObject.exit();
			}
		}

		if (dialogueList[0].screenGraphic != "") {
			screenGraphic.visible = false;
		} else {
			if (dialogueList[0].screenGraphicAnim != "") {
				screenGraphic.frames = Paths.getSparrowAtlas(dialogueList[0].screenGraphic);
				screenGraphic.animation.addByPrefix("idle", dialogueList[0].screenGraphicAnim, 24, dialogueList[0].screenGraphicLoop);
				screenGraphic.animation.play("idle");
			} else {
				screenGraphic.loadGraphic(dialogueList[0].screenGraphic);
			}
			screenGraphic.scale.x = Math.min(FlxG.width / screenGraphic.frameWidth, FlxG.height / screenGraphic.frameHeight);
			screenGraphic.scale.y = screenGraphic.scale.x;
		}

		trace("curCharacter: " + curCharacter.characterName);
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0].text);
		swagDialogue.start(dialogueList[0].rate, true);
		autoWait = dialogueList[0].text.length * -swagDialogue.delay;

		switch (curCharacter.characterName) {
			case 'senpai-pixel' | 'spirit-pixel':
				portraitRight.visible = false;
				if (!portraitLeft.visible) {
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'bf-pixel':
				portraitLeft.visible = false;
				if (!portraitRight.visible) {
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
		}
	}
}

class DialogueCharacter extends SpriteVManExtra {
	public var expression:String = "normal";
	public var talking:Bool = false;
	public var parent:DialogueBoxVMan;
	public var isJustAdded:Bool = true;
	
	public var myMod:String;
	public var characterName:String;
	public var isPlayer:Bool;

	public function new(char:String, mod:String, parent:DialogueBoxVMan) {
		super(0, 0);
		characterName = char;
		this.parent = parent;
		setCharacter(char, mod);
	}

	public function setSide(side:Float) {
		if (isJustAdded) {
			if (side > 2/3) {
				x = FlxG.width + 100;
			} else if (side < 1/3) {
				x = -100;
			} else {
				x = (FlxG.width - width) / 2;
				y += 800;
				FlxTween.tween(this, {y: y - 800}, 0.3, {ease: FlxEase.cubeInOut});
			}
			isJustAdded = false;
			playAvailableAnim([talking ? "entertalk_"+expression : "enter_"+expression]);
		}
		FlxTween.tween(this, {x: side * (FlxG.width - width)}, 0.3, {ease: FlxEase.cubeInOut});
	}

	public function setCharacter(char:String, ?mod:Null<String>) {
		var jsonThing = Character.loadCharacterJson("dialogue/"+char, mod == null ? this.myMod : mod);
		if (jsonThing == null) {
			trace("Could not load character " + char);
			return;
		}
		isPlayer = jsonThing.isPlayer;
		frames = Paths.getSparrowAtlas(jsonThing.image);
		for (anim in jsonThing.animations) {
			Character.loadAnimation(this, anim);
			addOffset(anim.name, anim.offset[0], anim.offset[1]);
		}
		if (jsonThing.initAnim != null)
			playAvailableAnim([jsonThing.initAnim, "idle_neutral", "idle_normal"]);
	}

	public function setFlip(flip:Bool) {
		if (isPlayer)
			flip = !flip;
		if (flipX == flip)
			return;
		flipX = flip;
		playAvailableAnim(talking ? ["talkflip_"+expression, "flip_"+expression] : ["flip_"+expression]);
	}

	public function setExpression(expression:String) {
		if (this.expression == expression)
			return;
		playAvailableAnim(talking ? ["talkswitch_"+this.expression+"_"+expression, "talking_"+this.expression] : ["idleswitch_"+this.expression+"_"+expression, "idle_"+this.expression]);
		this.expression = expression;
	}

	public function setTalking(isTalking:Bool) {
		if (talking == isTalking)
			return;
		talking = isTalking;
		if (talking)
			playAvailableAnim(["talkstart_"+this.expression, "talking_"+this.expression]);
	}

	public function exit(?time:Float = 0.3) {
		playAvailableAnim(["exit_"+expression, "stoptalk_"+expression, "idle_"+expression]);
		FlxTween.tween(this, {alpha:0.0}, time, {onComplete:function(tween:FlxTween) {
			kill();
		}});
	}

	public override function update(elapsed:Float) {
		if (animation.curAnim != null && (animation.curAnim.finished || animation.curAnim.looped)) {
			if (animStartsWith("idle"))
				return super.update(elapsed); //do nothing
			else if (!talking && animStartsWith("talking"))
				playAvailableAnim(["stoptalk"+expression, "idle_"+expression]);
			else if (animStartsWith("starttalk") || animStartsWith("talkswitch"))
				playAvailableAnim(["talking_"+expression, "idle_"+expression]);
			else if (animStartsWith("stoptalk"))
				playAvailableAnim(["idle_"+expression]);
			else if (animStartsWith("talkflip") || animStartsWith("flip"))
				playAvailableAnim(talking ? ["talking_"+expression, "idle_"+expression] : ["idle_"+expression]);
		}
		super.update(elapsed);
	}
}