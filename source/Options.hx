package;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

class Options {
	public static var saved:Options;
	public static var instance:Options;
	public static var playedVersion:Int = -1; //-1 when you've never played before

	public static var masterVolume:Float = 1;
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var middleLarge:Bool = false;
	public var ghostTapping:Bool = false;
	public var instantRespawn:Bool = false;
	public var botplay:Bool = false;
	//public var playstyle:String = "default";
	public static var offset:Int = 0;
	public static var antialias:Bool = true;
	public var invisibleNotes:Bool = false;
	public var invisibleNotesType:Int = 0;
	//public static var freeplayFolders:Bool = true;
	public static var newModsActive:Bool = true;
	public var tappingHorizontal:Bool = false;
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
	public var modchartEnabled:Bool = false;
	public var antialiasing:Bool = true;
	public static var seenOptionsWarning:Int = 0;
	public var silentCountdown:Bool = false;
	public var noteMissAction:Int = 0;
	public static var noteMissAction_Vocals:Array<Bool> = [true, false, true, false];
	public static var noteMissAction_MissSound:Array<Bool> = [true, true, false, false];
	public static var showFPS:Bool = #if mobile false #else true #end;
	public static var soundVolume:Float = 1;
	public static var instrumentalVolume:Float = 1;
	public static var vocalsVolume:Float = 1;
	public var resetButton:Bool = false;
	public var noteCamMovement:Bool = false;
	public static var selfAware(get, never):Bool;
	private static var _selfAware:Bool = false;
	public static var dataStrip:Bool = true;
	public var uiReloading:Bool = false;
	public var noteQuant:Bool = false;
	public var hudThingInfo:String = "score,misses,fc,accRating,accSimple,health\nsong,difficulty\nhits,sicks,goods,bads,shits,misses,totalnotes";
	
	//PlayState changeables
	public var playstate_opponentmode:Bool = false;
	public var playstate_bothside:Bool = false;
	public var playstate_endless:Bool = false;
	public var playstate_guitar:Bool = false;
	public var playstate_confusion:Bool = false;
	public static var playstate_anychanges:Bool = false;
	//todo: these things
	public var playstateparam_healthgain:Float = 1.0;
	public var playstateparam_healthloss:Float = 1.0;
	public var playstate_inorder:Bool = false;

	//Practice tools
	public var practice_enabled:Bool = false;
	public var practice_preplay_menu:Bool = false;
	public var practice_disable_death:Bool = false;
	public var practice_disable_mechanics:Bool = false;

	public function updatePlayStateAny() {
		playstate_anychanges = [playstate_opponentmode, playstate_bothside, playstate_endless, playstate_guitar, playstate_confusion, playstate_anychanges].contains(true);
	}

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

	//todo: Mod options
	//public static var modOptions:Map<String, Map<String, Dynamic>>;
	//public static var modGameplayChanges:Map<String, Array<String>>;

	public function new() {
		
	}

