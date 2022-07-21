package;

import Character.SwagCharacterAnim;
import Character;
import Paths;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import io.newgrounds.NGLite;
import sys.FileSystem;

typedef StageElement =
{
	var name:String;
	var image:String;
	var animated:Bool;
	var x:Float;
	var y:Float;
	var scaleX:Float;
	var scaleY:Float;
	var scrollX:Float;
	var scrollY:Float;
	var antialiasing:Bool;
	var animations:Null<Array<SwagCharacterAnim>>;
}

typedef SwagStage =
{
	var charPosition:Array<Array<Float>>;
	var defaultCamZoom:Float;
	var elementsFront:Array<StageElement>;
	var elementsBack:Array<StageElement>;
}

class Stage
{
	public var charPosition:Array<Array<Float>>;
	public var defaultCamZoom:Float;
	public var elementsFront:FlxTypedGroup<FlxSprite>;
	public var elementsBack:FlxTypedGroup<FlxSprite>;

	public static function getStage(name:String, ?mod:Null<String>):Null<SwagStage> {
		if (mod == null) {
			mod = PlayState.modName;
		}
		#if !VMAN_DEMO
		var path:String = "mods/${mod}/objects/stages/${name}.json";
		var isJson = FileSystem.exists(path);
		if (isJson) {
			trace("Found json for custom stage "+name);
			var json:SwagStage = cast CoolUtil.loadJsonFromFile(path);
			return json;
		}
		#end
		//your hardcoded stage would go here
		switch(name) {
			case "poops":
				//nothing lol
		#if VMAN_DEMO
			case "cornflower":
				//still nothing lol
			case "cornflower_sunset":
				//once again still nothing lol
			case "cornflower_erect1":
				//haha
			case "cornflower_erect2":
				//i
			case "cornflower_erect3":
				//funny
		#end
			case "stage":
				trace("Basegame new format stage");
				return {
					charPosition: [[100, 100], [770, 100], [400, 130]],
					defaultCamZoom: 0.9,
					elementsFront: [
						{
							name: "bg",
							image: Paths.image("stage/stageback"),
							animated: false,
							x: -600,
							y: -200,
							scaleX: 1,
							scaleY: 1,
							scrollX: 0.9,
							scrollY: 0.9,
							antialiasing: true,
							animations: null
						},
						{
							name: "stageFront",
							image: Paths.image("stage/stagefront"),
							animated: false,
							x: -650,
							y: 600,
							scaleX: 1,
							scaleY: 1,
							scrollX: 0.9,
							scrollY: 0.9,
							antialiasing: true,
							animations: null
						}
					],
					elementsBack: [
						{
							name: "stageCurtains",
							image: Paths.image("stage/stagecurtains"),
							animated: false,
							x: -500,
							y: -300,
							scaleX: 1,
							scaleY: 1,
							scrollX: 1.3,
							scrollY: 1.3,
							antialiasing: true,
							animations: null
						}
					]
				};
		}
		//the void
		trace("No stage found, you'll be put in the void >:)");
		return {
			charPosition: [[100, 100], [770, 100], [400, 130]],
			defaultCamZoom: 1,
			elementsFront: new Array<StageElement>(),
			elementsBack: new Array<StageElement>()
		};
	}

	public static function makeElements(elementsList:Array<StageElement>):FlxTypedGroup<FlxSprite> {
		var result:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		for (element in elementsList) {
			var sprite = new FlxSprite(element.x, element.y);
			sprite.antialiasing = element.antialiasing;
			if (element.animated) {
				sprite.frames = Paths.getSparrowAtlas(element.image);
				for (anim in element.animations) {
					Character.loadAnimation(sprite, anim);
				}
			} else {
				sprite.loadGraphic(element.image);
			}
			sprite.scale.x = element.scaleX;
			sprite.scale.y = element.scaleY;
			sprite.scrollFactor.x = element.scrollX;
			sprite.scrollFactor.y = element.scrollY;
			result.add(sprite);
		}
		return result;
	}

	//constructor
	public function new(?name:Null<String>, ?mod:Null<String>):Void {
		if (name == null) {
			return;
		}
		if (mod == null) {
			mod = PlayState.modName;
		}
		createStage(getStage(name, mod), this);
	}

	public static function createStage(data:Null<SwagStage>, ?target:Stage):Stage {
		if (data == null) {
			return new Stage();
		}
		if (target == null) {
			target = new Stage();
		}
		target.charPosition = data.charPosition;
		target.defaultCamZoom = data.defaultCamZoom;
		target.elementsFront = makeElements(data.elementsFront);
		target.elementsBack = makeElements(data.elementsBack);
		return target;
	}
}
