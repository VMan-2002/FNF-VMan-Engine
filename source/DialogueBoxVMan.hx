package;

import Character;
import cpp.abi.Abi;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import json2object.JsonParser;
import sys.io.File;

using StringTools;

//todo: The the and the talk

class DialogueFile {
	public var texts:Array<DialogueLine> = new Array<DialogueLine>();
	public var dontClose:Bool = false;
	public var music:String = "";
}

class DialogueLine {
	public var text:String = "Whats going on bros names pewdiepie";
	public var rate:Float = 0.04;
	public var boxMode:String = "normal";
	public var portraitEvents:Array<PortraitEvent>;
	public var boxStyle = "default";
	public var skippable:Bool = true;
	public var autoNext:Bool = false;
	public var autoNextDelay:Float = 0.0;
	public var fontSize:Float = 1.0;
	public var font:String = "";
	public var choices:Array<String>;
}

class PortraitEvent {
	public var number:Int = 0;
	public var character:String = "";
	public var expression:String = "";
	public var isTalking:Bool = true;
	public var flip:Bool = false;
	public var side:Int = 1; //-1 left, 0 middle, 1 right
	public var removeCharacter:Bool = false;
}

class DialogBoxStyle {
	public var image:String = "";
	public var imagePosition:Array<Float> = [-20, 45, 6];
	public var animations:Array<Character.SwagCharacterAnim>;
	public var textPosition:Array<Float> = [240, 500];
	public var textWidth:Float = 100;
	public var textLines:Int = 3;
	public var textOverflowUp:Bool = false;
	public var font:String = "";
	public var fontSize:Int = 18;
	public var fontColor:String = "0xffffffff";
	public var fontShadowColor:String = "0xff000000";
	public var fontShadowOffset:Array<Float>;
}

class DialogueBoxVMan extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<DialogueLine> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var curDialogBoxStyle:String = "";

	public var dialogueFile:DialogueFile;

	public function new(?file:String, ?dialogueFile:DialogueFile) {
		super();

		trace('loading vman dialogue');

		var parser = new JsonParser<DialogueFile>();
		if (file != null) {
			this.dialogueFile = dialogueFile = parser.fromJson(File.getContent(file));
		} else {
			this.dialogueFile = dialogueFile;
		}
		dialogueList = dialogueFile.texts;

		trace(dialogueList[0].text);

		if (dialogueFile.music != "") {
			FlxG.sound.playMusic(Paths.music(dialogueFile.music), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);

		switch (dialogueFile.texts[0].boxStyle) {
			case 'senpai':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				box.animation.addByIndices('normalClose', 'Text Box Appear', [4, 3, 2, 1, 0], "", 24);
			case 'roses':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

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
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
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
		portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite(0, 40);
		portraitRight.frames = Paths.getSparrowAtlas('weeb/bfPortrait');
		portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;
		
		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('pixelUI/hand_textbox'));
		handSelect.setGraphicSize(Std.int(handSelect.width * PlayState.daPixelZoom * 0.9));
		add(handSelect);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);
		
		Translation.setObjectFont(swagDialogue, "pixel font");

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	public function setDialogueBoxStyle(style:DialogBoxStyle):Void {
		var keepAnim = box.animation.curAnim;
		box.frames = Paths.getSparrowAtlas(style.image);
		box.x = style.imagePosition[0];
		box.y = style.imagePosition[1];
		box.scale.x = style.imagePosition.length <= 2 ? 1 : style.imagePosition[2];
		box.scale.y = style.imagePosition.length <= 3 ? box.scale.x : style.imagePosition[3];
		for (a in 0...style.animations.length) {
			Character.loadAnimation(box, style.animations[a]);
		}
		if (keepAnim != null) {
			box.animation.play(keepAnim.name);
		} else {
			box.animation.play('normalOpen');
		}
		swagDialogue.x = style.textPosition[0];
		swagDialogue.y = style.textPosition[1];
		swagDialogue.fieldWidth = Std.int(style.textPosition[2]);
		swagDialogue.setFormat(style.font, style.fontSize, style.fontColor);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float) {
		// HARD CODING CUZ IM STUPDI

		if (box.animation.curAnim != null) {
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished) {
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted) {
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true) {
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null) {
				if (!isEnding) {
					isEnding = true;
					
					if (dialogueFile.dontClose) {
						finishThing();
					} else {
						if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
							FlxG.sound.music.fadeOut(2.2, 0);

						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5;
							bgFade.alpha -= 1 / 5 * 0.7;
							portraitLeft.visible = false;
							portraitRight.visible = false;
							swagDialogue.alpha -= 1 / 5;
						}, 5);

						new FlxTimer().start(1.2, function(tmr:FlxTimer)
						{
							finishThing();
							kill();
						});
					}
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void {
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0].text);
		swagDialogue.start(0.04, true);

		switch (curCharacter) {
			case 'dad':
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'bf':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
		}
	}

	function cleanDialog():Void {
		//do nothing (it's already correct)
		/*var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();*/
	}
}
