package;

import Sys.sleep;

using StringTools;
#if !html5
import cpp.abi.Abi;
import discord_rpc.DiscordRpc;
#end

class DiscordClient
{
	static var isActivated:Bool = false;
	public function new()
	{
		#if !html5
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "983954658231975946",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		isActivated = true;
		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if !html5
		if (!isActivated) {
			return;
		}
		DiscordRpc.shutdown();
		isActivated = false;
		#end
	}
	
	static function onReady()
	{
		#if !html5
		if (!isActivated) {
			return;
		}
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Friday Night Funkin'"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if !html5
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		#end
	}

	public static function changePresenceSimple(type:String, ?extra:String = "") {
		#if !html5
		if (!isActivated) {
			return;
		}
		var songName:String = "No song lmao";
		var difficultyText = "Ur Difficult :sunglasses:";
		var modifierString = "been modified LMAO";
		var doStuff:Bool = false;
		switch(type) {
			case "paused" | "not_playing" | "playing" | "not_playing_multi" | "playing_multi":
				doStuff = true;
			case "options":
				doStuff = OptionsMenu.wasInPlayState;
		}
		if (doStuff && PlayState.SONG != null) {
			songName = PlayState.SONG.song;
			modifierString = Highscore.getModeString();
			difficultyText = modifierString == "" ? ' (${PlayState.instance.storyDifficultyText})' : ' (${PlayState.instance.storyDifficultyText}^${modifierString})';
		}
		var detailsText:String = PlayState.isStoryMode ? "Story Mode: Week " + PlayState.storyWeek : "Freeplay";
		var songText:String = songName + difficultyText;
		switch(type) {
			case "paused":
				changePresence("Paused - "+detailsText, songText, PlayState.instance.iconRPC);
			case "not_playing":
				changePresence(detailsText, songText, PlayState.instance.iconRPC);
			case "playing":
				changePresence(detailsText, songText, PlayState.instance.iconRPC, true, PlayState.instance.songLength);
			case "menu":
				changePresence("Main Menu");
			case "freeplay":
				changePresence("Freeplay Menu");
			case "options":
				if (OptionsMenu.wasInPlayState) {
					changePresence("Options Menu", songText, PlayState.instance.iconRPC);
				} else {
					changePresence("Options Menu");
				}
			case "controls":
				if (extra.length > 128) {
					extra = extra.substring(0, extra.indexOf(":")) + " too long";
				}
				changePresence("Controls Menu", extra);
			case "credits":
				changePresence("Credits");
			case "story":
				changePresence("Story Mode Menu");
			case "editor":
				changePresence("Song Editor", songText);
			case "character_editor":
				changePresence("Character Editor");
			case "dialogue_editor":
				changePresence("Dialogue Editor");
			case "not_playing_multi":
				changePresence("Multiplayer - "+detailsText, songText, PlayState.instance.iconRPC);
			case "playing_multi":
				changePresence("Multiplayer - "+detailsText, songText, PlayState.instance.iconRPC, true, PlayState.instance.songLength);
			default:
				trace("unknown presence type "+type+", this shouldn't happen but whatever i'll just make it look nice");
				changePresence((type.charAt(0).toUpperCase() + type.substring(1)).replace("_", " "));
		}
		#end
	}

	public static function changePresence(details:String, ?state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		#if !html5
		if (!isActivated) {
			return;
		}
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "Friday Night Funkin'",
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
		#end
	}
}
