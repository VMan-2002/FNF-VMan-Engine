package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef LyricsItem = {
	text:Array<String>,
	timing:Array<Float>
}

class LyricsThing extends FlxGroup {
	public var pos:Int = -1;
	public var itemPos:Int = 0;
	public var nextPos:Int = 0;
	public static var lyricsItems:Array<LyricsItem>;
	public var lyrText:FlxText;
	//public var lyrTextNext:FlxText;
	public var clearTime:Float;

	public static var txtFormat:FlxTextFormat = new FlxTextFormat(FlxColor.RED, false, false, FlxColor.BLACK);

	public static function readLyricsFile(path:String) {
		return FileSystem.exists(path) ? readLyricsString(File.getContent(path)) : new Array<LyricsItem>();
	}

	public static inline function readLyricsFromSong(mod:String, song:String, ?fname:String = "lyrics") {
		return readLyricsFile(mod == "" ? 'assets/data/${song}/${fname}.txt' : 'mods/${mod}/data/${song}/${fname}.txt');
	}

	public static function readLyricsString(str:String) {
		var pos:Int = 0;
		var thingyPos:Int = 0;
		var textArr:Array<String> = null;
		var lastThingyPos:Int = 0;
		var result = new Array<LyricsItem>();
		var lines = str.replace("\r", "").split("\n");
		while (pos < lines.length) {
			if (lines[pos].startsWith("|")) {
				thingyPos = pos;
				while (lines.length < thingyPos) {
					thingyPos += 1;
					if (!lines[thingyPos].startsWith("|")) {
						if (lastThingyPos != thingyPos) {
							lastThingyPos = thingyPos;
							textArr = lines[thingyPos].trim().split("^");
							while (textArr.length != 1 && textArr[textArr.length - 1].length == 0)
								textArr.pop();
						}
						var strFloatArr = lines[pos].substring(1).split(",");
						var floatArr = new Array<Float>();
						while (floatArr.length < textArr.length && floatArr.length < strFloatArr.length)
							floatArr.push(Std.parseFloat(strFloatArr[floatArr.length]));
						result.push({
							text: textArr,
							timing: floatArr
						});
					}
				}
			}
		}
		result.sort(function(a:LyricsItem, b:LyricsItem) {
			return cast (a.timing[0] - b.timing[0]);
		});
		var lastresult = result[result.length - 1];
		result.push({
			text: [""],
			timing: [lastresult.timing[lastresult.timing.length - 1] + 2]
		});
		return result;
	}
	
	public function new(x:Float, y:Float, list:Array<String>, ?vertical:Bool = false) {
		super();
		
		lyrText = new FlxText(FlxG.width * 0.1, FlxG.height * 0.75, FlxG.width * 0.9, "")
			.setFormat("VCR OSD Mono", 10, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		lyrText.moves = false;
		add(lyrText);
	}

	public override function update(elapsed:Float) {
		if (pos == -4)
			return super.update(elapsed);
		if (Conductor.songPosition > lyricsItems[nextPos].timing[0]) {
			pos = nextPos;
			nextPos = pos + 1;
			itemPos = -1;
			lyrText.clearFormats();
			if (nextPos == lyricsItems.length) {
				pos = -4; //just stop!
				lyrText.text = "";
			} else {
				lyrText.text = lyricsItems[pos].text.join("");
			}
		}
		if (lyricsItems[pos].text.length < itemPos && Conductor.songPosition > lyricsItems[pos].timing[itemPos]) {
			itemPos += 1;
			lyrText.clearFormats();
			var formatLen = 0;
			var i = 0;
			while (i <= itemPos) {
				formatLen += lyricsItems[pos].text[i].length;
				i += 1;
			}
			lyrText.addFormat(txtFormat, 0, formatLen);
		}
		super.update(elapsed);
	}
	
	public inline function getPlayState():Dynamic {
		return PlayState.instance;
	}
}
