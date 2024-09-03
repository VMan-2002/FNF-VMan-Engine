package chartformat;

class ChartFormat {
	//basic info
	public var song:String;
	public var title:Null<String>;
    public var bpm:Float;
	public var speed:Float = 1.0;
	public var attributes:Array<Array<Dynamic>>;
	
	//gameplay
	public var validScore:Bool = true;
	public var events:Array<EventFormatVE>;
	public var notes:Array<SectionFormatVE>;

    public function new(song:String) {
        this.song = song;
        attributes = new Array<Array<String>>();
        events = new Array<EventFormatVE>();
        notes = new Array<SectionFormatVE>();
        setAttributesFromMap([
            "noteTypes" => ["Normal Note"]
        ]);
    }

    public function getAttribute(name:String) {
        for (thing in attributes) {
            if (thing[0] == name)
                return thing;
        }
        return [name];
    }

    public function setAttribute(dat:Array<Dynamic>) {
        for (i => thing in attributes.keyValueIterator()) {
            if (thing[0] == dat[0])
                return attributes[i] = dat;
        }
        attributes.push(dat);
        return dat;
    }

    public function setAttributesFromMap(attrib:Map<String, Array<Dynamic>>) {
        attributes.resize(0);
        for (n => dat in attrib) {
            attributes.push(cast([n], Array<Dynamic>).concat(dat));
        }
    }

    public function addAttributesFromMap(attrib:Map<String, Array<Dynamic>>) {
        for (n => dat in attrib) {
            setAttribute(cast([n], Array<Dynamic>).concat(dat));
        }
    }

    public function attributesToMap() {
        var result = new Map<String, Array<Dynamic>>();
        for (thing in attributes) {
            result.set(thing[0], thing.slice(1));
        }
        return result;
    }

    inline static function condSet(map, cond, name, val) {
        if (cond)
            map.set(name, val);
    }

    public static function fromOld(dat:ChartFormatOld) {
        var result = new ChartFormat(dat.song);
        result.title = dat.newtitle;
        result.bpm = dat.bpm;
        result.speed = dat.speed;
        result.validScore = dat.validScore;
        var attributes = new Map<String, Array<Dynamic>>();
        var empty = new Array<String>();
        if (dat.attributes == null) {
            for (thing in dat.attributes) {
                var newAttribute = [];
                for (n in thing) {
                    newAttribute.push(Std.string(n));
                }
                attributes.set(newAttribute.shift(), newAttribute);
            }
        }
        for (thing in dat.actions)
            attributes.set(thing, empty);
        attributes.set("healthDrain", [Std.string(dat.healthDrain == null ? 0 : dat.healthDrain), Std.string(dat.healthDrainMin == null ? 0 : dat.healthDrainMin)]);
        condSet(attributes, dat.usedNoteTypes != null && dat.usedNoteTypes.length != 0, "noteTypes", dat.usedNoteTypes);
        condSet(attributes, dat.hide_girlfriend == true, "hideGirlfriend", empty);
        condSet(attributes, dat.moreStrumLines == null, "strumLineCount", [Std.string(dat.moreStrumLines + 2)]);
        attributes.set("voicesName", [dat.voicesName]);
        condSet(attributes, dat.needsVoices == false, "needsVoices", [false]);
        attributes.set("instName", [dat.instName]);
        attributes.set("voicesOpponentName", [dat.voicesOpponentName]);
        condSet(attributes, dat.threeLanes == true, "threeLanes", empty);
        condSet(attributes, dat.picospeaker != null && dat.picospeaker != "", "picoSpeaker", [dat.picospeaker]);
        condSet(attributes, dat.picocharts != null && dat.picocharts.length != 0, "linkedCharts", dat.picocharts);
        condSet(attributes, dat.loopbackPoint != null, "loopTime", [Std.string(dat.loopbackPoint)]);
        condSet(attributes, dat.timeSignature != null && dat.timeSignature != 4, "sectionBeats", [Std.string(dat.timeSignature)]);
        
        attributes.set("characters", [dat.player1 == null ? "bf" : dat.player1, dat.player2 == null ? "mr_placeholder_guy" : dat.player2, dat.gfVersion == null ? "gf" : dat.gfVersion].concat(dat.moreCharacters == null ? [] : dat.moreCharacters));
        condSet(attributes, dat.stage != "stage" && dat.stage != null, "stage", [dat.stage]);
        condSet(attributes, dat.noteSkin != null && dat.noteSkin != "normal" && dat.noteSkin != "" && dat.noteSkinOpponent != null && dat.noteSkinOpponent.length != 0, "noteSkin", dat.noteSkinOpponent != null ? [dat.noteSkin].concat(dat.noteSkinOpponent) : [dat.noteSkin]);
        condSet(attributes, dat.uiStyle != null && dat.uiStyle != "" && dat.uiStyle != "normal", "uiStyle", [dat.uiStyle]);
        result.setAttributesFromMap(attributes);
        //this is wacky

        //todo: notes and events
    }

