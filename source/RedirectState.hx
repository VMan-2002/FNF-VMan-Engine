package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class RedirectState extends MusicBeatState
{
	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var ver = "v" + Application.current.meta.get('version');
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Please don't upload HTML5 builds of\nother people's mods without permission!\n\nPress G to go to the mod download page.",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		//if (controls.ACCEPT || controls.) {
		//	FlxG.openURL("https://vman-2002.github.io/fnf_mods.html#vmanengine");
		//}
		if (controls.ACCEPT || FlxG.keys.justPressed.G) {
			FlxG.openURL(true ? "https://github.com/VMan-2002/FNF-VMan-Engine/releases/latest" : "https://vman-2002.github.io/downloadvmanengine.html");
		}
		super.update(elapsed);
	}
}
