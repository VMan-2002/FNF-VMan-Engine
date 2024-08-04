package source;

import ManiaInfo.SwagMania;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.touch.FlxTouch;

class TouchControls extends FlxTypedGroup<TouchButton> {
    public function new(?menu:Bool = true) {
        super();
        exists = menu ? Options.instance.touch_menuEnabled : Options.instance.touch_enabled;
    }

    public function addButton(x:Float, y:Float, width:Float, height:Float, icon:String) {
        return add(new TouchButton(x, y, width, height, icon));
    }

    public function addButtonRow(x:Float, y:Float, width:Float, height:Float, icons:Array<String>) {
        var sep = width / icons.length;
        for (i => iconname in icons.keyValueIterator()) {
            addButton(x + (sep * i), y, sep, height, iconname);
        }
    }

    public function addManiaButtonRow(x:Float, y:Float, width:Float, height:Float, mania:SwagMania) {
        var icons = mania.arrows;
        var sep = width / icons.length;
        for (i => iconname in icons.keyValueIterator()) {
            addButton(x + (sep * i), y, sep, height, ManiaInfo.StrumlineArrow.get(iconname)).setColor(NoteSplash.noteSplashColorsDefault.get(iconname));
        }
    }

    public inline function justPressed(num:Int)
        return members[num].justPressed();

    public inline function pressed(num:Int)
        return members[num].pressed();

    public inline function justReleased(num:Int)
        return members[num].justReleased();

    public inline function released(num:Int)
        return members[num].released();
}

enum TouchButtonState {
    justPressed;
    pressed;
    justReleased;
    released;
}

class TouchButton extends FlxTypedGroup<FlxSprite> {
    public static var touches:Array<FlxTouch> = new Array<FlxTouch>();

    public var myTouches:Array<FlxTouch> = new Array<FlxTouch>();
    public var touchState:TouchButtonState = TouchButtonState.released;

    public var bgSprite:FlxSprite;
    public var iconSprite:FlxSprite;

    static var icons = [
        "space", "trileft", "triright", "tridown", "triup", "right",
        "down", "left", "up", "gtstrum", "pause", "retry",
        "back", "accept", "uidown", "uiright", "uiup", "uileft"
    ];

    public function new(x:Float, y:Float, width:Float, height:Float, icon:String) {
        super();
        add(bgSprite = new FlxSprite(x, y));

        add(iconSprite = new FlxSprite(x + ((width - 128) / 2), y + ((height - 128) / 2)));
        iconSprite.loadGraphic(Paths2.image("menu/touchIcons", "shared/images/", ModLoad.primaryMod.id), 128, 128);
        var ind = icons.indexOf(icon.toLowerCase());
        iconSprite.animation.add("idle", [ind == -1 ? 0 : ind], 8, false);
        iconSprite.animation.play("idle");
    }

    public override function update(elapsed:Float) {
        if (touchState == TouchButtonState.justPressed)
            touchState = TouchButtonState.pressed;
        else if (touchState == TouchButtonState.justReleased)
            touchState = TouchButtonState.released;

        for (touch in FlxG.touches.justStarted(touches)) {
            if (touch.justPressed && touch.overlaps(this)) {
                myTouches.push(touch);
                if (myTouches.length == 1) {
                    touchState = TouchButtonState.justPressed;
                }
            }
        };
        for (touch in myTouches) {
            if (touch.justReleased) {
                myTouches.remove(touch);
                if (myTouches.length == 0) {
                    touchState = TouchButtonState.justReleased;
                }
            }
        }

        return super.update(elapsed);
    }

    public inline function setColor(col:Int)
        return bgSprite.color = iconSprite.color = col;

    public inline function pressed()
        return touchState == TouchButtonState.pressed;

    public inline function justPressed()
        return touchState == TouchButtonState.justPressed;

    public inline function justReleased()
        return touchState == TouchButtonState.justReleased;

    public inline function released()
        return touchState == TouchButtonState.released;
}