package;

import Conductor.BPMChangeEvent;
import ManiaInfo;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle'; //seems unused
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedNoteTypes:FlxTypedGroup<FlxText>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	
	var currentChartMania:SwagMania;
	var gridBlackLine:FlxSprite;
	
	var xView:Float = 0;

	var curNoteType:String = "Normal Note";
	var curNoteTypeArr:Array<String> = ["Normal Note"];

	var chartNoteHitSfx:FlxSound = new FlxSound().loadEmbedded(Paths.sound("chartHit", "shared"));
	var notesPast:Map<Int, Bool> = new Map<Int, Bool>();

	var snapMults:Array<Float> = [];
	var snapMultNames:Array<String> = [];
	var curSnapMult:Int = 1;

	override function create()
	{
		if (snapMults.length == 0) {
			//read from data/charting_snapMults.txt
			var snapMultsStr:String = Assets.getText(Paths.txt("charting_snapMults"));
			var snapMultsArr:Array<String> = snapMultsStr.split("\n");
			for (snapMultStr in snapMultsArr) {
				//format: "16/12" = 16 divided by 12
				var snapMultArr:Array<String> = snapMultStr.split("/");
				snapMults.push(Std.parseFloat(snapMultArr[0].trim()) / Std.parseFloat(snapMultArr[1].trim()));
				snapMultNames.push(snapMultStr);
			}
			if (snapMults.length == 0) {
				snapMults.push(1);
			}
			if (snapMults.length == 1) {
				curSnapMult = 0;
			}
		}
		curSection = lastSection;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		gridBlackLine = new FlxSprite().makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNoteTypes = new FlxTypedGroup<FlxText>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				speed: 1,
				validScore: false,
				maniaStr: "4k",
				mania: 0,
				keyCount: 4,
				gfVersion: "gf",
				stage: "",
				usedNoteTypes: new Array<String>(),
				healthDrain: 0,
				healthDrainMin: 0,
				moreCharacters: new Array<String>(),
				actions: new Array<String>(),
				noteSkin: ""
			};
			curNoteTypeArr = _song.usedNoteTypes;
		}

		leftIcon = new HealthIcon(_song.player1, false, PlayState.modName);
		rightIcon = new HealthIcon(_song.player2, false, PlayState.modName);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(0, -100);
		
		currentChartMania = ManiaInfo.GetManiaInfo(_song.maniaStr);

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGridChangeMania();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(0, 5, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);
		Translation.setObjectFont(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: Translation.getTranslation('tab_Song', "charteditor")},
			{name: "Section", label: Translation.getTranslation('tab_Section', "charteditor")},
			{name: "Note", label: Translation.getTranslation('tab_Note', "charteditor")},
			{name: "Event", label: Translation.getTranslation('tab_Event', "charteditor")}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		
		//UI_box._tabs is private, so I must do this bullshit!
		for (i in UI_box.members) {
			if (Std.isOfType(i, FlxUIButton)) {
				Translation.setUIObjectFont(cast(i, FlxUIButton));
			}
		}

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width - 480;
		UI_box.y = 24 * 4;
		add(UI_box);
		bpmTxt.x = UI_box.x;

		var arrMania = [
			for (i in ManiaInfo.AvailableMania) {
				i = ManiaInfo.GetManiaName(ManiaInfo.GetManiaInfo(i));
			}
		];

		addSongUI(arrMania);
		addSectionUI(arrMania);
		addNoteUI();
		addEventUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedNoteTypes);
		
		super.create();
	}

	function addSongUI(arrMania:Array<String>):Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 90, _song.song, 8);
		typingShit = UI_songTitle;
		//Translation.setUIObjectFont(UI_songTitle);

		var check_voices = new FlxUICheckBox(10, 25, null, null, Translation.getTranslation("Has voice track", "charteditor"), 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};
		Translation.setUIObjectFont(check_voices);

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, Translation.getTranslation("Mute Instrumental", "charteditor"), 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};
		Translation.setUIObjectFont(check_mute_inst);

		var saveButton:FlxUIButton = new FlxUIButton(110, 8, Translation.getTranslation("Save", "charteditor"), function()
		{
			saveLevel();
		});
		Translation.setUIObjectFont(saveButton);

		var reloadSong:FlxUIButton = new FlxUIButton(saveButton.x + saveButton.width + 10, saveButton.y, Translation.getTranslation("Reload Audio", "charteditor"), function()
		{
			loadSong(_song.song);
		});
		Translation.setUIObjectFont(reloadSong);

		var reloadSongJson:FlxUIButton = new FlxUIButton(reloadSong.x, saveButton.y + 30, Translation.getTranslation("Reload JSON", "charteditor"), function()
		{
			loadJson(_song.song.toLowerCase());
		});
		Translation.setUIObjectFont(reloadSongJson);

		var loadAutosaveBtn:FlxUIButton = new FlxUIButton(reloadSongJson.x, reloadSongJson.y + 30, Translation.getTranslation('load autosave', "charteditor"), loadAutosave);
		Translation.setUIObjectFont(loadAutosaveBtn);
		
		if (Translation.getUIObjectIsMultiline(reloadSong) || Translation.getUIObjectIsMultiline(reloadSongJson) || Translation.getUIObjectIsMultiline(loadAutosaveBtn)) {
			reloadSong.resize(150, 20);
			reloadSongJson.resize(150, 20);
			loadAutosaveBtn.resize(150, 20);
		}

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 62, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = CoolUtil.coolTextFile('data/characterList');
		var stages:Array<String> = CoolUtil.coolTextFile('data/stageList');

		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});
		player1DropDown.selectedLabel = _song.player1;
		//Translation.setUIObjectFont(player1DropDown);

		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});
		player2DropDown.selectedLabel = _song.player2;
		//Translation.setUIObjectFont(player2DropDown);

		var girlfriendDropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.gfVersion = characters[Std.parseInt(character)];
		});
		girlfriendDropDown.selectedLabel = _song.gfVersion;
		//Translation.setUIObjectFont(player2DropDown);

		var stageDropDown = new FlxUIDropDownMenu(140, 130, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(character:String)
		{
			_song.stage = stages[Std.parseInt(character)];
		});
		stageDropDown.selectedLabel = _song.player2;
		//Translation.setUIObjectFont(stageDropDown);

		var maniaSelect = new FlxUIDropDownMenu(10, 160, FlxUIDropDownMenu.makeStrIdLabelArray(arrMania, true), function(character:String)
		{
			_song.maniaStr = ManiaInfo.AvailableMania[Std.parseInt(character)];
			currentChartMania = ManiaInfo.GetManiaInfo(_song.maniaStr);
			_song.keyCount = currentChartMania.keys;
			_song.mania = ManiaInfo.ManiaConvertBack.get(_song.maniaStr);
			updateGridChangeMania();
		});
		//noteTypeSelect.resize(200, 20);
		maniaSelect.selectedLabel = arrMania[ManiaInfo.AvailableMania.indexOf(_song.maniaStr)];

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(stageDropDown);
		tab_group_song.add(maniaSelect);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();
		
		//Translation.setUIObjectFont(tab_group_song);

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var check_changeMania:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var sectionManiaSelect:FlxUIDropDownMenu;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI(arrMania:Array<String>):Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 70, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(200, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxUIButton = new FlxUIButton(10, 130, Translation.getTranslation("Copy last", "charteditor"), function()
		{
			copySection(Std.int(stepperCopy.value));
		});
		copyButton.resize(180, 20);
		Translation.setUIObjectFont(copyButton);

		var clearSectionButton:FlxUIButton = new FlxUIButton(10, 150, Translation.getTranslation("Clear", "charteditor"), clearSection);
		Translation.setUIObjectFont(clearSectionButton);
		clearSectionButton.resize(180, 20);

		var swapSection:FlxUIButton = new FlxUIButton(10, 170, Translation.getTranslation("Swap section", "charteditor"), function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});
		swapSection.resize(180, 20);
		Translation.setUIObjectFont(swapSection);

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, Translation.getTranslation("Must hit section", "charteditor"), 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;
		Translation.setUIObjectFont(check_mustHitSection);

		check_altAnim = new FlxUICheckBox(10, 400, null, null, Translation.getTranslation("Alt Animation", "charteditor"), 100);
		check_altAnim.name = 'check_altAnim';
		Translation.setUIObjectFont(check_altAnim);

		check_changeBPM = new FlxUICheckBox(10, 50, null, null, Translation.getTranslation("Change BPM", "charteditor"), 100);
		check_changeBPM.name = 'check_changeBPM';
		Translation.setUIObjectFont(check_changeBPM);

		check_changeMania = new FlxUICheckBox(10, 90, null, null, Translation.getTranslation("Change Mania", "charteditor"), 100);
		check_changeMania.name = 'check_changeMania';
		Translation.setUIObjectFont(check_changeMania);

		sectionManiaSelect = new FlxUIDropDownMenu(10, 120, FlxUIDropDownMenu.makeStrIdLabelArray(arrMania, true), function(character:String) {
			_song.notes[curSection].maniaStr = ManiaInfo.AvailableMania[Std.parseInt(character)];
			if (_song.notes[curSection].changeMania) {
				updateGridChangeMania();
			}
		});

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(check_changeMania);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(sectionManiaSelect);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxUIButton = new FlxUIButton(100, 10, Translation.getTranslation("Apply", "charteditor"));
		Translation.setUIObjectFont(applyLength);

		//todo: have real
		var noteTypes = [
			"Normal Note",
			"Hurt Note",
			"Death Note",
			"Warning Note",
			"Angel Note",
			"Alt Animation",
			"Bob Note",
			"Glitch Note",
			"Hey",
			"Death Warning Note",
			"Guitar Note"
		];
		var noteTypeSelect = new FlxUIDropDownMenu(10, 40, FlxUIDropDownMenu.makeStrIdLabelArray(noteTypes, true), function(character:String)
		{
			curNoteType = character;
		});
		//noteTypeSelect.resize(200, 20);
		noteTypeSelect.selectedLabel = noteTypes[0];
		
		Translation.setUIDropDownFont(noteTypeSelect);

		tab_group_note.add(noteTypeSelect);
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);

		UI_box.addGroup(tab_group_note);
	}

	function addEventUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Event';

		/*var applyLength:FlxUIButton = new FlxUIButton(100, 10, Translation.getTranslation("Add event here", "charteditor"));
		Translation.setUIObjectFont(applyLength);*/

		//todo: have real
		var noteTypes = [
			"Hey",
			"Play Animation",
			"Zoom Hit",
			"Set GF Speed",
			"Blammed Lights"
		];
		var noteTypeSelect = new FlxUIDropDownMenu(10, 40, FlxUIDropDownMenu.makeStrIdLabelArray(noteTypes, true), function(character:String)
		{
			//_song.player1 = characters[Std.parseInt(character)];
		});
		//noteTypeSelect.resize(200, 20);
		noteTypeSelect.selectedLabel = noteTypes[0];
		
		Translation.setUIDropDownFont(noteTypeSelect);

		tab_group_event.add(noteTypeSelect);
		//tab_group_event.add(stepperSusLength);

		UI_box.addGroup(tab_group_event);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id != "over_button" && id != "out_button") {
			//that just spams the log otherwise
			FlxG.log.add('ui event type ${id} | sender ${sender} | data ${data} | params ${params}');
		}

		if (id == FlxUICheckBox.CLICK_EVENT) {
			var check:FlxUICheckBox = cast sender;
			var label = check.name;
			trace('checkbox - ${label}');
			switch (label) {
				case 'check_mustHit':
					_song.notes[curSection].mustHitSection = check.checked;
					FlxG.log.add('changed must hit of ${curSection} to ${check.checked}');
					updateHeads();
				case 'check_changeBPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit of ${curSection} to ${check.checked}');
				case "check_altAnim":
					_song.notes[curSection].altAnim = check.checked;
					FlxG.log.add('changed alt anim of ${curSection} to ${check.checked}');
				case 'check_changeMania':
					_song.notes[curSection].changeMania = check.checked;
					FlxG.log.add('changed mania shit of ${curSection} to ${check.checked}');
					updateGridChangeMania();
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			trace('numeric stepper - ${wname}');
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
		}
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else {
				var funnySnap = GRID_SIZE * snapMults[curSnapMult];
				dummyArrow.y = Math.floor(FlxG.mouse.y / funnySnap) * funnySnap;
			}	
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		var spdSideways = elapsed * 128;
		if (FlxG.keys.pressed.SHIFT) {
			spdSideways *= 6;
		}
		if (FlxG.keys.pressed.I)
		{
			xView += spdSideways;
		}
		if (FlxG.keys.pressed.O)
		{
			xView -= spdSideways;
		}
		FlxG.camera.targetOffset.x = xView;

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		if (FlxG.sound.music.playing) {
			for (i in 0..._song.notes[curSection].sectionNotes.length) {
				if (_song.notes[curSection].sectionNotes[i][0] <= FlxG.sound.music.time && !notesPast.get(i)) {
					chartNoteHitSfx.play(true);
					notesPast.set(i, true);
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);
		if (FlxG.keys.justPressed.COMMA && curSnapMult >= 0)
			curSnapMult -= 1;
		if (FlxG.keys.justPressed.PERIOD && curSnapMult + 1 < snapMults.length)
			curSnapMult += 1;

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\n"
			+ Translation.getTranslation("section number", "charteditor", [Std.string(curSection)])
			+ "\n"
			+ Translation.getTranslation("step number", "charteditor", [Std.string(curStep)])
			+ "\n"
			+ Translation.getTranslation("snap mult", "charteditor", [Std.string(snapMultNames[curSnapMult]), Std.string(curSnapMult)]);
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked) {
			leftIcon.changeCharacter(_song.player1);
			rightIcon.changeCharacter(_song.player2);
		} else {
			leftIcon.changeCharacter(_song.player2);
			rightIcon.changeCharacter(_song.player1);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}
	
	function updateGridChangeMania() {
		//todo: Fix this
		/*var maniaSection = curSection;
		while (maniaSection > 0 && _song.notes[maniaSection].changeMania)
			maniaSection--;
		if (maniaSection >= 0)
			currentChartMania = ManiaInfo.GetManiaInfo(_song.notes[maniaSection].maniaStr);
		else
			currentChartMania = ManiaInfo.GetManiaInfo(_song.maniaStr);*/
		var newGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * currentChartMania.keys * 2, GRID_SIZE * 16);
		insert(members.indexOf(gridBG), newGridBG);
		remove(gridBG);
		gridBG = newGridBG;
		gridBlackLine.x = gridBG.x + gridBG.width / 2;
		PlayState.curManiaInfo = currentChartMania;
		rightIcon.x = gridBG.width / 2;
		updateGrid();
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0) {
			curRenderedNotes.members.shift().destroy();
		}

		while (curRenderedSustains.members.length > 0) {
			curRenderedSustains.members.shift().destroy();
		}

		while (curRenderedNoteTypes.members.length > 0) {
			curRenderedNoteTypes.members.shift().destroy();
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0) {
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		} else {
			// get last bpm
			var i:Int = curSection;
			while (i > 0 && !_song.notes[i].changeBPM)
				i--;
			Conductor.changeBPM(i < 0 ? _song.bpm : _song.notes[i].bpm);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:Note = new Note(daStrumTime, daNoteInfo % currentChartMania.keys);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
				if (i.length >= 4 && i[3] > 0) {
					curRenderedNoteTypes.add(new FlxText(note.x, note.y, 8, i[3]));
				}
			}
		}

		notesPast = new Map<Int, Bool>();
		for (i in 0..._song.notes[curSection].sectionNotes.length) {
			notesPast.set(i, _song.notes[curSection].sectionNotes[i][0] <= FlxG.sound.music.time);
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			gfSection: false,
			focusCharacter: null,
			maniaStr: "",
			changeMania: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % currentChartMania.keys == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % currentChartMania.keys == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;

		if (curNoteTypeArr.indexOf(curNoteType) <= -1) {
			curNoteTypeArr.push(curNoteType);
			PlayState.SONG.usedNoteTypes = curNoteTypeArr;
		}

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, curNoteTypeArr.indexOf(curNoteType)]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(Highscore.formatSong(song, PlayState.storyDifficulty), Highscore.formatSong(song));
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
