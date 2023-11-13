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
class OptionBase {
	public var name:String = "nothing optionnel, kid";
	public var canLRHold:Bool = false;

	public function descriptionTextArgs():Array<String>
		return [];

	public function description()
		return generateDescription(name);

	public function accept()
		return false;

	public function left()
		return false;
	
	public function right()
		return false;

	public function reset()
		return false;

	public function generateDescription(translationKey:String, ?arg:Null<String>):String
		return arg != null ? '${Translation.getTranslation(translationKey, "options", descriptionTextArgs())}\n\n${Translation.getTranslation(arg, "optionsMenu")}' : Translation.getTranslation(translationKey, "options", descriptionTextArgs());

	public function new(name:String)
		this.name = name;
}

class OptionDefaultBool extends OptionBase {
	public var varname:String = "downScroll";
	public var enabled:String = "Enabled";
	public var disabled:String = "Disabled";
	public var instanceType:Bool = false;
	public var _default:Bool = true;

	inline function optionInstance():Dynamic
		return instanceType ? Options.instance : Options;

	public override function description()
		return generateDescription(name, Reflect.getProperty(optionInstance(), varname) ? enabled : disabled);

	public override function accept() {
		Reflect.setProperty(optionInstance(), varname, !Reflect.getProperty(optionInstance(), varname));
		return true;
	}

	public override function reset() {
		Reflect.setProperty(optionInstance, varname, _default);
		return true;
	}

	public function new(name:String, varname:String, ?instanceType:Bool = false, ?enabled:String = "Enabled", ?disabled:String = "Disabled") {
		super(name);
		this.varname = varname;
		this.instanceType = instanceType;
		this.enabled = enabled;
		this.disabled = disabled;
	}
}