package;

import flixel.FlxSprite;
import flixel.system.FlxSound;
import sys.thread.Thread;

class AsyncNullLoad {
	public var onLoad:Null<Dynamic->Void> = null;
	public var hasLoaded:Bool = false;
	public var resource:Dynamic = null;
	public var cancelled = false;

	public function new(?onLoad:Null<Dynamic->Void>) {
		this.onLoad = onLoad;
	}

	public function run(name:String) {
		Thread.create(() -> {
			resource = loadResource(name);
			hasLoaded = true;
			if (onLoad != null && !cancelled)
				onLoad(resource);
		});
		return this;
	}

	public function loadResource(name:String):Dynamic {
		return null;
	}
}

class AsyncAudioLoad extends AsyncNullLoad {
	override function loadResource(name:String) {
		return new FlxSound().loadEmbedded(name);
	}
}

class AsyncImageLoad extends AsyncNullLoad {
	override function loadResource(name:String) {
		return new FlxSprite().loadGraphic(name);
	}
}