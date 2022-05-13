package;
import flixel.util.FlxSave;
import lime.ui.ScanCode;
import flixel.input.keyboard.FlxKey;

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
	public static var uiControls = new Map<String, Array<Int>>();
	public static var language = "en_us";
	public static var modchartEnabled = "en_us";
	
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
		/*var insertControls = new Map<String, Array<Array<Int>>>();
		insertControls = ifNotNull(svd.data.controls, controls);
		for (i in insertControls.keys()) {
			if (!controls.exists(i)) {
				controls.set(insertControls[i]);
			}
		}*/
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
