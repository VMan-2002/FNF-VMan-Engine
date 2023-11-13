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

using StringTools;

class ResetControlsSubState extends MusicBeatSubstate
{

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
			Options.saved.SaveOptions();
			FlxG.switchState(new OptionsMenu(new ControlsSubState()));

			close();
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			close();
			FlxG.state.persistentUpdate = true;
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}

class ErrorReportSubstate extends MusicBeatSubstate
{
	public var errorItems:Array<String> = new Array<String>();
	public var errorCountItems:Array<Int> = new Array<Int>();
	public var title:FlxText;
	public var errorTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	public static var currentErrorThing:ErrorReportSubstate = null;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		title = new FlxText(0, 15, FlxG.width - 20, "error report", 32);
		title.scrollFactor.set();
		title.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, FlxTextAlign.LEFT);
		Translation.setObjectFont(title, "vcr font");
		title.updateHitbox();
		add(title);

		title.alpha = 0;

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(title, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	public static function addError(txt) {
		trace(txt);
		if (currentErrorThing == null) {
			initReport();
		}
		if (currentErrorThing.errorItems.contains(txt)) {
			currentErrorThing.errorCountItems[currentErrorThing.errorItems.indexOf(txt)]++;
		} else {
			currentErrorThing.errorItems.push(txt);
			currentErrorThing.errorCountItems.push(1);
		}
	}

	public static function buildReport() {
		if (currentErrorThing == null || currentErrorThing.errorItems.length == 0) {
			if (currentErrorThing != null) {
				currentErrorThing.destroy();
			}
			return false;
		}
		currentErrorThing.title.text = currentErrorThing.errorItems.length+" issues were found";
		currentErrorThing.title.updateHitbox();
		
		for (thing in currentErrorThing.errorItems) {
			var errorText:FlxText = new FlxText(0, currentErrorThing.title.x + currentErrorThing.title.height + 10 + (20 * currentErrorThing.errorTexts.members.length), FlxG.width - 20, thing + " x" + currentErrorThing.errorCountItems[currentErrorThing.errorItems.indexOf(thing)], 16);
			errorText.scrollFactor.set();
			errorText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.LEFT);
			Translation.setObjectFont(errorText, "vcr font");
			errorText.updateHitbox();
			currentErrorThing.errorTexts.add(errorText);
		}
		return true;
	}

	public static function displayReport() {
		if (buildReport()) {
			FlxG.state.openSubState(currentErrorThing);
		} else {
			currentErrorThing = null;
		}
	}

	public static function initReport() {
		currentErrorThing = new ErrorReportSubstate();
		currentErrorThing.errorItems = new Array<String>();
		currentErrorThing.errorCountItems = new Array<Int>();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE || controls.ACCEPT || controls.BACK) {
			close();
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}

#if html5
class HtmlModSelectMenu extends OptionsSubStateBasic
{
	static var modWasSelected = false;

	override function optionList() {
		backSubState = 2;
		var thingToLoad = CoolUtil.coolTextFile("data/webPortMods.txt");
		var i = 0;
		var things:Array<String> = new Array<String>();
		while (i < thingToLoad.length) {
			things.push(thingToLoad[i++]);
			lowercaseNames.push(things[things.length - 1].toLowerCase());
			modIds.push(thingToLoad[i++]);
			descriptions.push(thingToLoad[i++].split("\\n"));
		}
		return things.concat(["Download VMan Engine"]);
	}

	var modIds:Array<String> = new Array<String>();

	var lowercaseNames:Array<String> = new Array<String>();
	var descriptions:Array<String> = new Array<String>();
	
	override public function new() {
		super();
		var menuBG:FlxSprite = CoolUtil.makeMenuBackground('Desat');
		menuBG.color = 0xFF242424;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		insert(0, menuBG);
		
		optionsImage.color = FlxColor.WHITE;
		optionsImage.animation.addByPrefix("freeplay folders", "freeplay folders0", 12, true);
	}
	
	override function optionDescription(name:String) {
		var desc = "A really cool mod\n\nBy a cool, well known person (but is that really possible?)";
		switch(name) {
			case "download vman engine":
				optionsImage.visible = true;
				return ["Download VMan Engine to play and create mods on your computer."];
			default:
				if (lowercaseNames.contains(name)) {
					desc = descriptions[lowercaseNames.indexOf(name)];
				} else {
					optionsImage.visible = true;
					return ["Unknown option. This will probably cause a crash.", '', 'unknownOption'];
				}
		}
		optionsImage.visible = false;
		return [desc, "", "freeplay folders"];
	}

	override function optionAccept(name:String) {
		switch (name) {
			case "download vman engine":
				FlxG.openURL("https://github.com/VMan-2002/FNF-VMan-Engine");
			default:
				ModLoad.loadMods([modIds[curSelected]]);
				modWasSelected = true;
				FlxG.state.closeSubState();
				FlxG.switchState(new TitleState());
				return false;
		}
		return false;
	}

	override function optionBack() {
		return modWasSelected;
	}
}
#end