    public static function fromPsych(dat:ChartFormatPsych) {
        var result = new ChartFormat(dat.song);
        result.bpm = dat.bpm;
        result.speed = dat.speed;
        result.validScore = true;

        var attributes = new Map<String, Array<Dynamic>>();
        attributes.set("characters", [dat.player1, dat.player2]);
        attributes.set("stage", [dat.stage]);
        condSet(attributes, dat.needsVoices == false, "needsVoices", [false]);
        result.setAttributesFromMap(attributes);

        var noteTypes:Array<String> = ["Normal Note"];
        var ntOld = ['Normal Note', 'Alt Animation', 'Hey', 'Hurt Note', 'GF Sing', 'No Animation'];
        for (section in dat.notes) {
            var newSection:SectionFormatVE = {
                notes: [],
                chars: section.gfSection ? [2, section.mustHitSection ? 1 : 0] : null,
                bpm: section.changeBPM ? section.bpm : null,
                mania: null,
                mustHitSection: section.mustHitSection,
                focusCharacter: section.gfSection ? 2 : null,
                sectionSteps: Math.floor(section.sectionBeats * 4),
                beatSteps: 4
            }
            for (note in section.sectionNotes) {
                var nt:String = (note.length < 4 || note[3] == null) ? "Normal Note" : (Std.isOfType(note[3], String) ? note[3] : ntOld[note[3]]);
                newSection.notes.push({
                    t: note[0],
                    d: note[1],
                    l: note[2],
                    n: noteTypes.indexOf(nt)
                });
            }
            result.notes.push(newSection);
        }

        //todo: events

        return result;
    }
    
    public static function fromLeather(dat:ChartFormatLeather) {
        var result = new ChartFormat(dat.song);
        result.bpm = dat.bpm;
        result.speed = dat.speed;
        result.validScore = dat.validScore;

        var attributes = new Map<String, Array<Dynamic>>();
        var gf = dat.gf;
        if (gf == null)
            gf = dat.gfVersion == null ? dat.player3 : dat.gfVersion;
        attributes.set("characters", [dat.player1, dat.player2, gf]);
        if (dat.specialAudioName != null) {
            attributes.set("instName", ["Inst-" + dat.specialAudioName]);
            attributes.set("voicesName", ["Voices-" + dat.specialAudioName]);
        }
        if (dat.keyCount != null || dat.playerKeyCount != null) {
            var kc = dat.keyCount == null ? 4 : dat.keyCount;
            attributes.set("mania", [(dat.playerKeyCount != null ? dat.playerKeyCount : kc) + "k", kc + "k"]);
        }
        if (dat.ui_Skin != null) {
            attributes.set("uiStyle", [dat.ui_Skin]);
            attributes.set("noteSkin", [dat.ui_Skin]);
        }
        
        //todo: notes and events
    }
}

typedef SectionFormatVE = {
    var notes:Array<NoteFormatVE>;
    var chars:Null<Array<Int>>; //by default, which characters sing in this section per side
    var bpm:Float;
    var mania:Null<Array<Null<String>>>;
    var mustHitSection:Bool;
    var focusCharacter:Null<Int>;
    var sectionSteps:Int; //how many steps in sections
    var beatSteps:Int; //how many steps are in beats in sections
}

typedef NoteFormatVE = {
    var t:Float; //strumTime
    var d:Int; //noteData
    var l:Float; //sustainLength
    var n:Int; //noteType
}

typedef EventFormatVE = {
    var t:Float; //strumTime
    var d:Int; //index in attributes -> "events"
}