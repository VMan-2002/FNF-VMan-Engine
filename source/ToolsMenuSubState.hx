package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class ToolsMenuSubState extends OptionsSubStateBasic
{
	override function optionList() {
		return [
			'Chart Editor',
			"Animation Debug",
			//"Week Editor",
			//"Folder Editor",
			//"Menu Character Editor",
			//"Intro Text Test",
			//"Stage Editor",
			//"Spritesheet Tool",
			//"Noteskin Creator"
		];
	}
	
	override public function new() {
		super();
		optionsImage.animation.addByPrefix("freeplay folders", "freeplay folders0", 12, true);
		optionsImage.animation.addByPrefix("change color advanced", "change color advanced0", 12, true);
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "chart editor":
				return ["Edit song charting."];
			case "animation debug":
				return ["Look at animations n stuff."];
			case "week editor":
				return ["Edit in-game weeks for Story Mode."];
			case "folder editor":
				return ["Edit category structures for the Freeplay menu.", "", "freeplay folders"];
			case "menu character editor":
				return ["Edit characters for the Story Mode menu.", "", "animation debug"];
			case "intro text test":
				return ["Preview and edit the randomized intro text."];
			case "stage editor":
				return ["Edit stages, including positions of stage sprites."];
			case "spritesheet tool":
				return ["Convert spritesheets to or from individual frames.", "", "animation debug"];
			case "noteskin creator":
				return ["Create noteskins.", "", "change color advanced"];
		}
		return ["Unknown option.", '', 'unknownOption'];
	}

	override function optionAccept(name:String) {
		switch (name)
		{
			case "chart editor":
				FlxG.state.closeSubState();
				FlxG.switchState(new ChartingState());
			case "animation debug":
				FlxG.state.closeSubState();
				FlxG.switchState(new AnimationDebug());
		}
		return false;
	}
}
