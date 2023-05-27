package atlas;

import flxanimate.FlxAnimate;

class AtlasTest extends FlxAnimate {
    public var myAnims = [];

    public function new(x:Float, y:Float, char:String) {
        //Tankman cutscene test
        super(x, y, Paths.file("images/characters/Parents_Christmas_Atlas"));
        addAnim("idle", "Christmas_Idle", 12);
        addAnim("singDOWN", "CDad_Down", 24);
        addAnim("singDOWN-alt", "CMom_Down", 24);
        addAnim("singUP", "CDad_Up", 24);
        addAnim("singUP-alt", "CMom_Up", 24);
        addAnim("singLEFT", "CDad_Left", 24);
        addAnim("singLEFT-alt", "CMom_Left", 24);
        addAnim("singRIGHT", "CDad_Right", 12);
        addAnim("singRIGHT-alt", "CMom_Right", 12);
        playAnim("idle");
    }

    public function addAnim(name:String, prefix:String, ?framerate:Int = 24, ?indices:Array<Int>, ?loop:Bool = false) {
        if (!myAnims.contains(name))
            myAnims.push(name);
        if (indices == null) {
            anim.addBySymbol(name, prefix, framerate, loop, 0, 0);
            return;
        }
        anim.addBySymbolIndices(name, prefix, indices, framerate, loop, 0, 0);
    }

    public function playAnim(name, ?force:Bool = true) {
        anim.play(name, force);
    }
}