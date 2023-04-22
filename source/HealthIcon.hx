package;

import Character;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
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
		'monster-christmas' => [19, 20, 19]
	];

	public var iconOffsets:Array<Float> = [0, 0];

	public function new(char:String = 'bf', isPlayer:Bool = false, ?myMod:String = "")
	{
		super();
		scrollFactor.set();
		this.isPlayer = isPlayer;

		changeCharacter(char, isPlayer, myMod);
	}

	inline function loadAnimsForIcon(anims:Array<SwagCharacterAnim>, loadFunc:(FlxSprite,SwagCharacterAnim,Bool)->Void, flip:Bool) {
		for (anim in anims) {
			loadFunc(this, anim, flip);
			if (anim.offset != null && anim.offset.length >= 2)
				addOffset(anim.name, anim.offset[flip && anim.offset.length >= 3 ? 2 : 0], anim.offset[1], 0);
			if (animation.getByName(anim.name).frames.length != 0) {
				switch(anim.name) {
					case "winning":
						hasWinning = true;
					case "losing":
						hasLosing = true;
				}
			}
		}
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
				for (thing in jsonData.items) {
					addChild(thing.name, thing.x, thing.y, thing.scale);
				}
				folderType = children[0].folderType;
				return;
			}
			trace("wait what");
		}
		if (!FileSystem.exists('${path}.png')) {
			pathPrefix = "assets/images/icons/";
			path = '${pathPrefix}${char}';
		}
		isMultiIcon = false;
		if (
			#if !html5
			FileSystem.exists('${path}.png')
			#else
			Assets.exists('${path}.png')
			#end
		) { //todo: this
			trace('found health icon ${char}');
			#if !html5
			var isJson = FileSystem.exists('${path}.json');
			#else
			var isJson = Assets.exists('${path}.json');
			#end
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
			#if !html5
			var isSheet = FileSystem.exists('${path}.xml');
			#else
			var isSheet = Assets.exists('${path}.xml');
			#end
			var bitmap = BitmapData.fromFile('${path}.png');
			if (isSheet) {
				#if !html5
				frames = FlxAtlasFrames.fromSparrow(bitmap, File.getContent('${path}.xml'));
				#else
				frames = FlxAtlasFrames.fromSparrow(bitmap, Assets.getText('${path}.xml'));
				#end
				hasWinning = false;
				hasLosing = false;
				loadAnimsForIcon(jsonData != null && jsonData.animations != null ? jsonData.animations : [
					cast {
						name: "neutral",
						anim: "neutral",
						framerate: 24,
						loop: true
					},
					cast {
						name: "winning",
						anim: "winning",
						framerate: 24,
						loop: true
					},
					cast {
						name: "losing",
						anim: "losing",
						framerate: 24,
						loop: true
					}
				], Character.loadAnimationNameless, isPlayer);
			} else {
				loadGraphic(bitmap);
				var ratio = width / height;
				var intHeight = Math.floor(height);
				if (isJson && jsonData != null && jsonData.tileWidth != null) {
					//todo: load anims
					loadGraphic(bitmap, true, jsonData.tileWidth, jsonData.tileHeight == null ? intHeight : jsonData.tileHeight);
					loadAnimsForIcon(jsonData.animations, Character.loadAnimationNameless, isPlayer);
				} else if (ratio > 2.5) {
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
			animation.play("neutral");
			updateHitbox();
			if (Std.isOfType(FlxG.state, FreeplayState) && isJson && jsonData != null && jsonData.position_freeplay != null && jsonData.position_freeplay.length > 0) {
				offset.add(jsonData.position_freeplay[0], jsonData.position_freeplay[1]);
			}
			return;
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
	}

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
