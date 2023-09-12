package render3d;

import away3d.containers.View3D;
import away3d.entities.Mesh;
import away3d.events.Asset3DEvent;
import away3d.library.assets.Asset3DType;
import away3d.loaders.Loader3D;
import away3d.loaders.parsers.DAEParser;
import away3d.loaders.parsers.Max3DSParser;
import away3d.loaders.parsers.OBJParser;
import away3d.materials.TextureMaterial;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.events.Event;
import openfl.geom.Vector3D;
import sys.io.File;

using StringTools;

//todo: The Third Dimension
class VeScene3D extends FlxObject {
	public var members:Array<VeObject3D>;
	public var view3d:View3D;

	public override function new(?x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
		if (width == 0)
			width = FlxG.width;
		if (height == 0)
			height = FlxG.height;
		super(x, y, width, height);

		solid = false;
		moves = false;
		
		view3d = new View3D();
		sceneViews = CoolUtil.addToArrayPossiblyNull(sceneViews, this);
		updateScale();
	}

	public override function draw() {
		if (visible)
			view3d.render();
		super.draw();
	}

	public function add(thing:VeObject3D) {
		if (!members.contains(thing)) {
			members.push(thing);
			thing.addTo(this);
		}
	}

	public function remove(thing:VeObject3D) {
		if (members.remove(thing))
			thing.removeFrom(this);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
	}

	//haxe, when can we have override vars so i can add setter functions for such vars :pleading_face:
	//like
	//
	//public override var x(default, set):Float = 0.0;
	//
	//function set_x(value:Float):Float {
	//	x = value;
	//	updatePosition();
	//	return value;
	//}
	
	public override function setSize(width:Float, height:Float) {
		super.setSize(width, height);
		updateScale();
	}

	public inline function updateScale() {
		view3d.width = width * renderScale;
		view3d.height = height * renderScale;
	}

	public override function setPosition(x:Float = 0.0, y:Float = 0.0) {
		super.setPosition(x, y);
		updatePosition();
	}

	public override function reset(x:Float, y:Float) {
		super.reset(x, y);
		updatePosition();
	}

	public inline function updatePosition() {
		view3d.x = (x * renderScale) + renderOffsetX;
		view3d.y = (y * renderScale) + renderOffsetY;
	}

	public override function destroy() {
		sceneViews.remove(this);
		view3d.dispose();
		super.destroy();
	}

	/**
		Used to create alternate views , like if you need to render the same scene twice with different cameras.

		`view3d.scene`, `view3d.renderer` and `members` are linked together
	**/
	public function clone(?x:Float, ?y:Float, ?width:Float, ?height:Float) {
		var cloned = new VeScene3D(x, y, width, height);
		cloned.view3d.scene = view3d.scene;
		cloned.view3d.renderer = view3d.renderer;
		cloned.members = members;
	}

	public static var sceneViews:Array<VeScene3D> = null;
	public static var renderScale:Float;
	public static var renderOffsetX:Float;
	public static var renderOffsetY:Float;

	public static function onResize(evt:Event) {
		renderScale = Math.min(FlxG.stage.width / FlxG.width, FlxG.stage.height / FlxG.height);
		renderOffsetX = CoolUtil.positionValueWithin(FlxG.width * renderScale, FlxG.stage.width, 0.5);
		renderOffsetY = CoolUtil.positionValueWithin(FlxG.height * renderScale, FlxG.stage.height, 0.5);
		if (sceneViews == null)
			return;
		for (thing in sceneViews)
			thing.updateScale();
	}
}

class VeObject3D {
	public var moves:Bool = false;
	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	public var z(default, set):Float = 0;
	public var velocity:Vector3D; //what's a locity? what's a ctor?

	public function new(?x:Float = 0, ?y:Float = 0, ?z:Float = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
		velocity = new Vector3D();
	}

	function set_x(value:Float):Float {
		return x = value;
	}

	function set_y(value:Float):Float {
		return y = value;
	}

	function set_z(value:Float):Float {
		return z = value;
	}

	public function update(elapsed:Float) {
		if (moves) {
			x += velocity.x * elapsed;
			y += velocity.y * elapsed;
			z += velocity.z * elapsed;
		}
	}

	public function addTo(scene:VeScene3D) {}

	public function removeFrom(scene:VeScene3D) {}

	//No draw function because Scene3D handles that shit
}

class VeModel3D extends VeObject3D {
	public var object:Mesh;
	public var onModelLoad:VeModel3D->Void = null;
	public var onMaterialLoad:VeModel3D->Void = null;

	public function new() {
		super();
		loader.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
	}

	//public static var parserDae:DAEParser = null;
	//public static var parser3ds:Max3DSParser = null;
	//public static var parserObj:OBJParser = null;
	public var loader = new Loader3D();

	public function loadModel(path:String, modName:String, type:String, ?onLoaded:VeModel3D->Void = null) {
		var filepath = 'mods/${modName}/models/${path}';
		onModelLoad = onLoaded;
		/*switch(type.toLowerCase()) {
			case "dae" | ".dae":
				filepath += ".dae";
				if (parserDae == null)
					parserDae = new DAEParser();
			case "3ds" | ".3ds":
				filepath += ".3ds";
				if (parser3ds == null)
					parser3ds = new Max3DSParser(true);
			default:
				filepath += ".obj";
				if (parserObj == null)
					parserObj = new OBJParser();
		}*/
		loader.loadData(File.getBytes(filepath));
	}

	public function loadTexture(path:String, modName:String, type:String, ?onLoaded:VeModel3D->Void = null) {
		var filepath = 'mods/${modName}/models/${path}';
		onMaterialLoad = onLoaded;
		loader.loadData(File.getBytes(filepath));
	}

	public static function destroyParsers() {
		//parserDae = null;
		//parser3ds = null;
		//parserObj = null;
	}

	public function onAssetComplete(e:Event) {
		var event:Asset3DEvent = cast(e, Asset3DEvent);
		if (event.asset.assetType == Asset3DType.MESH) {
			object = cast(event.asset, Mesh);
		} else if (event.asset.assetType == Asset3DType.MATERIAL) {
			var material:TextureMaterial = cast(event.asset, TextureMaterial);
		}
	}

	public override function addTo(scene:VeScene3D) {
		scene.view3d.scene.addChild(loader);
	}

	public override function removeFrom(scene:VeScene3D) {
		scene.view3d.scene.removeChild(loader);
	}
}

class VeFlxSprite3D extends VeObject3D {
	public var sprite:FlxSprite;
	public function new(sprite:FlxSprite) {
		this.sprite = sprite;
		super();
	}
}