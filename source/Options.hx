package;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import lime.ui.ScanCode;

class Options
{
	public static var masterVolume:Float = 1;
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var ghostTapping:Bool = false;
	public static var instantRespawn:Bool = false;
	public static var botplay:Bool = false;
	public static var playstyle:String = "default";
	public static var offset:Int = 0;
	public static var antialias:Bool = true;
	public static var invisibleNotes:Bool = false;
	public static var freeplayFolders:Bool = true;
	public static var newModsActive:Bool = true;
	public static var tappingHorizontal:Bool = false;
	public static var skipTitle:Bool = false;
	public static var flashingLights:Bool = true;
	public static var controls:Map<String, Array<Array<Int>>> = [
		"4k" => [
			[FlxKey.A, FlxKey.LEFT],
			[FlxKey.S, FlxKey.DOWN],
			[FlxKey.W, FlxKey.UP],
			[FlxKey.D, FlxKey.RIGHT]
		],
		"5k" => [
			[FlxKey.A, FlxKey.LEFT],
			[FlxKey.S, FlxKey.DOWN],
			[FlxKey.SPACE, -1],
			[FlxKey.W, FlxKey.UP],
			[FlxKey.D, FlxKey.RIGHT]
		],
		"6k" => [
			[FlxKey.S, -1],
			[FlxKey.D, -1],
			[FlxKey.F, -1],
			[FlxKey.J, FlxKey.LEFT],
			[FlxKey.K, FlxKey.DOWN],
			[FlxKey.L, FlxKey.RIGHT]
		],
		"7k" => [
			[FlxKey.S, -1],
			[FlxKey.D, -1],
			[FlxKey.F, -1],
			[FlxKey.SPACE, -1],
			[FlxKey.J, FlxKey.LEFT],
			[FlxKey.K, FlxKey.DOWN],
			[FlxKey.L, FlxKey.RIGHT]
		],
		"8k" => [
			[FlxKey.A, -1],
			[FlxKey.S, -1],
			[FlxKey.D, -1],
			[FlxKey.F, -1],
			[FlxKey.J, FlxKey.LEFT],
			[FlxKey.K, FlxKey.DOWN],
			[FlxKey.L, FlxKey.UP],
			[FlxKey.SEMICOLON, FlxKey.RIGHT]
		],
		"9k" => [
			[FlxKey.A, -1],
			[FlxKey.S, -1],
			[FlxKey.D, -1],
			[FlxKey.F, -1],
			[FlxKey.SPACE, -1],
			[FlxKey.J, FlxKey.LEFT],
			[FlxKey.K, FlxKey.DOWN],
			[FlxKey.L, FlxKey.UP],
			[FlxKey.SEMICOLON, FlxKey.RIGHT]
		]
	];
	public static var language = "en_us";
	public static var modchartEnabled:Bool = false;
	public static var antialiasing:Bool = true;
	public static var seenOptionsWarning = false;
	public static var silentCountdown:Bool = false;
	public static var noteMissAction:Int = 0;
	public static var noteMissAction_Vocals:Array<Bool> = [true, false, true, false];
	public static var noteMissAction_MissSound:Array<Bool> = [true, true, false, false];
	public static var showFPS:Bool = #if mobile false #else true #end;
	public static var soundVolume:Float = 1;
	public static var instrumentalVolume:Float = 1;
	public static var vocalsVolume:Float = 1;
	public static var resetButton:Bool = false;
	
	//PlayState changeables
	public static var playstate_opponentmode:Bool = false;
	public static var playstate_bothside:Bool = false;
	public static var playstate_endless:Bool = false;
	public static var playstate_guitar:Bool = false;

	//Controls stuff
	public static var uiControls = new Map<String, Array<Int>>();
	public static var uiControlsDefault:Map<String, Array<Int>> = [
		"up" => [FlxKey.UP, FlxKey.W],
		"down" => [FlxKey.DOWN, FlxKey.S],
		"left" => [FlxKey.LEFT, FlxKey.A],
		"right" => [FlxKey.RIGHT, FlxKey.D],
		"accept" => [FlxKey.ENTER, FlxKey.SPACE],
		"back" => [FlxKey.BACKSPACE, FlxKey.ESCAPE],
		"pause" => [FlxKey.ESCAPE],
		"reset" => [FlxKey.R],
		"gtstrum" => [FlxKey.LBRACKET, FlxKey.RBRACKET]
	];

