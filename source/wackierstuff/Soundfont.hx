package wackierstuff;

import CoolUtil.ScriptHelper;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flxanimate.data.AnimationData.OneOfTwo;

//todo: a lot
class Soundfont {
    /**
        Create a soundfont object. This doesn't load the soundfont, use `.load()` for that.

        I recommend Polyphone for creating soundfonts.
    **/
    public function new() {
        
    }

    /**
        Load a soundfont file
    **/
    public function load(path:String, modName:String) {

    }

    /**
        Logs soundfont information in the console, and as a `Array<String>`
    **/
    public function soundfontInfo() {
        var result = new Array<String>();
    }
    public var bank(default, set):Int = 0;
    public var patch(default, set):Int = 0;
    public var detune(default, set):Float = 0;

    /**
        Shortcut for setting `bank` and `patch` individually
    **/
    public function setInstrument(bank:Int, patch:Int) {
        this.bank = bank;
        this.patch = patch;
    }

    /**
        Play a MIDI note.
    **/
    public function playNote(pitch:Int, length:Float) {

    }

    /**
        Stop all MIDI notes. Doesn't instantly end notes, use `.silence()` for that.
    **/
    public function stop() {

    }

    /**
        Tween the pitch of currently playing notes.
    **/
    public function pitchbend(detune:Float, time:Float, ?ease:OneOfTwo<Float->Float, String> = null) {
        if (pitchbendTween != null)
            pitchbendTween.cancel();
        if (Std.isOfType(ease, String))
            ease = ScriptHelper.getEaseFromString(ease);
        pitchbendTween = FlxTween.tween(this, {detune: detune}, time, {ease: ease == null ? FlxEase.linear : ease});
    }

    /**
        The tween created by `.pitchbend()`.
    **/
    public var pitchbendTween:FlxTween;

    /**
        Stop all MIDI notes, as well as entirely cutting off playback of currently playing notes.
    **/
    public function silence() {

    }

    function set_patch(value:Int):Int {
        throw new haxe.exceptions.NotImplementedException();
    }

    function set_detune(value:Float):Float {
        throw new haxe.exceptions.NotImplementedException();
    }

    function set_bank(value:Int):Int {
        throw new haxe.exceptions.NotImplementedException();
    }
}