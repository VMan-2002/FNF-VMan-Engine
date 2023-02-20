package;

import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef ModInfo = {
	name:String,
	description:String,
	version:Null<Int>,
	versionStr:Null<String>,
	titleScreen:Null<Bool>,
	gamebananaId:Null<Int>
}

class ModsMenuState extends MusicBeatState {
	//todo: this can be tidied up a bit i think

	public var creditsInfo:Map<Int, ModInfo> = new Map<Int, ModInfo>();
	public var curSelected:Int = 0;
	public var grabber:FlxSprite;

	public var currentCreditsThing:FlxTypedSpriteGroup<ModMenuItem> = new FlxTypedSpriteGroup<ModMenuItem>();
	public var inTabber:Bool = false;
	public var draggingMod:Bool = false;
	public var descTitleText:FlxText = new FlxText(230, 8, FlxG.width - 235, "Really cool mod").setFormat("VCR OSD Mono", 32).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 0.5);
	public var descVersionText:FlxText = new FlxText(230, 18, FlxG.width - 235, "Coolest version").setFormat("VCR OSD Mono", 20, FlxColor.WHITE, FlxTextAlign.RIGHT).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 0.5);
	public var descText:FlxText = new FlxText(230, 48, FlxG.width - 235, "You should play it :)").setFormat("VCR OSD Mono", 20).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 0.5);
	//public var funnyText:FlxText = new FlxText(0, 0, FlxG.width - 220, "Lol").setFormat("VCR OSD Mono", 32).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 0);

	public var enables:Map<String, Bool>;
	public var modObjects:Null<Array<ModMenuItem>> = null;

	public var titleScreenWas:String = "";

	public override function new() {
		super();
		enables = new Map<String, Bool>();
		ModLoad.checkNewMods();
		for (cool in ModLoad.normalizeModsListFileArr(ModLoad.getModsListFileArr())) {
			enables.set(cool, ModLoad.enabledMods.contains(cool));
			loadCreditsJson("mods/"+cool, cool);
			if (titleScreenWas == "" && enables.get(cool) && creditsInfo.get(currentCreditsThing.members[currentCreditsThing.length - 1].ID).titleScreen == true)
				titleScreenWas = cool;
		}
		modObjects = currentCreditsThing.members.copy();
		addCreditsStuff("", {
			name: Translation.getTranslation("more mods gamebanana", "mods", null, "More Mods"),
			version: 0,
			versionStr: "gamebananaMods",
			description: Translation.getTranslation("more mods gamebanana_desc", "mods", null, "Find more mods on GameBanana"),
			titleScreen: false,
			gamebananaId: null
		}, Paths.image("menu/moreModsIcon"));
		updateCheckboxes();
	}

	public override function create() {
		super.create();
		
		var bg:FlxSprite = CoolUtil.makeMenuBackground('Blue');
		add(bg);
		add(bgGroup);

		showCreditsThing();

		var hintText = new FlxText(230, 0, 0, Translation.getTranslation("reorder hint", "mods", [Options.getUIControlName("gtstrum"), Options.getUIControlName("reset")], "GTStrum: Reorder mods\nReset: Enable/Disable All"), 16).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		Translation.setObjectFont(hintText);
		hintText.y = FlxG.height - hintText.height;
		add(hintText);
		//add(funnyText);

		bgGroup.add(newBg);
		bgGroup.add(newBgCorner);
		newBg.color = 0xFF858585;

		add(descTitleText);
		add(descVersionText);
		add(descText);

		Translation.setObjectFont(descTitleText);
		Translation.setObjectFont(descVersionText);
		Translation.setObjectFont(descText);
	}

	public function showCreditsThing() {
		addOrReplace(currentCreditsThing, currentCreditsThing);
		curSelected = 0;
		updateDesc();
	}

	public inline function loadCreditsJson(path:String, mod:String) {
		if (FileSystem.exists(path + "/mod.json")) {
			loadCreditsJsonString(File.getContent(path + "/mod.json"), mod);
		} else {
			addCreditsStuff(mod, {
				name: mod,
				description: Translation.getTranslation("default desc", "mods", null, "This mod has no mod.json"),
				version: 0,
				versionStr: "...",
				titleScreen: false,
				gamebananaId: null
			});
		}
	}

	public function loadCreditsJsonString(stuff:String, ?mod:Null<String>) {
		var creditsFile:ModInfo = CoolUtil.loadJsonFromString(stuff);
		addCreditsStuff(mod, creditsFile);
	}

	public function toggleTabber() {
		inTabber = !inTabber;
		trace(inTabber ? "tabber is now On" : "tabber is now Off");
		if (grabber == null) {
			if (inTabber) {
				grabber = new FlxSprite(0, 0, Paths.image("menu/grabber"));
				grabber.loadGraphic(Paths.image("menu/grabber"), true, 100, 130);
				grabber.offset.set(-70, -40);
				grabber.animation.add("idle", [0]);
				grabber.animation.add("grab", [1]);
				grabber.animation.play("idle");
				add(grabber);
			}
		} else {
			grabber.visible = inTabber;
			if (!inTabber)
				draggingMod = false;
			else
				grabber.animation.play("idle");
		}
		if (inTabber)
			grabber.setPosition(currentCreditsThing.members[curSelected].x, currentCreditsThing.members[curSelected].y);
	}

	/**
		Manage newly changed mods.

		Return `true` if the title screen changed.
	**/
	public function checkModChanges() {
		var newModsFile = new Array<String>();
		var titleThing:ModMenuItem = null;
		for (a in modObjects) {
			newModsFile[a.order] = a.modName.trim().replace("\r", "");
			if ((titleThing == null || a.order < titleThing.order) && creditsInfo.get(a.ID).titleScreen == true)  {
				titleThing = a;
			}
		}
		var newEnables = newModsFile.filter(function(a) {
			return enables.get(a);
		});
		File.saveContent("mods/modList.txt", newModsFile.map(function(a) {
			return (enables.get(a) ? "1::" : "0::") + a;
		}).join("\n"));
		trace("Prev enables: "+ModLoad.enabledMods.join(","));
		trace("New enables: "+newEnables.join(","));
		var same = newEnables.length == ModLoad.enabledMods.length;
		if (same) {
			for (i in 0...newEnables.length) {
				if (newEnables[i].trim() == ModLoad.enabledMods[i].trim()) {
					same = false;
					break;
				}
			}
		}
		if (same)
			return false;
		else
			exitingModsChanged = true;
		//ModLoad.enabledMods = newModsFile; //let's just hope nothing bad happens from reusing this var
		//ModLoad.reloadMods = true;
		if (titleThing.modName != titleScreenWas)
			return true;
		return false;
	}

	var exitingModsChanged:Bool = false;

	public override function update(elapsed:Float) {
		if (controls.BACK) {
			var exitingTitleChanged = checkModChanges();
			switchTo(new TitleState(exitingTitleChanged, true/*,exitingModsChanged || exitingTitleChanged || controls.GTSTRUM*/));
			//somehow only TitleState can reload mods. this doesn't make sense lol
		}
		if (controls.GTSTRUM) {
			toggleTabber();
		}
		if (controls.RESET) {
			trace("Reset btn: enable/disable all");
			var newState = true;
			for (thing in enables.keys()) {
				if (enables.get(thing)) {
					newState = false;
					break;
				}
			}
			for (thing in enables.keys()) {
				enables.set(thing, newState);
			}
			updateCheckboxes();
		}
		if (controls.UP_P) {
			moveSelection(-1);
		}
		if (controls.DOWN_P) {
			moveSelection(1);
		}
		if (controls.ACCEPT) {
			if (curSelected >= modObjects.length) {
				//Special items
				switch(creditsInfo.get(currentCreditsThing.members[curSelected].ID).versionStr) {
					case "gamebananaMods":
						FlxG.openURL("https://gamebanana.com/search?_idGameRow=8694&_sSearchString=FNFVManEngine");
				}
			} else if (inTabber) {
				//Reorder actions
				draggingMod = !draggingMod;
				grabber.animation.play(draggingMod ? "grab" : "idle");
			} else {
				//Toggle Enabled
				var thisOne = currentCreditsThing.members[curSelected].modName;
				enables.set(thisOne, !enables.get(thisOne));
				trace('Toggle state of ${thisOne} to ${enables.get(thisOne)}');
				updateCheckboxes();
			}
		}

		currentCreditsThing.forEach(function(a) {
			//var n = currentCreditsThing.members.indexOf(a);
			var n = a.order;
			var targetX = curSelected == n ? 75 : 0;
			var targetY = ((n - curSelected) * 100) + (FlxG.height / 2) - 75;
			a.x = FlxMath.lerp(a.x, targetX, elapsed * 8);
			a.y = FlxMath.lerp(a.y, targetY, elapsed * 8);
		});

		if (inTabber) {
			var lerpy:Float = draggingMod ? 1 : elapsed * 8;
			grabber.setPosition(
				FlxMath.lerp(grabber.x, currentCreditsThing.members[curSelected].x, lerpy),
				FlxMath.lerp(grabber.y, currentCreditsThing.members[curSelected].y, lerpy)
			);
		}

		//funnyText.x = currentCreditsThing.members[curSelected].x + 130;
		//funnyText.y = currentCreditsThing.members[curSelected].y + 30;

		super.update(elapsed);
	}

	public function updateCheckboxes() {
		for (obj in modObjects) {
			var enby = enables.get(obj.modName) == true;
			obj.members[1].animation.play(enby ? "enable" : "disable");
			obj.members[0].alpha = enby ? 1 : 0.5;
		}
	}

	public function moveSelection(by:Int) {
		var was = curSelected;
		curSelected = (curSelected + by) % (draggingMod ? modObjects.length : currentCreditsThing.length);
		if (curSelected < 0) {
			curSelected = (draggingMod ? modObjects.length : currentCreditsThing.length) - 1;
		}
		if (draggingMod) {
			var oldThing:Int = currentCreditsThing.members[curSelected].order;
			currentCreditsThing.members[curSelected].order = currentCreditsThing.members[was].order;
			currentCreditsThing.members[was].order = oldThing;
			currentCreditsThing.members.sort(function(a, b) {
				return a.order - b.order;
			});
		} else {
			updateDesc();
		}
	}

	public function updateDesc() {
		var numbrThing = currentCreditsThing.members[curSelected];
		descText.text = creditsInfo[numbrThing.ID].description;
		//funnyText.text = creditsInfo[numbrThing].name;
		descTitleText.text = creditsInfo[numbrThing.ID].name;
		var ver:Null<String> = creditsInfo[numbrThing.ID].versionStr != null ? creditsInfo[numbrThing.ID].versionStr : (creditsInfo[numbrThing.ID].version != null ? 'v${creditsInfo[numbrThing.ID].version}' : null);
		descVersionText.visible = ver != null && curSelected < modObjects.length;
		if (descVersionText.visible) {
			descVersionText.text = ver;
			//descVersionText.x = descTitleText.x + descTitleText.frameWidth + 2;
		}
		setBg(numbrThing.modName);
	}

	//Bg stuff

	public var bgGroup = new FlxTypedGroup<FlxSprite>();
	public var newBg = new FlxSprite();
	public var newBgCorner = new FlxSprite();
	public var bgCornerRect = new FlxRect(230, FlxG.height - 1, FlxG.width - 230, 1);

	public inline function setBg(mod:String) {
		var bgPath = 'mods/${mod}/modmenu_bg.png';
		var bgImg = FileSystem.exists(bgPath) ? BitmapData.fromFile(bgPath) : null;

		if (bgImg != null) {
			var bgBlurPath = 'mods/${mod}/modmenu_bg_blur.png';
			var bgBlurImg = FileSystem.exists(bgBlurPath) ? BitmapData.fromFile(bgBlurPath) : null;

			newBgCorner.loadGraphic(BitmapData.fromFile(bgPath));
			if (bgBlurImg == null) {
				newBg.loadGraphic(bgImg);
				newBg.antialiasing = false;
			} else {
				newBg.loadGraphic(bgBlurImg);
				newBg.antialiasing = true;
			}
			newBg.setGraphicSize(FlxG.width);
			newBgCorner.setGraphicSize(FlxG.width);
			newBg.screenCenter(XY);
			newBgCorner.screenCenter(XY);
			newBg.visible = true;
			newBgCorner.visible = true;

			bgCornerRect.x = Math.round(230 / newBgCorner.scale.x);
			bgCornerRect.width = newBgCorner.frameWidth - bgCornerRect.x;
		} else {
			newBg.visible = false;
			newBgCorner.visible = false;
		}

		//FlxTween.tween(bgCornerRect, {y: descText.height + descText.y + 4}, 1, {ease:FlxEase.cubeOut, onUpdate: updateBgRect, onComplete: updateBgRect});
		bgCornerRect.y = Math.round((descText.height + descText.y + 4) / newBgCorner.scale.y);
		updateBgRect();
	}

	public inline function updateBgRect(?dumb) {
		bgCornerRect.height = newBgCorner.frameHeight - bgCornerRect.y;
		newBgCorner.clipRect = bgCornerRect;
	}
	
	public function addCreditsStuff(mod:String, stuff:ModInfo, ?image:Null<String>) {
		//trace("Adding credits of "+title);
		var stuffGroup = currentCreditsThing;
		//for (thing in stuff) {
			//trace("Add credits entry "+thing.name);
			var thisEntry = new ModMenuItem();
			thisEntry.modName = mod;
			thisEntry.order = stuffGroup.length;
			var icon = new FlxSprite(0, 0);
			if (image != null) {
				icon.loadGraphic(image);
			} else {
				var iconPath = 'mods/${mod}/_polymod_icon.png';
				if (FileSystem.exists(iconPath))
					icon.loadGraphic(BitmapData.fromFile(iconPath));
				else 
					icon.loadGraphic(Paths.image("menu/noModIcon"));
			}
			icon.offset.set((icon.frameWidth - 150) * 0.5, (icon.frameHeight - 150) * 0.5);
			thisEntry.add(icon);
			if (modObjects == null) {
				var checkmark = new FlxSprite(110, 110).loadGraphic(Paths.image("menu/modCheckmark"), true, 40, 40);
				checkmark.animation.add("enable", [1]);
				checkmark.animation.add("disable", [0]);
				thisEntry.add(checkmark);
			}
			thisEntry.y = stuffGroup.length * 100;
			stuffGroup.add(thisEntry);
		//}
		creditsInfo.set(thisEntry.ID, stuff);
	}
}

class ModMenuItem extends FlxSpriteGroup {
	public var modName:String;
	public var order:Int;
}