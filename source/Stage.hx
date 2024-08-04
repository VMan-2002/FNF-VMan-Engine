package;

import Character;
import Paths;
import ThingThatSucks.ErrorReportSubstate;
import flixel.group.FlxGroup.FlxTypedGroup;
#if !html5
import sys.FileSystem;
import sys.io.File;
#end

typedef StageElement = {
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
	var startVisible:Bool;
	var blendMode:Null<String>;
	var alpha:Null<Float>;
	var showInFast:Null<Bool>; //todo: i should add this into the options menu!!!!!!!!!!!!!!!
	var generateColor:Null<String>;
	var angle:Null<Float>;
}

typedef SwagStage = {
	var charPosition:Array<Array<Float>>;
	var defaultCamZoom:Null<Float>;
	var charZoom:Null<Array<Null<Float>>>;
	var elementsFront:Array<StageElement>;
	var elementsBack:Array<StageElement>;
	var elementsBetween:Array<StageElement>;
	var hide_girlfriend:Bool;
	var animFollowup:Array<Array<String>>;
	var cameraOffset:Null<Array<Array<Float>>>;
	var extraCamPos:Array<Array<Float>>;
	var charFacing:Null<Array<Int>>;
	var charBetween:Null<Array<Int>>;
	var library:Null<String>;
}

class Stage {
	public var charPosition:Array<Array<Float>>;
	public var charFacing:Array<Int>;
	public var defaultCamZoom:Float;
	public var elementsFront:FlxTypedGroup<SpriteVMan>;
	public var elementsBack:FlxTypedGroup<SpriteVMan>;
	public var elementsBetween:FlxTypedGroup<SpriteVMan>;
	public var elementsAll:Array<SpriteVMan>;
	public var elementsNamed:Map<String, SpriteVMan>;
	//public var namedElements:Map<String, FlxSprite>;
	public var hide_girlfriend:Bool;
	public var animFollowup:Map<String, String> = [
		"danceLeft" => "danceRight",
		"danceRight" => "danceLeft",
		"idle" => "idle"
	];
	public var cameraOffset:Array<Array<Float>> = [[0, 0, 0]];
	public var extraCamPos:Array<Array<Float>> = [[0, 0, 0]];
	public var charZoom:Array<Null<Float>>;
	public var charBetween:Null<Array<Int>>;
	public var library:String;
	public var myMod:String;
	public var name:String;

	public static function getStage(name:String, ?mod:Null<String>):Null<SwagStage> {
		if (mod == null) {
			mod = PlayState.modName == "" ? ModLoad.enabledMods[0] : PlayState.modName;
		}
		if (name != "emptyLoad") {
			//#if !VMAN_DEMO
			#if !html5
			var path:String = 'mods/${mod}/objects/stages/${name}.json';
			var isJson = FileSystem.exists(path);
			if (!isJson)
			#else
			var path:String;
			var isJson:Bool;
			#end
			{
				path = 'assets/objects/stages/${name}.json';
				#if !html5
				isJson = FileSystem.exists(path);
				#else
				isJson = Assets.exists(path);
				#end
			}
			if (isJson) {
				trace("Found json for custom stage "+name);
				#if !html5
				var json:SwagStage = cast CoolUtil.loadJsonFromString(File.getContent(path));
				#else
				var json:SwagStage = cast CoolUtil.loadJsonFromString(Assets.getText(path));
				#end
				return json;
			}
			//#end
			//your hardcoded stage would go here
			switch(name) {
				//weird fallbacks! because new FNF
				case "limoRide":
					return getStage("limo", mod);
				case "mainStage":
					return getStage("stage", mod);
				case "phillyTrain":
					return getStage("philly", mod);
				case "spookyMansion":
					return getStage("spooky", mod);
				case "mallXmas":
					return getStage("mall", mod);
				case "tankmanBattlefield":
					return getStage("tank", mod);
				case "poops":
					//nothing lol
			}
		}
		//the void
		ErrorReportSubstate.addError("No stage found for "+name+", you'll be put in the void");
		return {
			charPosition: [[770, 100], [100, 100], [400, 130]],
			defaultCamZoom: 1.05,
			elementsFront: new Array<StageElement>(),
			elementsBack: new Array<StageElement>(),
			elementsBetween: new Array<StageElement>(),
			hide_girlfriend: false,
			animFollowup: null,
			cameraOffset: null,
			charFacing: [0],
			charZoom: null,
			extraCamPos: new Array<Array<Float>>(),
			charBetween: [2],
			library: null
		};
	}

