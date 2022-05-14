package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSubState;
import Translation;

class OptionsSubStateBasic extends MusicBeatSubstate
{
	public var textMenuItems:Array<String> = [
		'no dur',
		'but why amog'
	];
	
	function optionList():Array<String> {
		return ["angry fire element lesbian"];
	}

	//var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;
	
	var currentOptionText:FlxText;
	var optionsImage:FlxSprite;
	
	var willReturnToTxt:FlxText;
	
	var canMoveSelected:Bool = true;
	var backSubState:Int = 0;
	
	var curSelectedName:String = "finish the green one ash!!";

	public function new()
	{
		super();
		
		textMenuItems = optionList();

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		//selector = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		//add(selector);

		for (i in 0...textMenuItems.length) {
			var optionText:FlxText = new FlxText(20, 20 + (i * 50), 0, Translation.getTranslation(textMenuItems[i], "options"), 32);
			optionText.ID = i;
			Translation.setObjectFont(optionText);
			grpOptionsTexts.add(optionText);
		}
		
		optionsImage = new FlxSprite(FlxG.width - 450, FlxG.height - 450);
		optionsImage.frames = Paths.getSparrowAtlas('menu/vman_options');
		for (v in textMenuItems) {
			optionsImage.animation.addByPrefix(v.toLowerCase(), v.toLowerCase()+"0", 12, true);
		}
		optionsImage.animation.addByPrefix("unknownOption", "unknownOption", 12, true);
		optionsImage.color = FlxColor.BLACK;
		add(optionsImage);
		
		if (OptionsMenu.wasInPlayState) {
			willReturnToTxt = new FlxText(8, FlxG.height - 24, 0, Translation.getTranslation("will return to", "optionsMenu", [PlayState.SONG.song]), 16);
			add(willReturnToTxt);
			Translation.setObjectFont(willReturnToTxt);
		}
		
		currentOptionText = new FlxText(FlxG.width / 2, 20, FlxG.width / 2, "Hey look buddy. I'm an engineer, t", 32);
		Translation.setObjectFont(currentOptionText);
		add(currentOptionText);
		moveSelection(0);
	}
	
	public function moveSelection(by:Int) {
		grpOptionsTexts.members[curSelected].color = FlxColor.WHITE;
		curSelected += by;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;

		if (curSelected >= textMenuItems.length)
			curSelected = 0;
		
		curSelectedName = textMenuItems[curSelected].toLowerCase();
			
		grpOptionsTexts.members[curSelected].color = FlxColor.YELLOW;
		updateDescription();
		
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	
	public function updateDescription() {
		var description:Array<String> = optionDescription(curSelectedName);
		if (Translation.active) {
			var translationKey:String = optionDescriptionTranslation(curSelectedName);
			currentOptionText.text = description.length > 1 ? (Translation.getTranslation(translationKey, "options") + "\n\n" + Translation.getTranslation(description[1], "optionsMenu")) : Translation.getTranslation(translationKey, "options");
		} else {
			currentOptionText.text = description.length > 1 ? (description[0] + "\n\n" + description[1]) : description[0];
		}
		optionsImage.animation.play(description.length >= 3 ? description[2] : textMenuItems[curSelected].toLowerCase(), false);
	}
	
	public function optionUpdate(name:String) {
		//thing
	}
	
	public function optionAccept(name:String):Bool {
		//thing
		return false;
	}
	
	public function optionDescription(name:String):Array<String> {
		//thing
		return ["ya know", "the one who make blue plantoid", "unknownOption"];
	}
	
	public function optionDescriptionTranslation(name:String):String {
		//thing
		return '${curSelectedName}_desc';
	}
	
	public function optionBack():Bool {
		//thing
		return true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canMoveSelected) {
			if (controls.UP_P)
				moveSelection(-1);

			if (controls.DOWN_P)
				moveSelection(1);
		}

		var optname = curSelectedName;
		
		if (canMoveSelected) {
			if (controls.ACCEPT) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (optionAccept(optname)) {
					updateDescription();
				}
			}
			
			if (controls.BACK) {
				if (optionBack()) {
					Options.SaveOptions();
					goBack();
					return;
				}
			}
		}
		
		optionUpdate(optname);
	}
	
	public function goBack() {
		FlxG.sound.play(Paths.sound('cancelMenu'));
		FlxG.state.closeSubState();
		switch(backSubState) {
			case 1:
			return FlxG.state.openSubState(new OptionsSubState());
		}
		if (OptionsMenu.wasInPlayState)
			return FlxG.switchState(new PlayState());
		MainMenuState.returnToMenuFocusOn('options');
	}
}
