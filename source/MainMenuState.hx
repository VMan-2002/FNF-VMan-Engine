package;

import CoolUtil;
import Note.SwagNoteSkin;
import Note.SwagUIStyle;
import OptionsMenu;
import ThingThatSucks.ResetControlsSubState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;
//import io.newgrounds.NG;
#if desktop
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'story mode',
		'freeplay',
	#if !switch
		'donate',
	#end
		'options',
	#if desktop
		//'mods', //todo: yea
	#end
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	
	#if !html5
	var hillarious:MultiWindow;
	#end

	static var possiblyForgotControls:Bool = true;
	var possiblyForgotControlsTimer:Float = 8;
	var possiblyForgotControlsText:FlxText;
	var resetControlsTimer:Float = 0;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresenceSimple("menu");
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing) {
			CoolUtil.playMenuMusic();
		}

		SwagNoteSkin.clearLoadedNoteSkins();
		SwagUIStyle.clearLoadedUIStyles();

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = CoolUtil.makeMenuBackground('', -80);
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuBGDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('menu/FNF_main_menu_assets');

		for (i in 0...optionShit.length) {
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var vmanEngineThing:FlxText = new FlxText(5, FlxG.height - 38, 0, "vman engine wip! :)", 12);
		vmanEngineThing.scrollFactor.set();
		vmanEngineThing.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(vmanEngineThing);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		
		OptionsMenu.wasInPlayState = false;

		super.create();
	}
	
	public inline static function returnToMenuFocusOn(item:String) {
		var a = new MainMenuState();
		a.curSelected = a.optionShit.indexOf(item);
		FlxG.switchState(a);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (isSubStateActive && Std.isOfType(_requestedSubState, ResetControlsSubState)) {
			return super.update(elapsed);
		}

		if (possiblyForgotControls) {
			possiblyForgotControlsTimer -= elapsed;
			if (possiblyForgotControlsTimer <= 0) {
				possiblyForgotControlsText = new FlxText(0, 0, FlxG.width, Translation.getTranslation("reset controls title", "mainmenu", null, "Forgot your controls (or they don't work)? Hold SHIFT for 3 seconds."), 12).setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				Translation.setObjectFont(possiblyForgotControlsText, "vcr font");
				add(possiblyForgotControlsText);
			}
			if (controls.UP_P || controls.DOWN_P) {
				possiblyForgotControlsTimer = 8;
			}
			if (controls.ACCEPT) {
				possiblyForgotControls = false;
				if (possiblyForgotControlsText != null) {
					remove(possiblyForgotControlsText);
					possiblyForgotControlsText = null;
				}
			}
		}

		if (FlxG.keys.pressed.SHIFT) {
			resetControlsTimer += elapsed;
			if (resetControlsTimer > 3) {
				openSubState(new ThingThatSucks.ResetControlsSubState());
			}
		} else {
			resetControlsTimer = 0;
		}
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			#if !html5
			if (FlxG.keys.justPressed.U) {
				hillarious = new MultiWindow(1, true);
			}

			if (FlxG.keys.justPressed.SEVEN) {
				FlxG.switchState(new OptionsMenu(new ToolsMenuSubState()));
			}
			#end

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'options':
										FlxG.switchState(new OptionsMenu());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
			spr.screenCenter(X);
		});
	}
}
