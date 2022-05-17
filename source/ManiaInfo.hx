package;

import lime.utils.Assets;
import Controls;
import Math;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
//import ClientPrefs;
//import lime;

import flixel.input.keyboard.FlxKey;

using StringTools;

typedef SwagMania = {
	var keys:Int;
	var arrows:Array<String>;
	var controls:Array<String>;
	var special:Bool;
	var specialTag:String;
	var control_set:Null<Array<Array<Int>>>;
	var control_any:Null<Array<Int>>;
	var splashName:Map<String, String>;
	// for unhardcoded
	var scale:Null<Float>;
	var spacing:Null<Float>;
}

class ManiaInfo {
	public static var StrumlineArrow:Map<String, String> = [
		'purple' => "LEFT",
		'blue' => "DOWN",
		'green' => "UP",
		'red' => "RIGHT",
		'white' => "SPACE",
		'yellow' => "LEFT",
		'violet' => "DOWN",
		'darkred' => "UP",
		'dark' => "RIGHT",
		'13a' => "TRILEFT",
		'13b' => "TRIDOWN",
		'13c' => "TRIUP",
		'13d' => "TRIRIGHT",
		'17a' => "TRILEFT",
		'17b' => "TRIDOWN",
		'17c' => "TRIUP",
		'17d' => "TRIRIGHT",
		'piano1k' => "PIANOLEFT",
		'piano2k' => "PIANOMID",
		'piano3k' => "PIANORIGHT",
		'piano4k' => "PIANOLEFT",
		'piano5k' => "PIANOMID",
		'piano6k' => "PIANOMID",
		'piano7k' => "PIANORIGHT",
		'piano8k' => "PIANOZERO",
		'pianoblack' => "PIANOBLACK"
	];
	
	public static var PixelArrowNum:Map<String, Int> = [ //used for something?
		'purple' => 0,
		'blue' => 1,
		'green' => 2,
		'red' => 3,
		'white' => 4,
		'yellow' => 5,
		'violet' => 6,
		'darkred' => 7,
		'dark' => 8,
		'13a' => 9,
		'13b' => 10,
		'13c' => 11,
		'13d' => 12,
		'17a' => 13,
		'17b' => 14,
		'17c' => 15,
		'17d' => 16,
		'piano1k' => 0,
		'piano2k' => 1,
		'piano3k' => 2,
		'piano4k' => 3,
		'piano5k' => 10,
		'piano6k' => 11,
		'piano7k' => 5,
		'piano8k' => 6,
		'piano9k' => 7,
		'pianoblack' => 8
	];
	
	public static var PixelNoteSheetWide:Int = 13; //this one is used
	
	/*public static var PixelArrowTypeNum:Map<String, Int> = [ //not actually used yet
		'purple' => 0,
		'blue' => 1,
		'green' => 2,
		'red' => 3,
		'white' => 4,
		'yellow' => 0,
		'violet' => 1,
		'darkred' => 2,
		'dark' => 3,
		'13a' => 5,
		'13b' => 6,
		'13c' => 7,
		'13d' => 8,
		'piano1k' => 0,
		'piano2k' => 1,
		'piano3k' => 2,
		'piano4k' => 3,
		'piano5k' => 10,
		'piano6k' => 11,
		'piano7k' => 5,
		'piano8k' => 6,
		'piano9k' => 7,
		'pianoblack' => 8
	];
	
	public static var PixelNoteTypeSheetWide:Int = 9; //also not actually used yet*/
	
	public static var Dir:Map<String, String> = [
		'purple' => "LEFT",
		'blue' => "DOWN",
		'green' => "UP",
		'red' => "RIGHT",
		'white' => "UP",
		'yellow' => "LEFT",
		'violet' => "DOWN",
		'darkred' => "UP",
		'dark' => "RIGHT",
		'13a' => "LEFT",
		'13b' => "DOWN",
		'13c' => "UP",
		'13d' => "RIGHT",
		'17a' => "LEFT",
		'17b' => "DOWN",
		'17c' => "UP",
		'17d' => "RIGHT",
		'piano1k' => "LEFT",
		'piano2k' => "DOWN",
		'piano3k' => "RIGHT",
		'piano4k' => "LEFT",
		'piano5k' => "DOWN",
		'piano6k' => "RIGHT",
		'piano7k' => "LEFT",
		'piano8k' => "RIGHT",
		'piano9k' => "UP",
		'pianoblack' => "UP"
	];
	
