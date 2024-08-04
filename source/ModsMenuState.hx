package;

import Discord.DiscordClient;
import Translation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.net.URLLoaderDataFormat;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef ModInfo = {
	name:String,
	description:String,
	version:Null<Int>,
	versionStr:Null<String>,
	titleScreen:Null<Bool>,
	gamebananaId:Null<Int>,
	id:Null<String>,
	devMode:Null<Bool>,
	requiredGameVer:Null<Int>,
	loadableGameVer:Null<Int>
}

typedef ModMenuInfo = {
	antialiasIcon:Null<Bool>,
	antialiasBg:Null<Bool>,
	antialiasBlur:Null<Bool>
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
	public var errorText:FlxText = new FlxText(230, 0, FlxG.width - 235, Translation.getTranslation("engine outdated", "mods", null, "Your version of VMan Engine is outdated, please update!")).setFormat("VCR OSD Mono", 20, FlxColor.RED).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 0.5);
	//public var funnyText:FlxText = new FlxText(0, 0, FlxG.width - 220, "Lol").setFormat("VCR OSD Mono", 32).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 0);
	
	public var enables:Map<String, Bool>;
	public var modObjects:Null<Array<ModMenuItem>> = null;

	public var titleScreenWas:String = "";

	public override function new() {
		super();
		enables = new Map<String, Bool>();
		ModLoad.checkNewMods();
		for (cool in ModLoad.normalizeModsListFileArr(ModLoad.getModsListFileArr())) {
			enables.set(cool, ModLoad.enabledMods.contains(cool) && ModLoad.modLoadAllowed(cool));
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
			gamebananaId: null,
			id: null,
			devMode: false,
			requiredGameVer: null,
			loadableGameVer: null
		}, Paths2.image("menu/moreModsIcon", "shared/images/"));
		updateCheckboxes();
	}

	public override function create() {
		super.create();
		
		var bg:FlxSprite = CoolUtil.makeMenuBackground('Blue');
		add(bg);
		add(bgGroup);

		Translation.setObjectFont(descTitleText);
		Translation.setObjectFont(descVersionText);
		Translation.setObjectFont(descText);
		Translation.setObjectFont(errorText);

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
		add(errorText);
	}

	public function showCreditsThing() {
		addOrReplace(currentCreditsThing, currentCreditsThing);
		curSelected = 0;
		updateDesc();
	}

	//todo: use this in other functions here
	public static function getModJsonData(path:String, mod:String, ?fillDesc = false) {
		if (FileSystem.exists(path + "/mod.json")) {
			var creditsFile:ModInfo = CoolUtil.loadJsonFromString(File.getContent(path + "/mod.json"));
			var descTranslationPath:String = 'mods/${mod}/modmenu_desc_${Translation.translationId}.txt';
			if (FileSystem.exists(descTranslationPath)) {
				creditsFile.description = File.getContent(descTranslationPath);
			}
			creditsFile.id = mod;
			return creditsFile;
		} else {
			var exists = FileSystem.exists(path + "/");
			return {
				name: mod,
				description: fillDesc ? Translation.getTranslation(exists ? "default desc" : "no exist desc", "mods", null, exists ? "This mod has no mod.json" : "This mod folder doesn't exist (possibly deleted?)") : "",
				version: 0,
				versionStr: "",
				titleScreen: false,
				gamebananaId: null,
				id: mod,
				devMode: false,
				requiredGameVer: null,
				loadableGameVer: null
			};
		}
	}

	public static inline function quickModJsonData(mod:String) {
		return getModJsonData(mod, mod, false);
	}

	public inline function loadCreditsJson(path:String, mod:String) {
		if (FileSystem.exists(path + "/mod.json")) {
			loadCreditsJsonString(File.getContent(path + "/mod.json"), mod);
		} else {
			addCreditsStuff(mod, {
				name: mod,
				description: Translation.getTranslation("default desc", "mods", null, "This mod has no mod.json"),
				version: 0,
				versionStr: "",
				titleScreen: false,
				gamebananaId: null,
				id: mod,
				devMode: false,
				requiredGameVer: null,
				loadableGameVer: null
			});
		}
	}

	public function loadCreditsJsonString(stuff:String, ?mod:Null<String>) {
		try {
			var creditsFile:ModInfo = CoolUtil.loadJsonFromString(stuff);
			var descTranslationPath:String = 'mods/${mod}/modmenu_desc_${Translation.translationId}.txt';
			if (FileSystem.exists(descTranslationPath))
				creditsFile.description = File.getContent(descTranslationPath);
			addCreditsStuff(mod, creditsFile);
		} catch (err) {
			trace("Error while loading mod json for "+mod);
			addCreditsStuff(mod, {
				name: mod,
				description: Translation.getTranslation("error desc", "mods", null, "This mod's mod.json isn't formatted correctly"),
				version: 0,
				versionStr: "",
				titleScreen: false,
				gamebananaId: null,
				id: mod,
				devMode: false,
				requiredGameVer: null,
				loadableGameVer: null
			});
		}
	}

	public function toggleTabber() {
		inTabber = !inTabber;
		trace(inTabber ? "tabber is now On" : "tabber is now Off");
		if (grabber == null) {
			if (inTabber) {
				grabber = new FlxSprite(0, 0);
				grabber.loadGraphic(Paths2.image("menu/grabber", "shared/images/"), true, 100, 130);
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
		//todo: why does this crash
		/*if (titleThing.modName != titleScreenWas)
			return true;*/
		return false;
	}

	var exitingModsChanged:Bool = false;

	public override function update(elapsed:Float) {
		if (controls.BACK) {
			var exitingTitleChanged = checkModChanges();
			CoolUtil.resetMenuMusic();
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
				if (!enables.get(thisOne) && currentCreditsThing.members[curSelected].needsNewVer) {
					FlxG.openURL("https://github.com/VMan-2002/FNF-VMan-Engine/releases/latest");
				} else {
					enables.set(thisOne, !enables.get(thisOne));
					trace('Toggle state of ${thisOne} to ${enables.get(thisOne)}');
					updateCheckboxes();
				}
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
		var enableCount = 0;
		for (obj in modObjects) {
			var needUpdate = obj.needsNewVer;
			var enby = enables.get(obj.modName) == true;
			if (enby)
				enableCount++;
			obj.members[1].animation.play(needUpdate ? (enby ? "outdatedWeak" : "outdated") : (enby ? "enable" : "disable"));
			obj.members[0].alpha = enby ? 1 : 0.5;
		}
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresenceSimple("mods", '$enableCount enabled, ${modObjects.length} available');
		#end
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
		var theModInfo = creditsInfo[numbrThing.ID];
		descText.text = theModInfo.description;
		//funnyText.text = creditsInfo[numbrThing].name;
		descTitleText.text = theModInfo.name;
		var ver:Null<String> = theModInfo.versionStr != null ? theModInfo.versionStr : (theModInfo.version != null ? 'v${theModInfo.version}' : null);
		descVersionText.visible = ver != null && curSelected < modObjects.length;
		if (descVersionText.visible) {
			descVersionText.text = ver;
			//descVersionText.x = descTitleText.x + descTitleText.frameWidth + 2;
		}
		errorText.visible = theModInfo.requiredGameVer != null && theModInfo.requiredGameVer > Main.gameVersionInt;
		setBg(numbrThing.modName, numbrThing);
	}

	//Bg stuff

	public var bgGroup = new FlxTypedGroup<FlxSprite>();
	public var newBg = new FlxSprite();
	public var newBgCorner = new FlxSprite();
	public var bgCornerRect = new FlxRect(230, FlxG.height - 1, FlxG.width - 230, 1);

	public inline function setBg(mod:String, ?item:ModMenuItem) {
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

		if (item != null) {
			if (newBgCorner.visible) {
				newBg.antialiasing = item.menuStuff.antialiasBlur != false;
				newBgCorner.antialiasing = item.menuStuff.antialiasBg == true;
			} else {
				newBg.antialiasing = item.menuStuff.antialiasBg == true;
			}
		}

		//FlxTween.tween(bgCornerRect, {y: descText.height + descText.y + 4}, 1, {ease:FlxEase.cubeOut, onUpdate: updateBgRect, onComplete: updateBgRect});
		bgCornerRect.y = Math.round((descText.height + descText.y + 4) / newBgCorner.scale.y);
		updateBgRect();
	}

	public inline function updateBgRect(?dumb) {
		bgCornerRect.height = newBgCorner.frameHeight - bgCornerRect.y;
		newBgCorner.clipRect = bgCornerRect;
	}
	
	public function addCreditsStuff(mod:String, stuff:ModInfo, ?image:Null<FlxGraphicAsset>) {
		//trace("Adding credits of "+title);
		var stuffGroup = currentCreditsThing;
		//for (thing in stuff) {
			//trace("Add credits entry "+thing.name);
			var thisEntry = new ModMenuItem();
			thisEntry.modName = mod;
			thisEntry.order = stuffGroup.length;
			thisEntry.needsNewVer = stuff.requiredGameVer > Main.gameVersionInt;
			if (modObjects == null) {
				if (FileSystem.exists('mods/${mod}/modmenu.json'))
					thisEntry.menuStuff = CoolUtil.loadJsonFromString(File.getContent('mods/${mod}/modmenu.json'));
			} else {
				thisEntry.menuStuff = {
					antialiasIcon: true,
					antialiasBlur: null,
					antialiasBg: null
				}
			}
			var icon = new FlxSprite(0, 0);
			if (image != null) {
				icon.loadGraphic(image);
			} else {
				var iconPath = 'mods/${mod}/_polymod_icon.png';
				if (FileSystem.exists(iconPath))
					icon.loadGraphic(BitmapData.fromFile(iconPath));
				else 
					icon.loadGraphic(Paths2.image("menu/noModIcon", "shared/images/"));
			}
			icon.antialiasing = thisEntry.menuStuff.antialiasIcon == true;
			icon.offset.set((icon.frameWidth - 150) * 0.5, (icon.frameHeight - 150) * 0.5);
			thisEntry.add(icon);
			if (modObjects == null) {
				var checkmark = new FlxSprite(110, 110).loadGraphic(Paths2.image("menu/modCheckmark", "shared/images/"), true, 40, 40);
				checkmark.animation.add("enable", [1]);
				checkmark.animation.add("disable", [0]);
				checkmark.animation.add("outdated", [2]);
				checkmark.animation.add("outdatedWeak", [4]);
				checkmark.antialiasing = true;
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
	public var needsNewVer:Bool = false;
	public var menuStuff:ModMenuInfo = {
		antialiasBlur: null,
		antialiasBg: null,
		antialiasIcon: null
	};
}