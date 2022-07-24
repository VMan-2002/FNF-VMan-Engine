package;

import Character.SwagCharacterAnim;
import Character;
import Paths;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import io.newgrounds.NGLite;
import sys.FileSystem;
import sys.io.File;

typedef StageElement =
{
	var name:String;
	var image:String;
	var animated:Bool;
	var x:Null<Float>;
	var y:Null<Float>;
	var scaleX:Null<Float>;
	var scaleY:Null<Float>;
	var scrollX:Null<Float>;
	var scrollY:Null<Float>;
	var antialias:Bool;
	var animations:Null<Array<SwagCharacterAnim>>;
	var initAnim:String;
}

typedef SwagStage =
{
	var charPosition:Array<Array<Float>>;
	var defaultCamZoom:Null<Float>;
	var elementsFront:Array<StageElement>;
	var elementsBack:Array<StageElement>;
}

class Stage
{
	public var charPosition:Array<Array<Float>>;
	public var defaultCamZoom:Float;
	public var elementsFront:FlxTypedGroup<FlxSprite>;
	public var elementsBack:FlxTypedGroup<FlxSprite>;
	public var elementsAll:Array<FlxSprite>;
	//public var namedElements:Map<String, FlxSprite>;
	public static var animFollowup:Map<String, String> = [
		"danceLeft" => "danceRight",
		"danceRight" => "danceLeft",
		"idle" => "idle"
	];

	public static function getStage(name:String, ?mod:Null<String>):Null<SwagStage> {
		if (mod == null) {
			mod = PlayState.modName == "" ? ModLoad.enabledMods[0] : PlayState.modName;
		}
		//#if !VMAN_DEMO
		var path:String = 'mods/${mod}/objects/stages/${name}.json';
		var isJson = FileSystem.exists(path);
		if (!isJson) {
			path = 'assets/objects/stages/${name}.json';
			isJson = FileSystem.exists(path);
		}
		if (isJson) {
			trace("Found json for custom stage "+name);
			var json:SwagStage = cast CoolUtil.loadJsonFromString(File.getContent(path));
			return json;
		}
		//#end
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
					elementsBack: [
						{
							name: "bg",
							image: "stage/stageback",
							animated: false,
							x: -600,
							y: -200,
							scaleX: 1,
							scaleY: 1,
							scrollX: 0.9,
							scrollY: 0.9,
							antialias: true,
							animations: null,
							initAnim: null
						},
						{
							name: "stageFront",
							image: "stage/stagefront",
							animated: false,
							x: -650,
							y: 600,
							scaleX: 1,
							scaleY: 1,
							scrollX: 0.9,
							scrollY: 0.9,
							antialias: true,
							animations: null,
							initAnim: null
						}
					],
					elementsFront: [
						{
							name: "stageCurtains",
							image: "stage/stagecurtains",
							animated: false,
							x: -500,
							y: -300,
							scaleX: 1,
							scaleY: 1,
							scrollX: 1.3,
							scrollY: 1.3,
							antialias: true,
							animations: null,
							initAnim: null
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

	public static function makeElements(elementsList:Null<Array<StageElement>>):FlxTypedGroup<FlxSprite> {
		if (elementsList == null) {
			return new FlxTypedGroup<FlxSprite>();
		}
		var result:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		for (element in elementsList) {
			var sprite = new FlxSprite(element.x == null ? 0 : element.x, element.y == null ? 0 : element.y);
			sprite.antialiasing = element.antialias != false;
			if (element.animated) {
				sprite.frames = Paths.getSparrowAtlas(element.image);
				for (anim in element.animations) {
					Character.loadAnimation(sprite, anim);
				}
			} else {
				sprite.loadGraphic(Paths.image(element.image));
			}
			sprite.scale.x = element.scaleX == null ? 1 : element.scaleX;
			sprite.scale.y = element.scaleY == null ? 1 : element.scaleY;
			sprite.scrollFactor.x = element.scrollX == null ? 1 : element.scrollX;
			sprite.scrollFactor.y = element.scrollY == null ? 1 : element.scrollY;
			if (element.animated && element.initAnim != null) {
				sprite.animation.play(element.initAnim);
			}
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
		target.defaultCamZoom = data.defaultCamZoom == null ? 1 : data.defaultCamZoom;
		target.elementsFront = makeElements(data.elementsFront);
		target.elementsBack = makeElements(data.elementsBack);
		target.elementsAll = target.elementsBack.members.concat(target.elementsFront.members);
		return target;
	}
	
	//update stuff
	
	public function beatHit() {
		for (thing in elementsAll) {
			var animname = thing.animation.curAnim != null ? thing.animation.curAnim.name : "";
			if (animFollowup.exists(animname)) {
				thing.animation.play(animFollowup.get(animname), true);
			}
		}
	}
	
	public function playAnim(name:String, ?force:Bool = false) {
		for (thing in elementsAll) {
			if (thing.animation.getNameList().indexOf(name) >= 0) {
				thing.animation.play(name, force);
			}
		}
	}
}