	public static inline function applyControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(Custom);
	}
	
	public static function SaveOptions() {
		var svd = GetSaveObj();
		svd.data.masterVolume = masterVolume;
		svd.data.downScroll = downScroll;
		svd.data.middleScroll = middleScroll;
		svd.data.ghostTapping = ghostTapping;
		svd.data.instantRespawn = instantRespawn;
		svd.data.botplay = botplay;
		svd.data.playstyle = playstyle;
		svd.data.offset = offset;
		svd.data.antialias = antialias;
		svd.data.freeplayFolders = freeplayFolders;
		svd.data.newModsActive = newModsActive;
		svd.data.tappingHorizontal = tappingHorizontal;
		svd.data.skipTitle = skipTitle;
		svd.data.invisibleNotes = invisibleNotes;
		svd.data.controls = controls;
		svd.data.uiControls = uiControls;
		svd.data.language = language;
		svd.data.modchartEnabled = modchartEnabled;
		svd.data.flashingLights = flashingLights;
		svd.data.antialiasing = antialiasing;
		svd.data.seenOptionsWarning = seenOptionsWarning;
		svd.data.silentCountdown = silentCountdown;
		svd.data.noteMissAction = noteMissAction;
		svd.data.showFPS = showFPS;
		svd.data.resetButton = resetButton;

		svd.data.playstate_opponentmode = playstate_opponentmode;
		svd.data.playstate_bothside = playstate_bothside;
		svd.data.playstate_endless = playstate_endless;
		svd.data.playstate_guitar = playstate_guitar;
		svd.close();
	}
	
	public static function LoadOptions() {
		var svd = GetSaveObj();
		masterVolume = ifNotNull(svd.data.masterVolume, masterVolume);
		downScroll = ifNotNull(svd.data.downScroll, downScroll);
		middleScroll = ifNotNull(svd.data.middleScroll, middleScroll);
		ghostTapping = ifNotNull(svd.data.ghostTapping, ghostTapping);
		instantRespawn = ifNotNull(svd.data.instantRespawn, instantRespawn);
		botplay = ifNotNull(svd.data.botplay, botplay);
		playstyle = ifNotNull(svd.data.playstyle, playstyle);
		offset = ifNotNull(svd.data.offset, offset);
		antialias = ifNotNull(svd.data.antialias, antialias);
		freeplayFolders = ifNotNull(svd.data.freeplayFolders, freeplayFolders);
		newModsActive = ifNotNull(svd.data.newModsActive, newModsActive);
		tappingHorizontal = ifNotNull(svd.data.tappingHorizontal, tappingHorizontal);
		skipTitle = ifNotNull(svd.data.skipTitle, skipTitle);
		invisibleNotes = ifNotNull(svd.data.invisibleNotes, invisibleNotes);
		controls = ifNotNull(svd.data.controls, controls);
		language = ifNotNull(svd.data.language, language);
		modchartEnabled = ifNotNull(svd.data.modchartEnabled, modchartEnabled);
		flashingLights = ifNotNull(svd.data.flashingLights, flashingLights);
		antialiasing = ifNotNull(svd.data.antialiasing, antialiasing);
		seenOptionsWarning = ifNotNull(svd.data.seenOptionsWarning, seenOptionsWarning);
		silentCountdown = ifNotNull(svd.data.silentCountdown, silentCountdown);
		noteMissAction = ifNotNull(svd.data.noteMissAction, noteMissAction);
		showFPS = ifNotNull(svd.data.showFPS, showFPS);
		resetButton = ifNotNull(svd.data.resetButton, resetButton);
		
		playstate_opponentmode = ifNotNull(playstate_opponentmode, playstate_opponentmode);
		playstate_bothside = ifNotNull(playstate_bothside, playstate_bothside);
		playstate_endless = ifNotNull(playstate_endless, playstate_endless);
		playstate_guitar = ifNotNull(playstate_guitar, playstate_guitar);
		/*var insertControls = new Map<String, Array<Array<Int>>>();
		insertControls = ifNotNull(svd.data.controls, controls);
		for (i in insertControls.keys()) {
			if (!controls.exists(i)) {
				controls.set(insertControls[i]);
			}
		}*/

		for (thing in uiControlsDefault.keys()) {
			if (!uiControls.exists(thing)) {
				uiControls.set(thing, uiControlsDefault[thing]);
			}
		}

		svd.destroy();
	}
	
	static function ifNotNull(a:Any, b:Any):Null<Any> {
		if (a == null) {
			return b;
		}
		return a;
	}
	
	public static function GetSaveObj() {
		var svd = new FlxSave();
		svd.bind("Options");
		return svd;
	}
}
