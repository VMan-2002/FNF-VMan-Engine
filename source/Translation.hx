package;
import flixel.util.FlxSave;
import lime.ui.ScanCode;
import flixel.input.keyboard.FlxKey;
import CoolUtil;
import flixel.text.FlxText;
import Paths;

using StringTools;

class Translation
{
	public static var context:String = "game";
	public static var translation = new Map<String, Map<String, String>>();
	public static var active:Bool = true;
	public static var usesFont:Bool = false;
	
	public static function loadTranslation(name:String):Map<String, Map<String, String>> {
		var a = CoolUtil.coolTextFile('objects/translations/${name}/strings');
		var loadTranslat = new Map<String, Map<String, String>>();
		for (tx in a) {
			if (!tx.startsWith("//")) {
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
		usesFont = loadTranslat.exists("font");
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
}
