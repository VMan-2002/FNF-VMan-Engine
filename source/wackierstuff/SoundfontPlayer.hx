package wackierstuff;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

typedef SoundfontNote = {
    pitch:Int,
    length:Int,
    
}

typedef SoundfontPitchEffect = {
    pos:Int,
    length:Int,
    type:Float,
}

//todo: a lot
class SoundfontPlayer {
    public function new() {
        
    }

    public function add(obj:Soundfont) {
        
    }

    public var notes:Array<SoundfontNote>;

    /**
        For scripting
    **/
    public static function newSoundfontEffect():SoundfontNote {
        return {
            pitch: 0,
            length: 0
        }
    }
}