	public static function makeElements(elementsList:Null<Array<StageElement>>, ?stage:Stage):FlxTypedGroup<SpriteVMan> {
		if (elementsList == null)
			return new FlxTypedGroup<SpriteVMan>();
		var result:FlxTypedGroup<SpriteVMan> = new FlxTypedGroup<SpriteVMan>();
		for (element in elementsList) {
			if (element.showInFast == true) //null: always show
				continue;
			//todo: Makes stage elems appear depending on fast/fancy graphics
			
			/*
			if (((element.showInFast == true) == Options.fastGraphics) || ((element.showInFast == false) == !Options.fastGraphics))
				continue;
			*/
			var sprite = new SpriteVMan(element.x == null ? 0 : element.x, element.y == null ? 0 : element.y);
			sprite.moves = false;
			sprite.antialiasing = element.antialias != false;
			var colorGenArgs = element.generateColor != null ? element.generateColor.split(",") : null;
			if (colorGenArgs != null) {
				switch(colorGenArgs.length) {
					case 1: //solid color
						sprite.makeGraphic(8, 8, CoolUtil.parseColor(colorGenArgs[0]));
						sprite.scale.set(element.scaleX / 8, element.scaleY / 8);
					case 2: //vertical gradient
					case 3: //rotated gradient
					case 5: //something else
						if (colorGenArgs[0] == "rectangle") {
							//0: id
							//1: width
							//2: height
							//3: outline width
							//4: inner opacity
						}
				}
			} else {
				if (element.animated == true) {
					sprite.frames = Paths.getSparrowAtlas(element.image);
					for (anim in element.animations) {
						Character.loadAnimation(sprite, anim);
						if (anim.offset != null) {
							sprite.addOffset(anim.name, anim.offset[0], anim.offset[1]);
						}
					}
					sprite.playAvailableAnim([element.initAnim != null ? element.initAnim : "idle"]);
				} else {
					sprite.loadGraphic(Paths.image(element.image));
				}
				sprite.scale.x = element.scaleX == null ? 1 : Math.abs(element.scaleX);
				sprite.scale.y = element.scaleY == null ? 1 : Math.abs(element.scaleY);
			}
			if (element.scaleX != null && element.scaleX < 0)
				sprite.flipX = true;
			if (element.scaleY != null && element.scaleY < 0)
				sprite.flipY = true;
			sprite.scrollFactor.x = element.scrollX == null ? 1 : element.scrollX;
			sprite.scrollFactor.y = element.scrollY == null ? 1 : element.scrollY;
			sprite.visible = element.startVisible != false;
			sprite.angle = element.angle == null ? 0 : element.angle;
			if (element.blendMode != null) {
				switch(element.blendMode.toLowerCase()) {
					case "add" | "alpha" | "darken" | "difference" | "erase" | "hardlight" | "invert" | "layer" | "lighten" | "multiply" | "normal" | "overlay" | "screen" | "shader" | "subtract":
						sprite.blend = element.blendMode.toLowerCase();
					case "additive":
						sprite.blend = "add";
				}
			}
			sprite.alpha = element.alpha == null ? 1 : element.alpha;
			sprite.updateHitbox();
			result.add(sprite);
			if (stage != null)
				stage.elementsNamed.set(element.name, sprite);
		}
		return result;
	}

	//constructor
	public function new(?name:Null<String>, ?mod:Null<String>, ?loadLibNow:Bool = false):Void {
		if (name == null) {
			elementsFront = new FlxTypedGroup<SpriteVMan>();
			elementsBack = new FlxTypedGroup<SpriteVMan>();
			elementsBetween = new FlxTypedGroup<SpriteVMan>();
			elementsAll = new Array<SpriteVMan>();
			charFacing = [0];
			return;
		}
		if (mod == null) {
			mod = PlayState.modName;
		}
		new Scripting("objects/stages/"+name, mod, "Stage");
		new Scripting("objects/stages/"+name, "", "Stage"); //let basegame scripts exist :)
		var stageDat = getStage(name, mod);
		myMod = mod;
		this.name = name;
		if (loadLibNow)
			Paths.setCurrentLevel(stageDat.library);
		Scripting.runOnScripts("stageInit", [name, mod, createStage(stageDat, this)]);
	}

	public static function createStage(data:Null<SwagStage>, ?target:Stage):Stage {
		if (data == null)
			return new Stage();
		if (target == null)
			target = new Stage();
		target.library = data.library;
		target.charPosition = data.charPosition == null ? [[770,100],[100,100],[400,130]] : data.charPosition;
		target.charFacing = data.charFacing == null ? [0] : data.charFacing;
		target.defaultCamZoom = data.defaultCamZoom == null ? 1.05 : data.defaultCamZoom;
		target.elementsNamed = new Map<String, SpriteVMan>();
		target.elementsFront = makeElements(data.elementsFront, target);
		target.elementsBack = makeElements(data.elementsBack, target);
		target.elementsBetween = makeElements(data.elementsBetween, target);
		trace("elementsFront: "+(target.elementsFront.length)+", elementsBetween: "+(target.elementsBetween.length)+", elementsBack: "+(target.elementsBack.length));
		target.elementsAll = target.elementsBack.members.concat(target.elementsFront.members).concat(target.elementsBetween.members);
		target.hide_girlfriend = data.hide_girlfriend == true;
		target.cameraOffset = data.cameraOffset == null ? [] : data.cameraOffset;
		target.cameraOffset.push([0, 0, 0]);
		target.extraCamPos.push([0, 0]);
		if (data.animFollowup != null && data.animFollowup.length != 0) {
			for (thing in data.animFollowup) {
				target.animFollowup.set(thing[0], thing[1]);
			}
		}
		if (target.charZoom == null)
			target.charZoom = new Array<Null<Float>>();
		if (target.charBetween == null)
			target.charBetween = [2];
		return target;
	}
	
	//update stuff
	
	public function beatHit() {
		for (thing in elementsAll) {
			var animname = thing.animation.curAnim != null ? thing.animation.curAnim.name : "";
			if (animFollowup.exists(animname)) {
				thing.playAnim(animFollowup.get(animname), true);
			}
		}
	}
	
	public function playAnim(name:String, ?force:Bool = false) {
		for (thing in elementsAll) {
			if (thing.hasAnim(name)) {
				thing.playAnim(name, force);
			}
		}
	}

	public function destroy() {
		elementsFront.destroy();
		elementsBetween.destroy();
		elementsBack.destroy();
		elementsNamed.clear();
		elementsAll.resize(0);
		Scripting.clearScriptByID(myMod+":objects/stages/"+name);
	}
}
