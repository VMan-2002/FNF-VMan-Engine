package;

import Sys.sleep;
import discord_rpc.DiscordRpc;

using StringTools;

class DiscordClient
{
	static var isActivated:Bool = false;
	public function new()
	{
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
	}

	public static function shutdown()
	{
		if (!isActivated) {
			return;
		}
		DiscordRpc.shutdown();
		isActivated = false;
	}
	
	static function onReady()
	{
		if (!isActivated) {
			return;
		}
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "Friday Night Funkin'"
		});
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
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
	}

	public static function changePresenceSimple(type:String) {
		if (!isActivated) {
			return;
		}
		var songName:String = "No song lmao";
		if (PlayState.SONG != null) {
			songName = PlayState.SONG.song;
		}
		var detailsText:String = PlayState.isStoryMode ? "Story Mode: Week " + PlayState.storyWeek : "Freeplay";
		var songText:String = songName + " (" + PlayState.instance.storyDifficultyText + ")";
		switch(type) {
			case "paused":
				changePresence("Paused - "+detailsText, songText, PlayState.instance.iconRPC);
			case "not_playing":
				changePresence(detailsText, songText, PlayState.instance.iconRPC);
			case "playing":
				changePresence(detailsText, songText, PlayState.instance.iconRPC, true, PlayState.instance.songLength);
			case "menu":
				changePresence("Main Menu");
			case "options":
				if (OptionsMenu.wasInPlayState) {
					changePresence("Options Menu", songText, PlayState.instance.iconRPC);
				} else {
					changePresence("Options Menu");
				}
			case "credits":
				changePresence("Credits");
			case "story":
				changePresence("Story Mode");
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
				changePresence((type.charAt(0).toUpperCase() + type.substring(1)).replace("_", " "));
		}
	}

	public static function changePresence(details:String, ?state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
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
	}
}
