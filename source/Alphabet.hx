package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	public var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;
	
	var isFlxText:Bool = Translation.usesFont;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false)
	{
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
	}
	
	public function changeText(text:String) {
		clearLetters();
		this.text = text;
		addText();
	}
	
	public inline function clearLetters() {
		CoolUtil.clearMembers(this);
	}
	
	public function addFlxText() {
		var tx = new FlxText(0, 0, widthOfWords, text);
		tx.setFormat(60, 0xFF000000);
		tx.setBorderStyle(OUTLINE, 0xFFFFFFFF, 6, 2);
		Translation.setObjectFont(tx, "alphabet");
		add(tx);
		tx.antialiasing = true;
		tx.updateHitbox();
		tx.fieldWidth = tx.textField.textWidth + 16;
		//width = tx.textField.textWidth;
		//height = tx.textField.textHeight;
	}

	public function addText()
	{
		if (isFlxText) {
			return addFlxText();
		}
		doSplitWords();

		var xPos:Float = 0;
		var spaceCount:Int = 0;
		for (character in splitWords) {
			// if (character.fastCodeAt() == " ")
			// {
			// }

			if (character == " ") 
				spaceCount++;

			var isLet = AlphaCharacter.alphabet.contains(character.toLowerCase());
			var isNum = !isLet && AlphaCharacter.numbers.contains(character);
			var isSym = !isNum && !isNum && AlphaCharacter.symbols.contains(character);

			if (isLet || isNum || isSym)
				// if (AlphaCharacter.alphabet.contains(character.toLowerCase()))
			{
				if (lastSprite != null) {
					xPos = lastSprite.x + lastSprite.width + (spaceCount * 40);
					spaceCount = 0;
				}

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);

				if (isBold)
					letter.createBold(character);
				else if (isNum)
					letter.createNumber(character);
				else if (isSym)
					letter.createSymbol(character);
				else
					letter.createLetter(character);

				add(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void {
		splitWords = _finalText.split("");
	}

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = !isNumber && AlphaCharacter.symbols.contains(splitWords[loopNum]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			#end

			if (!AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)
				// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)

			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				letter.row = curRow;
				if (isBold) {
					letter.createBold(splitWords[loopNum]);
				} else {
					if (isNumber)
						letter.createNumber(splitWords[loopNum]);
					else if (isSymbol)
						letter.createSymbol(splitWords[loopNum]);
					else
						letter.createLetter(splitWords[loopNum]);

					letter.x += 90;
				}

				if (FlxG.random.bool(40)) {
					FlxG.sound.play(Paths.soundRandom("GF_", 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);
			x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16);
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'\"!?•";
	//todo: draw these bold symbols: |~#$*;<=>@^'

	public var row:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = FlxAtlasFrames.fromSparrow(Paths2.image('alphabet'), Paths.file('images/alphabet.xml'));
		frames = tex;
		moves = false;

		antialiasing = true;
	}

	public function createBold(letter:String) {
		var animLetter = letter;
		var newOffset = FlxPoint.weak(0, 0);
		var extraWidth:Float = 0;
		switch(letter) {
			case ".":
				newOffset.set(0, -38);
			case ",":
				animLetter = "comma";
				newOffset.set(0, -38);
			case "•":
				animLetter = ".";
				newOffset.set(-10, -20);
				extraWidth = 20;
			case ":":
				newOffset.set(0, -12);
			case "(" | ")" | "[" | "]":
				newOffset.set(0, 10);
			case "-":
				newOffset.set(0, -20);
			case "+":
				animLetter = "plus";
				newOffset.set(0, -3);
			case "_":
				animLetter = "-";
				newOffset.set(0, -48);
			case "'":
				animLetter = "single quote";
			case "\"":
				animLetter = "double quote";
			case "%":
				animLetter = "percent";
			case "!":
				animLetter = "exclamation";
			case "?":
				animLetter = "question";
			default:
				animLetter = letter.toUpperCase();
		}
		animation.addByPrefix(letter, animLetter + " bold", 24);
		animation.play(letter);
		updateHitbox();
		offset.copyFrom(newOffset);
		width += extraWidth;
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter) {
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}
