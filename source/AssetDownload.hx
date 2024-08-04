import CoolUtil.MultiStepResult;

class AssetDownloadListFile {
    public var songDownloads:Map<String, Array<String>>;
}

class AssetDownloadList extends MultiStepResult {
    private static var whitelist:Array<String> = [
        "https://raw.githubusercontent.com/",
        "https://drive.google.com/uc",
        "https://www.dropbox.com/"
    ];

    public var perStep:Null<Void->Void>;
    public var modName:String;

    public override function new(items:Array<String>, then:Void->Void, modName:String, ?perStep:Void->Void = null) {
        this.perStep = perStep;
        super(items.length, then);
    }

    public override function fulfillStep(num:Int) {
        if (!steps[num])
            perStep();
        return super.fulfillStep(num);
    }
}

class AssetDownload {
    public var parent:AssetDownloadList;
    public var num:Int;

    public function new(items:Array<String>) {
        
    }
}