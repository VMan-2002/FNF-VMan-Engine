package;

import Character;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import haxe.Json;
import openfl.Assets;
import openfl.display.BitmapData;
#if polymod
import json2object.JsonParser;
#if !html5
import sys.FileSystem;
import sys.io.File;
#end
#end

typedef SwagHealthIcon = {
	public var image:String;
	public var imagePlayer:String;
	public var initAnim:String;
	public var antialias:Null<Bool>;
	public var animations:Array<SwagCharacterAnim>;
	public var scale:Array<Float>;
	public var folderType:String;
	public var position_freeplay:Null<Array<Float>>;
	public var tileWidth:Null<Int>;
	public var tileHeight:Null<Int>;
	public var healthStates:Array<Float>;
}

typedef SwagHealthIconItem = {
	public var name:String;
	public var x:Float;
	public var y:Float;
	public var scale:Float;
}

typedef SwagMultiHealthIcon = {
	public var items:Array<SwagHealthIconItem>;
}

class HealthIcon extends SpriteVMan
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var sprTrackerX:Float;
	public var sprTrackerY:Float;

	public var attachToIcon:Bool;
	public var children:Array<HealthIcon>;
	public var isMultiIcon:Bool = false;
	public var realScale:Float;
	
	public var myMod:String;
	public var curCharacter:String;
	public var folderType:String;
	public var isPlayer:Bool;
	
	private final defaultStuff:Map<String, Array<Int>> = [
		'bf' => [0, 1, 0],
		'bf-car' => [0, 1, 0],
		'bf-christmas' => [0, 1, 0],
		'bf-pixel' => [21, 21, 21],
		'bf-holding-gf' => [0, 1, 0],
		'spooky' => [2, 3, 2],
		'pico' => [4, 5, 4],
		'pico-speaker' => [4, 5, 4],
		'mom' => [6, 7, 6],
		'mom-car' => [6, 7, 6],
		'tankman' => [8, 9, 8],
		'face' => [10, 11, 29],
		'dad' => [12, 13, 12],
		'senpai' => [22, 22, 22],
		'senpai-angry' => [22, 22, 22],
		'spirit' => [23, 23, 23],
		'bf-old' => [14, 15, 14],
		'gf' => [16, 16, 16],
		'gf-christmas' => [16, 16, 16],
		'gf-pixel' => [16, 16, 16],
		'gf-tankmen' => [16, 16, 16],
		'gf-car' => [16, 16, 16],
		'parents-christmas' => [17, 17, 17],
		'monster' => [19, 20, 19],
		'monster-christmas' => [19, 20, 19],
		'darnell' => [24, 25, 24]
	];

	public var iconOffsets:Array<Float> = [0, 0];
	public var healthStates = new Array<Float>();
	
	//todo: finish making animated health icons

	public function new(char:String = 'bf', isPlayer:Bool = false, ?myMod:String = "") {
		super();
		moves = false;
		scrollFactor.set();
		this.isPlayer = isPlayer;

		changeCharacter(char, isPlayer, myMod);
	}

	inline function loadAnimsForIcon(anims:Array<SwagCharacterAnim>, loadFunc:(FlxSprite,SwagCharacterAnim,Bool)->Void, flip:Bool) {
		for (anim in anims) {
			loadFunc(this, anim, flip);
			if (anim.offset != null && anim.offset.length >= 2)
				addOffset(anim.name, anim.offset[flip && anim.offset.length >= 3 ? 2 : 0], anim.offset[1], 0);
		}
	}

	public function changeCharacter(char:String, isPlayer:Bool = false, ?myMod:String) {
		if (myMod == this.myMod && char == this.curCharacter) {
			return;
		}

		this.myMod = myMod;
		this.curCharacter = char;
		
		//first, find icon that belongs to the char's mod
		var pathPrefix = 'mods/${myMod}/images/icons/';
		var multiThingPathPrefix = 'mods/${myMod}/objects/multiHealthIcon/';
		var path = '${pathPrefix}${char}';
		var multiThingPath = '${multiThingPathPrefix}${char}.json';
		if (FileSystem.exists(multiThingPath)) {
			trace("multi icon found lets goooo");
			var jsonData:Null<SwagMultiHealthIcon> = cast CoolUtil.loadJsonFromString(File.getContent(multiThingPath));
			if (jsonData != null) {
				//todo: this doesn't work yet
				isMultiIcon = true;
				visible = false;
				for (thing in jsonData.items)
					addChild(thing.name, thing.x, thing.y, thing.scale);
				folderType = children[0].folderType;
				return;
			}
			trace("wait what");
		}
		if (!FileSystem.exists('${path}.png') && !FileSystem.exists('${path}.webp')) {
			pathPrefix = "assets/images/icons/";
			path = '${pathPrefix}${char}';
		}
		isMultiIcon = false;
		if (Paths.exists('${path}.png') || Paths.exists('${path}.webp')) {
			trace('found health icon ${char}');
			var isJson = Paths.exists('${path}.json');
			var jsonData:Null<SwagHealthIcon> = null;
			//is there accompanying json
			if (isJson) {
				trace('json found for health icon ${char}');
				#if !html5
				jsonData = cast CoolUtil.loadJsonFromString(File.getContent('${path}.json'));
				#else
				jsonData = cast CoolUtil.loadJsonFromString(Assets.getText('${path}.json'));
				#end
				if (jsonData.image != null && jsonData.image.length > 0) {
					path = '${pathPrefix}${jsonData.image}';
				}
				if (isPlayer && jsonData.imagePlayer != null && jsonData.imagePlayer != "") {
					path = '${pathPrefix}${jsonData.imagePlayer}';
				}
			}
			//is there accompanying xml
			var isSheet = Paths.exists('${path}.xml');
			//var bitmap = BitmapData.fromFile('${path}.png');
			//todo: This is an unusual way to do this
			var bitmap = Paths.exists('${path}.webp') ? Paths2.webpTest('${path}.webp') : BitmapData.fromFile('${path}.png');
			if (isSheet) {
				#if !html5
				frames = FlxAtlasFrames.fromSparrow(bitmap, File.getContent('${path}.xml'));
				#else
				frames = FlxAtlasFrames.fromSparrow(bitmap, Assets.getText('${path}.xml'));
				#end
				if (jsonData == null || jsonData.animations == null) {
					var hasLosing = prefixFrameExists("losing");
					var hasWinning = prefixFrameExists("winning");
					var s:Int = hasLosing ? 0 : -1;
					var aList:Array<Dynamic> = [{name: "idle" + (1 + s), anim: "neutral", framerate: 24, loop:true}];
						aList.push({name: "idle0", anim: "losing", framerate: 24, loop:true});
					if (hasWinning)
						aList.push({name: "idle" + (2 + s), anim: "winning", framerate: 24, loop:true});
					loadAnimsForIcon(cast aList, Character.loadAnimation, isPlayer);
				} else {
					loadAnimsForIcon(jsonData.animations, Character.loadAnimation, isPlayer);
				}
			} else {
				loadGraphic(bitmap);
				var ratio = width / height;
				var intHeight = Math.floor(height);
				if (isJson && jsonData != null && jsonData.tileWidth != null) {
					//todo: load anims
					loadGraphic(bitmap, true, jsonData.tileWidth, jsonData.tileHeight == null ? intHeight : jsonData.tileHeight);
					loadAnimsForIcon(jsonData.animations, Character.loadAnimationNameless, isPlayer);
				} else { 
					if (ratio > 2.5) {
						loadGraphic(bitmap, true, Math.floor(width / 3), intHeight);
						animation.add('idle2', [2], 0, false, isPlayer);
						animation.add('idle1', [0], 0, false, isPlayer);
						animation.add('idle0', [1], 0, false, isPlayer);
						if (healthStates.length == 0)
							healthStates = [20, 80];
					} else if (ratio > 1.5) {
						loadGraphic(bitmap, true, Math.floor(width / 2), intHeight);
						animation.add('idle1', [0], 0, false, isPlayer);
						animation.add('idle0', [1], 0, false, isPlayer);
						if (healthStates.length == 0)
							healthStates = [20];
					} else {
						loadGraphic(bitmap, true, Math.floor(width), intHeight);
						animation.add('idle0', [0], 0, false, isPlayer);
					}
				}
				iconOffsets[0] = (width - 150) * 0.5;
				iconOffsets[1] = 0;
				//origin.x += 75;
				//origin.y += 75;
				//if (isPlayer) {
				//	iconOffsets[0] = width - iconOffsets[0];
				//}
			}
			if (isJson && jsonData != null) { //i have to do that or else compiler says no. brugh
				antialiasing = jsonData.antialias != false;
				folderType = jsonData.folderType != null ? jsonData.folderType : "";
				//todo: put more loads!
			} else {
				antialiasing = true;
				folderType = "";
			}
			healthAmount = 0.5;
			updateHitbox();
			if (Std.isOfType(FlxG.state, FreeplayState) && isJson && jsonData != null) {
				if (jsonData.position_freeplay != null && jsonData.position_freeplay.length != 0)
					offset.add(jsonData.position_freeplay[0], jsonData.position_freeplay[1]);
				if (jsonData.initAnim != "")
					playAnim(jsonData.initAnim, true);
				else
					setState(50);
			} else {
				setState(50);
			}
			return;
		} else {
			trace('using inbuilt health icon for ${char}');
		}
		
		loadGraphic(Paths2.image('iconGrid'), true, 150, 150);

		var isPixel = (char == "bf-pixel" || char == "senpai" || char == "senpai-angry" || char == "spirit");
		antialiasing = !isPixel;
		folderType = isPixel ? "pixel" : "";
		
		var thing:Array<Int> = defaultStuff.get(defaultStuff.exists(char) ? char : "face");
		animation.add('idle2', [thing[2]], 0, false, isPlayer);
		animation.add('idle1', [thing[0]], 0, false, isPlayer);
		animation.add('idle0', [thing[1]], 0, false, isPlayer);
		healthStates = [20, 80];
		
		animation.play("idle1");
	}

	public var healthAmount(default, set):Float = 50;

	public function set_healthAmount(a:Float) {
		if (healthAmount == a)
			return a;
		healthAmount = a;
		return setState(a);
	}

	public function setState(a:Float) {
		var i = 0;
		while (healthStates.length != i && healthStates[i] < a) {
			i++;
		}
		playAnim("idle" + i);
		return a;
	}
	
	/*public function setState(a:Int) {
		if (isMultiIcon) {
			for (thing in children) {
				thing.setState(a);
			}
			return;
		}
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
	}*/

	public function addChild(name:String, x:Float, y:Float, scale:Float) {
		if (children == null) {
			children = new Array<HealthIcon>();
		}
		var child = new HealthIcon(name, isPlayer, myMod);
		child.sprTrackerX = x;
		child.sprTrackerY = y;
		child.realScale = scale;
		child.sprTracker = this;
		child.attachToIcon = true;
		children.push(child);
	}

	override function destroy() {
		destroyChildren();
		super.destroy();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			if (attachToIcon) {
				scale.x = sprTracker.scale.x * realScale;
				scale.y = sprTracker.scale.y * realScale;
				setPosition((sprTracker.x + sprTrackerX) * scale.x, (sprTracker.y + sprTrackerY) * scale.y);
			} else {
				setPosition(sprTracker.x + sprTracker.width + 10 + sprTrackerX, (sprTracker.y - 30) + sprTrackerY);
			}
		}
	}

	public function addChildrenToScene() {
		if (!isMultiIcon) {
			return;
		}
		for (thing in children) {
			FlxG.state.add(thing);
		}
	}

	public function destroyChildren() {
		if (!isMultiIcon) {
			return;
		}
		for (thing in children) {
			thing.destroy();
			FlxG.state.remove(thing);
		}
	}

	override function updateHitbox() {
		super.updateHitbox();
		offset.x += iconOffsets[0];
		offset.y += iconOffsets[1];
	}
}
