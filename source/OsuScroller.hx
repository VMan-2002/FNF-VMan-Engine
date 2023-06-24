package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class OsuScroller extends FlxTypedGroup<FlxSprite> {
    //recreate the scrolly thing with the yellow bars from the osu!mania editor.

    var dragbar:FlxSprite;
    var bg:FlxSprite;
    var state:ChartingState;
    var rows:Array<Int> = new Array<Int>();
    var rowPos:Array<Int> = new Array<Int>();
    var shouldUpdateBitmap:Bool = true;
    var maximum:Int = 0;
    
    #if FLX_MOUSE
    var mouseDragging:Bool = false;
    #end

	override function update(elapsed:Float) {
		super.update(elapsed);
        if (shouldUpdateBitmap)
            updateBitmap();
        #if FLX_MOUSE
        if (FlxG.mouse.justPressed)
            mouseDragging = bg.getScreenBounds(FlxRect.weak()).containsPoint(FlxPoint.weak(FlxG.mouse.screenX, FlxG.mouse.screenY));
        if (FlxG.mouse.justReleased)
            mouseDragging = false;
        if (mouseDragging) {
            dragbar.y = CoolUtil.clamp(FlxG.mouse.screenY, bg.y, bg.y + bg.height);
            var percentage:Float = (dragbar.y - bg.y) / bg.height;
            FlxG.sound.music.time = FlxG.sound.music.length * percentage;
            state.vocals.pause();
            state.vocals.time = FlxG.sound.music.time;
            var newSection = state.curSection;
            while (FlxG.sound.music.time < state.sectionStartTime(newSection))
                newSection--;
            if (newSection == state.curSection) { //i like optimiaztaion :)
                while (state._song.notes.length > newSection && FlxG.sound.music.time > state.sectionStartTime(newSection + 1))
                    newSection++;
            }
            if (newSection != state.curSection)
                state.changeSection(newSection, false);
        } else
        #end
        {
            dragbar.y = FlxMath.lerp(bg.y, bg.y + bg.height, FlxG.sound.music.time / FlxG.sound.music.length);
        }
	}

    public function new(state:ChartingState, x:Float) {
        this.state = state;
        super();
        bg = new FlxSprite().makeGraphic(135, FlxG.height - 10, FlxColor.GRAY, true);
        bg.moves = false;
        bg.y = 5;
        add(bg);
        bg.updateHitbox();
        dragbar = new FlxSprite().makeGraphic(135, 2, FlxColor.WHITE);
        dragbar.moves = false;
        add(dragbar);

        bg.x = x;
        dragbar.x = x;

        bg.scrollFactor.y = 0;
        dragbar.scrollFactor.y = 0;
    }

	public function setRowCount(n:Int) {
        var wasLen = rows.length;
        while (rows.length > n) {
            rows.pop();
        }
        while (rows.length < n) {
            rows.push(state._song.notes.length > rows.length ? state._song.notes[rows.length].sectionNotes.length : 0);
        }
        updateRowPos(wasLen - 1);
        shouldUpdateBitmap = true;
    }

	public function setAmountForRow(n:Int, c:Int) {
        var newMax = false;
        if (rows[n] == maximum && c < rows[n]) {
            maximum = -1;
        } else if (c > maximum) {
            maximum = c;
        }
        rows[n] = c;
        shouldUpdateBitmap = true;
    }

    public function updateRowPos(from:Int) {
        while (from < rows.length) {
            rowPos[from] = Math.floor(state.sectionStartTime(from));
            from++;
        }
    }

    function updateBitmap() {
        shouldUpdateBitmap = false;
        if (maximum == -1) {
            for (i in rows) {
                if (i > maximum) {
                    maximum = i;
                }
            }
        }
        var bitmap:BitmapData = bg.pixels;
        rectangle(bitmap, 0, 0, bg.frameWidth, bg.frameHeight, FlxColor.GRAY);
        var sep:Float = (FlxG.height - 14) / FlxG.sound.music.length;
        //var rowHeight:Int = Math.floor(Math.max(Math.min(((FlxG.height - 14) / rows.length), 10 + (300 / rows.length)), 1));
        var rowHeight:Int = sep > 2.25 ? 2 : 1;
        for (i in 0...rows.length) {
            var barY = Math.round(3 + (sep * rowPos[i]));
            if (rows[i] == 0)
                rectangle(bitmap, 2, barY, bg.frameWidth - 4, rowHeight, 0xFF404040);
            else
                rectangle(bitmap, 2, barY, Math.ceil((bg.frameWidth - 4) * (rows[i] / maximum)), rowHeight, FlxColor.YELLOW);
        }
		bg.pixels = bitmap;
    }

    inline function rectangle(bitmap:BitmapData, x:Int, y:Int, w:Int, h:Int, color:Int) {
        bitmap.fillRect(new Rectangle(x, y, w, h), color);
    }
}