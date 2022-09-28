package;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var notesMoreLayers:Array<Array<Dynamic>>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
	var gfSection:Bool;
	var focusCharacter:Null<Int>;
	var changeMania:Bool;
	var maniaStr:String;
	var changeTimeSignature:Bool;
	var timeSignature:Int;
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
}
