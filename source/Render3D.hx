package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.geom.Vector3D;

class VeScene3D extends FlxObject {
	public var members:Array<VeObject3D>;

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
		if (visible) {
			//draw to the screen
		}
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

	public override function destroy() {
		super.destroy();
	}
}

class VeObject3D {
	public var moves:Bool = false;
	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	public var z(default, set):Float = 0;
	public var velocity:Vector3D; //what's a ctor?

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
	public function new(path:String, modName:String) {
		super();
	}
}

class VeFlxSprite3D extends VeObject3D {
	public var sprite:FlxSprite;
	public function new(sprite:FlxSprite) {
		this.sprite = sprite;
		super();
	}
}