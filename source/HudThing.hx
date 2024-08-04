package;

import Translation;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

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
	public var autoDataUpdate:Bool = false;

	public static var hudThingDispTypes:Array<String> = [
		"song", "difficulty", "modName", //Song info
		"score", "hits", "misses", "accSimple", "accRating", "rankWord", "fc", "combo", "maxCombo", "overTaps", "overStrums", "health", //performance
		"marvelous", "sicks", "sickNoMarv", "goods", "bads", "shits", "imperfects", "totalnotes", //ratings
		"curStep", "curBeat", "curSection", "songPosition" //charting
	];

	public var ranks:Null<Array<SwagRank>> = null;
	public var noRankName:String = "...";

	public function loadRankWords(?name:String = "default") {
		var txarr = CoolUtil.uncoolTextFile('objects/translations/${Translation.translationId}/rankwords/${name}.txt', "", function(_:String) {
			return CoolUtil.uncoolTextFile('objects/rankwords/${name}.txt', "", function(_:String) {
				return CoolUtil.uncoolTextFile('objects/rankwords/default');
			});
		});
		if (ranks == null) {
			ranks = [];
		} else {
			ranks.resize(0);
		}
		for (i => tx in txarr.keyValueIterator()) {
			tx = tx.trim();
			
			var colonpos = tx.indexOf("::");
			var a = tx.substr(0, colonpos);
			var b = tx.substr(colonpos + 2);
			if (i == 0) {
				noRankName = b.ltrim();
			} else {
				ranks.push({level: Std.parseFloat(a), name: b.ltrim()});
			}
		}
		trace("Loaded "+txarr.length+" from rankWords file "+name);
	}

	public var onUpdateText:Null<HudThing->Void> = null;
	public var onUpdateInfo:Null<HudThing->Void> = null;
	public var textUpdating:Bool = true;
	
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
		if (items.length > 1) {
			var i = 0;
			while (true) {
				if (items[i] == "song" && items[i + 1] == "difficulty") {
					items[i] = "songAndDifficulty";
					items.splice(i + 1, 1);
					if (i == items.length)
						break;
				}
				/*if (items[i] == "accRating" && items[i + 1] == "rankWord") {
					items[i] = "accRatingAndRankWord";
					items.splice(i + 1, 1);
					if (i == items.length)
						break;
				}*/
				if (i + 1 == items.length)
					break;
				i += 1;
			}
			if (items.contains("songPosition") || items.contains("curStep") || items.contains("curSection") || items.contains("curBeat")) {
				autoUpdate = true;
				autoDataUpdate = true;
				trace("Hud thing autoupdate because it has chart time info");
			} else {
				trace("Hud thing doesn't autoupdate, doesn't contain chart time info");
				trace("It's "+items);
			}
			if (items.contains("rankWord")) {
				loadRankWords((PlayState.SONG.rankWords == null || PlayState.SONG.rankWords == "") ? "default" : PlayState.SONG.rankWords);
			}
			if (items.contains("marvelous")) {
				trace("Hud thing separate marvelous/sick");
				for (i => name in items.keyValueIterator()) {
					if (name == "sicks") {
						items[i] = "sickNoMarv";
					}
				}
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
		if (autoDataUpdate)
			updateDatas();
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
				case "marvelous":
					Std.string(PlayState.instance.marvelous);
				case "sicks":
					Std.string(PlayState.instance.sicks);
				case "sickNoMarv":
					Std.string(PlayState.instance.sicks - PlayState.instance.marvelous);
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
				case "curStep":
					Std.string(PlayState.instance.curStep);
				case "curBeat":
					Std.string(PlayState.instance.curBeat);
				case "curSection":
					Std.string(PlayState.instance.currentSection);
				case "songPosition":
					Std.string(FlxMath.roundDecimal(Conductor.songPosition, 3));
				case "rankWord":
					(PlayState.instance.songHits == 0 && PlayState.instance.songMisses == 0) ? noRankName : (PlayState.instance.songFC == 0 ? ranks[ranks.length - (PlayState.instance.songMFC ? 1 : 2)].name : getRank(accuracy(), ranks));
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
				case "score" | "misses" | "health" | "accSimple" | "accRating" | "marvelous" | "sicks" | "goods" | "bads" | "shits" | "imperfects" | "hits" | "totalnotes" | "combo" | "maxCombo" | "overTaps" | "overStrums" | "curBeat" | "curStep" | "curSection" | "songPosition":
					text += Translation.getTranslation("hud_" + items[i], "playstate", [itemDatas[i]]);
				case "sickNoMarv":
					text += Translation.getTranslation("hud_sicks", "playstate", [itemDatas[i]]);
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
		if (textUpdating)
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
		return min + (sec > 9 ? ":" : ":0") + sec;
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