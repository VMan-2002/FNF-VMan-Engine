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
import flixel.group.FlxSpriteGroup;
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
import sys.FileSystem;

using StringTools;

class ChartingState extends MusicBeatState {
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	public var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	//var curSong:String = 'Dadbattle'; //seems unused
	//var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<ChartingNote>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedNoteTypes:FlxTypedGroup<FlxText>;
	var curRenderedEvents:FlxTypedGroup<ChartEventSprite>;

	var gridBG:FlxSprite;

	public var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	public var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	
	var currentChartMania:SwagMania;
	var gridBlackLine:FlxSprite;
	
	var xView:Float = 0;

	var curNoteType:String = "Normal Note";
	var curNoteTypeArr:Array<String> = ["Normal Note"];

	var chartNoteHitSfx:FlxSound = new FlxSound().loadEmbedded(Paths.sound("chartHitNew", "shared"));
	var notesPast:Map<Int, Bool> = new Map<Int, Bool>();

	var snapMults:Array<Float> = [];
	var snapMultNames:Array<String> = [];
	var curSnapMult:Int = 1;

	var headPositions:Array<Float> = new Array<Float>();

	var songAudioPartPositions:Array<Float> = new Array<Float>();
	var songAudioPartInst = new Array<FlxSound>();
	var songAudioPartVocals = new Array<FlxSound>();
	var songAudioPartNum = 0;
	var songAudioOffset:Float = 0;
	var songAudioLengthTotal:Float = 0;

	var currentTimeSignature:Int = 4;

	var curNotesLayer:Int = 0;
	var sectionInfo:Array<Dynamic>;
	var nextSectionTime:Float;
	var sectionBeatsActive:Bool = false;

	var osuScroller:OsuScroller;

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
				snapMultNames.push(snapMultStr.rtrim());
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

		curRenderedNotes = new FlxTypedGroup<ChartingNote>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNoteTypes = new FlxTypedGroup<FlxText>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
			_song = Song.songFunc();
		curNoteTypeArr = _song.usedNoteTypes != null ? _song.usedNoteTypes : curNoteTypeArr;

		leftIcon = new HealthIcon("bf", false, PlayState.modName);
		rightIcon = new HealthIcon("dad", false, PlayState.modName);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(0, -100);

		headPositions[0] = leftIcon.x;
		headPositions[1] = rightIcon.x;
		
		currentChartMania = ManiaInfo.GetManiaInfo(_song.maniaStr);

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		osuScroller = new OsuScroller(this, gridBG.x - 150);
		add(osuScroller);

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;
		if (curSection >= _song.notes.length)
			curSection = 0;

		updateGridChangeMania();

		loadSong(_song.song);
		osuScroller.setRowCount(_song.notes.length);
		for (i in 0..._song.notes.length) {
			osuScroller.setAmountForRow(i, _song.notes[i].sectionNotes.length);
		}
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
			{name: "Event", label: Translation.getTranslation('tab_Event', "charteditor")},
			{name: "NoteStacking", label: Translation.getTranslation('tab_NoteStacking', "charteditor")}
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
		UI_box.y = 24 * 5;
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
		addNoteStackingUI();

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

