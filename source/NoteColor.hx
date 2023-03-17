package;

import ManiaInfo;
import Math;
import flash.display.PNGEncoderOptions;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.util.PNGEncoder;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.FlxColor;
import haxe.io.Bytes;
import lime.ui.FileDialog;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
#if !html5
import sys.io.File;
#end

class NoteColor
{
	//todo: this doesn't really work, but it's a start
	//A mod already did this??????? What!!!!!!! https://gamebanana.com/mods/406432
	
	public static function TestThing() {
		var arrs = makeNoteSet(
			"pixelUI", //style
			"right", //arrow
			[
				FlxColor.fromString("#FFFFFF"),
				FlxColor.fromString("#6F00C4"),
				FlxColor.fromString("#B656FF")
			], //note col
			[
				FlxColor.fromString("#FFF5FC"),
				FlxColor.fromString("#404047"),
				FlxColor.fromString("#A2BAC8")
			] //strum col
		);
		for (i in arrs.keys()) {
			saveImage(arrs.get(i)[0], i);
		}
	}
	
	//Credit https://gist.github.com/miltoncandelero/0c452f832fa924bfdd60fe9d507bc581
	public static function saveImage(bitmapData:BitmapData, name:String)
	{
		#if !html5
		var b:ByteArray = new ByteArray();
		b = bitmapData.encode(bitmapData.rect, new PNGEncoderOptions(true), b);
		File.saveBytes('f/${name}.png', b);
		//new FileDialog().save(b, "png", null, "file");
		#end
	}
	
	public static function makeSprite(style:String, arrow:String, col:Array<FlxColor>) {
		//todo: idk what's going on but the color swapping isn't working and idfk why
		var imagePath = Paths.image('notecustom/${style}/${arrow}');
		imagePath = imagePath.substr(imagePath.indexOf(":") + 1);
		var inSprite = BitmapData.fromFile(imagePath);
		//var inSprite = Paths.image('notecustom/${style}/${arrow}');
		var outSprite = new BitmapData(inSprite.width, inSprite.height, true);
		for (x in 0...Math.floor(inSprite.width)) {
			for (y in 0...Math.floor(inSprite.height)) {
				var pixel = inSprite.getPixel(x, y);
				var inColor = FlxColor.fromInt(pixel);
				var outColor = FlxColor.fromRGBFloat(
					col[0].redFloat * inColor.redFloat + col[1].redFloat * inColor.greenFloat + col[2].redFloat * inColor.blueFloat, 
					col[0].greenFloat * inColor.redFloat + col[1].greenFloat * inColor.greenFloat + col[2].greenFloat * inColor.blueFloat, 
					col[0].blueFloat * inColor.redFloat + col[1].blueFloat * inColor.greenFloat + col[2].blueFloat * inColor.blueFloat, 
					inColor.alpha
				);
				outSprite.setPixel(x, y, pixel);
			}
		}
		return outSprite;
	}
	
	public static function makeNoteSet(style:String, arrow:String, colNote:Array<FlxColor>, colStrum:Array<FlxColor>):Map<String, Array<BitmapData>> {
		var holdTmp = makeSprite(style, "hold_note", colNote);
		var holdTmpHalfHeight = Math.floor(holdTmp.height / 2);
		var hold = new BitmapData(holdTmp.width, holdTmpHalfHeight);
		var holdEnd = new BitmapData(holdTmp.width, holdTmpHalfHeight);
		hold.copyPixels(holdTmp, new Rectangle(0, 0, holdTmp.width, holdTmpHalfHeight), new Point(0, 0));
		holdEnd.copyPixels(holdTmp, new Rectangle(0, holdTmpHalfHeight, holdTmp.width, holdTmpHalfHeight), new Point(0, 0));
		return [
			"note" => [makeSprite(style, arrow, colNote)],
			"hold part" => [hold],
			"hold end" => [holdEnd],
			"arrow" => [makeSprite(style, arrow, colStrum)]
		];
	}
	
	public static function makeAtlas(style:String, propertySet:Map<String, Array<FlxColor>>, ?TheMania:Null<SwagMania>) {
//		var frames = new FlxFramesCollection();
	}
}
