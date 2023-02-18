package;

import Translation;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class HudThing extends FlxGroup
{
	public var items = new Array<String>();
	public var vertical:Bool = false;
	public var textThing:FlxText;
	static var botplayExclude:Array<String> = [
		"misses", "fc", "accSimple", "accRating"
	];
	static var spoopyExclude:Array<String> = [
		"hits", "totalnotes", "difficulty", "engine", "accSimple", "health", "fc", "offset_min", "offset_max", "offset_avg"
	];
	static var showoffOnly:Array<String> = [
		"song", "engine"
	];
	public var autoUpdate:Bool = false;
	
	public function new(x:Float, y:Float, list:Array<String>, ?vertical:Bool = false)
	{
		super();
		
		items = list.filter(function(item) {
			return !Options.botplay || botplayExclude.indexOf(item) == -1;
		});
		if (PlayState.SONG.actions.contains("hideDifficulty")) {
			if (items.contains("difficulty")) {
				items.remove("difficulty");
			}
		}
		this.vertical = vertical;
		textThing = new FlxText(x, y, 0, "", 20);
		textThing.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		textThing.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 1, 1);
		Translation.setObjectFont(textThing, "vcr font");
		add(textThing);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (autoUpdate)
			updateInfo();
	}
	
	//todo: This function is being called quite often and we should reduce that
	public function getInfoText() {
		var text = "";
		var noteThing = PlayState.instance.songHits + PlayState.instance.songMisses;
		for (i in 0...items.length) {
			if (i > 0) {
				text += vertical ? "\n" : " | ";
			}
			switch(items[i]) {
				case "score":
					text += Translation.getTranslation("hud_score", "playstate", [Std.string(PlayState.instance.songScore)]);
				case "misses":
					text += Translation.getTranslation("hud_misses", "playstate", [Std.string(PlayState.instance.songMisses)]);
				case "health":
					text += Translation.getTranslation("hud_health", "playstate", [trimNoPercent(PlayState.instance.health / 2)]);
				case "song":
					text += PlayState.instance.songTitle;
				case "difficulty":
					text += Translation.getTranslation(PlayState.instance.storyDifficultyText, "difficulty") + Highscore.getModeString(true, true);
				case "accSimple":
					text += Translation.getTranslation("hud_accsimple", "playstate", [trimNoPercent(PlayState.instance.songHits / noteThing)]);
				case "accRating":
					text += Translation.getTranslation("hud_accrating", "playstate", [trimNoPercent(PlayState.instance.songScore / ((noteThing * 350) + PlayState.instance.possibleMoreScore))]);
				case "fc":
					if (PlayState.instance.songMisses >= 10) {
						text += Translation.getTranslation("fc_clear", "playstate");
					} else if (PlayState.instance.songMisses > 0) {
						text += Translation.getTranslation("fc_sdcb", "playstate");
					} else if (PlayState.instance.bads + PlayState.instance.shits > 0) {
						text += Translation.getTranslation("fc_fc", "playstate");
					} else if (PlayState.instance.goods > 0) {
						text += Translation.getTranslation("fc_gfc", "playstate");
					} else {
						text += Translation.getTranslation("fc_sfc", "playstate");
					}
				case "sicks":
					text += Translation.getTranslation("hud_sicks", "playstate", [Std.string(PlayState.instance.sicks)]);
				case "goods":
					text += Translation.getTranslation("hud_goods", "playstate", [Std.string(PlayState.instance.goods)]);
				case "bads":
					text += Translation.getTranslation("hud_bads", "playstate", [Std.string(PlayState.instance.bads)]);
				case "shits":
					text += Translation.getTranslation("hud_shits", "playstate", [Std.string(PlayState.instance.shits)]);
				case "hits":
					text += Translation.getTranslation("hud_hits", "playstate", [Std.string(PlayState.instance.songHits)]);
				case "totalnotes":
					text += Translation.getTranslation("hud_totalnotes", "playstate", [Std.string(PlayState.instance.songHits + PlayState.instance.songHittableMisses)]);
				case "combo":
					text += Translation.getTranslation("hud_combo", "playstate", [Std.string(PlayState.instance.combo)]);
				case "maxCombo":
					text += Translation.getTranslation("hud_maxcombo", "playstate", [Std.string(PlayState.instance.maxCombo)]);
				case "engine":
					//this one should always show on the hud thing in the corner
					text += Translation.getTranslation(Options.botplay ? "hud_engine botplay" : "hud_engine", "playstate");
				//For input offset calibrate
				case "offset_min":
					text += "MinOffset: "+offsetMilliseconds(getPlayState().hitOffsetMin);
				case "offset_max":
					text += "MaxOffset: "+offsetMilliseconds(getPlayState().hitOffsetMax);
				case "offset_avg":
					text += "AvgOffset: "+offsetMilliseconds(getPlayState().hitOffsetAvg);
				case "offset_range":
					text += "RngOffset: "+offsetMilliseconds(getPlayState().hitOffsetMin - getPlayState().hitOffsetMax);
				case "timer_up":
					text += "TimerUp: "+formatTime(Conductor.songPosition);
				case "timer_down":
					text += "TimerDown: "+formatTime(PlayState.instance.songLength - Conductor.songPosition);
				case "timer_down_notitle":
					text += formatTime(PlayState.instance.songLength - Conductor.songPosition);
				default:
					text += "Unknown: "+items[i];
			}
		}
		return vertical ? text+"\n" : text; //vertical text needs an additional newline idk why
	}
	
	public function getPlayState():Dynamic {
		return PlayState.instance;
	}
	
	public inline function updateInfo() {
		textThing.text = getInfoText();
	}
	
	public inline static function trimPercent(num:Float) {
		return Math.isNaN(num) ? "0%" : FlxMath.roundDecimal(num * 100, 2) + "%";
	}
	
	public inline static function trimNoPercent(num:Float):String {
		return Math.isNaN(num) ? "0" : Std.string(FlxMath.roundDecimal(num * 100, 2));
	}
	
	public inline static function offsetMilliseconds(num:Float) {
		return Std.string(FlxMath.roundDecimal(num, 2))+"ms";
	}

	public static function formatTime(num:Float) {
		var tNum:Int = Math.floor(num / 1000);
		var min:String = Std.string(Math.floor(tNum / 60));
		var sec:String = Std.string(Math.abs(tNum % 60));
		if (sec.length == 1)
			sec = "0" + sec;
		return min + ":" + sec;
	}

	public function doSpoop() {
		items = items.filter(function(item:String):Bool {
			return spoopyExclude.indexOf(item) < 0;
		});
		var a:FlxText = cast members[0];
		a.font = Paths.font("NotoSansJP-Medium.otf");
		Translation.setObjectFont(a, "vcr font");
	}
}
