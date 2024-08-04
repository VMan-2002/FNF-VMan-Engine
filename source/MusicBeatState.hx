package;

import Conductor.BPMChangeEvent;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIState;
import flixel.group.FlxGroup.FlxTypedGroup;

class MusicBeatState extends FlxUIState {
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var controls(get, never):Controls;

	/**
		Group that is on top of everything else, unless something is `insert`ed at the end (but not `add`ed)
	**/
	public var overlayGroup:FlxTypedGroup<FlxBasic> = null;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		Scripting.clearScriptsByContext("PlayStateSong");
		Paths2.dumpCache();
		
		if (transIn != null)
			trace('reg ' + transIn.region);

		Conductor.offset = Options.offset;

		super.create();
		overlayGroup = cast insert(members.length, new FlxTypedGroup<FlxBasic>());
	}

	override function update(elapsed:Float) {
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (curStep > 0){
			while (oldStep < curStep) {
				stepHit();
				oldStep++;
			}
		}

		super.update(elapsed);
	}

	private function updateBeat():Void {
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void {
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {
		Scripting.runOnScripts("beatHit", [curBeat]);
		//do literally nothing dumbass
	}

	public var isSubStateActive:Bool = false;

	public override function openSubState(a:FlxSubState) {
		isSubStateActive = true;
		super.openSubState(a);
	}

	public override function closeSubState() {
		isSubStateActive = false;
		super.closeSubState();
	}

	/**
		If `old` exists, replace it with `put`, otherwise just add `put`
	**/
	public function addOrReplace(old:FlxBasic, put:FlxBasic) {
		if (members.contains(old))
			return replace(old, put);
		return add(put);
	}

	public function switchToThis() {
		FlxG.state.switchTo(this);
	}

	/**
		Add an object to state
	**/
	public override function add(obj:FlxBasic) {
		if (members.contains(null) || overlayGroup == null)
			return super.add(obj);
		return super.insert(members.indexOf(overlayGroup), obj);
	}
}
