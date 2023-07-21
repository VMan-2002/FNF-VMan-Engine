package;

import ThingThatSucks.ErrorReportSubstate;
import WiggleEffect.WiggleEffectType;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.system.FlxAssets.FlxGraphicAsset;

using StringTools;

enum SpriteVManExtraRenderType {
	unset;
	wobbly;
	spriteMapVMan;
}

class SpriteVManExtra extends SpriteVMan {
	public var renderType:SpriteVManExtraRenderType = unset;
	public function setRenderType(type:String, ?info:Dynamic) {
		switch(type) {
			case "wobbly":
				renderType = wobbly;
				waveSprite = new FlxEffectSprite(this);
				waveSprite.scale = scale;
				waveSprite.offset = offset;
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
	
	//what am i doing does this work
	var waveSprite:FlxEffectSprite;

	public override function new(?x:Null<Float>, ?y:Null<Float>, ?graphic:Null<FlxGraphicAsset>, ?renderType:String = "unset") {
		super(x, y, graphic);
		setRenderType(renderType);
	}
	
	public function setWobble(?amp:Float = 0.01, ?freq:Float = 60, ?speed:Float = 0.8, ?waveType:String = "dreamy") {
		var waveEffectBG:FlxWaveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		//idk what do :shrug:
		//currently this is just stuff copied from unused evilSchool stage code
		var bg:FlxSprite = this;
		// bg.setGraphicSize(Std.int(bg.width * 6));
		// bg.updateHitbox();

		var wiggleShit = new WiggleEffect();
		switch(waveType.toLowerCase()) {
			case "wavy":
				wiggleShit.effectType = WiggleEffectType.WAVY;
			case "horizontal" | "wave_horizontal" | "heat_wave_horizontal":
				wiggleShit.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
			case "vertical" | "wave_vertical" | "heat_wave_vertical":
				wiggleShit.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL;
			case "flag":
				wiggleShit.effectType = WiggleEffectType.FLAG;
			default:
				wiggleShit.effectType = WiggleEffectType.DREAMY;
		}
		wiggleShit.waveAmplitude = amp;
		wiggleShit.waveFrequency = freq;
		wiggleShit.waveSpeed = speed;

		// bg.shader = wiggleShit.shader;


		// Using scale since setGraphicSize() doesnt work???
		waveSprite.setPosition(x, y);

		waveSprite.scrollFactor = scrollFactor;
		waveSprite.origin = origin;
		waveSprite.offset = offset;
		waveSprite.scale = scale;
		waveSprite.effects.push(waveEffectBG);

		// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		// waveSprite.updateHitbox();
		return this;
	}

	public override function update(elapsed:Float) {
		switch(renderType) {
			case wobbly:
				waveSprite.update(elapsed);
			default:
				//do nothing
		}
		super.update(elapsed);
	}

	public override function draw() {
		switch(renderType) {
			case wobbly:
				waveSprite.x = x;
				waveSprite.y = y;
				waveSprite.angle = angle;
				waveSprite.draw();
			default:
				super.draw();
		}
	}
}
