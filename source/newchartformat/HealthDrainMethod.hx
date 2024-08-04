package newchartformat;

import flixel.math.FlxMath;
import PlayState;
import Note;
import Scripting;

class HealthDrainMethodNone {
	public function new() {}
	
	public function setAttribute(num:Int, val:Float) {}
	
	public function opponentNoteHit(note:Note, state:PlayState) {
		//do nothing
		return state.health;
	}
}

class HealthDrainMethodFatal extends HealthDrainMethodNone {
	public var amount:Float = 0.02;
	
	public override function setAttribute(num:Int, val:Float) {
		switch(num) {
			case 0:
				amount = val;
		}
	}
	
	public override function opponentNoteHit(note:Note, state:PlayState) {
		return state.health -= amount;
	}
}

class HealthDrainMethod extends HealthDrainMethodFatal {
	public static function getHealthDrainMethod(name:String):HealthDrainMethodNone {
		switch(name.toLowerCase()) {
			case "fatal":
				return new HealthDrainMethodFatal();
			case "normal":
				return new HealthDrainMethod();
			case "script":
				return new HealthDrainMethodCustom();
			case "enforcer":
				return new HealthDrainMethodEnforcer();
			case "smoothenforcer":
				return new HealthDrainMethodSmoothEnforcer();
			case "multiplyaddfatal":
				return new HealthDrainMethodMultiplyAddFatal();
			case "multiplyadd":
				return new HealthDrainMethodMultiplyAdd();
		}
		return new HealthDrainMethodNone();
	}
	
	public var min:Float = 0.05;
	
	public override function setAttribute(num:Int, val:Float) {
		switch(num) {
			case 0:
				amount = val;
			case 1:
				min = val;
		}
	}
	
	public override function opponentNoteHit(note:Note, state:PlayState) {
		if (state.health > min)
			return state.health = Math.max(min, state.health - amount);
		return state.health;
	}
}

class HealthDrainMethodCustom extends HealthDrainMethod {
	public dynamic function healthDrainFunc(note:Note, state:PlayState) {
		return state.health;
	}

	public override function setAttribute(num:Int, val:Float) {
		Scripting.runOnScripts("customHealthDrainMethod", [this, num, val]);
	}
	
	public override function opponentNoteHit(note:Note, state:PlayState) {
		return healthDrainFunc(note, state);
	}
}

class HealthDrainMethodEnforcer extends HealthDrainMethod {
	public var threshold:Float = 1.5;
	public var thresholdAmount:Float = 0.1;
	
	function override opponentNoteHit(note:Note, state:PlayState) {
		if (state.health > threshold)
			return state.health = Math.max(min, state.health - threshold);
		return super.opponentNoteHit(note, state);
	}
}

class HealthDrainMethodSmoothEnforcer extends HealthDrainMethod {
	public var threshold:Float = 1.5;
	public var thresholdTop:Float = 1.75;
	public var thresholdAmount:Float = 0.1;
	
	function override opponentNoteHit(note:Note, state:PlayState) {
		if (state.health > threshold)
			return state.health = Math.max(min, state.health - FlxMath.lerp(FlxMath.bound(FlxMath.remapToRange(state.health, threshold, thresholdTop, 0, 1), 0, 1), amount, thresholdAmount));
		return super.opponentNoteHit(note, state);
	}
}

class HealthDrainMethodMultiplyAddFatal extends HealthDrainMethodFatal {
	public var offset:Float = 0.01;
	
	public override function new() {
		super();
		amount = 0.975;
	}
	
	public override function setAttribute(num:Int, val:Float) {
		switch(num) {
			case 0:
				amount = val;
			case 1:
				offset = val;
		}
	}
	
	public override function opponentNoteHit(note:Note, state:PlayState) {
		return state.health = (state.health * amount) - offset;
	}
}

class HealthDrainMethodMultiplyAdd extends HealthDrainMethodMultiplyAddFatal {
	public var min:Float = 0.05;
	
	public override function setAttribute(num:Int, val:Float) {
		switch(num) {
			case 0:
				amount = val;
			case 1:
				offset = val;
			case 2:
				min = val;
		}
	}
	
	public override function opponentNoteHit(note:Note, state:PlayState) {
		if (state.health > min)
			return state.health = Math.max(min, (state.health * amount) - offset);
		return state.health;
	}
}