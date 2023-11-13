package new_options;

import Controls.Control;
import Translation;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import new_options.NewOptionItemBasic.OptionBase;
import new_options.NewOptionItemBasic.OptionDefaultBool;

class NewOptionsCategoryBasic extends FlxTypedGroup<FlxSprite> {
	public var optionObjects = new Array<OptionBase>();
	public var optionTexts = new FlxTypedSpriteGroup<FlxText>();
	public var optionsImage:FlxSprite;
	public var curSelectedName:String = "the person reading this has nicer hair";

	public function addDefaultBoolOption(name:String, varname:String, ?instanceType:Bool = false, ?enabled:String = "Enabled", ?disabled:String = "Disabled") {
		optionObjects.push(new OptionDefaultBool(name, varname, instanceType, enabled, disabled));
	}

	public function updateOptionButtons() {
		CoolUtil.clearMembers(optionTexts);
	}

	public function new(?substate:Null<MusicBeatSubstate>, ?highlight:String) {
		super();
	}

	public dynamic function back() {
		
	}
}

class OptionsSubStateBasicOld extends MusicBeatSubstate {
	public var textMenuItems:Array<String> = [
		"The end of my pain will be WHEN",
		"GIVE ME THE FORMULA",
		"sure your mods are good,",
		"but is it FAIR",
		"that you get a TEAM",
		"and i do not"
	];
	
	function optionList():Array<String> {
		return ["My favourite part"];
	}

	//var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedSpriteGroup<FlxText>;
	
	var currentOptionText:FlxText;
	var optionsImage:FlxSprite;
	
	var willReturnToTxt:FlxText;
	var upcomingTxt:FlxText;
	
	var canMoveSelected:Bool = true;
	var backSubState:Int = 0;
	
	/**
		This is in lowercase
	**/
	var curSelectedName:String = "the person reading this has nice hair";

	var textTween:FlxTween;

	public static var flashingLightsWas:Bool = false;

	public var leftRightHold:Float = 0;
	public var leftRightDir:Bool;

	public function new() {
		super();
		
		textMenuItems = optionList();

		grpOptionsTexts = new FlxTypedSpriteGroup<FlxText>();
		add(grpOptionsTexts);

		//selector = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		//add(selector);

		for (i in 0...textMenuItems.length) {
			var optionText:FlxText = new FlxText(20, 20 + (i * 50), 0, Translation.getTranslation(textMenuItems[i], "options"), 32);
			optionText.ID = i;
			Translation.setObjectFont(optionText);
			grpOptionsTexts.add(optionText);
			if (optionUpcoming(textMenuItems[i].toLowerCase())) {
				optionText.color = FlxColor.GRAY;
			}
		}
		
		optionsImage = new FlxSprite(FlxG.width - 450, FlxG.height - 450);
		optionsImage.frames = Paths.getSparrowAtlas('menu/vman_options');
		for (v in textMenuItems) {
			optionsImage.animation.addByPrefix(v.toLowerCase(), v.toLowerCase()+"0", 12, true);
		}
		optionsImage.animation.addByPrefix("unknownOption", "unknownOption", 12, true);
		optionsImage.color = FlxColor.BLACK;
		optionsImage.antialiasing = true;
		add(optionsImage);
		
		willReturnToTxt = new FlxText(8, FlxG.height - 24, FlxG.width - 16, "Hyuponia is very cool", 16);
		Translation.setObjectFont(willReturnToTxt);
		if (Std.isOfType(FlxG.state.subState, ToolsMenuSubState)) {
			willReturnToTxt.text = Translation.getTranslation("version int", "optionsMenu", [Std.string(Main.gameVersionInt)], "Version Int: "+Main.gameVersionInt);
		} else if (OptionsMenu.wasInPlayState) {
			willReturnToTxt.text = Translation.getTranslation("will return to", "optionsMenu", [PlayState.SONG.song]);
		} else {
			willReturnToTxt.visible = false;
		}
		add(willReturnToTxt);
		
		upcomingTxt = new FlxText(8, FlxG.height - 50, FlxG.width - 16, Translation.getTranslation("incomplete feature", "optionsMenu", [], "Incomplete/Coming Soon"), 32);
		upcomingTxt.alignment = FlxTextAlign.RIGHT;
		upcomingTxt.visible = false;
		add(upcomingTxt);
		Translation.setObjectFont(upcomingTxt);
		
		currentOptionText = new FlxText(FlxG.width / 2, 20, FlxG.width / 2, "Hey look buddy. I'm an engineer, t", 32);
		Translation.setObjectFont(currentOptionText);
		add(currentOptionText);
		moveSelection(0);
	}
	