	public static inline function applyControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(Custom);
	}
	
	public function SaveOptions() {
		var svd = GetSaveObj();
		svd.data.masterVolume = masterVolume;
		svd.data.downScroll = downScroll;
		svd.data.middleScroll = middleScroll;
		svd.data.middleLarge = middleLarge;
		svd.data.ghostTapping = ghostTapping;
		svd.data.instantRespawn = instantRespawn;
		svd.data.botplay = botplay;
		//svd.data.playstyle = playstyle;
		svd.data.offset = offset;
		svd.data.antialias = antialias;
		/*#if debug
		svd.data.freeplayFolders = freeplayFolders;
		#end*/
		svd.data.newModsActive = newModsActive;
		svd.data.tappingHorizontal = tappingHorizontal;
		svd.data.skipTitle = skipTitle;
		svd.data.invisibleNotes = invisibleNotes;
		svd.data.invisibleNotesType = invisibleNotesType;
		svd.data.controls = controls;
		svd.data.uiControls = uiControls.copy();
		svd.data.language = language;
		svd.data.modchartEnabled = modchartEnabled;
		svd.data.flashingLights = flashingLights;
		svd.data.antialiasing = antialiasing;
		svd.data.seenOptionsWarning_Int = seenOptionsWarning;
		svd.data.silentCountdown = silentCountdown;
		svd.data.noteMissAction = noteMissAction;
		svd.data.showFPS = showFPS;
		svd.data.resetButton = resetButton;
		svd.data.noteCamMovement = noteCamMovement;
		svd.data.selfAware = selfAware;
		svd.data.dataStrip = dataStrip;
		svd.data.uiReloading = uiReloading;
		svd.data.noteQuant = noteQuant;
		svd.data.hudThingInfo = hudThingInfo;

		svd.data.playstate_opponentmode = playstate_opponentmode;
		svd.data.playstate_bothside = playstate_bothside;
		svd.data.playstate_endless = playstate_endless;
		svd.data.playstate_guitar = playstate_guitar;
		svd.data.playstate_confusion = playstate_confusion;

		svd.data.playedVersion = Main.gameVersionInt;
		svd.data.optionVersion = Std.int(0);
		svd.close();
	}
	
	public static function LoadOptions() {
		saved = new Options();
		var svd = GetSaveObj();
		masterVolume = ifNotNull(svd.data.masterVolume, masterVolume);
		saved.downScroll = ifNotNull(svd.data.downScroll, saved.downScroll);
		saved.middleScroll = ifNotNull(svd.data.middleScroll, saved.middleScroll);
		saved.middleLarge = ifNotNull(svd.data.middleLarge, saved.middleLarge);
		saved.ghostTapping = ifNotNull(svd.data.ghostTapping, saved.ghostTapping);
		saved.instantRespawn = ifNotNull(svd.data.instantRespawn, saved.instantRespawn);
		saved.botplay = ifNotNull(svd.data.botplay, saved.botplay);
		//saved.playstyle = ifNotNull(svd.data.playstyle, saved.playstyle);
		offset = Std.int(CoolUtil.clamp(ifNotNull(svd.data.offset, offset), -500, 500));
		antialias = ifNotNull(svd.data.antialias, antialias);
		//freeplayFolders = ifNotNull(svd.data.freeplayFolders, freeplayFolders);
		newModsActive = ifNotNull(svd.data.newModsActive, newModsActive);
		saved.tappingHorizontal = ifNotNull(svd.data.tappingHorizontal, saved.tappingHorizontal);
		skipTitle = ifNotNull(svd.data.skipTitle, skipTitle);
		saved.invisibleNotes = ifNotNull(svd.data.invisibleNotes, saved.invisibleNotes);
		saved.invisibleNotesType = ifNotNull(svd.data.invisibleNotesType, saved.invisibleNotesType);
		controls = ifNotNull(svd.data.controls, controls);
		language = ifNotNull(svd.data.language, language);
		saved.modchartEnabled = ifNotNull(svd.data.modchartEnabled, saved.modchartEnabled);
		flashingLights = ifNotNull(svd.data.flashingLights, flashingLights);
		saved.antialiasing = ifNotNull(svd.data.antialiasing, saved.antialiasing);
		seenOptionsWarning = ifNotNull(svd.data.seenOptionsWarning_Int, seenOptionsWarning);
		saved.silentCountdown = ifNotNull(svd.data.silentCountdown, saved.silentCountdown);
		saved.noteMissAction = ifNotNull(svd.data.noteMissAction, saved.noteMissAction);
		showFPS = ifNotNull(svd.data.showFPS, showFPS);
		saved.resetButton = ifNotNull(svd.data.resetButton, saved.resetButton);
		saved.noteCamMovement = ifNotNull(svd.data.noteCamMovement, saved.noteCamMovement);
		_selfAware = ifNotNull(svd.data.selfAware, _selfAware);
		dataStrip = ifNotNull(svd.data.dataStrip, dataStrip);
		saved.uiReloading = ifNotNull(svd.data.uiReloading, saved.uiReloading);
		saved.noteQuant = ifNotNull(svd.data.noteQuant, saved.noteQuant);
		saved.hudThingInfo = Std.string(ifNotNull(svd.data.hudThingInfo, saved.hudThingInfo)).split("\n").slice(0, 2).join("\n"); //Ok
		
		saved.playstate_opponentmode = ifNotNull(svd.data.playstate_opponentmode, saved.playstate_opponentmode);
		saved.playstate_bothside = ifNotNull(svd.data.playstate_bothside, saved.playstate_bothside);
		saved.playstate_endless = ifNotNull(svd.data.playstate_endless, saved.playstate_endless);
		saved.playstate_guitar = ifNotNull(svd.data.playstate_guitar, saved.playstate_guitar);
		saved.playstate_confusion = ifNotNull(svd.data.playstate_confusion, saved.playstate_confusion);

		saved.updatePlayStateAny();
		
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
		instance = saved.copy();
	}
	
	static inline function ifNotNull(a:Any, b:Any):Null<Any> {
		return a == null ? b : a;
	}
	
	public static function GetSaveObj() {
		var svd = new FlxSave();
		svd.bind("Options");
		return svd;
	}

	public static function getControlName(mania:String, num:Int) {
		return ControlsSubState.ConvertKey(controls.get(mania)[num][0], true);
	}

	public static function getUIControlName(num:String) {
		return ControlsSubState.ConvertKey(uiControls.get(num)[0], true);
	}

	public static function getUIControlNameBoth(num:String) {
		return Translation.getTranslation("two keys", "optionsMenu", [ControlsSubState.ConvertKey(uiControls.get(num)[0], true), ControlsSubState.ConvertKey(uiControls.get(num)[1], true)], '${ControlsSubState.ConvertKey(uiControls.get(num)[0], true)}/${ControlsSubState.ConvertKey(uiControls.get(num)[1], true)}');
	}

	public function copy() {
		var a = new Options();
		for (n in Reflect.fields(a)) {
			Reflect.setProperty(a, n, Reflect.getProperty(this, n));
		}
		if (!a.practice_enabled) {
			a.practice_disable_death = false;
			a.practice_disable_mechanics = false;
			a.practice_preplay_menu = false;
		}
		return a;
	}

	static function get_selfAware():Bool {
		return _selfAware;
	}
}