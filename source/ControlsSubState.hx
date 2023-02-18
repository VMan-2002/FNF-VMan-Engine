package;

//some things in here are copied from my own code in a psych engine mod (this should be fine, right?)

import Discord.DiscordClient;
import ManiaInfo;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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
			"Set UI Alt Controls",
			"Reset UI Controls",
			//"Color By Quantization",
			//"Change Color", //todo: this
			//"Change Strumline Color",
			//"Change Color Advanced"
		];
	}

	var uiControlStuffNames:Array<String> = [
		"set ui controls",
		"set ui alt controls",
		"reset ui controls"
	];
	
	var cachedFrames = new Map<String, FlxSprite>();
	
	var bindingControl:Bool = false;
	
	private var grpNoteStuff = new FlxTypedGroup<FlxSprite>();
	private var grpNoteText = new FlxTypedGroup<FlxText>();
	
	private var ncSelMania:Int;
	private var ncManiaID:String;
	private var ncManiaTitle:Alphabet;
	private var ncSelectedNote:Int;
	private var ncTexts = new FlxTypedGroup<Alphabet>();

	private var moveSidewaysHold:Float = 0;
	var ManiaName:String;
	
	var ncControls:Map<String, Array<Array<Int>>> = Options.controls;

	var presenceKeys = new Array<String>();

	var keyNameText = new FlxText(0, 0, 800, "Key name").setFormat("VCR OSD Mono", 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	var controlKeyNames:Array<String> = [
		"left",
		"down",
		"up",
		"right",
		"accept",
		"back",
		"pause",
		"reset",
		"gtstrum"
	];
	var isChangingUIControls = false;

	//var tweens = new Array<FlxTween>();
	var basePositions = new Array<Float>();
	var arrowBump:Float = 0;

	var releasedEnter = false;
	
	function doAtla(name:String):FlxFramesCollection {
		if (!cachedFrames.exists(name)) {
			var a = new FlxSprite().loadGraphic(name);
			a.alpha = 0.001;
			add(a);
			cachedFrames.set(name, a);
		}
		
		return Paths.getSparrowAtlas(name);
	}
	
	function createRow(m) {
		if (m >= ManiaInfo.AvailableMania.length) {
			m = 0;
		} else if (m < 0) {
			m = ManiaInfo.AvailableMania.length - 1;
		}
		/*for (a in tweens) {
			if (a == null) {
				continue;
			}
			a.cancel();
		}*/
		ncSelMania = m;
		ncManiaID = ManiaInfo.AvailableMania[m];
		var maniastuff:SwagMania = ManiaInfo.GetManiaInfo(ncManiaID);
		if (isChangingUIControls) {
			maniastuff = {
				keys: controlKeyNames.length,
				arrows: [
					"purple", "blue", "green", "red", "accept", "back", "pause", "reset", "gtstrum"
				],
				special: false,
				specialTag: "",
				control_set: null,
				control_any: null,
				splashName: new Map<String, String>(),
				image: "",
				scale: null,
				spacing: null
			};
			ManiaName = "UI controls";
			//i do it in the most badass way possible
		} else {
			ManiaName = ManiaInfo.GetManiaName(maniastuff);
		}
		//ncManiaTitle.changeText(ManiaInfo.GetManiaName(maniastuff));
		//ncManiaTitle.screenCenter(X);
		CoolUtil.clearMembers(grpNoteStuff);
		CoolUtil.clearMembers(grpNoteText);
		var posX:Float = (-40 * maniastuff.keys) + 40;
		var shift:Float = 80;
		var lerpmode = shift * maniastuff.keys > FlxG.width;
		/*if (maniastuff.keys > 16) {
			var w:Float = FlxG.width - 80;
			posX = w * -0.5;
			shift = w / maniastuff.keys;
		}*/
		var posY = 240;
		var NoteAssetsFrames = doAtla(isChangingUIControls ? "menu/UI_CONTROLS_assets" : 'normal/'+maniastuff.image);
		for (str in maniastuff.arrows) {
			if (lerpmode) {
				posX = Math.fround(FlxMath.lerp(40, FlxG.width - 40, grpNoteStuff.length / (maniastuff.keys - 1)) - (FlxG.width / 2));
			}
			var note:FlxSprite = new FlxSprite(0, posY);
			note.frames = NoteAssetsFrames;
			note.animation.addByPrefix('idle', "arrow"+ManiaInfo.StrumlineArrow[str]);
			note.animation.addByPrefix('active', str+" confirm", false);
			note.animation.play('idle');
			note.scale.x = 0.5;
			note.scale.y = 0.5;
			note.updateHitbox();
			note.centerOffsets(true);
			note.centerOrigin();
			note.antialiasing = true;
			note.screenCenter(X);
			note.x += posX;
			basePositions[grpNoteStuff.length] = note.x;
			grpNoteStuff.add(note);
			
			var txt:FlxText = new FlxText((FlxG.width / 2) + (posX - 40), posY, 80, "---\n---", 16).setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			txt.alignment = CENTER;
			txt.updateHitbox();
			txt.antialiasing = false;
			if (Translation.usesFont) {
				Translation.setObjectFont(txt, "vcr font");
			}
			grpNoteText.add(txt);
			
			posX += shift;
		}
		ncSelectedNote = 0;
		arrowBump = (basePositions[1] - basePositions[0]) / 10;
		SelectNote();
		while (presenceKeys.length > maniastuff.keys) {
			presenceKeys.pop();
		}
		updateRowKeyNames();
		updateKeyNamePos();
	}
	
	function updateRowKeyNames() {
		var keys = ncControls.get(ncManiaID);
		if (isChangingUIControls) {
			keys = new Array<Array<Int>>();
			for (thing in Controls.controlNames) {
				keys.push(Options.uiControls.get(thing));
			}
		}
		if (keys != null) {
			for (num in 0...keys.length) {
				if (keys[num] != null) {
					var i = keys[num];
					//grpNoteText.members[num].text = '${InputFormatter.getKeyName(i[0])}\n${InputFormatter.getKeyName(i[1])}';
					grpNoteText.members[num].text = '${ConvertKey(i[0])}\n${ConvertKey(i[1])}';
					presenceKeys[num] = i[0] > 0 ? ConvertKey(i[0], false) : ConvertKey(i[1], false);
				} else {
					presenceKeys[num] = "none";
				}
			}
		} else {
			presenceKeys = [];
			while (presenceKeys.length < grpNoteText.members.length) {
				presenceKeys.push("none");
			}
		}
		DiscordClient.changePresenceSimple("controls", ManiaName+": "+presenceKeys.join(", "));
	}

	function updateKeyNamePos() {
		if (isChangingUIControls) {
			keyNameText.text = controlKeyNames[ncSelectedNote];
		} else {
			keyNameText.text = '#${ncSelectedNote}';
		}
		keyNameText.x = basePositions[ncSelectedNote] + 40;
		keyNameText.y = grpNoteStuff.members[ncSelectedNote].y + 84;
	}
	
	function SelectNote(?n:Int = 0, ?direction:Float = 0) {
		if (ncSelectedNote != n) {
			grpNoteStuff.members[ncSelectedNote].animation.play('idle');
			grpNoteStuff.members[ncSelectedNote].centerOffsets();
			grpNoteStuff.members[ncSelectedNote].centerOrigin();
			if (n >= grpNoteStuff.length) {
				n = 0;
			} else if (n < 0) {
				n = grpNoteStuff.length - 1;
			}
			ncSelectedNote = n;
		}
		grpNoteStuff.members[ncSelectedNote].animation.play('active', true);
		grpNoteStuff.members[ncSelectedNote].centerOffsets();
		grpNoteStuff.members[ncSelectedNote].centerOrigin();
		if (direction != 0) {
			/*if (tweens[ncSelectedNote] != null) {
				tweens[ncSelectedNote].cancel();
			}*/
			FlxTween.cancelTweensOf(grpNoteStuff.members[ncSelectedNote]);
			grpNoteStuff.members[ncSelectedNote].x += direction;
			/*tweens[ncSelectedNote] =*/ FlxTween.tween(grpNoteStuff.members[ncSelectedNote], {x:basePositions[ncSelectedNote]}, 1.5, {ease:FlxEase.expoOut});
		}
		updateKeyNamePos();
	}
	
	/*function addNcText(tx:String):Alphabet {
		var a = new Alphabet(0, ncTexts.length * 42, tx);
		a.screenCenter(X);
		//a.forceX = a.x;
		//a.yAdd = a.y;
		a.yMulti = 60;
		a.isMenuItem = true;
		ncTexts.add(a);
		return a;
	}*/

	public override function moveSelection(by:Int) {
		if (by == 0) {
			return super.moveSelection(0); //dunno how you'd do that but sure
		}
		var was = curSelected;
		super.moveSelection(by);
		isChangingUIControls = uiControlStuffNames.contains(curSelectedName);
		if (isChangingUIControls != (uiControlStuffNames.contains(textMenuItems[was].toLowerCase()))) {
			createRow(ncSelMania); //amazing way of making the ui controls
			keyNameText.visible = isChangingUIControls;
		}
		trace("now selected "+textMenuItems[curSelected]);
	}

	public override function new()
	{
		super();
		DiscordClient.changePresenceSimple("controls");
		keyNameText.offset.x = 400;
		Translation.setObjectFont(keyNameText, "vcr font");
		keyNameText.visible = false;
		add(keyNameText);

		controlKeyNames = controlKeyNames.map(function(a) {
			return Translation.getTranslation("uiKey_"+a, "optionsMenu");
		});
		
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
			case "set ui controls" | "set ui alt controls":
				return ["Change the other controls, such as those for the UI."];
			case "change color":
				return ["Change the colors of notes. Left/Right to change the key selected."];
			case "change color advanced":
				return ["Change the colors of notes in a more detailed way."];
			case "change strumline color":
				return ["Change the color of the strumline.", "", "change color advanced"];
			case "color by quantization":
				return ["If enabled, note color is based on it's fractional position within the beat."];
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
				if (Options.uiControls.get("accept").contains(newKey)) { //Enter key
					if (!releasedEnter) {
						releasedEnter = true;
						return;
					}
				}
				if (newKey == FlxKey.ESCAPE && !isChangingUIControls) {
					bindingControl = false;
					return updateRowKeyNames();
				}
				if (isChangingUIControls) {
					Options.uiControls[Controls.controlNames[ncSelectedNote]][curSelectedName == "set ui alt controls" ? 1 : 0] = newKey;
				} else {
					if (!ncControls.exists(ncManiaID)) {
						var thing = new Array<Array<Int>>();
						while (thing.length < grpNoteStuff.length) {
							thing.push(new Array<Int>());
						}
						ncControls.set(ncManiaID, thing);
					}
					ncControls[ncManiaID][ncSelectedNote][curSelectedName == "set alt bind" ? 1 : 0] = newKey;
				}
				updateRowKeyNames();
				bindingControl = false;
				canMoveSelected = true;
			}
			return;
		}
		
		var isMoveLR = controls.LEFT_P != controls.RIGHT_P;
		var isLeft = controls.LEFT_P;
		if (!isMoveLR && controls.LEFT != controls.RIGHT) {
			moveSidewaysHold += FlxG.elapsed;
			if (moveSidewaysHold > 0.5) {
				moveSidewaysHold -= 0.06;
				isMoveLR = true;
				isLeft = controls.LEFT;
			}
		} else {
			moveSidewaysHold = 0;
		}
		switch(name) {
			case "change mania":
				if (isMoveLR) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					if (isLeft) {
						createRow(ncSelMania - 1);
					} else {
						createRow(ncSelMania + 1);
					}
					updateDescription();
				}
			case "set bind" | "set alt bind" | "change color" | "change color advanced" | "change strumline color":
				moveableNote(isMoveLR, isLeft);
			case "set ui controls" | "set ui alt controls" | "reset ui controls":
				moveableNote(isMoveLR, isLeft);
				//FlxG.sound.play(Paths.sound('scrollMenu'));
				//Options.ghostTapping = !Options.ghostTapping;
		}
	}
	
	override function optionAccept(name:String) {
		if (bindingControl) {
			return false;
		}
		switch(name) {
			case "set bind" | "set alt bind" | 'set ui controls' | 'set ui alt controls':
				bindingControl = true;
				canMoveSelected = false;
				releasedEnter = false;
			case "change color" | "change color advanced" | "change strumline color":
				//colors
			case "reset ui controls":
				//reset
				Options.uiControls = Options.uiControlsDefault;
				updateRowKeyNames();
		}
		return false;
	}
	
	override function optionBack() {
		if (!bindingControl) {
			for (i in ncControls.keys()) {
				Options.controls.set(i, ncControls.get(i));
			}
			Options.applyControls();
			return true;
		}
		return false;
	}
	
	inline function moveableNote(does:Bool, left:Bool) {
		if (does) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (left) {
				SelectNote(ncSelectedNote - 1, -arrowBump);
			} else {
				SelectNote(ncSelectedNote + 1, arrowBump);
			}
		}
	}
	
	public static function ConvertKey(n:Int, ?useTranslat:Bool = true) {
		if (n <= 0) {
			return useTranslat ? Translation.getTranslation("empty", "optionsKeys", null, "---") : "none";
			//return "---";
		}
		var str:String = FlxKey.toStringMap.get(n);
		if (useTranslat && Translation.translation["optionsKeys"].exists(str)) {
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
			return ".";
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
			return CoolUtil.capitalizeFirstLetter(str, true);
		}
	}
}
