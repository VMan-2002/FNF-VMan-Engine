package;
import CoolUtil;
import Paths;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.ILabeled;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import flixel.util.typeLimit.OneOfTwo;
import lime.ui.ScanCode;

using StringTools;

class Translation
{
	public static var translation = new Map<String, Map<String, String>>();
	public static var active:Bool = true;
	public static var usesFont:Bool = false;
	
	public static function loadTranslation(name:String):Map<String, Map<String, String>> {
		var a = CoolUtil.coolTextFile('objects/translations/${name}/strings');
		var loadTranslat = new Map<String, Map<String, String>>();
		for (tx in a) {
			if (!tx.startsWith("//") && tx != "") {
				var underscorepos = tx.indexOf("_");
				var colonpos = tx.indexOf("::");
				var a = tx.substr(0, colonpos).replace("\\n", "\n");
				var b = tx.substr(colonpos + 2);
				var c = a.substr(0, underscorepos);
				if (!loadTranslat.exists(c)) {
					loadTranslat.set(c, new Map<String, String>());
				}
				loadTranslat[c].set(a.substr(underscorepos + 1), b);
				#if debug
				//trace('added translation string ${c} ${a.substr(underscorepos + 1)} ${b}');
				#end
			}
		}
		//usesFont = loadTranslat.exists("font");
		return loadTranslat;
	}
	
	public static function setTranslation(name:String) {
		translation = loadTranslation(name);
		usesFont = translation.exists("font") && translation["font"].exists("font");
	}
	
	public static function getTranslation(txt:String, ?context:String = "", ?args:Array<String>, ?notfound:Null<String>) {
		var key = txt.toLowerCase();
		if (active && translation.exists(context) && translation[context].exists(key)) {
			txt = translation[context].get(key).replace("\\n", "\n");
			//trace('found translation for ${key}');
		} else if (notfound != null) {
			return notfound;
		}
		if (args != null) {
			for (i in 0...args.length) {
				//trace('replace #${i} with ${args[i]}');
				txt = txt.replace('#${i}', args[i]);
			}
		}
		//trace('getting translated text ${key}, returned ${txt}');
		return txt;
	}
	
	public static function setObjectFont(a:FlxText, ?type:String = "font") {
		if (usesFont && active) {
			a.font = Paths.font(
				translation["font"].exists(type) ?
				translation["font"].get(type) :
				translation["font"].get("font")
			);
		}
	}
	
	public static function setUIObjectFont(a:ILabeled, ?type:String = "font") {
		if (usesFont && active) {
			a.getLabel().size = Math.floor(a.getLabel().size * 1.25);
			setObjectFont(a.getLabel());
		}
	}
	
	public static function setUIDropDownFont(a:FlxUIDropDownMenu, ?type:String = "font") {
		if (usesFont && active) {
			a.header.text.size = Math.floor(a.header.text.size * 1.25);
			setObjectFont(a.header.text, type);
			for (i in a.list) {
				setUIObjectFont(i, type);
			}
		}
	}
	
	public inline static function getUIObjectLineNum(a:ILabeled) {
		return a.getLabel().textField.numLines;
	}
	
	public inline static function getUIObjectIsMultiline(a:ILabeled) {
		return getUIObjectLineNum(a) > 1;
	}
}
