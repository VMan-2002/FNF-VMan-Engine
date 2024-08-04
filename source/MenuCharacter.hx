package;

import Character.SwagCharacterAnim;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;

typedef SwagMenuCharacter = {
	public var image:String;
	public var initAnim:String;
	public var antialias:Null<Bool>;
	public var animations:Array<SwagCharacterAnim>;
	public var position:Null<Array<Float>>;
	public var isPlayer:Null<Bool>;
	public var scale:Null<Float>;
}

class MenuCharacter extends SpriteVMan {
	public var character:String;
	public var modName:String;
	public var flipped:Bool = false;

	public function new(x:Float, character:String = 'bf', ?flipped:Bool = false) {
		super(x);
		moves = false;

		this.flipped = flipped;
		setCharacter(character, "friday_night_funkin");
		animation.play(character);
		updateHitbox();
	}

	public function setCharacter(name:String, mod:String) {
		if ((name != character || mod != modName) || (!visible && name.length > 0)) {
			visible = name.length > 0;
			if (!visible)
				return;
			flipX = flipped;
			animOffsets = new Map<String, Array<Null<Float>>>();

			trace("Mod menu char "+name+" from "+mod);
			var input = loadCharacterJson(name, mod);
			if (input != null) {
				frames = Paths.getSparrowAtlas(input.image);
				animOffsets.clear();
				
				antialiasing = input.antialias != false;
				flipX = (input.isPlayer == true) == flipped;
				if (input.position == null) {
					input.position = [0, 0];
				} else while (input.position.length < 2) {
					input.position.push(0);
				}
				for (thing in input.animations) {
					if (thing.indicies != null && thing.indicies.length > 0) {
						animation.addByIndices(thing.name, thing.anim, thing.indicies, "", thing.framerate, thing.loop);
					} else {
						animation.addByPrefix(thing.name, thing.anim, thing.framerate, thing.loop);
					}
					var flippedPlayer:Bool = !input.isPlayer;
					if (thing.offset != null && thing.offset.length > 0) {
						//im tired of it (also got no time lol)
						addOffset(thing.name, thing.offset[0] + input.position[0], thing.offset[1] + input.position[1], thing.offset[0] + input.position[0]);
					} else {
						addOffset(thing.name, input.position[0], input.position[1], input.position[0]);
					}
				}
				scale.set(input.scale, input.scale);
				playAnim(input.initAnim);
			}
			
			generateFlipOffsets();
			character = name;
			modName = mod;
		}
	}

	public static function loadCharacterJson(name:String, mod:String) {
		#if !html5
		var thing:String = 'assets/objects/characters/menu/${name}.json';
		var thingMy:String = 'mods/${mod}/objects/characters/menu/${name}.json';
		var isMyMod = mod != "" && FileSystem.exists(thingMy);
		trace('loading custom char of ${isMyMod ? thingMy : thing}');
		if (isMyMod ? FileSystem.exists(thingMy) : OpenFlAssets.exists(thing)) {
			var loadStr = isMyMod ? File.getContent(thingMy) : Assets.getText(thing);
			//trace(loadStr);
			var loadedStuff:SwagMenuCharacter = cast CoolUtil.loadJsonFromString(loadStr);
			return loadedStuff;
		}
		#else
		var loadStr = Assets.getText('assets/objects/characters/menu/${name}.json');
		var loadedStuff:SwagMenuCharacter = cast CoolUtil.loadJsonFromString(loadStr);
		return loadedStuff;
		#end
		return null;
	}
}
