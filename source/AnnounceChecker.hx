package;

import Highscore;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;


//example
/*
{
	"announcements": [
		{
			"id": "test1",
			"type": "announcement",
			"title": "Announcement Title",
			"message": "Announcement Message",
			"link": "http://www.google.com",
			"ifPlayedSong": ["FNF Cornflower Week:cornflower", "FNF Cornflower Week:meadow-wind"],
			"ifNotPlayedSong": ["FNF Cornflower Week:uncalled-for"],
			"ifPlayedWeek": ["FNF Cornflower Week":week_cornflower],
			"ifNotPlayedWeek": ["FNF Cornflower Week":week_cornflower_2],
			"minimumVersion": "1.0.0",
			"maximumVersion": "1.0.0",
			"gameTypes": ["vman_engine"],
			"active": true
		}
	]
}
*/
typedef SwagAnnouncement = {
	var id:String;
	var type:String;
	var title:String;
	var message:String;
	var link:String;
	var ifPlayedSong:Array<String>;
	var ifNotPlayedSong:Array<String>;
	var ifPlayedWeek:Array<String>;
	var ifNotPlayedWeek:Array<String>;
	var minimumVersion:String;
	var maximumVersion:String;
	var gameTypes:Array<String>;
	var active:Bool;
}

class AnnounceChecker extends MusicBeatState
{
	//todo: this to check some json file on github. also finish this
	public static var leftState:Bool = false;
	
	public static var dismissedAnnouncements:Array<String>;
	public static var readyAnnounce:Null<Array<SwagAnnouncement>> = null;
	public static var checkTime:Int = -1;
	
	public static function checkAnnounce(?forcecheck:Bool = false, ?showafter:Bool = false) {
		var cTime:Int = Std.parseInt(Sys.cpuTime());
		if (checkTime > 0 && checkTime + 3000 /*50 minutes*/ < cTime && !forcecheck) {
			return;
		}
		checkTime = cTime;
		if (readyAnnounce == null) {

			//read github file at https://github.com/VMan-2002/test-assets/blob/main/announce.json
			var url:String = "https://raw.githubusercontent.com/VMan-2002/test-assets/main/announce.json";
			var request:HttpRequest = new HttpRequest();
			request.onComplete = function(response:String) {
				var AnnounceList = JSON.parse(response);
				for (ann in AnnounceList) {
					if (ann.active && (ann.gameTypes.length <= 0 || ann.gameTypes.contains("vman_engine"))) {
						for (i in ann.ifPlayedSong) {
							if (Highscore.songScores.exists(i)) {
								ann.ifPlayedSong.remove(i);
							}
						}
						if (ann.ifPlayedSong.length > 0) {
							continue;
						}
						for (i in ann.ifNotPlayedSong) {
							if (Highscore.songScores.exists(i)) {
								continue;
							}
						}
						for (i in ann.ifPlayedWeek) {
							if (Highscore.weekScores.exists(i)) {
								ann.ifPlayedWeek.remove(i);
							}
						}
						if (ann.ifPlayedWeek.length > 0) {
							continue;
						}
						for (i in ann.ifNotPlayedWeek) {
							if (Highscore.weekScores.exists(i)) {
								continue;
							}
						}
						//check that the version is between the minimum and maximum version
						if (ann.minimumVersion != null && ann.minimumVersion != "") {
							if (!ann.minimumVersion.contains(".")) {
								ann.minimumVersion += ".0";
							}
							var minVersion:Array<String> = ann.minimumVersion.split(".");
							var curVersion:Array<String> = Application.current.meta.get('version').split(".");
							for (i in 0...minVersion.length) {
								if (minVersion[i] != "*" && curVersion[i] < minVersion[i]) {
									continue;
								}
							}
						}
						//finally add it
						readyAnnounce.push(ann);
					}
				}
				if (showafter) {
					showAnnounce();
				}
			};

			
		}
	}
	
	public static function showAnnounce() {
		if (readyAnnounce.length <= 0) {
			return;
		}
		//go to AnnounceChecker state
		FlxG.switchState(new AnnounceChecker());
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
		txt.applyMarkup(txt.text, [
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xffff0000), "[red]"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xff00ff00), "[gre]"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xff0000ff), "[blu]"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xff00ffff), "[cya]"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xffffff00), "[yel]"),
			new FlxTextFormatMarkerPair(new FlxTextFormat(0xffff00ff), "[mag]")
		]);
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
