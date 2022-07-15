package;

import Character;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
#if polymod
import json2object.JsonParser;
import sys.FileSystem;
import sys.io.File;
#end

typedef SwagHealthIcon = {
	public var image:String;
	public var imagePlayer:String;
	public var initAnim:String;
	public var antialias:Null<Bool>;
	public var animations:Array<SwagCharacterAnim>;
	public var scale:Array<Float>;
	public var folderType:String;
}

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var sprTrackerX:Float;
	public var sprTrackerY:Float;
	
	public var myMod:String;
	public var curCharacter:String;
	public var folderType:String;
	
	private final defaultStuff:Map<String, Array<Int>> = [
		'bf' => [0, 1, 0],
		'bf-car' => [0, 1, 0],
		'bf-christmas' => [0, 1, 0],
		'bf-pixel' => [21, 24, 21],
		'spooky' => [2, 3, 2],
		'pico' => [4, 5, 4],
		'mom' => [6, 7, 6],
		'mom-car' => [6, 7, 6],
		'tankman' => [8, 9, 8],
		'face' => [10, 11, 29],
		'dad' => [12, 13, 12],
		'senpai' => [22, 25, 22],
		'senpai-angry' => [22, 25, 22],
		'spirit' => [23, 26, 23],
		'bf-old' => [14, 15, 14],
		'gf' => [16, 16, 16],
		'gf-christmas' => [16, 16, 16],
		'gf-pixel' => [16, 16, 16],
		'gfcar' => [16, 16, 16],
		'parents-christmas' => [17, 17, 17],
		'monster' => [19, 20, 19],
		'monster-christmas' => [19, 20, 19]
	];

	var iconOffsets:Array<Float> = [0, 0];

	public function new(char:String = 'bf', isPlayer:Bool = false, ?myMod:String = "")
	{
		super();
		scrollFactor.set();

		changeCharacter(char, isPlayer, myMod);
	}

	public function changeCharacter(char:String, isPlayer:Bool = false, ?myMod:String) {
		if (myMod == this.myMod && char == this.curCharacter) {
			return;
		}

		hasWinning = true;
		hasLosing = true;

		this.myMod = myMod;
		this.curCharacter = char;
		
		//first, find icon that belongs to the char's mod
		var pathPrefix = 'mods/${myMod}/images/icons/';
		var path = '${pathPrefix}${char}';
		/*if (!FileSystem.exists(path)) {
			//if it doesn't exist
			path = 'mods/${myMod}/images/icons/${char}';
		}*/
		if (FileSystem.exists('${path}.png')) { //todo: this
			trace('found health icon ${char}');
			var isJson = FileSystem.exists('${path}.json');
			var jsonData:Null<SwagHealthIcon> = null;
			//is there accompanying json
			if (isJson) {
				trace('json found for health icon ${char}');
				jsonData = cast CoolUtil.loadJsonFromString(File.getContent('${path}.json'));
				if (jsonData.image != null && jsonData.image.length > 0) {
					path = '${pathPrefix}${jsonData.image}';
				}
				if (isPlayer && jsonData.imagePlayer != null && jsonData.imagePlayer != "") {
					path = '${pathPrefix}${jsonData.imagePlayer}';
				}
			}
			//is there accompanying xml
			var isSheet = FileSystem.exists('${path}.xml');
			var bitmap = BitmapData.fromFile('${path}.png');
			if (isSheet) {
				frames = FlxAtlasFrames.fromSparrow(bitmap, File.getContent('${path}.xml'));
				hasWinning = false;
				hasLosing = false;
			} else {
				loadGraphic(bitmap);
				var ratio = width / height;
				var intHeight = Math.floor(height);
				if (ratio > 2.5) {
					loadGraphic(bitmap, true, Math.floor(width / 3), intHeight);
					animation.add('winning', [2], 0, false, isPlayer);
					animation.add('neutral', [0], 0, false, isPlayer);
					animation.add('losing', [1], 0, false, isPlayer);
				} else if (ratio > 1.5) {
					loadGraphic(bitmap, true, Math.floor(width / 2), intHeight);
					animation.add('winning', [0], 0, false, isPlayer);
					animation.add('neutral', [0], 0, false, isPlayer);
					animation.add('losing', [1], 0, false, isPlayer);
					hasWinning = false;
				} else {
					loadGraphic(bitmap, true, Math.floor(width), intHeight);
					animation.add('winning', [0], 0, false, isPlayer);
					animation.add('neutral', [0], 0, false, isPlayer);
					animation.add('losing', [0], 0, false, isPlayer);
					hasWinning = false;
					hasLosing = false;
				}
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = iconOffsets[0];
				//if (isPlayer) {
				//	iconOffsets[0] = width - iconOffsets[0];
				//}
				updateHitbox();
			}
			if (isJson && jsonData != null) { //i have to do that or else compiler says no. brugh
				antialiasing = jsonData.antialias != false;
				folderType = jsonData.folderType != null ? jsonData.folderType : "";
				//todo: put more loads!
			} else {
				antialiasing = true;
				folderType = "";
			}
			return animation.play("neutral");
		} else {
			trace('using inbuilt health icon for ${char}');
		}
		
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		var isPixel = (char == "bf-pixel" || char == "senpai" || char == "senpai-angry" || char == "spirit");
		antialiasing = !isPixel;
		folderType = isPixel ? "pixel" : "";
		
		var thing:Array<Int> = defaultStuff.get(defaultStuff.exists(char) ? char : "face");
		animation.add('winning', [thing[2]], 0, false, isPlayer);
		animation.add('neutral', [thing[0]], 0, false, isPlayer);
		animation.add('losing', [thing[1]], 0, false, isPlayer);
		
		animation.play("neutral");
	}
	
	private final states:Array<String> = ["neutral", "losing", "winning"];
	public var hasWinning = true;
	public var hasLosing = true;
	
	public function setState(a:Int) {
		switch(a) {
			case 1:
			if (!hasLosing) {
				a = 0;
			}
			case 2:
			if (!hasWinning) {
				a = 0;
			}
		}
		animation.play(states[a]);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + sprTracker.width + 10 + sprTrackerX, (sprTracker.y - 30) + sprTrackerY);
		}
	}

	override function updateHitbox() {
		super.updateHitbox();
		offset.x += iconOffsets[0];
		offset.y += iconOffsets[1];
	}
}