	//this was for psych engine colorswap
	/*public static var getReal:Map<String, Int> = [
		'purple' => 0,
		'blue' => 1,
		'green' => 2,
		'red' => 3,
		'white' => 4,
		'yellow' => 5,
		'violet' => 6,
		'darkred' => 7,
		'dark' => 8,
		'13a' => 9,
		'13b' => 10,
		'13c' => 11,
		'13d' => 12,
		'piano1k' => 0,
		'piano2k' => 1,
		'piano3k' => 2,
		'piano4k' => 3,
		'piano5k' => 5,
		'piano6k' => 6,
		'piano7k' => 7,
		'piano8k' => 8,
		'pianoblack' => 4
	];*/
	
	public static var AvailableMania:Array<String> = [ //for chart editor
		'1k',
		'2k', //2k
		'3k', //3k
		'4k', //4k
		'5k', //5k
		'6k', //6k
		'7k', //7k
		'8k', //8k
		'9k', //9k
		'10k', //10k
		'11k', //11k
		'12k', //12k
		'13k', //13k
		'14k', //14k
		'15k', //15k
		'16k', //16k
		'17k', //17k
		'18k', //18k
		//27, //14k
		//28, //15k
		//29, //16k
		//30, //17k
		//31, //18k
		'19k', //19k
		//32, //20k
		'21k', //21k
		'50k', //50k
		'piano', //Piano
		'105k' //105
	];
	
	public static var ManiaConvert:Map<Int, String> = [ //for upcoming unhardcoded manias holy shit
		6 => "1k", //1k
		7 => "2k", //2k
		8 => "3k", //3k
		0 => "4k", //4k
		3 => "5k", //5k
		1 => "6k", //6k
		4 => "7k", //7k
		5 => "8k", //8k
		2 => "9k", //9k
		27 => "10k", //10k
		28 => "11k", //11k
		//25 => "10k", //10k
		//26 => "11k", //11k
		21 => "12k", //12k
		20 => "13k", //13k
		29 => "14k",
		30 => "15k",
		31 => "16k",
		32 => "17k",
		33 => "18k",
		//27 => "14k", //14k
		//28 => "15k", //15k
		//29 => "16k", //16k
		//30 => "17k", //17k
		//31 => "18k", //18k
		23 => "19k", //19k
		//32 => "20k", //20k
		22 => "21k", //21k
		24 => "50k", //50k
		25 => "piano", //Piano
		26 => "105k" //105
	];
	
	public static var ManiaConvertBack:Map<String, Int> = [ //for sideways compat
		"1k" => 6, //1k
		"2k" => 7, //2k
		"3k" => 8, //3k
		"4k" => 0, //4k
		"5k" => 3, //5k
		"6k" => 1, //6k
		"7k" => 4, //7k
		"8k" => 5, //8k
		"9k" => 2, //9k
		"10k" => 27, //10k
		"11k" => 28, //11k
		"12k" => 21, //12k
		"13k" => 20, //13k
		"14k" => 29,
		"15k" => 30,
		"16k" => 31,
		"17k" => 32,
		"18k" => 33,
		"19k" => 23, //19k
		"21k" => 22, //21k
		"50k" => 24, //50k
		"piano" => 25, //Piano
		"105k" => 26 //105
	];
	
	
	/*public static var LeatherConvert:Map<Int, Int> = [
		1 => 6,
		2 => 7,
		3 => 8,
		4 => 0,
		5 => 3,
		6 => 1,
		7 => 4,
		8 => 5,
		9 => 2,
		10 => 27,
		11 => 28,
		12 => 21,
		13 => 20,
		14 => 29,
		15 => 30,
		16 => 31,
		17 => 32,
		18 => 33
	];*/
	
	/*public static var splashNameDefault:Map<String, String> = [
		"purple" => "purple",
		"red" => "red",
		"yellow" => "yellow",
		"blue" => "blue",
		"violet" => "violet",
		"dark" => "dark",
		"darkred" => "darkred",
		"green" => "green",
		"white" => "white",
		"13a" => "13a",
		"13b" => "13b",
		"13c" => "13c",
		"13d" => "13d"
	];*/
	
