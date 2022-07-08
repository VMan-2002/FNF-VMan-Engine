package;

import networking.Network;

using StringTools;

class Multiplayer {
	public static var server:Net;
	public static var myName:String = "Nameless somehow";
	public static var myID:Int = 0;
	public static var valid:Bool = false;
	public static var isHost:Bool = false;

	//use info from MultiMenuState.multiInfoThing
	//0: action ("host" or "join")
	//1: ip
	//2: port
	//3: player name

	public static function hostServer() {
	}

	public static function joinServer() {
	}
}