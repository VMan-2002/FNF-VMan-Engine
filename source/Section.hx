package;

typedef SwagSection = {
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

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}

	public static inline function sectionFunc():SwagSection {
		return {
			sectionNotes: new Array<Array<Dynamic>>(),
			lengthInSteps: 16,
			typeOfSection: 0,
			mustHitSection: true,
			bpm: 150.0,
			changeBPM: false,
			altAnim: false,
			gfSection: false,
			focusCharacter: null,
			changeMania: false,
			maniaStr: null,
			//maniaArr: null,
			notesMoreLayers: null,
			changeTimeSignature:false,
			timeSignature:4,
			sectionBeats:-1,
			dType:-1
		};
	}
}