	public static function GetManiaInfo(mania:String):SwagMania {
		//they're now string based
		trace('Accessed ManiaInfo for '+mania);
		var keys:Int = -4;
		var arrows:Array<String> = ['purple'];
		var controls:Array<String> = ['undefinedmania'];
		var splashName:Null<Map<String, String>> = null;
		var special:Bool = false;
		var specialTag:String = "";
		/*var mi:SwagMania = {
			keys: -4, //it'll cause the game to Fucking Die but whatever
			arrows: ['purple'], //these still have to count as the correct data type
			controls: ["undefinedmania"],
			special: true,
			specialTag: "undefined",
			control_set: null
		}*/
		switch(mania) {
			case "6k": //6K
				arrows = ['purple', 'green', 'red', 'yellow', 'blue', 'dark']; //apparently that causes crashing as well
				controls = ["6k0", "6k1", "6k2", "6k4", "6k5", "6k6"];
			case "9k": //9K
				arrows = ['purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'];
				controls = ["9k0", "9k1", "9k2", "9k3", "9k4", "9k5", "9k6", "9k7", "9k8"];
			case "5k": //5K
				arrows = ['purple', 'blue', 'white', 'green', 'red'];
				controls = ["note_left", "note_down", "6k3", "note_up", "note_right"];
			case "7k": //7K
				arrows = ['purple', 'green', 'red', 'white', 'yellow', 'blue', 'dark'];
				controls = ["6k0", "6k1", "6k2", "6k3", "6k4", "6k5", "6k6"];
			case "8k": //8K
				arrows = ['purple', 'blue', 'green', 'red', 'yellow', 'violet', 'darkred', 'dark'];
				controls = ["9k0", "9k1", "9k2", "9k3", "9k5", "9k6", "9k7", "9k8"];
			case "1k": //1K
				arrows = ['white'];
				controls = ["6k3"];
			case "2k": //2K
				arrows = ['purple', 'red'];
				controls = ["note_left", "note_right"];
			case "3k": //3K
				arrows = ['purple', 'white', 'red'];
				controls = ["note_left", "9k4", "note_right"];
			case "13k": //13K
				//arrows = ['yellow', 'violet', 'darkred', 'dark', 'purple', 'blue', 'white', 'green', 'red', 'yellow', 'violet', 'darkred', 'dark'];
				arrows = ['purple', 'blue', 'green', 'red', '13a', '13b', 'white', '13c', '13d', 'yellow', 'violet', 'darkred', 'dark'];
				controls = ["9k0", "9k1", "9k2", "9k3", "note_left", "note_down", "9k4", "note_up", "note_right", "9k5", "9k6", "9k7", "9k8"];
			case "12k": //12K
				arrows = ['purple', 'blue', 'green', 'red', '13a', '13b', '13c', '13d', 'yellow', 'violet', 'darkred', 'dark'];
				controls = ["9k0", "9k1", "9k2", "9k3", "note_left", "note_down", "note_up", "note_right", "9k5", "9k6", "9k7", "9k8"];
			case "21k": //21K
			//no assets from the original 21 keys mod lol
				arrows = [
					'17a', '17b', '17c', '17d', 'purple', 'blue', 'green', 'red', '13a', '13b',
					'white',
					'13c', '13d', 'yellow', 'violet', 'darkred', 'dark', '17a', '17b', '17c','17d'
				];
				/*arrows = [
					'21la', '21lb', '21lc', '21ld', '21le', '21lf', 
					'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark'
					'21ra', '21rb', '21rc', '21rd', '21re', '21rf', 
				],*/
				//this needs controls
				//im gonna try this
			case "19k": //19K (combined 4k+6k+9k)
				arrows = [
					'17a', '17c', '17d',
					'purple', 'blue', 'green', 'red', 
					'13a', '13b', 'white', '13c', '13d',
					'yellow', 'violet', 'darkred', 'dark',
					'17a', '17b', '17d'
				];
				/*arrows = [
					'21la', '21lb', '21lc',
					'purple', 'blue', 'green', 'red', 
					'13a', '13b', 'white', '13c', '13d',
					'yellow', 'violet', 'darkred', 'dark',
					'21rd', '21re', '21rf'
				];*/
				controls = [
					"6k0", "6k1", "6k2", 
					"9k0", "9k1", "9k2", "9k3",
					"note_left", "note_down", "9k4", "note_up", "note_right",
					"9k5", "9k6", "9k7", "9k8",
					"6k3", "6k4", "6k5"
				];
			//also add combined 19k and 21k (but wHYYY you are squeezing this game to death)
			case "50k": //50k (this actually not controllable)
			//"Y'know what I dare you to do it"
			//-Mr.Shadow
				arrows = [
					'purple', 'blue', 'green', 'red', 'white', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'purple', 'blue', 'green', 'red', 'white', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'purple', 'blue', 'green', 'red', 'white', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'purple', 'blue', 'green', 'red', 'white', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'purple', 'blue', 'green', 'red', 'white', 'white', 'yellow', 'violet', 'darkred', 'dark'
				];
				/*arrows = [
					'21la', '21lb', '21lc', '21ld', '21le', '21lf',
					'purple', 'blue', 'green', 'red',
					'yellow', 'violet', 'darkred', 'dark',
					'13a', '13b', 'white', '13c', '13d',
					'purple', 'green', 'red', '21la', '21lb', '21lc', '21ld', '21le', '21lf', 'yellow', 'blue', 'dark',
					'13a', '13b', 'white', '13c', '13d',
					'purple', 'blue', 'green', 'red',
					'yellow', 'violet', 'darkred', 'dark',
					'21ra', '21rb', '21rc', '21rd', '21re', '21rf'
				],*/
				//or maybe i can put some midi keyboard support
			case "piano": //Piano
				arrows = [
					'piano1k',
					'pianoblack',
					'piano2k',
					'pianoblack',
					'piano3k',
					'piano4k',
					'pianoblack',
					'piano5k',
					'pianoblack',
					'piano6k',
					'pianoblack',
					'piano7k',
					'piano1k',
					'pianoblack',
					'piano2k',
					'pianoblack',
					'piano3k',
					'piano4k',
					'pianoblack',
					'piano5k',
					'pianoblack',
					'piano6k',
					'pianoblack',
					'piano7k',
					'piano8k',
				];
				//or maybe i can put some midi keyboard support
				special = true;
				specialTag = "piano";
				splashName = [
					"piano1k" => "purple",
					"piano2k" => "blue",
					"piano3k" => "green",
					"piano4k" => "red",
					"piano5k" => "yellow",
					"piano6k" => "violet",
					"piano7k" => "darkred",
					"piano8k" => "dark",
					"pianoblack" => "white"
				];
			case "105k": //105
				arrows = [
					'yellow', 'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'white',
					'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark','red',
					'yellow', 'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'white',
					'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark','red',
					'yellow', 'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'white',
					'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark','red',
					'yellow', 'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'white',
					'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark','red',
					'yellow', 'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark',
					'white',
					'purple', 'blue', 'green', 'red', 'white', 'yellow', 'violet', 'darkred', 'dark','red'
				];
			case "10k": //10K
				arrows = ['purple', 'blue', 'green', 'red', '13a', '13d', 'yellow', 'violet', 'darkred', 'dark'];
				controls = ["9k0", "9k1", "9k2", "9k3", "note_left", "note_right", "9k5", "9k6", "9k7", "9k8"];
			case "11k": //11K
				arrows = ['purple', 'blue', 'green', 'red', '13a', 'white', '13d', 'yellow', 'violet', 'darkred', 'dark'];
				controls = ["9k0", "9k1", "9k2", "9k3", "note_left", "9k4", "note_right", "9k5", "9k6", "9k7", "9k8"];
			case "14k": //14K
				arrows = ['17a', 'purple', 'blue', 'green', 'red', '13a', '13b', '13c', '13d', 'yellow', 'violet', 'darkred', 'dark', '17d'];
			case "15k": //15K
				arrows = ['17a', 'purple', 'blue', 'green', 'red', '13a', '13b', 'white', '13c', '13d', 'yellow', 'violet', 'darkred', 'dark', '17d'];
			case "16k": //16K
				arrows = ['17a', '17b', 'purple', 'blue', 'green', 'red', '13a', '13b', '13c', '13d', 'yellow', 'violet', 'darkred', 'dark', '17c', '17d'];
			case "17k": //17K
				arrows = ['17a', '17b', 'purple', 'blue', 'green', 'red', '13a', '13b', 'white', '13c', '13d', 'yellow', 'violet', 'darkred', 'dark', '17c', '17d'];
			case "18k": //18K
				arrows = ['17a', '17b', 'purple', 'blue', 'green', 'red', 'white', '13a', '13b', '13c', '13d', 'white', 'yellow', 'violet', 'darkred', 'dark', '17c', '17d'];
			default: //4K
				if (mania != '4k') {
					trace('Mania not existant!');
				}
				arrows = ['purple', 'blue', 'green', 'red'];
				controls = ["note_left", "note_down", "note_up", "note_right"]; //Controls in ManiaInfo are Not Unused kinda
		};
		if (keys == -4) {
			keys = arrows.length;
		} else if (keys != arrows.length) {
			trace('WRONG ARROW COUNT: want '+keys+' but have '+arrows.length);
		}
		//todo: we gotta implement notesplashes somehow.
		//if (splashName == null) {
		//	splashName = splashNameDefault;
		//}
		var mi:SwagMania = {
			keys: keys,
			arrows: arrows,
			controls: controls,
			special: special,
			specialTag: specialTag,
			control_set: new Array<Array<Int>>(),
			control_any: new Array<Int>(),
			splashName: splashName,
			scale: 0.0,
			spacing: 0.0
		}
		mi.scale = GetNoteScale(mi);
		mi.spacing = GetNoteSpacing(mi);
		if (Options.controls[mania] != null) {
			for (i in Options.controls[mania]) {
				mi.control_set.push([i[0], i[1]]);
			}
			trace('INPUT control set: ${Std.string(mi.control_set)} - control any: ${Std.string(mi.control_any)}');
			//no cheating!
			var checks = new Array<Int>();
			var newControlSet = new Array<Array<Int>>();
			for (k in 0...mi.control_set.length) {
				var newThing = new Array<Int>();
				var v = mi.control_set[k];
				for (i in 0...v.length) {
					if (checks.indexOf(v[i]) < 0 && v[i] > 0) {
						checks.push(v[i]);
						newThing.push(v[i]);
					}
					if (i >= 2 || (i > 0 && v[0] == v[1])) {
						break;
					}
				}
				newControlSet[k] = newThing;
			}
			mi.control_set = newControlSet;
			trace('OUTPUT control set: ${Std.string(mi.control_set)} - control any: ${Std.string(mi.control_any)}');
			mi.control_any = checks.filter(function(a:Int) {
				return a >= 0;
			});
		}
		if (mi.keys == -4) {
			//lime.window.alert("Undefined mania with ID "+mania, "Undefined Mania");
			mi.keys = 1;
		}
		return mi;
	}
	
