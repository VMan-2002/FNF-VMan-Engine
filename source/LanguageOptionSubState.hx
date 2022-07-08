package;

class LanguageOptionSubState extends OptionsSubStateBasic
{
	var langNames:Map<String, String>;
	var langDesc:Map<String, String>;
	var langFont:Map<String, String>;
	var langIds:Array<String> = [];
	override function optionList() {
		backSubState = 1;
		langIds = CoolUtil.coolTextFile('objects/translations/languageList');
		langNames = new Map<String, String>();
		langDesc = new Map<String, String>();
		langFont = new Map<String, String>();
		for (i in langIds) {
			trace('loading translation '+i);
			var loadfunny = Translation.loadTranslation(i);
			langNames.set(i, loadfunny["lang"].get("native language name"));
			langDesc.set(i, '${loadfunny["lang"].get("native language name")} (${i}) (in English: ${loadfunny["lang"].get("english language name")})\n\n${loadfunny["lang"].get("translation description")}');
			langFont.set(i, (loadfunny.exists("font") && loadfunny["font"].exists("font")) ? loadfunny["font"].get("font") : "Roboto-Medium.ttf");
		}
		return langIds;
	}
	
	public override function new() {
		Translation.active = false;
		super();
		for (i in 0...textMenuItems.length) {
			grpOptionsTexts.members[i].text = langNames[langIds[i]];
			grpOptionsTexts.members[i].font = Paths.font(langFont[langIds[i]]);
		}
		optionsImage.animation.addByPrefix("language", "language0", 12, true);
		optionsImage.animation.play("language");
	}
	
	override function optionDescription(name:String) {
		currentOptionText.font = Paths.font(langFont.get(name));
		return [langDesc.get(name), "", "language"];
	}

	override function optionAccept(name:String) {
		Options.language = name;
		Translation.setTranslation(name);
		return true;
	}

	override function optionBack() {
		Translation.active = true;
		return true;
	}
}
