package;

import flixel.FlxG;
import flixel.FlxObject;
import openfl.geom.Vector3D;

class Scene3D extends FlxObject {
	public var members:Array<Object3D>;

	public override function new(?x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
		if (width == 0)
			width = FlxG.width;
		if (height == 0)
			height = FlxG.height;
		super(x, y, width, height);

		solid = false;
		moves = false;
	}

	public override function draw() {
		
	}

	public function add(thing:Object3D) {
		members.push(thing);
		thing.addTo(this);
	}

	public function remove(thing:Object3D) {

	}
}

class Object3D {
	public var moves:Bool = false;
	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	public var z(default, set):Float = 0;
	public var velocity:Vector3D;

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

	public function addTo(scene:Scene3D) {}

	public function removeFrom(scene:Scene3D) {}

	//No draw function because Scene3D handles that shit
}

class Model3D extends Object3D {
	public function new(path:String, modName:String) {
		super();
	}
}