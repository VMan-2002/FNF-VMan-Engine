package chartformat;

typedef ChartFormatOld = {
	var song:String;
	var newtitle:Null<String>; //display name
	var notes:Array<SectionFormatOld>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
	
	var gfVersion:String;
	var maniaStr:Null<String>;
	var mania:Null<Int>; //for Kade/Psych (7k and 9k vs shaggy charts dont get interpreted right)
	var keyCount:Null<Int>; //for Leather
	var stage:String;
	var usedNoteTypes:Array<String>;

	var healthDrain:Null<Float>;
	var healthDrainMin:Null<Float>;
	
	var moreCharacters:Array<String>;

	var actions:Array<String>;
	var attributes:Array<Array<Dynamic>>;
	var noteSkin:String;
	var noteSkinOpponent:Array<String>;
	var uiStyle:String;
	
	var vmanEventTime:Array<Float>;
	var vmanEventOrder:Array<Int>;
	var vmanEventData:Array<Dynamic>;

	var hide_girlfriend:Null<Bool>;

	var moreStrumLines:Null<Int>;

	var timeSignature:Null<Int>;

	var voicesName:Null<String>;
	var voicesOpponentName:Null<String>;
	var instName:Null<String>;
	
	var threeLanes:Null<Bool>; //Pasta night :))))))

	var picospeaker:Null<String>; //Week 7 stress
	var picocharts:Null<Array<String>>; //It dont Crap

	var loopbackPoint:Null<Float>; //Music that is just endless on it's own
}

typedef SectionFormatOld = {
	var sectionNotes:Array<Array<Dynamic>>; // putting here so i remember:
	//sectionNotes[i][0]: strumTime
	//sectionNotes[i][1]: noteData
	//sectionNotes[i][2]: sustainLength
	//sectionNotes[i][3]: noteType
	var notesMoreLayers:Array<Array<Array<Dynamic>>>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
	var gfSection:Bool;
	var focusCharacter:Null<Int>;
	var changeMania:Bool;
	//var maniaArr:Array<String>;
	var maniaStr:String;
	var changeTimeSignature:Bool;
	var timeSignature:Int;
	var sectionBeats:Int;
	var dType:Int; //this exists because Final Destination!!!
}