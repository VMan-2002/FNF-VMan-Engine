package chartformat;

typedef ChartFormatLeather = {
	var song:String;
	var notes:Array<SectionFormatLeather>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gf:Null<String>;
	var stage:String;
	var validScore:Bool;
	var modchartPath:String;
	var keyCount:Null<Int>;
	var playerKeyCount:Null<Int>;
	var timescale:Array<Int>;
	var chartOffset:Null<Int>; // in milliseconds
	// shaggy pog
	var mania:Null<Int>;
	var ui_Skin:Null<String>;
	var cutscene:String;
	var endCutscene:String;
	var eventObjects:Array<EventFormatLeather>;
	var events:Null<Array<Array<Dynamic>>>;
	var specialAudioName:Null<String>;
	var gfVersion:Null<String>;
	var player3:Null<String>;
}

typedef SectionFormatLeather =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;

	var timeScale:Array<Int>;
	var changeTimeScale:Bool;
}

typedef EventFormatLeather = {
	var name:String;
	var position:Float;
	var value:Float;
	var type:String;
}