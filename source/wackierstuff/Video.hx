package wackierstuff;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Video extends FlxSprite {
    
}

class VideoSubState extends MusicBeatSubstate {
    public var video:Video;
    public var next:()->Void = null;
    public var skippable:Bool = true;
    public var skipText:FlxText;
    public var skipTimer:Float = -1;
    public var skipTextTween:FlxTween;

    public static function playVideo(path:String, modName:String, ?stateType:Bool = false) {
        var state = new VideoSubState();
        //todo: video loading
        if (stateType) {
            FlxG.state.switchTo(state);
        } else {
            FlxG.state.openSubState(state);
        }
    }

    public override function create() {
        super.create();
        video = new Video();
        add(video);
        skipText = new FlxText(10, FlxG.height + 8, 0, "Press " + Options.getUIControlName("accept") + " again to skip");
        add(skipText);
    }

    public override function update(elapsed:Float) {
        if (!skippable)
            return super.update(elapsed);
        if (controls.ACCEPT) {
            if (skipTimer == -1) {
                if (skipTextTween != null)
                    skipTextTween.cancel();
                skipTimer = 4;
                skipTextTween = FlxTween.tween(skipText, {y: FlxG.height - 20}, 0.5, {ease: FlxEase.backOut});
            } else {
                videoDone();
            }
        } else if (skipTimer != 0) {
            skipTimer -= elapsed;
            if (skipTimer <= 0) {
                skipTimer = -1;
                skipTextTween = FlxTween.tween(skipText, {y: FlxG.height + 8}, 0.5, {ease: FlxEase.sineIn});
            }
        }
        super.update(elapsed);
    }

    public function videoDone() {
        if (next != null)
            next();
    }
}