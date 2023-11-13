package new_options;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

class NewOptionsMenu extends MusicBeatState {
	var selector:FlxText;
	var curSelected:Int = 0;
	public static var wasInPlayState:Bool = false;

	//i deleted controls.txt so i cant use this
	//var controlsStrings:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	
	private var launchSubstate:Null<MusicBeatSubstate>;
	private var highlightOption:Null<String>;
	public var menuBG:FlxSprite;
	public var optionsCategory:NewOptionsCategoryBasic;
	
	
	public function new(?substate:Null<MusicBeatSubstate>, ?highlight:String) {
		launchSubstate = substate;
		highlightOption = highlight;
		super();
	}

	override function create() {
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		
		menuBG = CoolUtil.makeMenuBackground('Desat');
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		super.create();

		var newSubState:MusicBeatSubstate = launchSubstate == null ? new OptionsSubState() : launchSubstate;
		openSubState(newSubState);
		if (Std.isOfType(newSubState, OptionsSubStateBasic) && highlightOption != null) {
			var thing:OptionsSubStateBasic = cast newSubState;
			if (thing.textMenuItems.contains(highlightOption)) {
				thing.moveSelection(thing.textMenuItems.indexOf(highlightOption));
			}
		}
		launchSubstate = null;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		#if !switch
		//NGio.logEvent('Fresh');
		#end

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function setCategory() {

	}
}
