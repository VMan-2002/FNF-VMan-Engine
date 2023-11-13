package;

import Translation;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

typedef SwagRank = {
	level:Float,
	name:String
}

class HudThing extends FlxGroup {
	public var items = new Array<String>();
	public var itemDatas = new Array<String>();
	public var vertical:Bool = false;
	public var textThing:FlxText;
	static var botplayExclude:Array<String> = [
		"misses", "fc", "accSimple", "accRating"
	];
	static var spoopyExclude:Array<String> = [
		"hits", "totalnotes", "difficulty", "engine", "accSimple", "health", "fc", "offset_min", "offset_max", "offset_avg", "overTaps", "overStrums"
	];
	static var showoffOnly:Array<String> = [
		"song", "engine"
	];
	public var autoUpdate:Bool = false;

	public static var hudThingDispTypes:Array<String> = [
		"song", "difficulty", "modName", //Song info
		"score", "hits", "misses", "accSimple", "accRating", "rankWord", "fc", "combo", "maxCombo", "overTaps", "overStrums", //performance
		"sicks", "goods", "bads", "shits", "imperfects", "totalnotes" //ratings
	];

	public var ranks:Array<SwagRank> = [
		{level: -99, name: "What!?"},
		{level: 0.0, name: "Awful"},
		{level: 0.1, name: "Terrible"},
		{level: 0.2, name: "Stupid"},
		{level: 0.3, name: "Dumb"},
		{level: 0.4, name: "Crap"},
		{level: 0.5, name: "Bad"},
		{level: 0.6, name: "Alright"},
		{level: 0.69, name: "Nice"},
		{level: 0.7, name: "Good"},
		{level: 0.8, name: "Super"},
		{level: 0.9, name: "Awesome"},
		{level: 0.95, name: "Epic"},
		{level: 0.98, name: "Amazing"},
		{level: 1.0, name: "PERFECT!!"}
	];

	public var onUpdateText:Null<HudThing->Void> = null;
	public var onUpdateInfo:Null<HudThing->Void> = null;

