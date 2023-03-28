package;

import Boyfriend;
import CoolUtil;
import ThingThatSucks.ErrorReportSubstate;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import haxe.Json;
import lime.utils.Assets;

using StringTools;
#if polymod
import json2object.JsonParser;
import openfl.utils.Assets as OpenFlAssets;
#if !html5
import sys.FileSystem;
import sys.io.File;
#end
#end


typedef SwagCharacter = {
	public var image:String;
	public var healthIcon:String;
	public var deathChar:String;
	public var deathSound:String;
	public var initAnim:String;
	public var antialias:Null<Bool>;
	public var animations:Array<SwagCharacterAnim>;
	public var position:Null<Array<Float>>;
	public var isPlayer:Null<Bool>;
	public var scale:Null<Float>;
	public var danceModulo:Null<Int>;
	public var cameraOffset:Null<Array<Float>>;
	public var healthBarColor:Null<Array<Int>>;
	public var animNoSustain:Null<Bool>;
	public var isGirlfriend:Null<Bool>;
}

typedef SwagCharacterAnim = {
	public var name:String;
	public var anim:String;
	public var framerate:Int;
	public var offset:Null<Array<Float>>;
	public var indicies:Null<Array<Int>>;
	public var loop:Bool;
	public var noteCameraOffset:Array<Float>;
	public var nextAnim:Null<String>;
}

class Character extends SpriteVMan
{
	public static var nextId:Int = 0;
	public static var activeArray:Array<Character>;
	public static function findSuitableCharacter(name:String, ?def:Int = 0) {
		var result:Character = activeArray[def <= activeArray.length ? 0 : def];
		for (guy in activeArray) {
			if (guy.curCharacter == name) {
				return guy;
			} else if (guy.curCharacter.startsWith(name)) {
				result = guy;
			}
		}
		return result;
	}
	public static inline function findSuitableCharacterNum(name:String, ?def:Int = 0) {
		return activeArray.indexOf(findSuitableCharacter(name, def));
	}

	public var thisId:Int = 0;

	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var stunned:Bool = false;

	public var holdTimer:Float = 0;

	public var animationNotes:Array<Dynamic> = [];
	
	public var danceType:Bool = false;
	
	public var positionOffset:Array<Float> = [0, 0];
	
	public var myMod:String;
	public var playableSwapped:Bool = false;
	
	public var healthIcon:String;
	public var healthBarColor:FlxColor = new FlxColor(0xFF888888);
	public var deathChar:Null<String> = null;
	public var deathSound:Null<String> = null;

	public var curDances:Int = 0;
	public var moduloDances:Int = 1;

	public var cameraOffset:Array<Float> = [0, 0, 0];
	public var animNoSustain:Bool = false;
	public var hasMissAnims:Bool = false;

	public var misscolored:Bool = false;
	public var realcolor(default, set):FlxColor = FlxColor.WHITE;

	public var isGirlfriend = false;
	public var noteCameraOffset:Map<String, FlxPoint> = new Map<String, FlxPoint>();

