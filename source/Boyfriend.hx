package;

class Boyfriend extends Character {
	@:deprecated("Use Character instead")
	public function new(x:Float, y:Float, ?char:String = 'bf', ?modName:String, ?isPlayer:Bool = true) {
		super(x, y, char, isPlayer, modName, true, true);
	}
}