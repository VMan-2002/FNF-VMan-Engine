package;

import CoolUtil.TwoStrings;

typedef SwagCutsceneItem = {
    type:String,
    num:Null<Int>,
    animation:String,
    charName:Null<String>
}

typedef SwagCutsceneThread = {
    items:Array<SwagCutsceneItem>,
    initStart:Null<Bool>
}

class Cutscene {
	public var whenDone:Bool->Void;
    public var threads:Array<CutsceneThread>;
    public var origChars:Array<TwoStrings>;

    public function new() {
        for (i in 0...Character.activeArray.length)
            origChars[i] = {one: Character.activeArray[i].curCharacter, two:Character.activeArray[i].myMod};
    }

    public function addThread(data:Array<SwagCutsceneItem>, ?wait:Null<Bool>) {
        threads.push(new CutsceneThread(data, this, wait == true));
    }

    public function destroy() {
        for (i in 0...Character.activeArray.length) {
            if (Character.activeArray[i].curCharacter != origChars[i].one || Character.activeArray[i].myMod != origChars[i].two)
                Character.activeArray[i].changeCharacter(origChars[i].one, origChars[i].two);
        }
    }
}

class CutsceneThread {
    public var parent:Cutscene;
    public var data:Array<SwagCutsceneItem>;
    public var waiting:Bool = false;

    public function new(data:Array<SwagCutsceneItem>, parent:Cutscene, wait:Bool) {
        this.data = data;
        this.parent = parent;
        waiting = wait;
    }

    public static function runItem(item:SwagCutsceneItem) {
        var target = item.num != null ? Character.activeArray[item.num] : Character.findSuitableCharacter(item.charName);
        if (item.num != null && item.charName != null)
            target.changeCharacter(item.charName, PlayState.modName);
    }
}