	public function set_realcolor(a:FlxColor) {
		if (!misscolored) {
			color = a;
		}
		return a;
	}

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?myMod:String = "") {
		super(x, y);

		curCharacter = character.trim();
		this.isPlayer = isPlayer;
		healthIcon = curCharacter;
		
		if (activeArray != null) {
			thisId = nextId;
			activeArray[thisId] = this;
			nextId += 1;
		}
		
		this.myMod = myMod;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		noteCameraOffset.set("singLEFT", new FlxPoint(-45, 0));
		noteCameraOffset.set("singRIGHT", new FlxPoint(45, 0));
		noteCameraOffset.set("singUP", new FlxPoint(0, -45));
		noteCameraOffset.set("singDOWN", new FlxPoint(0, 45));

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

				noteCameraOffset.get("singLEFT").x = 25;
				noteCameraOffset.get("singRIGHT").x = 25;
				noteCameraOffset.get("singUP").y = -25;
				noteCameraOffset.get("singDOWN").y = 25;

				healthBarColor.setRGB(165, 0, 77);
				isGirlfriend = true;
			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('characters/gfChristmas');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

				healthBarColor.setRGB(165, 0, 77);
				isGirlfriend = true;
			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen');
				animation.addByIndices('sad', 'GF Crying at Gunpoint', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				playAnim('danceRight');

				healthBarColor.setRGB(165, 0, 77);
				positionOffset[0] = -170;
				positionOffset[1] = -75;
				isGirlfriend = true;
			case 'bf-holding-gf':
				frames = Paths.getSparrowAtlas('characters/bfAndGF');
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singUP', 'BF NOTE UP0');

				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('bfCatch', 'BF catches GF');

				//loadOffsetFile(curCharacter);

				addOffset('idle', 0, 0);
				addOffset('singUP', -29, 10);
				addOffset('singRIGHT', -41, 23);
				addOffset('singLEFT', 12, 7);
				addOffset('singDOWN', -10, -10);
				addOffset('singUPmiss', -29, 10);
				addOffset('singRIGHTmiss', -41, 21);
				addOffset('singLEFTmiss', 12, 7);
				addOffset('singDOWNmiss', -10, -10);
				addOffset('bfCatch', 0, 0);

				playAnim('idle');

				positionOffset[1] = 350;
				deathChar = 'bf-holding-gf-dead';

				flipX = true;
				healthBarColor.setRGB(43, 176, 209);
			case 'gf-car':
				tex = Paths.getSparrowAtlas('characters/gfCar');
				frames = tex;
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				healthBarColor.setRGB(165, 0, 77);
				isGirlfriend = true;
			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

				deathSound = 'fnf_loss_sfx-pixel';

				healthBarColor.setRGB(165, 0, 77);
				isGirlfriend = true;
			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');

				healthBarColor.setRGB(170, 99, 200);
			case 'spooky':
				tex = Paths.getSparrowAtlas('characters/spooky_kids_assets');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				addOffset("singUP", -20, 26);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 130, -10);
				addOffset("singDOWN", -50, -130);

				playAnim('danceRight');
				
				positionOffset[1] = 200;

				healthBarColor.setRGB(213, 126, 0);
			case 'mom':
				tex = Paths.getSparrowAtlas('characters/Mom_Assets');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				playAnim('idle');

				healthBarColor.setRGB(216, 85, 142);
			case 'mom-car':
				tex = Paths.getSparrowAtlas('characters/momCar');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				playAnim('idle');

				healthBarColor.setRGB(216, 85, 142);
			case 'monster':
				tex = Paths.getSparrowAtlas('characters/Monster_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'monster nrm idle', 24, false);
				animation.addByPrefix('singUP', 'monster nrm up', 24, false);
				animation.addByPrefix('singDOWN', 'monster nrm down', 24, false);
				animation.addByPrefix('singLEFT', 'monster nrm left', 24, false);
				animation.addByPrefix('singRIGHT', 'monster nrm right', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -30, -40);
				playAnim('idle');
				
				positionOffset[1] = 100;

				healthBarColor.setRGB(243, 255, 110);
			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('characters/monsterChristmas');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -40, -94);
				playAnim('idle');
				
				positionOffset[1] = 130;

				healthBarColor.setRGB(243, 255, 110);
			case 'pico':
				tex = Paths.getSparrowAtlas('characters/Pico_FNF_assetss');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
				animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				addOffset('idle');
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -68, -7);
				addOffset("singLEFT", 65, 9);
				addOffset("singDOWN", 200, -70);
				
				addOffset("singUPmiss", -19, 67);
				addOffset("singRIGHTmiss", -60, 41);
				addOffset("singLEFTmiss", 62, 64);
				addOffset("singDOWNmiss", 210, -28);

				playAnim('idle');

				flipX = true;
				
				positionOffset[1] = 300;

				healthBarColor.setRGB(183, 216, 85);

			case 'pico-speaker':
				frames = Paths.getSparrowAtlas('characters/picoSpeaker');

				quickAnimAdd('shoot1', "Pico shoot 1");
				quickAnimAdd('shoot2', "Pico shoot 2");
				quickAnimAdd('shoot3', "Pico shoot 3");
				quickAnimAdd('shoot4', "Pico shoot 4");

				// here for now, will be replaced later for less copypaste
				//loadOffsetFile(curCharacter);
				addOffset("shoot1", 0);
				addOffset("shoot2", -1, -128);
				addOffset("shoot3", 412, -64);
				addOffset("shoot4", 439, -19);
				playAnim('shoot1');
				positionOffset[0] = -50;
				positionOffset[1] = -200;

				moduloDances = 0; //no dances :)
				
				healthBarColor.setRGB(183, 216, 85);
			case 'bf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

				positionOffset[1] = 350;

				healthBarColor.setRGB(43, 176, 209);
			case 'bf-dead':
				var tex = Paths.getSparrowAtlas('characters/BF_Death');
				frames = tex;
				animation.addByPrefix('idle', "BF dies", 24, false);
				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);

				playAnim('firstDeath');

				flipX = true;

				positionOffset[1] = 350;

				healthBarColor.setRGB(43, 176, 209);
			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('characters/bfChristmas');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);

				playAnim('idle');

				flipX = true;
				positionOffset[1] = 350;

				healthBarColor.setRGB(43, 176, 209);
			case 'bf-car':
				var tex = Paths.getSparrowAtlas('characters/bfCar');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				playAnim('idle');

				flipX = true;
				positionOffset[1] = 350;

				healthBarColor.setRGB(43, 176, 209);
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				
				addOffset("singUPmiss");
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss");
				addOffset("singDOWNmiss");

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;
				positionOffset[1] = 350;
				deathSound = 'fnf-loss-sfx-pixel';
				deathChar = 'bf-pixel-dead';

				healthBarColor.setRGB(123, 214, 246);
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				animation.addByPrefix('idle', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				addOffset('firstDeath');
				addOffset('deathLoop', -37);
				addOffset('deathConfirm', -37);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

				positionOffset[1] = 350;

				healthBarColor.setRGB(123, 214, 246);

			case 'bf-holding-gf-dead':
				frames = Paths.getSparrowAtlas('characters/bfHoldingGF-DEAD');
				quickAnimAdd('singUP', 'BF Dead with GF Loop');
				quickAnimAdd('firstDeath', 'BF Dies with GF');
				animation.addByPrefix('deathLoop', 'BF Dead with GF Loop', 24, true);
				quickAnimAdd('deathConfirm', 'RETRY confirm holding gf');

				//loadOffsetFile(curCharacter);
				addOffset('firstDeath', 37, 14);
				addOffset('deathLoop', 37, -3);
				addOffset('deathConfirm', 37, 28);

				playAnim('firstDeath');

				positionOffset[1] = 350;

				flipX = true;
				healthBarColor.setRGB(123, 214, 246);
			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
				
				positionOffset = [150, 360];
				deathSound = 'fnf-loss-sfx-pixel';

				healthBarColor.setRGB(255, 170, 111);

				cameraOffset[0] = -100;
				cameraOffset[1] = -430;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

				positionOffset = [150, 360];
				deathSound = 'fnf-loss-sfx-pixel';

				healthBarColor.setRGB(255, 170, 111);

				cameraOffset[0] = -100;
				cameraOffset[1] = -430;
			case 'spirit':
				frames = Paths.getSparrowAtlas('characters/spirit');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -240);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -200, -280);
				addOffset("singDOWN", 170, 110);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

				positionOffset = [-150, 100];
				deathSound = 'fnf-loss-sfx-pixel';

				healthBarColor.setRGB(255, 60, 110);
			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				addOffset('idle');
				addOffset("singUP", -47, 24);
				addOffset("singRIGHT", -1, -23);
				addOffset("singLEFT", -30, 16);
				addOffset("singDOWN", -31, -29);
				addOffset("singUP-alt", -47, 24);
				addOffset("singRIGHT-alt", -1, -24);
				addOffset("singLEFT-alt", -30, 15);
				addOffset("singDOWN-alt", -30, -27);

				playAnim('idle');

				positionOffset[0] = -500;

				healthBarColor.setRGB(Std.int(217+175/2), Std.int(85+102/2), Std.int(142+206/2));
			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/tankmanCaptain');

				quickAnimAdd('idle', "Tankman Idle Dance");

				quickAnimAdd('singLEFT', 'Tankman Note Left instance');
				quickAnimAdd('singRIGHT', 'Tankman Right Note instance');
				quickAnimAdd('singLEFTmiss', 'Tankman Note Left MISS');
				quickAnimAdd('singRIGHTmiss', 'Tankman Right Note MISS');

				quickAnimAdd('singUP', 'Tankman UP note instance');
				quickAnimAdd('singDOWN', 'Tankman DOWN note instance');
				quickAnimAdd('singUPmiss', 'Tankman UP note MISS');
				quickAnimAdd('singDOWNmiss', 'Tankman DOWN note MISS');

				// PRETTY GOOD tankman
				// TANKMAN UGH instanc

				quickAnimAdd('singDOWN-alt', 'PRETTY GOOD');
				quickAnimAdd('singUP-alt', 'TANKMAN UGH');

				//loadOffsetFile(curCharacter);

				addOffset('idle');
				addOffset("singUP", 24, 56);
				addOffset("singRIGHT", -1, -7);
				addOffset("singLEFT", 100, -14);
				addOffset("singDOWN", 98, -90);
				addOffset("singUPmiss", 53, 84);
				addOffset("singRIGHTmiss", -1, -3);
				addOffset("singLEFTmiss", -30, 16);
				addOffset("singDOWNmiss", 69, -99);
				addOffset("singUP-alt", 24, 56);
				addOffset("singDOWN-alt", 98, -90);

				playAnim('idle');
				positionOffset[1] = 180;

				flipX = true;

				healthBarColor.setRGB(225, 225, 225);
			default: //placeholder guy
				//try to load character
				var successLoad = false;
				#if polymod
				var loadedStuff:Null<SwagCharacter> = null;
				try {
					loadedStuff = loadCharacterJson(curCharacter, myMod);
				} catch(e) {
					ErrorReportSubstate.addError("Error loading character "+curCharacter+": " + e.message);
				}
				if (loadedStuff != null) {
					trace('loaded custom char for ' + curCharacter);
					
					//Char stuff is load. now set up
					frames = Paths.getSparrowAtlas(loadedStuff.image);
					for (anim in loadedStuff.animations) {
						loadAnimation(this, anim);
						var flippedPlayer:Bool = (loadedStuff.isPlayer != flipX);
						if (anim.offset != null && anim.offset.length > 0) {
							//			LEN 2	LEN 3
							//NO FLIP	0,1,n	0,1,2
							//IS FLIP	0,1,n	2,1,0	
							var xNormal = anim.offset.length > 2 ? (anim.offset[!flippedPlayer ? 0 : 2]) : (!flippedPlayer ? anim.offset[0] : null);
							var xFlip = anim.offset.length > 2 ? (anim.offset[flippedPlayer ? 0 : 2]) : (flippedPlayer ? anim.offset[0] : null);
							addOffset(anim.name, xNormal, anim.offset[1], xFlip);
						} else {
							addOffset(anim.name);
						}
						if (anim.noteCameraOffset == null || anim.noteCameraOffset.length == 0) {
							if (anim.name.startsWith("sing")) {
								/*switch(anim.name.toLowerCase()) {
									case "singleft":
										noteCameraOffset.set(anim.name, new FlxPoint(-45, 0));
									case "singright":
										noteCameraOffset.set(anim.name, new FlxPoint(45, 0));
									case "singup":
										noteCameraOffset.set(anim.name, new FlxPoint(0, -45));
									case "singdown":
										noteCameraOffset.set(anim.name, new FlxPoint(0, 45));
								}*/
							}
						} else {
							noteCameraOffset.set(anim.name, new FlxPoint(anim.noteCameraOffset[0], anim.noteCameraOffset[1]));
						}
					}
					if (loadedStuff.position != null && loadedStuff.position.length != 0) {
						positionOffset = loadedStuff.position;
						if (positionOffset.length < 2) {
							positionOffset[1] = 0;
						}
					}
					if (loadedStuff.healthIcon != null && loadedStuff.healthIcon.length != 0) {
						healthIcon = loadedStuff.healthIcon;
					}
					if (loadedStuff.isPlayer != null) {
						flipX = loadedStuff.isPlayer;
					}
					if (loadedStuff.scale != null) {
						scale.x = loadedStuff.scale;
						scale.y = scale.x;
					}
					if (loadedStuff.deathChar != null) {
						this.deathChar = loadedStuff.deathChar;
					}
					if (loadedStuff.deathSound != null) {
						this.deathSound = loadedStuff.deathSound;
					}
					if (loadedStuff.danceModulo != null) {
						this.moduloDances = loadedStuff.danceModulo;
					}
					if (loadedStuff.cameraOffset != null) {
						this.cameraOffset = loadedStuff.cameraOffset;
						if (this.cameraOffset.length <= 2) {
							this.cameraOffset[2] = -this.cameraOffset[0];
						}
					} else {
						this.cameraOffset = [0, 0, 0];
					}
					if (loadedStuff.healthBarColor != null) {
						this.healthBarColor.setRGB(loadedStuff.healthBarColor[0], loadedStuff.healthBarColor[1], loadedStuff.healthBarColor[2]);
					}
					if (loadedStuff.animNoSustain != null) {
						this.animNoSustain = loadedStuff.animNoSustain;
					}
					this.isGirlfriend = loadedStuff.isGirlfriend == true;
					playAvailableAnim([loadedStuff.initAnim, "danceLeft", "idle"]);
					if (loadedStuff.initAnim != animation.curAnim.name) {
						trace("The set InitAnim wasn't found, but an idle anim was found");
					}
					antialiasing = loadedStuff.antialias != false;
					successLoad = true;
				}
				#end
				//otherwise, use da guy
				if (!successLoad) {
					trace('using default character');
					curCharacter = "mr_placeholder_guy";
					
					frames = Paths.getSparrowAtlas('characters/placeholderguy/dood');
					animation.addByPrefix('idle', 'idle lol', 24, false);
					animation.addByPrefix('singUP', 'up note', 24, false);
					animation.addByPrefix('singDOWN', 'down note', 24, false);
					animation.addByPrefix('singLEFT', 'left note', 24, false);
					animation.addByPrefix('singRIGHT', 'right note', 24, false);

					animation.addByPrefix('singUPmiss', 'up miss', 24, false);
					animation.addByPrefix('singDOWNmiss', 'down miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'left miss', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'right miss', 24, false);

					addOffset('idle');
					addOffset("singUP", 57, -1);
					addOffset("singDOWN", -58, -73);
					addOffset("singLEFT", 66, 2);
					addOffset("singRIGHT", 0, 0);
					
					addOffset("singUPmiss", 45, -1);
					addOffset("singDOWNmiss", -45, -63);
					addOffset("singLEFTmiss", 80, 2);
					addOffset("singRIGHTmiss", -46, 0);

					playAnim('idle');
				}
		}

		hasMissAnims = hasAnim('singRIGHTmiss');
		
		if (flipX != isPlayer && hasAnim("singRIGHT") && hasAnim("singLEFT")) {
			// var animArray
			/*var oldRight = animation.getByName('singRIGHT').frames;
			animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
			animation.getByName('singLEFT').frames = oldRight;*/
			swapAnimations('singLEFT', 'singRIGHT');

			// IF THEY HAVE MISS ANIMATIONS??
			if (hasMissAnims) {
				/*var oldMiss = animation.getByName('singRIGHTmiss').frames;
				animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
				animation.getByName('singLEFTmiss').frames = oldMiss;*/
				swapAnimations('singLEFTmiss', 'singRIGHTmiss');
			}
		}

		generateFlipOffsets();

		if (!hasMissAnims) {
			var things = ["singUP", "singDOWN", "singLEFT", "singRIGHT"];
			for (a in things) {
				copyAnimation(a, a + "miss");
			}
		}

		if (isPlayer) {
			flipX = !flipX;
		}
		
		if (frames == null) {
			ErrorReportSubstate.addError('INVALID SPRITE SHEET for $curCharacter');
		}
		
		if (animation.curAnim == null) {
			ErrorReportSubstate.addError("Animation for char "+curCharacter+" is null somehow! This will cause a crash!");
			
		}
		
		danceType = hasAnim("danceLeft");
		dance();
	}

	public static var charHealthIcons:Map<String, String> = new Map<String, String>();

	public static function loadCharacterJson(name:String, mod:String) {
		#if !html5
		var thing:String = 'assets/objects/characters/${name}.json';
		var thingMy:String = 'mods/${mod}/objects/characters/${name}.json';
		var isMyMod = mod != "" && FileSystem.exists(thingMy);
		trace('loading custom char file of ${isMyMod ? thingMy : thing}');
		if (isMyMod ? FileSystem.exists(thingMy) : OpenFlAssets.exists(thing)) {
			var loadStr = isMyMod ? File.getContent(thingMy) : Assets.getText(thing);
			//trace(loadStr);
			var loadedStuff:SwagCharacter = cast CoolUtil.loadJsonFromString(loadStr);
			charHealthIcons.set('${mod}:${name}', loadedStuff.healthIcon);
			return loadedStuff;
		}
		#else
		var loadStr = Assets.getText('assets/objects/characters/${name}.json');
		var loadedStuff:SwagCharacter = cast CoolUtil.loadJsonFromString(loadStr);
		charHealthIcons.set('${mod}:${name}', loadedStuff.healthIcon);
		return loadedStuff;
		#end
		return null;
	}

	public function loadMappedAnims(song:String, file:String) {
		var swagshit = Song.loadFromJson(file, song);

		var notes = swagshit.notes;

		for (section in notes)
		{
			for (idk in section.sectionNotes)
			{
				animationNotes.push(idk);
			}
		}

		//TankmenBG.animationNotes = animationNotes;

		trace(animationNotes);
		animationNotes.sort(sortAnims);
	}

	function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);
	}

	inline function quickAnimAdd(name:String, prefix:String, ?loop:Bool = false) {
		animation.addByPrefix(name, prefix, 24, loop);
	}

	@:deprecated("Don't use this, it causes crashes right now and also is basically obsolete in vman engine :)")
	private function loadOffsetFile(offsetCharacter:String)
	{
		//this doesnt work don't use this :>
		var daFile:Array<String> = CoolUtil.coolTextFile(Paths.file("images/characters/" + offsetCharacter + "Offsets.txt"));

		for (i in daFile) {
			var splitWords:Array<String> = i.split(" ");
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}

	public static function getHealthIcon(name:String, mod:String, ?force:Bool = false) {
		if (force || !charHealthIcons.exists('${mod}:${name}')) {
			var json = loadCharacterJson(name, mod);
			if (json != null) {
				return json.healthIcon;
			}
			return name;
		}
		return charHealthIcons.get('${mod}:${name}');
	}

	public static function loadAnimation(sprite:FlxSprite, anim:SwagCharacterAnim) {
		if (anim.indicies != null && anim.indicies.length > 0) {
			sprite.animation.addByIndices(anim.name, anim.anim, anim.indicies, "", anim.framerate, anim.loop);
		} else {
			sprite.animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);
		}
	}

	override function update(elapsed:Float) {
		if (!Std.isOfType(this, Boyfriend)) {
			if (animStartsWith('sing')) {
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance(true);
				holdTimer = 0;
			}
		}

		if (animationNotes.length > 0) {
			if (Conductor.songPosition > animationNotes[0][0]) {
				trace('played shoot anim' + animationNotes[0][1]);

				var shootAnim:Int = 1;

				if (animationNotes[0][1] >= 2)
					shootAnim = 3;

				shootAnim += FlxG.random.int(0, 1);

				playAnim('shoot' + shootAnim, true);
				animationNotes.shift();
			}
		}

		//todo: replace this with `-loop` stuff
		if (curCharacter == 'pico-speaker' && animation.curAnim.finished) {
			playAnim(animation.curAnim.name, false, false, animation.curAnim.numFrames - 3);
		}
		
		if (!hasMissAnims && misscolored && !animation.curAnim.name.endsWith('miss')) {
			misscolored = false;
			color = realcolor;
		}

		if (animation.curAnim.finished == true) {
			if (animation.curAnim.name == 'hairFall') {
				danced = false;
				dance(true);
			} else if (hasAnim(animation.curAnim.name+"-loop")) {
				playAnim(animation.curAnim.name+"-loop");
			}
		}

		super.update(elapsed);
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?anyway:Bool = false) {
		if (debugMode || moduloDances == 0 || (animation.curAnim != null && (animation.curAnim.name == 'hairBlow' || (animation.curAnim.name.startsWith('sing') && !animation.curAnim.name.endsWith("-loop") && !animation.curAnim.finished)))) {
			return;
		}
		if (!anyway) {
			if (curDances >= moduloDances) {
				curDances = 1;
			} else {
				curDances++;
				return;
			}
		}
		if (danceType) {
			danced = !danced;
			if (danced)
				return playAnim('danceRight');
			return playAnim('danceLeft');
		}
		playAnim('idle');
	}
	
	public function applyPositionOffset() {
		x += positionOffset[0];
		y += positionOffset[1];
	}

	public override function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		super.playAnim(AnimName, Force, Reversed, Frame);

		if (curCharacter.startsWith('gf')) {
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;
			else if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}

		if (!hasMissAnims && AnimName.endsWith("miss")) {
			misscolored = true;
			color = 0x999aff;
		}
	}
}
