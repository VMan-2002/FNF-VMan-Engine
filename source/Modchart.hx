package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.OneOfThree;

using StringTools;

typedef ModchartEvent = {
	time:Float,
	e:Dynamic,
	t:Int,
	n:Array<Bool>,
	l:Array<Bool>
}

typedef ModchartMathEvent = {
	x:String,
	y:String,
	xs:String,
	ys:String,
	r:String,
	length:String
}

typedef ModchartTweenEvent = {
	x:Null<Float>,
	y:Null<Float>,
	xs:Null<Float>,
	ys:Null<Float>,
	r:Null<Float>,
	length:Float,
	ease:String
}

typedef ModchartEffectEvent = {
	type:String,
	length:Float,
	ease:String
}

typedef ModchartSetEvent = {
	x:Null<Float>,
	y:Null<Float>,
	s:Null<Float>,
	xs:Null<Float>,
	ys:Null<Float>,
	r:Null<Float>
}

typedef ModchartRelSetEvent = {
	x:Null<Float>,
	y:Null<Float>,
	s:Null<Float>,
	xs:Null<Float>,
	ys:Null<Float>,
	r:Null<Float>
}

class Modchart {
	var runEffects:Bool = false;
	var effectStrength:Map<String, Float> = new Map<String, Float>();
	public var modchartEvents:Array<ModchartEvent>;
	var myState:PlayState;
	public var nextNum:Int = 0;
	public var nextTime:Float = -1;
	
	public function new(daState:PlayState) {
		myState = daState;
	}

	public function sort() {
		modchartEvents.sort(function(a, b) {
			return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
		});
	}

	public function update() {
		while (nextTime <= Conductor.songPosition) {
			runEvent(modchartEvents[nextNum]);
			nextNum += 1;
			nextTime = modchartEvents[nextNum].time;
		}
		if (runEffects) {
			
		}
	}

	//I dont know whati m doing
	//this is likely a bad way of doing this

	public function runEvent(ev:Dynamic) {
		switch(ev.t) {
			case 0: //Math event
			
			case 1: //Tween event
			
			case 2: //Effect event
			
			case 3: //Set event
			var evdat:ModchartSetEvent = ev.e;
			doStrumStuff(ev, function(ev, l, n, strumnote) {
				if (evdat.x != null) {
					strumnote.x = evdat.x;
				}
				if (evdat.y != null) {
					strumnote.y = evdat.y;
				}
				if (evdat.s != null) {
					strumnote.scale.set(evdat.s, evdat.s);
				} else {
					if (evdat.xs != null) {
						strumnote.scale.x = evdat.xs;
					}
					if (evdat.ys != null) {
						strumnote.scale.y = evdat.ys;
					}
				}
				if (evdat.r != null) {
					strumnote.angle = evdat.r;
				}
			});
			case 4: //Set relative event
			var evdat:ModchartRelSetEvent = ev.e;
			doStrumStuff(ev, function(ev, l, n, strumnote) {
				if (evdat.x != null) {
					strumnote.x += evdat.x;
				}
				if (evdat.y != null) {
					strumnote.y += evdat.y;
				}
				if (evdat.s != null) {
					strumnote.scale.x += evdat.s;
					strumnote.scale.y += evdat.s;
				}
				if (evdat.xs != null) {
					strumnote.scale.x += evdat.xs;
				}
				if (evdat.ys != null) {
					strumnote.scale.y += evdat.ys;
				}
				if (evdat.r != null) {
					strumnote.angle += evdat.r;
				}
			});
		}
	}

	inline function doStrumStuff(ev:Dynamic, func:(Dynamic, Int, Int, StrumNote)->Void) {
		var num = 0;
		var line = 0;
		while(line < myState.strumLines.length) {
			if (ev.l[line]) {
				while(num < myState.strumLines.members[line].length) {
					if (ev.n[num]) {
						func(ev, line, num, myState.strumLines.members[line].members[num]);
					}
					num++;
				}
			}
			line++;
		}
	}
}
