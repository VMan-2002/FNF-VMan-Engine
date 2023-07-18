package;

import Conductor.BPMChangeEvent;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import openfl.events.KeyboardEvent;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		Scripting.clearScriptsByContext("PlayStateSong");
		
		if (transIn != null)
			trace('reg ' + transIn.region);

		Conductor.offset = Options.offset;

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
		if (members.contains(old)) {
			return replace(old, put);
		}
		return add(put);
	}

	public function switchToThis() {
		FlxG.state.switchTo(this);
	}
	
	//Script Stuff
	//We dont need this anymore because hscript
	#if !html5
	/*public var luaScripts = new Array<LuaScript>();
	public var luaSprites = new Array<FlxSprite>();
	
	public function initLua():Void {*/
		//todo: get lua shit working first and THEN do this
		/*var scriptType = Type.getClassName(Type.getClass(this));
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
			luaScripts.push(new LuaScript('mods/${ModLoad.primaryMod}/objects/stages/${PlayState.curStage}'));
		}*/
		//addKeyboardCallbacks();
	/*}

	inline function addKeyboardCallbacks() {
		FlxG.stage.addEventListener("onKeyDown", luaPressKey);
		FlxG.stage.addEventListener("onKeyUp", luaReleaseKey);
	}

	public function runLuaCallback(name:String, ?args:Null<Array<Dynamic>>) {
		for (luaThing in luaScripts) {
			luaThing.runFunction(name, args);
		}
	}

	public function luaPressKey(ev:KeyboardEvent) {
		runLuaCallback("onKeyPressed", [ev.keyCode, ev.charCode]);
	}

	public function luaReleaseKey(ev:KeyboardEvent) {
		runLuaCallback("onKeyReleased", [ev.keyCode, ev.charCode]);
	}

	public override function destroy() {
		FlxG.stage.removeEventListener("onKeyDown", luaPressKey);
		FlxG.stage.removeEventListener("onKeyUp", luaReleaseKey);
		super.destroy();
	}*/
	#end
}
