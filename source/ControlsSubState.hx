package;

//some things in here are copied from my own code in a psych engine mod (this should be fine, right?)

import ManiaInfo;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;
//import 


class ControlsSubState extends OptionsSubStateBasic
{
	override function optionList() {
		backSubState = 1;
		return [
			'Change Mania',
			"Set Bind",
			"Set Alt Bind",
			"Set UI Controls",
			//"Change Color", //todo: this
			//"Change Strumline Color",
			//"Change Color Advanced"
		];
	}
	
	var cachedFrames = new Map<String, FlxFramesCollection>();
	
	var bindingControl:Bool = false;
	
	private var grpNoteStuff = new FlxTypedGroup<FlxSprite>();
	private var grpNoteText = new FlxTypedGroup<FlxText>();
	
	private var ncSelMania:Int;
	private var ncManiaID:String;
	private var ncManiaTitle:Alphabet;
	private var ncSelectedNote:Int;
	private var ncTexts = new FlxTypedGroup<Alphabet>();
	var ManiaName:String;
	
	var ncControls:Map<String, Array<Array<Int>>> = Options.controls;
	
	function doAtla(name:String):FlxFramesCollection {
		//if (!cachedFrames.exists(name)) {
			//cachedFrames.set(name, Paths.getSparrowAtlas(name));
		//}
		//return cachedFrames.get(name);
		
		return Paths.getSparrowAtlas(name); //idk. tried to fix some lag but it makes crashes lmamo
	}
	
	function createRow(m) {
		if (m >= ManiaInfo.AvailableMania.length) {
			m = 0;
		} else if (m < 0) {
			m = ManiaInfo.AvailableMania.length - 1;
		}
		ncSelMania = m;
		ncManiaID = ManiaInfo.AvailableMania[m];
		var maniastuff:SwagMania = ManiaInfo.GetManiaInfo(ncManiaID);
		//ncManiaTitle.changeText(ManiaInfo.GetManiaName(maniastuff));
		//ncManiaTitle.screenCenter(X);
		grpNoteStuff.forEach(function(a:FlxSprite) {
			a.destroy();
		});
		grpNoteStuff.members = [];
		grpNoteText.forEach(function(a:FlxSprite) {
			a.destroy();
		});
		grpNoteText.members = [];
		var posX:Float = (-40 * maniastuff.keys) + 40;
		var shift:Float = 80;
		var lerpmode = maniastuff.keys > 16;
		/*if (maniastuff.keys > 16) {
			var w:Float = FlxG.width - 80;
			posX = w * -0.5;
			shift = w / maniastuff.keys;
		}*/
		var posY = 240;
		var NoteAssetsFrames = doAtla('normal/NOTE_assets');
		for (str in maniastuff.arrows) {
			if (lerpmode) {
				posX = Math.fround(FlxMath.lerp(40, FlxG.width - 40, grpNoteStuff.members.length / (maniastuff.keys - 1)) - (FlxG.width / 2));
			}
			var note:FlxSprite = new FlxSprite(0, posY);
			note.frames = NoteAssetsFrames;
			note.animation.addByPrefix('idle', "arrow"+ManiaInfo.StrumlineArrow[str]);
			note.animation.addByPrefix('active', str+" confirm", false);
			note.animation.play('idle');
			note.updateHitbox();
			note.setGraphicSize(Std.int(note.width * 0.5));
			note.centerOffsets(false);
			note.centerOrigin();
			note.antialiasing = true;
			note.screenCenter(X);
			note.x += posX;
			grpNoteStuff.add(note);
			
			var txt:FlxText = new FlxText((FlxG.width / 2) + (posX - 40), posY, 80, "---\n---", 16);
			txt.alignment = CENTER;
			txt.updateHitbox();
			txt.antialiasing = false;
			grpNoteText.add(txt);
			
			posX += shift;
		}
		ManiaName = ManiaInfo.GetManiaName(maniastuff);
		ncSelectedNote = 0;
		SelectNote(0);
		updateRowKeyNames();
	}
	