		var stepperTimeSig:FlxUINumericStepper = new FlxUINumericStepper(100, 62, 1, 1, 1, 339, 0);
		stepperTimeSig.value = _song.timeSignature;
		stepperTimeSig.name = 'song_timesig';

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

		
		var clearNotesButton:FlxUIButton = new FlxUIButton(10, 280, Translation.getTranslation("Clear All Notes", "charteditor"), function()
		{
			var i:Int = _song.notes.length;
			while (i > 0) {
				i -= 1;
				if (_song.notes[i].sectionNotes != null && _song.notes[i].sectionNotes.length > 0) {
					_song.notes[i].sectionNotes = [];
				}
				if (_song.notes[i].notesMoreLayers != null && _song.notes[i].notesMoreLayers.length > 0) {
					_song.notes[i].notesMoreLayers = null;
				}
			}
			updateGrid();
		});
		Translation.setUIObjectFont(clearNotesButton);

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(clearNotesButton);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperTimeSig);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);
		tab_group_song.add(girlfriendDropDown);
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
	var stepperSectionChar:FlxUINumericStepper;

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
			if (curNotesLayer > 0) {
				return;
			}
			for (i in 0..._song.notes[curSection].sectionNotes.length) {
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + currentChartMania.keys) % (currentChartMania.keys * 2);
				_song.notes[curSection].sectionNotes[i] = note;
			}
			updateGrid();
		});
		swapSection.resize(180, 20);
		Translation.setUIObjectFont(swapSection);

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, Translation.getTranslation("Must hit section", "charteditor"), 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;
		Translation.setUIObjectFont(check_mustHitSection);

		check_altAnim = new FlxUICheckBox(180, 30, null, null, Translation.getTranslation("Alt Animation", "charteditor"), 100);
		check_altAnim.name = 'check_altAnim';
		Translation.setUIObjectFont(check_altAnim);

		check_changeBPM = new FlxUICheckBox(10, 50, null, null, Translation.getTranslation("Change BPM", "charteditor"), 100);
		check_changeBPM.name = 'check_changeBPM';
		Translation.setUIObjectFont(check_changeBPM);

		check_changeMania = new FlxUICheckBox(10, 90, null, null, Translation.getTranslation("Change Mania", "charteditor"), 100);
		check_changeMania.name = 'check_changeMania';
		Translation.setUIObjectFont(check_changeMania);

		sectionManiaSelect = new FlxUIDropDownMenu(10, 110, FlxUIDropDownMenu.makeStrIdLabelArray(arrMania, true), function(character:String) {
			_song.notes[curSection].maniaStr = ManiaInfo.AvailableMania[Std.parseInt(character)];
			if (_song.notes[curSection].changeMania) {
				updateGridChangeMania();
			}
		});

		stepperSectionChar = new FlxUINumericStepper(180, 50, 1, -1, -1, 999, 0);
		stepperSectionChar.name = "section_focuschar";

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperSectionChar);
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
	var stepperEventNumber:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxUIButton = new FlxUIButton(100, 10, Translation.getTranslation("Apply", "charteditor"));
		Translation.setUIObjectFont(applyLength);
		
		var noteTypes = CoolUtil.readDirectoryOptional("assets/objects/notetypes/");
		for (i in ModLoad.enabledMods) {
			noteTypes = noteTypes.concat(CoolUtil.readDirectoryOptional("mods/"+i+"/objects/notetypes/"));
		}
		noteTypes = noteTypes.map(function(a) {
			return CoolUtil.trimFromEnd(a, ".json");
		});
		var noteTypeSelect = new FlxUIDropDownMenu(10, 40, FlxUIDropDownMenu.makeStrIdLabelArray(noteTypes), function(character:String) {
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

		stepperEventNumber = new FlxUINumericStepper(10, 110);
		stepperEventNumber.value = 0;
		stepperEventNumber.name = 'eventNumber';

		var applyLength:FlxUIButton = new FlxUIButton(100, 10, Translation.getTranslation("Add event here", "charteditor"), function() {
			_song.vmanEventTime = CoolUtil.addToArrayPossiblyNull(_song.vmanEventTime, FlxG.sound.music.time + songAudioOffset);
			_song.vmanEventOrder = CoolUtil.addToArrayPossiblyNull(_song.vmanEventOrder, _song.vmanEventData.length);
			_song.vmanEventData = CoolUtil.addToArrayPossiblyNull(_song.vmanEventData, ["Event"]);
		});
		Translation.setUIObjectFont(applyLength);

		var applyLength2:FlxUIButton = new FlxUIButton(100, 40, Translation.getTranslation("Remove event here", "charteditor"), function() {
			var closest:Int = 0;
			var closestTime:Float = 0;
			for (i in 0..._song.vmanEventTime.length) {
				var time = _song.vmanEventTime[i];
				if (Math.abs(time - (FlxG.sound.music.time + songAudioOffset)) < Math.abs(closestTime - (FlxG.sound.music.time + songAudioOffset))) {
					continue;
				}
				closest = i;
				closestTime = time;
			}
			_song.vmanEventTime.splice(closest, 1);
			_song.vmanEventOrder.splice(closest, 1);
			_song.vmanEventData.splice(closest, 1);
		});
		Translation.setUIObjectFont(applyLength2);

		var applyLength4:FlxUIButton = new FlxUIButton(100, 70, Translation.getTranslation("Replace event here", "charteditor"), function() {
			var closest:Int = 0;
			var closestTime:Float = 0;
			for (i in 0..._song.vmanEventTime.length) {
				var time = _song.vmanEventTime[i];
				if (Math.abs(time - (FlxG.sound.music.time + songAudioOffset)) < Math.abs(closestTime - (FlxG.sound.music.time + songAudioOffset))) {
					continue;
				}
				closest = i;
				closestTime = time;
			}
			_song.vmanEventData[closest] = ["Event"];
		});
		Translation.setUIObjectFont(applyLength4);

		var applyLength3:FlxUIButton = new FlxUIButton(100, 90, Translation.getTranslation("Jump to event", "charteditor"), function() {
			//todo: this needs fixing for really long songs
			FlxG.sound.music.time = _song.vmanEventTime[Math.floor(stepperEventNumber.value)] - songAudioOffset;
		});
		Translation.setUIObjectFont(applyLength3);

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

		tab_group_event.add(applyLength);
		tab_group_event.add(applyLength2);

		tab_group_event.add(noteTypeSelect);
		//tab_group_event.add(stepperSusLength);

		UI_box.addGroup(tab_group_event);
	}

	var check_stackActive:FlxUICheckBox;
	var stepperStackNum:FlxUINumericStepper;
	var stepperStackOffset:FlxUINumericStepper;
	var stepperStackSideOffset:FlxUINumericStepper;

	function addNoteStackingUI():Void
	{
		var tab_group_stacking = new FlxUI(null, UI_box);
		tab_group_stacking.name = 'NoteStacking';

		check_stackActive = new FlxUICheckBox(10, 10, null, null, "Enable notestacking", 100);
		check_stackActive.name = 'check_stackActive';

		stepperStackNum = new FlxUINumericStepper(10, 30, 4, 4, 0, 999999);
		stepperStackNum.name = 'stack_count';

		stepperStackOffset = new FlxUINumericStepper(10, 50, 0.25, 1, 0, 999999);
		stepperStackOffset.name = 'stack_offset';

		stepperStackSideOffset = new FlxUINumericStepper(10, 70, 1, 0, -9999, 9999);
		stepperStackSideOffset.name = 'stack_sideways';

		tab_group_stacking.add(check_stackActive);
		tab_group_stacking.add(stepperStackNum);
		tab_group_stacking.add(stepperStackOffset);
		tab_group_stacking.add(stepperStackSideOffset);
		
		tab_group_stacking.add(new FlxText(100, 30, 0, "Count"));
		tab_group_stacking.add(new FlxText(100, 50, 0, "Offset"));
		tab_group_stacking.add(new FlxText(100, 70, 0, "Sideways"));

		UI_box.addGroup(tab_group_stacking);
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
		vocals = new FlxSound().loadEmbedded(Paths.getSongPathThing(daSong, _song.voicesName == null ? "Voices" : _song.voicesName));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		var i = 1;
		songAudioPartInst[0] = FlxG.sound.music;
		songAudioPartVocals[0] = vocals;
		songAudioLengthTotal = FlxG.sound.music.length;
		while (Assets.exists(Paths.getSongPathThing(daSong, 'part${i}/Inst'))) {
			trace('audio part ${i}');
			songAudioPartInst[i] = new FlxSound().loadEmbedded(Paths.getSongPathThing(daSong, 'part${i}/Inst'));
			songAudioPartInst[i].onComplete = endInst;
			songAudioPartInst[i].volume = 0.6;
			if (Assets.exists(Paths.getSongPathThing(daSong, 'part${i}/Voices'))) {
				songAudioPartVocals[i] = new FlxSound().loadEmbedded(Paths.getSongPathThing(daSong, 'part${i}/Voices'));
			} else {
				songAudioPartVocals[i] = new FlxSound();
			}
			songAudioLengthTotal += songAudioPartInst[i].length;
			i += 1;
		}
		var i = 1;
		while (i < songAudioPartInst.length && songAudioPartPositions[i] < Conductor.songPosition) {
			i++;
		}
		trace('song is ${songAudioPartInst.length} parts long and total length is ${songAudioLengthTotal / 1000}');
	}

	function endInst() {
		if (songAudioPartNum < songAudioPartInst.length) {
			songAudioPartNum++;
			songAudioOffset += songAudioPartPositions[songAudioPartNum];
			FlxG.sound.music = songAudioPartInst[songAudioPartNum];
			vocals = songAudioPartVocals[songAudioPartNum];
			FlxG.sound.music.play();
			vocals.play();
		} else {
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			FlxG.sound.music = songAudioPartInst[0];
			vocals = songAudioPartVocals[0];
			songAudioOffset = 0;
			changeSection();
		}
	}

	function generateUI():Void
	{
		CoolUtil.clearMembers(bullshitUI);

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
		} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			trace('numeric stepper - ${wname}');
			if (wname == 'section_length') {
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			} else if (wname == 'section_focuschar') {
				_song.notes[curSection].focusCharacter = Std.int(nums.value);
			} else if (wname == 'song_speed') {
				_song.speed = nums.value;
			} else if (wname == 'song_bpm') {
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			} else if (wname == 'song_timesig') {
				_song.timeSignature = Std.int(nums.value);
				nextSectionTime = sectionStartTime(curSection + 1);
				updateGrid();
			} else if (wname == 'note_susLength') {
				curSelectedNote[2] = nums.value;
				updateGrid();
			} else if (wname == 'section_bpm') {
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
	public function sectionStartTime(?sectionFind:Null<Int>):Float {
		var timeSig = _song.timeSignature == null ? 4 : _song.timeSignature;
		if (sectionFind == null) {
			sectionFind = curSection;
		}
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...sectionFind)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			if (_song.notes[i].changeTimeSignature)
			{
				timeSig = _song.notes[i].timeSignature;
			}
			daPos += timeSig * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time + songAudioOffset;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * getLengthInSteps(curSection)));

		if (curBeat % currentTimeSignature == 0 && Conductor.songPosition >= nextSectionTime)
		{
			trace(curStep);
			trace(getLengthInSteps(curSection) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null) {
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(curRenderedNotes)) {
				curRenderedNotes.forEach(function(note:ChartingNote) {
					if (FlxG.mouse.overlaps(note)) {
						if (FlxG.keys.pressed.CONTROL) {
							selectNote(note);
						} else if (FlxG.keys.pressed.ALT) {
							selectNote(note);
							if (!curNoteTypeArr.contains(curNoteType)) {
								curNoteTypeArr.push(curNoteType);
								PlayState.SONG.usedNoteTypes = curNoteTypeArr;
							}
							curSelectedNote[3] = curNoteTypeArr.indexOf(curNoteType);
							updateGrid();
						} else {
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			} else {
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getLengthInSteps(curSection)))
				{
					FlxG.log.add('added note');
					var addCount:Int = 0;
					if (check_stackActive.checked) {
						addCount = Math.floor(stepperStackNum.value) - 1;
					}
					var funnySnap:Float = Conductor.stepCrochet * snapMults[curSnapMult];
					while (addCount >= 0) {
						addNote(funnySnap * addCount * stepperStackOffset.value, Math.floor(addCount * stepperStackSideOffset.value), addCount == 0);
						addCount -= 1;
					}
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getLengthInSteps(curSection)))
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

		if (FlxG.keys.justPressed.LBRACKET && curNotesLayer > 0) {
			curNotesLayer -= 1;
			updateGridChangeMania();
		}
		if (FlxG.keys.justPressed.RBRACKET) {
			curNotesLayer += 1;
			updateGridChangeMania();
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

		if (FlxG.keys.justPressed.TAB) {
			//Tab key
			if (FlxG.keys.pressed.SHIFT) {
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 4;
			} else {
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 5)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus) {
			if (FlxG.keys.justPressed.SPACE) {
				if (FlxG.sound.music.playing) {
					FlxG.sound.music.pause();
					vocals.pause();
				} else {
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R) {
				resetSection(FlxG.keys.pressed.SHIFT);
			}

			if (FlxG.mouse.wheel != 0) {
				if (FlxG.keys.pressed.CONTROL) {
					FlxG.camera.zoom += FlxG.mouse.wheel / 16;
				} else {
					FlxG.sound.music.pause();
					vocals.pause();

					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
					vocals.time = FlxG.sound.music.time;
				}
			}

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
				FlxG.sound.music.pause();
				vocals.pause();

				var daTime:Float = FlxG.keys.pressed.SHIFT ? Conductor.stepCrochet * 2 : 700 * FlxG.elapsed;
				
				FlxG.sound.music.time += FlxG.keys.pressed.W ? -daTime : daTime;

				vocals.time = FlxG.sound.music.time;
			}
		}

		if (FlxG.sound.music.playing) {
			for (i in 0..._song.notes[curSection].sectionNotes.length) {
				if (_song.notes[curSection].sectionNotes[i][0] <= FlxG.sound.music.time + songAudioOffset && !notesPast.get(i)) {
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
			+ Std.string(FlxMath.roundDecimal(songAudioLengthTotal / 1000, 2))
			+ "\n"
			+ Translation.getTranslation("section number", "charteditor", [Std.string(curSection)])
			+ "\n"
			+ Translation.getTranslation("step number", "charteditor", [Std.string(curStep)])
			+ "\n"
			+ Translation.getTranslation("snap mult", "charteditor", [Std.string(snapMultNames[curSnapMult]), Std.string(curSnapMult)])
			+ "\n"
			+ Translation.getTranslation("layer number", "charteditor", [Std.string(curNotesLayer)]);
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
			if (FlxG.sound.music.time + songAudioOffset > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time + songAudioOffset - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		//updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		if (songBeginning) {
			FlxG.sound.music.time = 0;
			curSection = 0;
		} else {
			// Basically old shit from changeSection???
			FlxG.sound.music.time = sectionStartTime() - songAudioOffset;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	public function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (sec < 0) {
			sec = 0;
		}
		trace('changing section' + sec);

		while (_song.notes[sec] == null) {
			addSection();
		}
		//if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic) {
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime() - songAudioOffset;
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		nextSectionTime = sectionStartTime(sec + 1);
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		var result = getSectionNotes();
		for (note in (curNotesLayer == 0 ? _song.notes[daSec - sectionNum].sectionNotes : _song.notes[daSec - sectionNum].notesMoreLayers[curNotesLayer - 1])) {
			var strum = note[0] + Conductor.stepCrochet * (getLengthInSteps(daSec) * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection != false;
		check_altAnim.checked = sec.altAnim == true;
		check_changeBPM.checked = sec.changeBPM == true;
		stepperSectionBPM.value = sec.bpm;
		stepperSectionChar.value = sec.focusCharacter;

		updateHeads();
	}

	function updateHeads():Void
	{
		/*if (check_mustHitSection.checked) {
			leftIcon.changeCharacter(_song.player1);
			rightIcon.changeCharacter(_song.player2);
		} else {
			leftIcon.changeCharacter(_song.player2);
			rightIcon.changeCharacter(_song.player1);
		}*/
		if (check_mustHitSection.checked) {
			leftIcon.x = headPositions[0];
			rightIcon.x = headPositions[1];
		} else {
			leftIcon.x = headPositions[1];
			rightIcon.x = headPositions[0];
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
		var widthThing = currentChartMania.keys;
		gridBlackLine.visible = curNotesLayer == 0;
		if (gridBlackLine.visible) {
			widthThing *= 2;
		}
		var newGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * widthThing, GRID_SIZE * currentTimeSignature * 4);
		addOrReplace(gridBG, newGridBG);
		gridBG = newGridBG;
		if (newGridBG != null) { //i hate this SO much
			gridBlackLine.makeGraphic(2, Std.int(newGridBG.height), FlxColor.BLACK).x = widthThing * GRID_SIZE * 0.5;
		}
		PlayState.curManiaInfo = currentChartMania;
		rightIcon.x = widthThing * 0.5 * GRID_SIZE;

		if (gridBG != null) {
			headPositions[0] = gridBG.x + 100;
			headPositions[1] = gridBlackLine.x + 100;
		}

		updateGrid();
	}

	function updateGrid():Void
	{
		var toTimeSig = _song.timeSignature == null ? 4 : _song.timeSignature;
		sectionBeatsActive = false;
		var thisSection:SwagSection = _song.notes[curSection];
		if (thisSection.sectionBeats > 0) {
			toTimeSig = thisSection.sectionBeats;
			sectionBeatsActive = true;
		} else if (thisSection.changeTimeSignature == true && thisSection.timeSignature > 0) {
			toTimeSig = thisSection.timeSignature;
		} else {
			// get last time sig
			var i:Int = curSection;
			while (i >= 0 && _song.notes[i].changeTimeSignature != true)
				i--;
			toTimeSig = i < 0 ? _song.timeSignature : _song.notes[i].timeSignature;
		}
		if (toTimeSig == null)
			toTimeSig = 4;
		if (toTimeSig != currentTimeSignature) {
			trace("change time signature from "+currentTimeSignature+" to "+toTimeSig);
			currentTimeSignature = toTimeSig;
			return updateGridChangeMania();
		}

		CoolUtil.clearMembers(curRenderedNotes);
		CoolUtil.clearMembers(curRenderedSustains);
		CoolUtil.clearMembers(curRenderedNoteTypes);
		CoolUtil.clearMembers(curRenderedEvents);

		if (thisSection.sectionNotes == null) {
			thisSection.sectionNotes = new Array<Array<Dynamic>>();
		}
		sectionInfo = thisSection.sectionNotes;

		if (curNotesLayer > 0) {
			if (thisSection.notesMoreLayers == null)
				thisSection.notesMoreLayers = new Array<Array<Dynamic>>();
			if (thisSection.notesMoreLayers[curNotesLayer-1] == null)
				thisSection.notesMoreLayers[curNotesLayer-1] = new Array<Dynamic>();
			sectionInfo = thisSection.notesMoreLayers[curNotesLayer-1];
		}

		if (thisSection.changeBPM && thisSection.bpm > 0) {
			Conductor.changeBPM(thisSection.bpm);
			FlxG.log.add('CHANGED BPM!');
		} else {
			// get last bpm
			var i:Int = curSection;
			while (i >= 0 && _song.notes[i].changeBPM != true)
				i--;
			Conductor.changeBPM(i < 0 ? _song.bpm : _song.notes[i].bpm);
			trace("Using chart bpm of "+i+": "+Conductor.bpm);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length) {
				for (notesse in 0..._song.notes[sec].sectionNotes.length) {
					if (_song.notes[sec].sectionNotes[notesse][2] == null) {
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		var startThing = sectionStartTime();
		var hasNormalNote = _song.usedNoteTypes.contains("Normal Note");
		var normalNoteNum = hasNormalNote ? _song.usedNoteTypes.indexOf("Normal Note") : 0;
		for (pos in 0...sectionInfo.length) {
			var i = sectionInfo[pos];
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:ChartingNote = new ChartingNote(daStrumTime, Math.floor(daNoteInfo % currentChartMania.keys), null, false, null, i.length > 3 ? Math.floor(i[3]) : 0);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - startThing) % (Conductor.stepCrochet * getLengthInSteps(curSection))));
			note.mustPress = daNoteInfo < currentChartMania.keys;

			curRenderedNotes.add(note);

			if (daSus > 0) {
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 4 * currentTimeSignature, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
			if ((!hasNormalNote || i[3] != normalNoteNum) && i.length >= 4) {
				var roundedType = Math.round(i[3]);
				curRenderedNoteTypes.add(new FlxText(note.x, note.y, GRID_SIZE, (roundedType >= _song.usedNoteTypes.length || roundedType < 0) ? '${roundedType}?' : Note.SwagNoteType.loadNoteType(_song.usedNoteTypes[roundedType], PlayState.modName).acronym).setFormat("VCR OSD Mono", 10, 0xffffffff, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE_FAST, 0xFF000000));
				//trace("added rendered note type of "+_song.usedNoteTypes[Math.floor(i[3])]);
			}
		}

		for (i in 0..._song.vmanEventOrder.length) {
			curRenderedEvents.add(new ChartEventSprite(0, getYfromStrum(_song.vmanEventTime[i] - startThing), _song.vmanEventData[_song.vmanEventOrder[i]]));
		}

		notesPast = new Map<Int, Bool>();
		for (i in 0...thisSection.sectionNotes.length) {
			notesPast.set(i, thisSection.sectionNotes[i][0] <= FlxG.sound.music.time + songAudioOffset);
		}
	}

	private function addSection(lengthInSteps:Int = -1):Void
	{
		if (lengthInSteps == -1) {
			lengthInSteps = 4 * currentTimeSignature;
		}
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
			changeMania: false,
			notesMoreLayers: null,
			timeSignature: 4,
			changeTimeSignature: false,
			sectionBeats: -1
		};

		_song.notes.push(sec);

		osuScroller.setRowCount(_song.notes.length);
	}

	inline function getLengthInSteps(num:Int) {
		return _song.notes[num].sectionBeats > 0 ? _song.notes[num].lengthInSteps / (4 / _song.notes[num].sectionBeats) : _song.notes[num].lengthInSteps;
	}

	function selectNote(note:ChartingNote):Void {
		/*for (i in getSectionNotes()) {
			if (i.strumTime == note.strumTime && i.noteData % currentChartMania.keys == note.noteData) {
				curSelectedNote = i;
			}
		}*/
		//if you know the order of the notes, you don't need to search!
		curSelectedNote = getSectionNotes()[curRenderedNotes.members.indexOf(note)];

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:ChartingNote):Void {
		var result = getSectionNotes();
		var didDelete = false;
		for (i in result) {
			if (i[0] == note.strumTime && i[1] % currentChartMania.keys == note.noteData && (i[1] < currentChartMania.keys) == (note.mustPress)) {
				FlxG.log.add('FOUND EVIL NUMBER');
				result.remove(i);
				didDelete = true;
				break;
			}
		}
		if (!didDelete) {
			FlxG.log.add('didn\'t delete anything????');
			return;
		}
		
		if (curNotesLayer == 0) {
			osuScroller.setAmountForRow(curSection, _song.notes[curSection].sectionNotes.length);
		}
		setSectionNotes(result);
		updateGrid();
	}

	inline function clearSection():Void {
		setSectionNotes(new Array<Array<Dynamic>>());

		updateGrid();
	}

	function clearSong():Void {
		for (daSection in 0..._song.notes.length) {
			_song.notes[daSection].sectionNotes = [];
			_song.notes[daSection].notesMoreLayers = null;
		}
		curNotesLayer = 0;

		updateGrid();
	}

	private function addNote(?offset:Float = 0, ?offset2:Int, ?uGrid:Bool = true):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime() + offset;
		var noteData = (Math.floor(FlxG.mouse.x / GRID_SIZE) + offset2) % (currentChartMania.keys * 2);
		while (noteData < 0) {
			noteData += currentChartMania.keys;
		}
		var noteSus = 0;

		if (curNoteTypeArr.indexOf(curNoteType) <= -1) {
			curNoteTypeArr.push(curNoteType);
			PlayState.SONG.usedNoteTypes = curNoteTypeArr;
		}

		var addTo = curNotesLayer == 0 ? _song.notes[curSection].sectionNotes : _song.notes[curSection].notesMoreLayers[curNotesLayer - 1];

		curSelectedNote = [noteStrum, noteData, noteSus, curNoteTypeArr.indexOf(curNoteType)];

		addTo.push(curSelectedNote);

		if (FlxG.keys.pressed.CONTROL && curNotesLayer == 0)
			addTo.push([noteStrum, (noteData + currentChartMania.keys) % (currentChartMania.keys * 2), noteSus, curNoteTypeArr.indexOf(curNoteType)]);

		trace(noteStrum);
		trace(curSection);

		if (uGrid) {
			if (curNotesLayer == 0) {
				osuScroller.setAmountForRow(curSection, _song.notes[curSection].sectionNotes.length);
			}
			updateGrid();
			updateNoteUI();

			autosaveSong();
		}
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 4 * currentTimeSignature * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 4 * currentTimeSignature * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function setSectionNotes(thing:Array<Dynamic>) {
		if (curNotesLayer > 0) {
			_song.notes[curSection].notesMoreLayers[curNotesLayer - 1] = thing;
		} else {
			_song.notes[curSection].sectionNotes = thing;
		}
	}

	function getSectionNotes():Array<Dynamic> {
		if (curNotesLayer > 0) {
			return _song.notes[curSection].notesMoreLayers[curNotesLayer - 1];
		} else {
			return _song.notes[curSection].sectionNotes;
		}
	}

	/*function calculateSectionLengths(?sec:SwagSection):Int
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

	function autosaveSong():Void {
		_song.usedNoteTypes = curNoteTypeArr;
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel() {
		_song.usedNoteTypes = curNoteTypeArr;

		var json = {
			"song": _song
		};

		if (Options.dataStrip && !FlxG.keys.pressed.SHIFT) {
			var shrunkNoteTypeArr = new Array<String>();
			for (i in 0...curNoteTypeArr.length) {
				if (curNoteTypeArr.indexOf(curNoteTypeArr[i]) == i)
					shrunkNoteTypeArr.push(curNoteTypeArr[i]);
			}

			var curTimeSig:Int = json.song.timeSignature;
			//var remapNoteTypes = new Map<Float, Float>();
			//var neededNoteTypes = new Array<String>();
			for (thing in json.song.notes) {
				//delete unneeded empty layers
				if (thing.notesMoreLayers != null) {
					while (thing.notesMoreLayers.length > 0 && thing.notesMoreLayers[thing.notesMoreLayers.length - 1].length == 0) {
						thing.notesMoreLayers.pop();
					}
				}
				if (thing.notesMoreLayers == null || thing.notesMoreLayers.length == 0) {
					Reflect.deleteField(thing, "notesMoreLayers");
				}
				//strip out a bunch more shit to lower the filesize
				if (thing.changeBPM != true) {
					Reflect.deleteField(thing, "bpm");
					Reflect.deleteField(thing, "changeBPM");
				}
				if (thing.changeTimeSignature != true) {
					Reflect.deleteField(thing, "timeSignature");
					Reflect.deleteField(thing, "changeTimeSignature");
				} else {
					curTimeSig = thing.timeSignature;
				}
				if (thing.sectionBeats == curTimeSig || thing.sectionBeats == -1) {
					Reflect.deleteField(thing, "sectionBeats");
				}
				if (thing.typeOfSection == 0) {
					Reflect.deleteField(thing, "typeOfSection"); //this isnt even used why do we have this
				}
				if (thing.altAnim != true) {
					Reflect.deleteField(thing, "altAnim");
				}
				if (thing.gfSection != true) {
					Reflect.deleteField(thing, "gfSection");
				}
				if (thing.changeMania != true) {
					Reflect.deleteField(thing, "changeMania");
					Reflect.deleteField(thing, "maniaStr");
				}
				if (thing.focusCharacter == null) {
					Reflect.deleteField(thing, "focusCharacter");
				}
				if (thing.mustHitSection != false) {
					Reflect.deleteField(thing, "mustHitSection");
				}
				if (shrunkNoteTypeArr.length != curNoteTypeArr.length) {
					for (i in thing.sectionNotes) {
						i[3] = shrunkNoteTypeArr.indexOf(curNoteTypeArr[i[3]]);
					}
				}
			}
			if (json.song.maniaStr == "4k") {
				Reflect.deleteField(json.song, "maniaStr");
				Reflect.deleteField(json.song, "keyCount");
				Reflect.deleteField(json.song, "mania");
			} else {
				json.song.keyCount = ManiaInfo.GetManiaInfo(json.song.maniaStr).keys;
				if (ManiaInfo.ManiaConvertBack.exists(json.song.maniaStr)) {
					json.song.mania = ManiaInfo.ManiaConvertBack.get(json.song.maniaStr);
				}
			}
			if (json.song.timeSignature == 4) {
				Reflect.deleteField(json.song, "timeSignature");
			}
			if (json.song.healthDrain == 0) {
				Reflect.deleteField(json.song, "healthDrain");
				Reflect.deleteField(json.song, "healthDrainMin");
			}
			if (json.song.instName == "Inst" || json.song.instName == "") {
				Reflect.deleteField(json.song, "instName");
			}
			if (json.song.voicesName == "Voices" || json.song.voicesName == "") {
				Reflect.deleteField(json.song, "voicesName");
			}
			if (json.song.threeLanes != true) {
				Reflect.deleteField(json.song, "threeLanes");
			}
			if (json.song.picospeaker != "") {
				Reflect.deleteField(json.song, "picospeaker");
			}
			if (json.song.picocharts != null) {
				while (json.song.picocharts.length != 0 && json.song.picocharts[json.song.picocharts.length - 1] == "")
					json.song.picocharts.pop();
				if (json.song.picocharts.length == 0)
					Reflect.deleteField(json.song, "picocharts");
			} else {
				Reflect.deleteField(json.song, "picocharts");
			}
		}

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0)) {
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

class ChartEventSprite extends FlxSpriteGroup {
	public function new(x:Float, y:Float, eventInfo:Array<Dynamic>) {
		super(x, y);
		add(new FlxSprite(-100, 0).makeGraphic(100, 2, FlxColor.WHITE));
		add(new FlxText(-100, 2, 100, eventInfo[0], 16));
	}
}
