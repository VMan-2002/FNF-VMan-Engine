package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class SaveDeleteSubState extends OptionsSubStateBasic {
	public var warnText:FlxText;
	public var warnTime:Bool = false;

	override function optionList() {
		return [
			'Delete Song Scores',
			'Delete Week Scores',
			'Delete All Scores',
			'Delete Week Completion',
			'Delete Achievements',
			'DELETE ALL OF THE ABOVE'
		];
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "delete song scores":
				return ["Reset all of your freeplay song scores."];
			case "delete week scores":
				return ["Reset all of your story mode week scores."];
			case "delete all scores":
				return ["Reset all of your freeplay song scores and story mode week scores."];
			case "delete week completion":
				return ["Reset all of your story mode week completion."];
			case "delete achievements":
				return ["Reset all of your achievements."];
			case "delete all of the above":
				return ["Reset all of your freeplay scores, week scores, week completion and achievements."];
		}
		return ["Unknown option.", name, 'unknownOption'];
	}

	public override function new() {
		super();
		warnText = new FlxText(8, FlxG.height - 80, 0, Translation.getTranslation("delete save warning", "optionsMenu", "This operation is NOT REVERSIBLE,\nyour progress of this type will be GONE FOREVER.\nIf you're sure about this, press ACCEPT again to delete this progress. Otherwise, press BACK."), 16);
		warnText.exists = false;
		add(warnText);
	}

	override function optionAccept(name:String) {
		if (!warnText.exists) {
			warnText.exists = true;
			warnTime = false;
			return false;
		}
		//todo: this
		switch (name) {
			
		}
		return true;
	}
}