	function updateRowKeyNames() {
		var keys = ncControls.get(ncManiaID);
		if (keys != null) {
			for (i in keys) {
				if (i != null) {
					var num = keys.indexOf(i);
					//grpNoteText.members[num].text = '${InputFormatter.getKeyName(i[0])}\n${InputFormatter.getKeyName(i[1])}';
					grpNoteText.members[num].text = '${ConvertKey(i[0])}\n${ConvertKey(i[1])}';
				}
			}
		}
	}
	
	function SelectNote(?n:Int = 0) {
		grpNoteStuff.members[ncSelectedNote].animation.play('idle');
		grpNoteStuff.members[ncSelectedNote].centerOffsets();
		grpNoteStuff.members[ncSelectedNote].centerOrigin();
		if (n >= grpNoteStuff.members.length) {
			n = 0;
		} else if (n < 0) {
			n = grpNoteStuff.members.length - 1;
		}
		ncSelectedNote = n;
		grpNoteStuff.members[ncSelectedNote].animation.play('active');
		grpNoteStuff.members[ncSelectedNote].centerOffsets();
		grpNoteStuff.members[ncSelectedNote].centerOrigin();
	}
	
	function addNcText(tx:String):Alphabet {
		var a = new Alphabet(0, ncTexts.length * 42, tx);
		a.screenCenter(X);
		//a.forceX = a.x;
		//a.yAdd = a.y;
		a.yMulti = 60;
		a.isMenuItem = true;
		ncTexts.add(a);
		return a;
	}

	public override function new()
	{
		super();
		
		//optionsImage.visible = false;
		
		#if mobile
		add(new FlxText(8, FlxG.height - 48, 0, "Playing on Mobile - You'll need to connect a keyboard, the game is not touch compatible right now.", 16));
		#end
		
		add(grpNoteStuff);
		add(grpNoteText);
		createRow(ManiaInfo.AvailableMania.indexOf(OptionsMenu.wasInPlayState ? PlayState.SONG.maniaStr : "4k"));
	}
	
	override function optionDescription(name:String) {
		switch(name) {
			case "change mania":
				return ['Left/Right to change the amount of keys.', ManiaName];
			case "set bind":
				return ["Change the first keybind of a note. Left/Right to change the key selected."];
			case "set alt bind":
				return ["Change the second keybind of a note. Left/Right to change the key selected."];
			case "set ui controls":
				return ["Change the other controls, such as those for the UI."];
			case "change color":
				return ["Change the colors of notes. Left/Right to change the key selected."];
			case "change color advanced":
				return ["Change the colors of notes in a more detailed way."];
			case "change strumline color":
				return ["Change the color of the strumline.", "", "change color advanced"];
		}
		return ["is it susergion", "is it laccolith", "unknownOption"];
	}
	
