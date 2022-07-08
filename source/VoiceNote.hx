package;

import ManiaInfo;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagVoiceNote = {
	var time:Float;
	var note:Int;
	var lyric:String;
	var length:Float;
}

class VoiceNote {
	public static function readUtau(name:String) {
		//omg github copilot is so cool
		var result = new Array<SwagVoiceNote>();
		var ust = CoolUtil.coolTextFile(name);
		var section:String = "";
		var noteNum:Int = 0;
		var isNote:Bool = false;
		var currentNote:SwagVoiceNote = null;
		var currentTime:Float = 0;
		for (str in ust) {
			if (str.startsWith("[") && str.endsWith("]")) {
				section = str.substring(1, str.length - 1);
				isNote = section.startsWith("#");
				if (isNote) {
					noteNum = Std.parseInt(section.substring(1));
					if (currentNote != null) {
						if (currentNote.time == -1000) {
							trace('invalid note ${section}!');
						}
						result[noteNum] = currentNote;
					}
					currentNote = {
						time: -1000,
						note: 0,
						lyric: "",
						length: 0
					};
				}
			}
			else if (isNote) {
				if (str.startsWith("Lyric=")) {
					currentNote.lyric = str.substring(6);
				}
				else if (str.startsWith("Length=")) {
					currentNote.length = Std.parseFloat(str.substring(7));
					currentTime += currentNote.length;
					currentNote.time = currentTime;
				}
				else if (str.startsWith("NoteNum=")) {
					currentNote.note = Std.parseInt(str.substring(8));
				}
			}
		}
		return result;
	}
}
