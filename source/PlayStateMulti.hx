package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class PlayStateMulti extends PlayState
{
	//todo: This
	public var isLocal:Bool = false;
	public var isOnline:Bool = false;
	public var localCount:Int = 0;
	public var onlineCount:Int = 0;
	var localNames:Array<String> = ["colleague", "friend", "accomplice", "aquaintance", "player 2", "keyboard sharer", "partner", "companion", "alter ego", "counterpart", "peer", "fellow", "private QRT", "alt account", "clone", "photocopy", "replica", "copycat", "free sample", "supervisor", "employee", "mailman", "mailbox", "mail", "lunch bag", "fan", "simp", "top follower", "3rd @", "secretary", "2nd in command", "trainee", "bento box", "donator", "imaginary friend", "teammate", "classmate", "sandwich", "advisor", "idea guy", "pet", "moderator", "roommate", "wallet"];
	var localNamesRare:Array<String> = ["The man behind PLAYER's slaughter", "Comically large PLAYER", "Blammed Lights!!", "PLAYER jumpscare", "Trollge GF", "Lullaby GF", "Minus GF", "The cooler PLAYER", "Holiday GF", "Doge GF"];
	
	public static function secondaryName(name:String) {
		var n = Std.random(260) == 0 ? localNamesRare : localNames;
		var str = n[Std.random(n.length)];
		if (str.indexOf("PLAYER") < 0) {
			return '${name}\'s ${str}';
		}
		return str.replace("PLAYER", name);
	}

	public function new() {
		super();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
