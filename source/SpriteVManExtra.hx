package;

import ThingThatSucks.ErrorReportSubstate;
import WiggleEffect.WiggleEffectType;
import flixel.FlxSprite;

using StringTools;

enum SpriteVManExtraRenderType {
	unset;
	wobbly;
	spriteMapVMan;
}

class SpriteVManExtra extends SpriteVMan {
	public var renderType:SpriteVManExtraRenderType = unset;
	public function setRenderType(type:String, info:Dynamic) {
		switch(type) {
			default:
				renderType = unset;
		}
	}

	//var wiggleShit:WiggleEffect;
	
	/*public function makeWobbly(?amp:Float = 0.01, ?freq:Float = 60, ?speed:Float = 0.8, ?waveType:String = "dreamy") {
		//idk what do :shrug:
		//currently this is just stuff copied from unused evilSchool stage code
		var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		bg.scale.set(6, 6);
		// bg.setGraphicSize(Std.int(bg.width * 6));
		// bg.updateHitbox();
		add(bg);

		wiggleShit = new WiggleEffect();
		switch(waveType.toLowerCase()) {
			case "wavy":
				wiggleShit.effectType = WiggleEffectType.WAVY;
				break;
			case "horizontal":
				wiggleShit.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
				break;
			case "vertical":
				wiggleShit.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL
				break;
			case "flag":
				wiggleShit.effectType = WiggleEffectType.FLAG;
				break;
			default:
				wiggleShit.effectType = WiggleEffectType.DREAMY;
		}
		wiggleShit.waveAmplitude = amp;
		wiggleShit.waveFrequency = freq;
		wiggleShit.waveSpeed = speed;

		// bg.shader = wiggleShit.shader;

		var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);

		// Using scale since setGraphicSize() doesnt work???
		waveSprite.scale.set(6, 6);
		waveSprite.setPosition(posX, posY);

		waveSprite.scrollFactor.set(0.7, 0.8);

		// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		// waveSprite.updateHitbox();

		add(waveSprite);
	}*/
}
