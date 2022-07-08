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

	inline static function modPrefix(song:String, ?mod:String) {
		if (mod == null) {
			mod = PlayState.modName;
		}
		return '${mod}:${song}';
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Bool
	{
		var daSong:String = modPrefix(formatSong(song, diff));


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
		var saveAcc = setAcc(daSong, PlayState.instance.songScore / ((PlayState.instance.songHits - PlayState.instance.songMisses) * 350));
		return saveScore || saveFC || saveAcc; //return true if you got a high score
	}
	
	public static function getPlayStateFC(the:PlayState) {
		if (the.songMisses >= 10) {
			return "Clear";
		}
		if (the.songMisses > 0) {
			return "SDCB";
		}
		if (the.bads > 0 || the.shits > 0) {
			return "FC";
		}
		if (the.goods > 0) {
			return "GFC";
		}
		return "SFC";
	}
	
	public static function getPlayStateFCStore(the:PlayState) {
		if (the.songMisses > 0) {
			return -the.songMisses;
		}
		if (the.bads > 0 || the.shits > 0) {
			return 0;
		}
		if (the.goods > 0) {
			return 1;
		}
		return 2;
	}
	
	public static function formatFC(num:Int) {
		if (num < 0) {
			return '${num <= -10 ? "Clear" : "SDCB"} (${-num})';
		}
		switch(num) {
			case 0:
				return "FC";
			case 1:
				return "GFC";
			case 2:
				return "SFC";
		}
		return "???";
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Bool
	{

		#if !switch
		//NGio.postScore(score, "Week " + week);
		#end


		var daWeek:String = modPrefix(formatSong(week, diff));

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
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE... NOW!!
	 */
	static function setScore(song:String, score:Int):Bool
	{
		// Reminder that I don't need to format this song, it should come formatted!
		var formatted = formatSong(song);
		trace('setting score for ${formatted}');
		if (songScores.exists(formatted) && songScores.get(formatSong(song)) > score) {
			return false;
		}
		songScores.set(formatSong(song), score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
		return true;
	}
	
	static function setFC(song:String, score:Int):Bool
	{
		// Reminder that I don't need to format this song, it should come formatted!
		var formatted = formatSong(song);
		if (songScoreFC.exists(formatted) && songScoreFC.get(formatted) > score) {
			return false;
		}
		songScoreFC.set(formatSong(song), score);
		FlxG.save.data.songScoreFC = songScoreFC;
		FlxG.save.flush();
		return true;
	}
	
	static function setAcc(song:String, score:Float):Bool
	{
		// Reminder that I don't need to format this song, it should come formatted!
		var formatted = formatSong(song);
		if (songScoreAcc.exists(formatted) && songScoreAcc.get(formatted) > score) {
			return false;
		}
		songScoreAcc.set(formatSong(song), score);
		FlxG.save.data.songScoreAcc = songScoreAcc;
		FlxG.save.flush();
		return true;
	}

	public static function formatSong(song:String, ?diff:Int = -1):String
	{
		var daSong:String = (~/ /g).replace(song.toLowerCase(), "-");
		
		if (diff == -1)
			return daSong;

		return daSong + CoolUtil.difficultyPostfixString(diff);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong = formatSong(song, diff);
		trace('getting score for ${daSong}');
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getFCFormatted(song:String, diff:Int):String
	{
		var daSong = formatSong(song, diff);
		if (!songScoreFC.exists(daSong))
			return "???";

		return formatFC(songScoreFC.get(daSong));
	}

	public static function getAcc(song:String, diff:Int):Float
	{
		var daSong = formatSong(song, diff);
		if (!songScores.exists(daSong))
			return 0;

		return songScoreAcc.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek = modPrefix(formatSong(week, diff));
		if (!weekScores.exists(daWeek))
			weekScores.set(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null) {
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songScoreAcc != null) {
			songScoreAcc = FlxG.save.data.songScoreAcc;
		}
		if (FlxG.save.data.songScoreFC != null) {
			songScoreFC = FlxG.save.data.songScoreFC;
		}
	}
}
