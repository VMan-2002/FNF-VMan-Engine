package;

#if desktop
import Discord.DiscordClient;
#end
import CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;

using StringTools;
#if polymod
import polymod.Polymod.Framework;
import polymod.Polymod;
#if !html5
import sys.io.File;
#end
#end


class IntroTextTest extends MusicBeatState
{
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var titleGroup:FlxGroup;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	
	var doCoolText = true;

	var wackyNum = 0;
	
	public static var enabledMods = new Array<String>();

	override public function create():Void
	{
		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		credGroup = new FlxGroup();
		add(credGroup);
		createCoolText(getIntroTextShit()[0]);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var firstArray:Array<String> = CoolUtil.uncoolTextFile("data/introText");
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	override function update(elapsed:Float)
	{
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		var wackyChanged = false;

		if (controls.LEFT_P || controls.UP_P) {
			wackyNum -= 1;
			wackyChanged = true;
		}

		if (controls.RIGHT_P || controls.DOWN_P) {
			wackyNum += 1;
			wackyChanged = true;
		}

		if (wackyChanged) {
			var things = getIntroTextShit();
			wackyNum = wackyNum % things.length;
			if (wackyNum < 0)
				wackyNum += things.length;
			trace("wacky is now " + wackyNum);
			deleteCoolText();
			createCoolText(things[wackyNum]);
		}

		if (pressedEnter || controls.BACK) {
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			//textGroup.add(money);
		}
	}

	function deleteCoolText()
	{
		while (credGroup.members.length > 0)
		{
			credGroup.remove(credGroup.members[0], true);
			//textGroup.remove(textGroup.members[0], true);
		}
	}
}
