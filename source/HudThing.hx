package;

import Translation;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class HudThing extends FlxGroup
{
	public var items = new Array<String>();
	public var vertical:Bool = false;
	public var textThing:FlxText;
	
	public function new(x:Float, y:Float, list:Array<String>, ?vertical:Bool = false)
	{
		super();
		
		items = list;
		this.vertical = vertical;
		textThing = new FlxText(x, y, 0, "", 20);
		textThing.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		textThing.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 1, 1);
		Translation.setObjectFont(textThing, "vcr font");
		add(textThing);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	public function getInfoText() {
		var text = "";
		var noteThing = PlayState.instance.songHits + PlayState.instance.songMisses;
		for (i in 0...items.length) {
			if (i > 0) {
				text += vertical ? "\n" : " | ";
			}
			switch(items[i]) {
				case "score":
					text += Translation.getTranslation("hud_score", "playstate", [Std.string(PlayState.instance.songScore)]);
				case "misses":
					text += Translation.getTranslation("hud_misses", "playstate", [Std.string(PlayState.instance.songMisses)]);
				case "health":
					text += Translation.getTranslation("hud_health", "playstate", [trimNoPercent(PlayState.instance.health / 2)]);
				case "song":
					text += PlayState.instance.curSong;
				case "difficulty":
					text += Translation.getTranslation(PlayState.instance.storyDifficultyText, "difficulty");
				case "accSimple":
					text += Translation.getTranslation("hud_accsimple", "playstate", [trimNoPercent(PlayState.instance.songHits / noteThing)]);
				case "accRating":
					text += Translation.getTranslation("hud_accrating", "playstate", [trimNoPercent(PlayState.instance.songScore / (noteThing * 350))]);
				case "fc":
					if (PlayState.instance.songMisses >= 10) {
						text += Translation.getTranslation("fc_clear", "playstate");
					} else if (PlayState.instance.songMisses > 0) {
						text += Translation.getTranslation("fc_sdcb", "playstate");
					} else if (PlayState.instance.bads + PlayState.instance.shits > 0) {
						text += Translation.getTranslation("fc_fc", "playstate");
					} else if (PlayState.instance.goods > 0) {
						text += Translation.getTranslation("fc_gfc", "playstate");
					} else {
						text += Translation.getTranslation("fc_sfc", "playstate");
					}
				case "sicks":
					text += Translation.getTranslation("hud_sicks", "playstate", [Std.string(PlayState.instance.sicks)]);
				case "goods":
					text += Translation.getTranslation("hud_goods", "playstate", [Std.string(PlayState.instance.goods)]);
				case "bads":
					text += Translation.getTranslation("hud_bads", "playstate", [Std.string(PlayState.instance.bads)]);
				case "shits":
					text += Translation.getTranslation("hud_shits", "playstate", [Std.string(PlayState.instance.shits)]);
				case "hits":
					text += Translation.getTranslation("hud_hits", "playstate", [Std.string(PlayState.instance.songHits)]);
				case "totalnotes":
					text += Translation.getTranslation("hud_totalnotes", "playstate", [Std.string(noteThing)]);
				case "engine":
					//this one should always show on the hud thing in the corner
					text += Translation.getTranslation(Options.botplay ? "hud_engine botplay" : "hud_engine", "playstate");
			}
		}
		return vertical ? text+"\n" : text; //vertical text needs an additional newline idk why
	}
	
	public inline function updateInfo() {
		textThing.text = getInfoText();
	}
	
	public inline static function trimPercent(num:Float) {
		return Math.isNaN(num) ? "0%" : FlxMath.roundDecimal(num * 100, 2) + "%";
	}
	
	public inline static function trimNoPercent(num:Float):String {
		return Math.isNaN(num) ? "0" : Std.string(FlxMath.roundDecimal(num * 100, 2));
	}
}
