package;

import Discord.DiscordClient;
import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import sys.FileSystem;
import sys.io.File;

typedef CreditsFile = {
	credits:Array<CreditsEntry>,
	title:String
}

typedef CreditsEntry = {
	order:Int,
	name:String,
	description:String,
	funny:Array<String>,
	icon:String,
	link:String
}

class CreditsState extends MusicBeatState {
	public var creditsStuffs:Array<FlxTypedSpriteGroup<FlxSpriteGroup>> = new Array<FlxTypedSpriteGroup<FlxSpriteGroup>>();
	public var creditsInfo:Array<Array<CreditsEntry>> = new Array<Array<CreditsEntry>>();
	public var scrollableTitles:FlxTypedSpriteGroup<FlxText> = new FlxTypedSpriteGroup<FlxText>();
	public var curSelected:Int = 0;
	public var curSelectedSection:Int = 0;
	public var funnyBar:FlxSpriteGroup = new FlxSpriteGroup();

	public var currentCreditsThing:FlxTypedSpriteGroup<FlxSpriteGroup>;
	public var inTabber:Bool = false;
	public var descText:FlxText = new FlxText(0, FlxG.height - 50, FlxG.width, "Coolest mfer fuckin ever????").setFormat("VCR OSD Mono", 32).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 0.5);
	public var funnyText:FlxText = new FlxText(0, 0, FlxG.width - 220, "Lol").setFormat("VCR OSD Mono", 16).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 0);

	public override function new() {
		super();
		loadCreditsJsonString(Assets.getText(Paths.getLibraryPath("credits_inbuilt/credits_inbuilt/credits.json")));
		for (cool in ModLoad.enabledMods) {
			var path = 'mods/${cool}/objects/credits/credits.json';
			if (FileSystem.exists(path)) {
				trace("load credits of "+cool);
				loadCreditsJson(path, cool);
			}
		}
	}

	public override function create() {
		super.create();
		
		var bg:FlxSprite = CoolUtil.makeMenuBackground('Blue');
		add(bg);

		funnyBar.add(new FlxSprite().makeGraphic(FlxG.width, 40, FlxColor.BLACK));
		funnyBar.members[0].alpha = 0.5;
		funnyBar.add(scrollableTitles);

		showCreditsThing(0);

		add(funnyBar);
		funnyBar.y = -40;
		var hintText = new FlxText(0, 41, 0, Translation.getTranslation("switch category hint", "credits", [Options.getUIControlName("reset"), Options.getUIControlName("gtstrum")], "Reset/GTStrum: Switch category"), 16).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyBar.add(hintText);
		Translation.setObjectFont(hintText);
		add(funnyText);

		add(descText);
	}

	public function showCreditsThing(num:Int) {
		curSelectedSection = num % creditsStuffs.length;
		if (curSelectedSection < 0) {
			curSelectedSection = creditsStuffs.length - 1;
		}
		scrollableTitles.members[curSelectedSection].color = FlxColor.YELLOW;
		addOrReplace(currentCreditsThing, creditsStuffs[curSelectedSection]);
		curSelected = 0;
		currentCreditsThing = creditsStuffs[curSelectedSection];
		updateDesc();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresenceSimple("credits", scrollableTitles.members[curSelectedSection].text);
		#end
	}

	public inline function loadCreditsJson(path:String, ?mod:Null<String>) {
		loadCreditsJsonString(File.getContent(path), mod);
	}

	public function loadCreditsJsonString(stuff:String, ?mod:Null<String>) {
		var creditsFile:CreditsFile = CoolUtil.loadJsonFromString(stuff);
		addCreditsStuff(creditsFile.title, creditsFile.credits, mod);
	}

	public function toggleTabber() {
		inTabber = !inTabber;
		trace(inTabber ? "tabber is now On" : "tabber is now Off");
		FlxTween.cancelTweensOf(funnyBar);
		FlxTween.tween(funnyBar, {y: inTabber ? 0 : -40}, 0.25, {ease: FlxEase.cubeOut});
	}

	public override function update(elapsed:Float) {
		if (inTabber) {
			if (controls.BACK || controls.RESET || controls.GTSTRUM) {
				toggleTabber();
			} else if (controls.LEFT_P != controls.RIGHT_P) {
				scrollableTitles.members[curSelectedSection].color = FlxColor.WHITE;
				if (controls.LEFT_P) {
					showCreditsThing(curSelectedSection - 1);
				}
				if (controls.RIGHT_P) {
					showCreditsThing(curSelectedSection + 1);
				}
			}
		} else {
			if (controls.BACK) {
				MainMenuState.returnToMenuFocusOn("credits");
			}
			if (controls.RESET || controls.GTSTRUM) {
				toggleTabber();
			}
			if (controls.UP_P) {
				moveSelection(-1);
			}
			if (controls.DOWN_P) {
				moveSelection(1);
			}
			if (controls.ACCEPT) {
				var urlToOpen = creditsInfo[curSelectedSection][curSelected].link;
				if (urlToOpen != null && urlToOpen != "") {
					FlxG.openURL(urlToOpen);
				}
			}
		}

		currentCreditsThing.forEach(function(a) {
			var n = currentCreditsThing.members.indexOf(a);
			var targetX = curSelected == n ? 75 : 0;
			var targetY = ((n - curSelected) * 100) + (FlxG.height / 2);
			a.x = FlxMath.lerp(a.x, targetX, elapsed * 8);
			a.y = FlxMath.lerp(a.y, targetY, elapsed * 8);
		});

		funnyText.x = currentCreditsThing.members[curSelected].x + 130;
		funnyText.y = currentCreditsThing.members[curSelected].y + 85;

		super.update(elapsed);
	}

	public function moveSelection(by:Int) {
		curSelected = (curSelected + by) % currentCreditsThing.length;
		if (curSelected < 0) {
			curSelected = currentCreditsThing.length - 1;
		}
		updateDesc();
	}

	public inline function updateDesc() {
		descText.text = creditsInfo[curSelectedSection][curSelected].description;
		descText.y = FlxG.height - (21 + descText.textField.textHeight);
		var funnyArr = creditsInfo[curSelectedSection][curSelected].funny;
		funnyText.visible = funnyArr != null && funnyArr.length > 0;
		if (funnyText.visible)
			funnyText.text = funnyArr[Math.floor(Math.random() * funnyArr.length)];
	}

	public function addCreditsStuff(title:String, stuff:Array<CreditsEntry>, ?mod:Null<String>) {
		//trace("Adding credits of "+title);
		creditsInfo.push(stuff);
		scrollableTitles.add(new FlxText(scrollableTitles.length == 0 ? 0 : scrollableTitles.width + 10, 0, 0, title == null ? mod : title, 20));
		var stuffGroup = new FlxTypedSpriteGroup<FlxSpriteGroup>();
		for (thing in stuff) {
			//trace("Add credits entry "+thing.name);
			var thisEntry = new FlxSpriteGroup();
			var icon = new HealthIcon(thing.icon, false, mod);
			thisEntry.add(icon);
			thisEntry.add(new FlxText(130, 50, 0, thing.name).setFormat("VCR OSD Mono", 32).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 0));
			thisEntry.y = stuffGroup.length * 100;
			stuffGroup.add(thisEntry);
		}
		creditsStuffs.push(stuffGroup);
	}
}
