package;

typedef StageElement =
{
	var name:String;
	var image:String;
	var animated:Bool;
	var x:Float;
	var y:Float;
	var scale:Float;
	var scrollX:Float;
	var scrollY:Float;
	var antialiasing:Bool;
}

typedef SwagStage =
{
	var charPosition:Array<Array<Float>>;
	var defaultCamZoom:Float;
	var elementsFront:Array<StageElement>;
	var elementsBack:Array<StageElement>;
}

class Stages
{
	public static function getStage(name:String) {
		//todo: lmao!
	}
}
