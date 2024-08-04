package;

import flixel.FlxG;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end
	public static var weekScores:Map<String, Int> = new Map<String, Int>();
	public static var songScoreAcc:Map<String, Float> = new Map<String, Float>();
	public static var songScoreFC:Map<String, Int> = new Map<String, Int>();
	public static var songScoreNextRank:Map<String, Float> = new Map<String, Float>();

	inline static function modPrefix(song:String, ?mod:String) {
		if (mod == null) {
			mod = PlayState.modName;
		}
		return '${mod}:${song}';
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Bool {
		if (Multiplayer.valid) {
			return false; //i'll implement it properly later
		}
		var daSong:String = modPrefix(formatSong(song, diff, true));


		#if !switch
		//NGio.postScore(score, song);
		#end


		/*if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);*/
		var fc:Int = getPlayStateFCStore(PlayState.instance);
		var saveScore = setScore(daSong, score);
		var saveFC = setFC(daSong, fc);
		var saveAcc = setAcc(daSong, PlayState.instance.songScore / (((PlayState.instance.songHits + PlayState.instance.songMisses) * 350) + PlayState.instance.possibleMoreScore));
		return saveScore || saveFC || saveAcc; //return true if you got a high score
	}

	public static function accuracyCalc(state:PlayState) {
		return state.songScore / (((state.songHits + state.songMisses) * 350) + state.possibleMoreScore);
	}
	
	public static function getPlayStateFC(the:PlayState) {
		if (the.songMisses >= 10)
			return "Clear";
		if (the.songMFC)
			return "MFC";
		if (the.songMisses > 0)
			return "SDCB";
		if (the.bads > 0 || the.shits > 0)
			return "FC";
		if (the.goods > 0)
			return "GFC";
		return "SFC";
	}
	
	public static function getPlayStateFCStore(the:PlayState) {
		if (the.songMisses > 0)
			return -the.songMisses;
		if (the.songMFC)
			return 3;
		if (the.bads > 0 || the.shits > 0)
			return 0;
		if (the.goods > 0)
			return 1;
		return 2;
	}
	
	public static function formatFC(num:Int) {
		if (num < 0)
			return '${num <= -10 ? "Clear" : "SDCB"} (${-num})';
		switch(num) {
			case 0:
				return "FC";
			case 1:
				return "GFC";
			case 2:
				return "SFC";
			case 3:
				return "MFC";
		}
		return "???";
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Bool
	{

		#if !switch
		//NGio.postScore(score, "Week " + week);
		#end


		var daWeek:String = modPrefix(formatSong(week, diff, true));

		if (songScores.exists(daWeek))
		{
			if (songScores.get(daWeek) < score)
				weekScores.set(daWeek, score);
			else
				return false;
		}
		else
			weekScores.set(daWeek, score);

		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
		return true;
	}
	
	/**
		Returns the thing like: `^OpponentConfusion` that's put on the end of the Difficulty text.

		`translated`: Use translated strings

		`prefixed`: Add `^` on on the start
	**/
	public static function getModeString(?translated:Bool = false, ?prefixed:Bool = false):String {
		var prefix = prefixed ? (translated ? Translation.getTranslation("prefix", "modifier", null, "^") : "^") : "";
		var result:Array<String> = new Array<String>();
		if (Options.instance.playstate_bothside)
			result.push("Both");
		else if (Options.instance.playstate_opponentmode)
			result.push("Opponent");
		if (Options.instance.playstate_endless && !PlayState.isStoryMode)
			result.push("Endless");
		if (Options.instance.playstate_guitar)
			result.push("Guitar");
		if (Options.instance.playstate_confusion)
			result.push("Confusion");
		if (Options.instance.playstate_inorder)
			result.push("Ordered");
		if (result.length == 0)
			return "";
		if (translated)
			return prefix + result.map(function(a:String) { return Translation.getTranslation(a, "modifier"); }).join(Translation.getTranslation("separator", "modifer", null, ""));
		return prefix + result.join("");
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE... NOW!!
	 */
	static function setScore(song:String, score:Int):Bool {
		// Reminder that I don't need to format this song, it should come formatted!
		var formatted = formatSong(song);
		trace('setting score for ${formatted}');
		if (songScores.exists(formatted) && songScores.get(formatted) > score)
			return false;
		songScores.set(formatted, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
		return true;
	}
	
	static function setFC(song:String, score:Int):Bool {
		// Reminder that I don't need to format this song, it should come formatted!
		var formatted = formatSong(song);
		if (songScoreFC.exists(formatted) && songScoreFC.get(formatted) > score)
			return false;
		songScoreFC.set(formatted, score);
		FlxG.save.data.songScoreFC = songScoreFC;
		FlxG.save.flush();
		return true;
	}
	
	static function setAcc(song:String, score:Float):Bool {
		// Reminder that I don't need to format this song, it should come formatted!
		var formatted = formatSong(song);
		if (songScoreAcc.exists(formatted) && songScoreAcc.get(formatted) > score)
			return false;
		songScoreAcc.set(formatted, score);
		FlxG.save.data.songScoreAcc = songScoreAcc;
		FlxG.save.flush();
		return true;
	}

	public static function formatSong(song:String, ?diff:Int = -1, ?mode:Bool = false):String {
		var daSong:String = (~/ /g).replace(song.toLowerCase(), "-") + (mode ? getModeString(false, true).toLowerCase() : "");
		
		if (diff == -1)
			return daSong;

		return daSong + CoolUtil.difficultyPostfixString(diff);
	}

	public static function getScore(song:String, diff:Int, ?mode:Bool = false):Int {
		var daSong = formatSong(song, diff, mode);
		trace('getting score for ${daSong}');
		if (!songScores.exists(daSong))
			return 0;

		return songScores.get(daSong);
	}

	public static function getFCFormatted(song:String, diff:Int, ?mode:Bool = false):String {
		var daSong = formatSong(song, diff, mode);
		if (!songScoreFC.exists(daSong))
			return "???";

		return formatFC(songScoreFC.get(daSong));
	}

	public static function getAcc(song:String, diff:Int, ?mode:Bool = false):Float {
		var daSong = formatSong(song, diff, mode);
		if (!songScores.exists(daSong))
			return 0;

		return songScoreAcc.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int, ?mode:Bool = false):Int {
		var daWeek = modPrefix(formatSong(week, diff, mode));
		if (!weekScores.exists(daWeek))
			return 0;

		return weekScores.get(daWeek);
	}

	public static function load():Void {
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;
		if (FlxG.save.data.songScoreAcc != null)
			songScoreAcc = FlxG.save.data.songScoreAcc;
		if (FlxG.save.data.songScoreFC != null)
			songScoreFC = FlxG.save.data.songScoreFC;
	}
}
