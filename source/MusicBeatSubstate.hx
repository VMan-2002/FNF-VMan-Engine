package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (curStep > 0){
			while (oldStep < curStep) {
				stepHit();
				oldStep++;
			}
		}

		super.update(elapsed);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void {
		if (curStep % 4 == 0)
			beatHit();
		Scripting.runOnScripts("stepHit", [curStep]);
	}

	public function beatHit():Void {
		//do literally nothing dumbass
		Scripting.runOnScripts("beatHit", [curBeat]);
	}

	/**
		`top`: Open this substate on top of the topmost current substate, otherwise open it on `FlxG.state` which may not work if a substate is already active
	**/
	public function openThis(?top:Bool = false) {
		if (top && subState != null) {
			var a = subState;
			while (a.subState != null)
				a = a.subState;
			a.openSubState(this);
		} else {
			FlxG.state.openSubState(this);
		}
		return this;
	}
}
