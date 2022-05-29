package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
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

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
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
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
	
	//Script Stuff
	public var luaScripts = new Array<LuaScript>();
	
	public function initLua():Void {
		var scriptType = Type.getClassName(Type.getClass(this));
		trace('starting lua for ${scriptType}');
		luaScripts.push(new LuaScript('mods/${ModLoad.primaryMod}/scripts/${scriptType}'));
		if (scriptType == "PlayState") {
			//load song/character/stage/etc stuff
			//Song
			luaScripts.push(new LuaScript('mods/${ModLoad.primaryMod}/data/${Highscore.formatSong(PlayState.SONG.song)}/script'));
			//Characters
			for (i in Character.activeArray) {
				luaScripts.push(new LuaScript('mods/${i.myMod}/objects/characters/${i.curCharacter}'));
			}
			//Stage
			luaScripts.push(new LuaScript('mods/${ModLoad.primaryMod}/objects/stages/${i.curCharacter}'));
		}
	}
}