	override function optionUpdate(name:String) {
		if (bindingControl) {
			//wait for a control.
			if (FlxG.keys.firstJustReleased() != -1) {
				var newKey = FlxG.keys.firstJustReleased();
				if ((FlxG.keys.pressed.C && FlxG.keys.justReleased.B) || (FlxG.keys.pressed.B && FlxG.keys.justReleased.C)) {
					//clear bind.
					newKey = -1;
				}
				if (newKey == 13 && textMenuItems[curSelected].toLowerCase() != "set ui controls") { //Enter key
					return;
				}
				if (!ncControls.exists(ncManiaID)) {
					var thing = new Array<Array<Int>>();
					while (thing.length < grpNoteStuff.members.length) {
						thing.push(new Array<Int>());
					}
					ncControls.set(ncManiaID, thing);
				}
				if (textMenuItems[curSelected].toLowerCase() == "set alt bind") {
					ncControls[ncManiaID][ncSelectedNote][1] = newKey;
				} else {
					ncControls[ncManiaID][ncSelectedNote][0] = newKey;
				}
				updateRowKeyNames();
				bindingControl = false;
				canMoveSelected = true;
			}
			return;
		}
		
		var isMoveLR = controls.LEFT_P != controls.RIGHT_P;
		switch(name) {
			case "change mania":
				if (isMoveLR) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					if (controls.LEFT_P) {
						createRow(ncSelMania - 1);
					} else {
						createRow(ncSelMania + 1);
					}
					updateDescription();
				}
			case "set bind" | "set alt bind" | "change color" | "change color advanced" | "change strumline color":
				moveableNote(isMoveLR);
			case "set ui controls":
				//FlxG.sound.play(Paths.sound('scrollMenu'));
				//Options.ghostTapping = !Options.ghostTapping;
		}
	}
	
	override function optionAccept(name:String) {
		if (bindingControl) {
			return false;
		}
		switch(name) {
			case "set bind" | "set alt bind":
				bindingControl = true;
				canMoveSelected = false;
			case "change color" | "change color advanced" | "change strumline color":
				//colors
			case "set ui controls":
				//FlxG.sound.play(Paths.sound('scrollMenu'));
				//Options.ghostTapping = !Options.ghostTapping;
		}
		return false;
	}
	
	override function optionBack() {
		if (!bindingControl) {
			for (i in ncControls.keys()) {
				Options.controls.set(i, ncControls.get(i));
			}
			return true;
		}
		return false;
	}
	
	inline function moveableNote(does:Bool) {
		if (does) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (controls.LEFT_P) {
				SelectNote(ncSelectedNote - 1);
			} else {
				SelectNote(ncSelectedNote + 1);
			}
		}
	}
	
	public static function ConvertKey(n:Int) {
		if (n <= 0) {
			return Translation.getTranslation("empty", "optionsKeys");
			//return "---";
		}
		var str:String = FlxKey.toStringMap.get(n);
		if (Translation.translation["optionsKeys"].exists(str)) {
			return Translation.getTranslation(str, "optionsKeys");
		}
		switch(str) {
			case "BACKSLASH":
			return "\\";
			case "SLASH":
			return "/";
			case "SEMICOLON":
			return ";";
			case "QUOTE":
			return "\'";
			case "LBRACKET":
			return "[";
			case "RBRACKET":
			return "]";
			case "COMMA":
			return ",";
			case "PERIOD":
			return ",";
			case "GRAVEACCENT":
			return "~";
			case "MINUS":
			return "-";
			case "PLUS":
			return "=";
			case "NUMPADPLUS":
			return "#+";
			case "NUMPADMULTIPLY":
			return "#*";
			case "NUMPADDIVIDE":
			return "#/";
			case "NUMPADPERIOD":
			return "#.";
			case "NUMPADONE":
			return "#1";
			case "NUMPADTWO":
			return "#2";
			case "NUMPADTHREE":
			return "#3";
			case "NUMPADFOUR":
			return "#4";
			case "NUMPADFIVE":
			return "#5";
			case "NUMPADSIX":
			return "#6";
			case "NUMPADSEVEN":
			return "#7";
			case "NUMPADEIGHT":
			return "#8";
			case "NUMPADNINE":
			return "#9";
			case "NUMPADZERO":
			return "#0";
			case "ONE":
			return "1";
			case "TWO":
			return "2";
			case "THREE":
			return "3";
			case "FOUR":
			return "4";
			case "FIVE":
			return "5";
			case "SIX":
			return "6";
			case "SEVEN":
			return "7";
			case "EIGHT":
			return "8";
			case "NINE":
			return "9";
			case "ZERO":
			return "0";
			case "PAGEUP":
			return "PgUp";
			case "PAGEDOWN":
			return "PgDn";
			case "BACKSPACE":
			return "BckSp.";
			case "ESCAPE":
			return "Esc";
			case "SPACE":
			return str;
			default:
			if (str.length == 1) {
				return str;
			}
			return str.charAt(0)+str.substr(1).toLowerCase();
		}
	}
}