	public static function GetManiaName(mania:SwagMania):String {
		return mania.special ? '${mania.keys}K ${mania.specialTag}' : '${mania.keys}K';
	}
	
	public static function GetNoteScale(mania:SwagMania):Float {
		if (mania.specialTag == "piano") {
			return 0.25;
		}
		if (mania.keys <= 4)
			return 0.7;
		return Math.min(4.5 / mania.keys, Math.pow(mania.keys, -0.6) + 0.25);
	}
	
	public static function GetNoteSpacing(mania:SwagMania):Float {
		if (mania.specialTag == "piano") {
			return 0;
		}
		if (mania.keys <= 4)
			return 160 * 0.7;
		return 560 / (mania.keys + 1);
	}
	
	//todo: StrumNote class
	/*public static function DoNoteSpecial(spr:StrumNote, num:Int, maniaInfo:SwagMania) {
		if (maniaInfo.special) {
			switch(maniaInfo.specialTag) {
				case "piano": {
					var pos:Array<Int> = [0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 28];
					spr.x += 12.5 * pos[num % maniaInfo.keys];
				}
			}
		}
	}*/
	
	/*public static function GetControlPress(controls:Array<String>):Array<String>
	{
		return [
			for (v in controls) {
				v += "-press";
			}
		];
	}
	
	public static function GetControlRelease(controls:Array<String>):Array<String>
	{
		return [
			for (v in controls) {
				v += "-release";
			}
		];
	}*/
	
	//i also put my funny helper funcs here

	public static function ArrayRepeat(max:Int, val:Any):Any {
		var dumbArray:Array<Int> = [];
		for (i in 0...max)
		{
			dumbArray.push(val);
		}
		return dumbArray;
	}
	
	public static var JudgeNames:Array<String> = ["Sicks", "Goods", "Bads", "Shits", "Misses"];
}
