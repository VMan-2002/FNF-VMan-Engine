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

class MenuCharacter extends SpriteVMan
{
	public var character:String;
	public var modName:String;
	public var flipped:Bool = false;

	public function new(x:Float, character:String = 'bf', ?flipped:Bool = false)
	{
		super(x);

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
			/*if (mod == "friday_night_funkin" && name != "tankman") {
				trace("Inbuilt menu char "+name);
				frames = Paths.getSparrowAtlas('campaign_menu_UI_characters');
		
				animation.addByPrefix('bf', "BF idle dance white", 24);
				animation.addByPrefix('confirm', 'BF HEY!!', 24, false);
				animation.addByPrefix('gf', "GF Dancing Beat WHITE", 24);
				animation.addByPrefix('dad', "Dad idle dance BLACK LINE", 24);
				animation.addByPrefix('spooky', "spooky dance idle BLACK LINES", 24);
				animation.addByPrefix('pico', "Pico Idle Dance", 24);
				animation.addByPrefix('mom', "Mom Idle BLACK LINES", 24);
				animation.addByPrefix('parents-christmas', "Parent Christmas Idle", 24);
				animation.addByPrefix('senpai', "SENPAI idle Black Lines", 24);
				offset.set(-180, 0);
				scale.set(0.5, 0.5);
				switch(name) {
					case 'bf':
						scale.set(0.9, 0.9);
					case 'gf':
						offset.set(-69, 15);
					case 'parents-christmas':
						scale.set(0.45, 0.45);
						flipX = !flipX;
					case 'senpai':
						offset.set(130, 0);
						scale.set(1, 1);
						flipX = !flipX;
					case 'mom':
						flipX = !flipX;
					case 'dad':
						flipX = !flipX;
					case 'spooky':
						flipX = !flipX;
				}
				animation.play(name, false);
				width = frameWidth;
				height = frameHeight;
				antialiasing = true;
			} else*/ {
				trace("Mod menu char "+name+" from "+mod);
				var input = loadCharacterJson(name, mod);
				if (input != null) {
					frames = Paths.getSparrowAtlas(input.image);
					animOffsets.clear();
					
					antialiasing = input.antialias;
					flipX = (input.isPlayer == true) == flipped;
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
