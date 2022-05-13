package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class AnnounceChecker extends MusicBeatState
{
	//todo: this to check some json file on github. also finish this
	public static var leftState:Bool = false;
	
	public static var dismissedAnnouncements:Array<String>;
	public static var readyAnnounce:Null<Array<String>> = null;
	public static var checkTime:Int = -1;
	
	public static function checkAnnounce(?forcecheck:Bool = false, ?showafter:Bool = false) {
		var cTime:Int = Sys.parseInt(Sys.cpuTime());
		if (checkTime > 0 && checkTime + 3000 /*50 minutes*/ < cTime && !forcecheck) {
			return;
		}
		checkTime = cTime;
		if (readyAnnounce == null) {
			
		}
	}
	
	public static function showAnnounce() {
		if (readyAnnounce.length <= 0) {
			return;
		}
		checkAnnounce(true, true);
	}

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var ver = "v" + Application.current.meta.get('version');
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Announcement!\n\n"
			+ ver
			+ "\n\nAccept: Open link - Back: Dismiss",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.openURL("https://ninja-muffin24.itch.io/funkin");
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
