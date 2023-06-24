package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;

class RatingPopUpGroup extends FlxTypedGroup<RatingPopUp> {
    public static var instance:RatingPopUpGroup;
    public override function new() {
        super();
        instance = this;
    }

    public function bigThingAdd(x:Float, y:Float, img:FlxGraphicAsset, scale:Float, antialias:Bool):RatingPopUp {
        return add(new RatingPopUp(x, y, img, scale, antialias).bigThing());
    }

    public function comboThingAdd(x:Float, y:Float, img:FlxGraphicAsset, scale:Float, antialias:Bool):RatingPopUp {
        return add(new RatingPopUp(x, y, img, scale, antialias).comboThing());
    }

    public function smallThingAdd(x:Float, y:Float, img:FlxGraphicAsset, scale:Float, antialias:Bool):RatingPopUp {
        return add(new RatingPopUp(x, y, img, scale, antialias).smallThing());
    }
}

class RatingPopUp extends FlxSprite {
    public var time:Float;

    public override function new(x:Float, y:Float, img:FlxGraphicAsset, ?scale:Float = 1, ?antialias:Bool = true) {
        super(x, y, img);
        this.scale.set(scale, scale);
        antialiasing = antialias;
    }

    public function bigThing() {
        acceleration.y = 550;
        velocity.y = -FlxG.random.float(140, 175);
        velocity.x = -FlxG.random.float(0, 10);
        time = Conductor.crochet * 0.001;
        return this;
    }

    public function comboThing() {
		acceleration.y = 600;
		velocity.y = -150;
		velocity.x = FlxG.random.float(1, 10);
        time = Conductor.crochet * 0.001;
        return this;
    }

    public function smallThing() {
        acceleration.y = FlxG.random.float(200, 300);
        velocity.y = -FlxG.random.float(140, 160);
        velocity.x = FlxG.random.float(-5, 5);
        time = Conductor.crochet * 0.002;
        return this;
    }

    public override function update(elapsed:Float) {
        time -= elapsed;
        if (time < 0) {
            if (time <= -0.2) {
                RatingPopUpGroup.instance.remove(this, true);
                return destroy();
            }
            alpha = 1 + (time * 5);
        }

        super.update(elapsed);
    }
}