	public function moveSelection(by:Int) {
		grpOptionsTexts.members[curSelected].color = optionUpcoming(textMenuItems[curSelected].toLowerCase()) ? FlxColor.GRAY : FlxColor.WHITE;
		curSelected += by;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;
		else if (curSelected >= textMenuItems.length)
			curSelected = 0;
		
		curSelectedName = textMenuItems[curSelected].toLowerCase();
			
		grpOptionsTexts.members[curSelected].color = FlxColor.YELLOW;

		if (textTween != null) {
			textTween.cancel();
		}
		textTween = FlxTween.tween(grpOptionsTexts, {y: Math.min(FlxMath.lerp(0, (OptionsMenu.wasInPlayState ? -70 : -40) + (grpOptionsTexts.members.length * -50) + FlxG.height, curSelected / (grpOptionsTexts.members.length - 1)), 0)}, 1, {ease: FlxEase.expoOut});
		updateDescription();
		
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	
	public function updateDescription() {
		var description:Array<String> = optionDescription(curSelectedName);
		if (Translation.active) {
			var translationKey:String = optionDescriptionTranslation(curSelectedName);
			var argArr:Null<Array<String>> = optionDescriptionTranslationArgs(curSelectedName);
			currentOptionText.text = description.length > 1 ? (Translation.getTranslation(translationKey, "options", argArr, description[0]) + "\n\n" + Translation.getTranslation(description[1], "optionsMenu")) : Translation.getTranslation(translationKey, "options");
		} else {
			currentOptionText.text = description.length > 1 ? (description[0] + "\n\n" + description[1]) : description[0];
		}
		optionsImage.animation.play(description.length >= 3 ? description[2] : textMenuItems[curSelected].toLowerCase(), false);
		upcomingTxt.visible = optionUpcoming(curSelectedName);
	}
	
	public function optionUpdate(name:String) {
		//thing
	}
	
	/**
		Called when Accept button is pressed. Return `true` to update description.
	**/
	public function optionAccept(name:String):Bool {
		//thing
		return false;
	}
	
	public function optionDescription(name:String):Array<String> {
		//thing
		return ["It's when Ao says \"It's Aorbin Time\" and Starts to Aorb", "", "unknownOption"];
	}
	
	public function optionDescriptionTranslation(name:String):String {
		//thing
		return '${curSelectedName}_desc';
	}
	
	public function optionDescriptionTranslationArgs(name:String):Null<Array<String>> {
		//thing
		return null;
	}
	
	/**
		Called when Back button is pressed. Return `true` to backout.
	**/
	public function optionBack():Bool {
		//thing
		return true;
	}

	
	/**
		Return `true` if the option is unfinished or unimplemented.
	**/
	public function optionUpcoming(name:String):Bool {
		//thing
		return false;
	}

	public function optionLeftRightHold(name:String, dir:Float):Bool {
		//thing
		return false;
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

		if ((controls.LEFT != controls.RIGHT) && (controls.LEFT == leftRightDir)) {
			leftRightHold += elapsed;
			while (leftRightHold > 0.65) {
				leftRightHold -= 0.05;
				if (optionLeftRightHold(curSelectedName, leftRightDir ? -1 : 1))
					updateDescription();
			}
		} else {
			leftRightDir = controls.LEFT;
			leftRightHold = 0;
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
					Options.saved.SaveOptions();
					goBack();
					return;
				}
			}
		}
		
		optionUpdate(optname);
	}

	/**
		Pass in an option substate instance, for example `changeOptionMenu(new ControlsSubState())`

		Always returns `false`
	**/
	public inline function changeOptionMenu(a:Dynamic) {
		FlxG.state.closeSubState();
		FlxG.state.openSubState(a);
		return false;
	}
	
	public function goBack() {
		FlxG.sound.play(Paths.sound('cancelMenu'));
		FlxG.state.closeSubState();
		switch(backSubState) {
			case 1:
				return FlxG.state.openSubState(new OptionsSubState());
			case 2:
				return FlxG.switchState(new TitleState());
			case 3:
				if (flashingLightsWas != Options.flashingLights)
					return FlxG.switchState(new TitleState(false, true, true, true));
				return FlxG.switchState(new PlayState());
		}
		if (OptionsMenu.wasInPlayState)
			return FlxG.switchState(new PlayState());
		MainMenuState.returnToMenuFocusOn('options');
	}
}