	//arbitrary whatevers
	//public var ratingAcc:Array<Float> = [0.25, 0.5, 0.7, 0.8, 0.85, 0.9, 0.95, 0.975, 0.9825, 0.995, 1];
	//public var ratingLetters:Array<String> = ["F", "D", "C", "B", "B+", "A-", "A", "A+", "S-", "S", "S+", "P"];

	
	public function new(x:Float, y:Float, list:Array<String>, ?vertical:Bool = false) {
		super();
		
		if (list != null) {
			items = list.filter(function(item) {
				return !Options.instance.botplay || !botplayExclude.contains(item);
			});
			if (PlayState.SONG.actions.contains("hideDifficulty")) {
				while (items.contains("difficulty"))
					items.remove("difficulty");
			}
		} else {
			list = new Array<String>();
		}
		if (list.length > 1) {
			var i = 0;
			while (true) {
				if (list[i] == "song" && list[i + 1] == "difficulty") {
					list[i] = "songAndDifficulty";
					list.splice(i + 1, 1);
					if (i == list.length)
						break;
				}
				if (i + 1 == list.length)
					break;
				i += 1;
			}
		}
		this.vertical = vertical;
		textThing = new FlxText(x, y, 0, "", 20);
		textThing.moves = false;
		textThing.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		textThing.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 1, 1);
		Translation.setObjectFont(textThing, PlayState.instance.currentUIStyle.font, "vcr font");
		add(textThing);
	}

	public function removeItems(nameItems:Array<String>) {
		items = items.filter(function(item) {
			return !nameItems.contains(item);
		});
	}

	override function update(elapsed:Float) {
		if (autoUpdate)
			updateInfo();
		super.update(elapsed);
	}

	public static inline function accuracy():Float {
		return PlayState.instance.songScore / (((PlayState.instance.songHits + PlayState.instance.songMisses) * 350) + PlayState.instance.possibleMoreScore);
	}

	public static inline function getRank(acc:Float, things:Array<SwagRank>) {
		var n = things.length - 1;
		while (n == 0 || things[n].level >= acc)
			n -= 1;
		return things[n].name;
	}

	public function updateDatas() {
		for (i in 0...items.length) {
			itemDatas[i] = switch(items[i]) {
				case "score":
					Std.string(PlayState.instance.songScore);
				case "misses":
					Std.string(PlayState.instance.songMisses);
				case "health":
					trimNoPercent(PlayState.instance.health / 2);
				//case "difficulty":
				//	Translation.getTranslation(PlayState.instance.storyDifficultyText, "difficulty") + Highscore.getModeString(true, true);
				case "accSimple":
					trimNoPercent(PlayState.instance.songHits / (PlayState.instance.songHits + PlayState.instance.songMisses));
				case "accRating":
					trimNoPercent(accuracy());
				case "sicks":
					Std.string(PlayState.instance.sicks);
				case "goods":
					Std.string(PlayState.instance.goods);
				case "bads":
					Std.string(PlayState.instance.bads);
				case "shits":
					Std.string(PlayState.instance.shits);
				case "imperfects":
					Std.string(PlayState.instance.shits + PlayState.instance.bads + PlayState.instance.goods);
				case "hits":
					Std.string(PlayState.instance.songHits);
				case "totalnotes":
					Std.string(PlayState.instance.songHits + PlayState.instance.songHittableMisses);
				case "combo":
					Std.string(PlayState.instance.combo);
				case "maxCombo":
					Std.string(PlayState.instance.maxCombo);
				case "overTaps":
					Std.string(PlayState.instance.overTaps);
				case "overStrums":
					Std.string(PlayState.instance.overStrums);
				case "rankWord":
					getRank(accuracy(), ranks);
				default:
					null;
			}
		}
	}
	
	//todo: This function is being called quite often and we should reduce that
	public function getInfoText() {
		var text = "";
		//var noteThing = PlayState.instance.songHits + PlayState.instance.songMisses;
		for (i in 0...items.length) {
			if (i > 0) {
				text += vertical ? "\n" : " | ";
			}
			switch(items[i]) {
				case "score" | "misses" | "health" | "accSimple" | "accRating" | "sicks" | "goods" | "bads" | "shits" | "imperfects" | "hits" | "totalnotes" | "combo" | "maxCombo" | "overTaps" | "overStrums":
					text += Translation.getTranslation("hud_" + items[i], "playstate", [itemDatas[i]]);
				//case "score":
				//	text += Translation.getTranslation("hud_score", "playstate", [Std.string(PlayState.instance.songScore)]);
				//case "misses":
				//	text += Translation.getTranslation("hud_misses", "playstate", [Std.string(PlayState.instance.songMisses)]);
				//case "health":
				//	text += Translation.getTranslation("hud_health", "playstate", [trimNoPercent(PlayState.instance.health / 2)]);
				case "song":
					text += PlayState.instance.songTitle;
				case "difficulty":
					text += Translation.getTranslation(PlayState.instance.storyDifficultyText, "difficulty") + Highscore.getModeString(true, true);
				case "songAndDifficulty":
					text += PlayState.instance.songTitle + " " + Translation.getTranslation(PlayState.instance.storyDifficultyText, "difficulty") + Highscore.getModeString(true, true);
				//case "accSimple":
				//	text += Translation.getTranslation("hud_accsimple", "playstate", [trimNoPercent(PlayState.instance.songHits / (PlayState.instance.songHits + PlayState.instance.songMisses))]);
				//case "accRating":
				//	text += Translation.getTranslation("hud_accrating", "playstate", [trimNoPercent(accuracy())]);
				case "fc":
					var fcThing = PlayState.instance.songMFC ? "mfc" : PlayState.fcTypes[PlayState.instance.songFC];
					text += Translation.getTranslation("fc_" + fcThing, "playstate");
				/*case "sicks":
					text += Translation.getTranslation("hud_sicks", "playstate", [Std.string(PlayState.instance.sicks)]);
				case "goods":
					text += Translation.getTranslation("hud_goods", "playstate", [Std.string(PlayState.instance.goods)]);
				case "bads":
					text += Translation.getTranslation("hud_bads", "playstate", [Std.string(PlayState.instance.bads)]);
				case "shits":
					text += Translation.getTranslation("hud_shits", "playstate", [Std.string(PlayState.instance.shits)]);
				case "imperfects":
					text += Translation.getTranslation("hud_imperfects", "playstate", [Std.string(PlayState.instance.shits + PlayState.instance.bads + PlayState.instance.goods)]);
				case "hits":
					text += Translation.getTranslation("hud_hits", "playstate", [Std.string(PlayState.instance.songHits)]);
				case "totalnotes":
					text += Translation.getTranslation("hud_totalnotes", "playstate", [Std.string(PlayState.instance.songHits + PlayState.instance.songHittableMisses)]);
				case "combo":
					text += Translation.getTranslation("hud_combo", "playstate", [Std.string(PlayState.instance.combo)]);
				case "maxCombo":
					text += Translation.getTranslation("hud_maxcombo", "playstate", [Std.string(PlayState.instance.maxCombo)]);*/
				case "engine":
					//this one should always show on the hud thing in the corner
					text += Translation.getTranslation(Std.isOfType(FlxG.state, PlayStateReplay) ? "hud_engine replay" : (Options.instance.botplay ? "hud_engine botplay" : "hud_engine"), "playstate");
				//For input offset calibrate ONLY (these won't work in normal PlayState right now. //todo: fix this)
				case "offset_min":
					text += "MinOffset: "+offsetMilliseconds(getPlayState().hitOffsetMin);
				case "offset_max":
					text += "MaxOffset: "+offsetMilliseconds(getPlayState().hitOffsetMax);
				case "offset_avg":
					text += "AvgOffset: "+offsetMilliseconds(getPlayState().hitOffsetAvg);
				case "offset_range":
					text += "RngOffset: "+offsetMilliseconds(getPlayState().hitOffsetMin - getPlayState().hitOffsetMax);
				//and finally
				case "timer_up":
					text += "TimerUp: "+formatTime(Conductor.songPosition);
				case "timer_down":
					text += "TimerDown: "+formatTime(PlayState.instance.songLength - Conductor.songPosition);
				case "timer_down_notitle":
					text += formatTime(PlayState.instance.songLength - Conductor.songPosition);
				case "timer_up_notitle":
					text += formatTime(Conductor.songPosition);
				case "modName":
					text += ModLoad.primaryMod.name;
				/*case "overTaps":
					text += Translation.getTranslation("hud_overTaps", "playstate", [Std.string(PlayState.instance.overTaps)]);
				case "overStrums":
					text += Translation.getTranslation("hud_overStrums", "playstate", [Std.string(PlayState.instance.overStrums)]);*/
				//case "rankWord": //todo: translate this or something
				//	text += getRank(accuracy(), ranks);
				case "rankWord":
					text += itemDatas[i];
				default:
					text += "Unknown: "+items[i];
			}
		}
		if (onUpdateInfo != null)
			onUpdateInfo(this);
		return vertical ? text+"\n" : text; //vertical text needs an additional newline idk why
	}
	
	public inline function getPlayState():Dynamic {
		return PlayState.instance;
	}
	
	public inline function updateInfo() {
		textThing.text = getInfoText();
		if (onUpdateText != null)
			onUpdateText(this);
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

	public static function formatTime(num:Float):String {
		var tNum:Int = Math.floor(num / 1000);
		var hour:Int = Math.floor(tNum / 3600);
		var min:Int = Math.floor(tNum / 60) % 60;
		var sec:Int = Math.floor((tNum >= 0 ? tNum : -tNum) % 60);
		if (hour > 0)
			return hour + ":" + min + (sec > 9 ? ":" : ":0") + sec;
		return min + (sec >= 9 ? ":" : ":0") + sec;
	}

	public function doSpoop() {
		items = items.filter(function(item:String):Bool {
			return spoopyExclude.contains(item);
		});
		var a:FlxText = cast members[0];
		a.font = Paths.font("NotoSansJP-Medium.otf");
		Translation.setObjectFont(a, "vcr font");
	}
}

class HudThingGroup extends FlxTypedGroup<HudThing> {
	public function removeItems(nameItems:Array<String>) {
		for (thing in members)
			thing.removeItems(nameItems);
	}

	public function updateDatas() {
		for (thing in members)
			thing.updateDatas();
	}

	public function updateTextDatas() {
		for (thing in members) {
			thing.updateDatas();
			thing.updateInfo();
		}
	}
}