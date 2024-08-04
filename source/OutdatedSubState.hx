package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Http;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState {
	public static var leftState:Bool = false;
	public var minPos:Float = 40;
	public var maxPos:Float = 40;
	public var scrollable:Bool;
	public var changelogText:FlxText;
	public var versionStr:String;

	public function new(versionStr:String) {
		this.versionStr = versionStr;
		super();
	}

	override function create() {
		super.create();

		var bg:FlxSprite = new FlxSprite(0, 0, Paths2.image("menu/update_bg", "shared/images/"));
		bg.scale.x = FlxG.width / bg.frameWidth;
		bg.scale.y = bg.scale.x;
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFF858585;
		add(bg);

		changelogText = new FlxText(0, minPos, FlxG.width, 'Changes in v${versionStr}' + "\n\n" + Http.requestUrl("https://raw.githubusercontent.com/VMan-2002/FNF-VMan-Engine/master/version/vman_engine_changelog.txt"), 8).setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(changelogText);

		minPos = Math.min((maxPos + FlxG.height) - (changelogText.textField.textHeight + 60), maxPos);
		trace("Min pos "+minPos);
		trace("Max pos "+maxPos);
		scrollable = minPos != maxPos;
		if (!scrollable) {
			changelogText.screenCenter(Y);
			changelogText.y += 11;
		}

		var ver = "v" + Main.gameVersionInt;
		var bar = new FlxSprite().makeGraphic(FlxG.width, 22, FlxColor.BLACK);
		bar.alpha = 0.75;
		add(bar);
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Outdated Version! (You have "+Main.gameVersionNoSubtitle+") | Accept: Go to Download | Back: Ignore for this session",
			8);
		txt.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER);
		txt.screenCenter(X);
		add(txt);
	}

	override function update(elapsed:Float) {
		if (controls.ACCEPT) {
			FlxG.openURL("https://github.com/VMan-2002/FNF-VMan-Engine/releases/latest");
		}
		if (controls.BACK) {
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		
		if (scrollable) {
			var scroll:Float = (FlxG.mouse.wheel * 32);
			if (controls.UP)
				scroll += elapsed * 120;
			if (controls.DOWN)
				scroll -= elapsed * 120;

			changelogText.y = CoolUtil.clamp(changelogText.y + scroll, minPos, maxPos);
		}
		
		super.update(elapsed);
	}
}
