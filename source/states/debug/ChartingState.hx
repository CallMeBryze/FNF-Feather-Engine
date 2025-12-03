package states.debug;

import engine.Conductor;
import engine.Resources;
import engine.Song;
import engine.VocalGroup;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import objects.HealthIcon;
import objects.arrows.Note;
import objects.arrows.Strumline;
import objects.editor.NumericStepper;
import states.template.MusicBeatState;

class ChartingState extends MusicBeatState
{
    private var chartCam:FlxCamera;
    private var topCam:FlxCamera;

    private var chartElements:FlxGroup = new FlxGroup();
    private var uiElements:FlxGroup = new FlxGroup();

    private var renderedNotes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

    private var strumLine:FlxSprite;

    private var playerIcon:HealthIcon;
    private var opponentIcon:HealthIcon;

	private var sectionGridGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	private var opponentGridBG:FlxSprite;
	private var playerGridBG:FlxSprite;

    private var sectionTypeMap:Map<FlxSprite, Int> = new Map();

    private var lastSection:Int = 0;
    private var curSection:Int = 0;

    private var curSectionData:SongSection;
    private var curSectionGridBG:FlxSprite;

    private var uiMenu:FlxUITabMenu;
    private var chartCursor:FlxSprite;

    private var _song:Song;

    private var inst:FlxSound;
    private var vocals:VocalGroup;

    private var noteWidth:Int = 32;

    private var requiredLibrary:String;

    // This Game Engine is going to give me an aneurysm istg.
    private var dumbMouseFix:FlxObject;

    override public function create()
    {
        @:privateAccess
        requiredLibrary = Resources.selectedLibrary;

        var bgCam:FlxCamera = new FlxCamera();
        FlxG.cameras.add(bgCam, false);

        var bg:FlxSprite = new FlxSprite(0, 0, Resources.getImage("menuDesat"));
        bg.color = FlxColor.GRAY;
        bg.camera = bgCam;
        add(bg);

        chartCam = new FlxCamera();
        FlxG.cameras.add(chartCam, true);

        topCam = new FlxCamera();
        FlxG.cameras.add(topCam, false);

        topCam.bgColor = chartCam.bgColor = FlxColor.TRANSPARENT;

		FlxG.camera = this.camera = topCam;

        _song = PlayState._song;

        reloadAudio();

        // Initialize Conductor
        Conductor.songPosition = 0;

		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

        dumbMouseFix = new FlxObject();
        dumbMouseFix.camera = chartCam;
        chartElements.add(dumbMouseFix);

		opponentIcon = new HealthIcon("face", false);
        opponentIcon.setGraphicSize(Math.floor(150 / 2));
        opponentIcon.updateHitbox();
        opponentIcon.alpha = 0.4;
        opponentIcon.active = false;

        playerIcon = new HealthIcon("bf", true);
		playerIcon.setGraphicSize(Math.floor(150 / 2));
        playerIcon.updateHitbox();
        playerIcon.alpha = 0.4;
        playerIcon.active = false;

		opponentGridBG = FlxGridOverlay.create(noteWidth, noteWidth, noteWidth * 4, noteWidth * 16);
		opponentGridBG.updateHitbox();
        opponentGridBG.screenCenter(Y);
		opponentGridBG.x = ((camera.width / 2) - (opponentGridBG.width / 2)) - ((opponentGridBG.width / 2) + (noteWidth / 4));
        sectionGridGroup.add(opponentGridBG);

        sectionTypeMap.set(opponentGridBG, 0);

        playerGridBG = FlxGridOverlay.create(noteWidth, noteWidth, noteWidth * 4, noteWidth * 16);
		playerGridBG.updateHitbox();
        playerGridBG.screenCenter(Y);
		playerGridBG.x = ((camera.width / 2) - (playerGridBG.width / 2)) + ((playerGridBG.width / 2) + (noteWidth / 4));
        sectionGridGroup.add(playerGridBG);

        sectionTypeMap.set(playerGridBG, 1);

        strumLine = new FlxSprite().makeGraphic(camera.width, 4, FlxColor.BLACK);
        strumLine.alpha = 0.6;

		opponentIcon.x = ((opponentGridBG.x + opponentGridBG.width) - (opponentGridBG.width / 2)) - (opponentIcon.width / 2);
		playerIcon.x = ((playerGridBG.x + playerGridBG.width) - (playerGridBG.width / 2)) - (playerIcon.width / 2);
		playerIcon.y = opponentIcon.y = opponentGridBG.y - (150 / 2);

        chartCursor = new FlxSprite().makeGraphic(noteWidth, noteWidth, FlxColor.WHITE);
        chartCursor.alpha = 0.7;
		chartCursor.setPosition(opponentGridBG.x, opponentGridBG.y);

		chartElements.add(sectionGridGroup);
        chartElements.add(renderedNotes);
		chartElements.add(playerIcon);
		chartElements.add(opponentIcon);
        chartElements.add(chartCursor);
		chartElements.add(strumLine);

        // UI
		var tabs = [
            {name: "Editor", label: "Editor"},
            {name: "Note", label: "Note"},
            {name: "Section", label: "Section"},
            {name: "Song", label: "Song"}
        ];

        uiMenu = new FlxUITabMenu(null, tabs, true);
        uiMenu.resize(300, 400);

        initializeUI();
		
		uiMenu.setPosition((topCam.width - 332), ((topCam.height / 2) - (uiMenu.height / 2)));

        uiElements.add(uiMenu);

        super.create();

        curSectionGridBG = opponentGridBG;

        curSectionData = _song.notes[curSection];
        changeSection(curSection);

		chartElements.camera = chartCam;
        uiElements.camera = topCam;

        add(chartElements);
        add(uiElements);

        chartCam.follow(strumLine);
		chartCam.setScrollBounds(0, camera.width, -camera.height, camera.height * 2);
    }

    // Messy lol
    private function initializeUI():Void {
        // Editor Tab
        var editorTabGroup:FlxUI = new FlxUI(null, uiMenu);
        editorTabGroup.name = 'Editor';

        var saveButton:FlxButton = new FlxButton(8, 8, "Save", () -> {

        });

        editorTabGroup.add(saveButton);

		var loadButton:FlxButton = new FlxButton(0, saveButton.y, "Load", () -> {

        });
		loadButton.x = (uiMenu.width / 2) - (loadButton.width / 2);

        editorTabGroup.add(loadButton);

        var archiveButton:FlxButton = new FlxButton(0, saveButton.y, "Archive", () -> { 

        });
		archiveButton.x = uiMenu.width - (archiveButton.width + saveButton.x);

        editorTabGroup.add(archiveButton);

        var requiredLibraryText:FlxText = new FlxText(8, 32, 0, "Required Library");
        editorTabGroup.add(requiredLibraryText);
        var requiredLibrary:FlxUIDropDownMenu = new FlxUIDropDownMenu(requiredLibraryText.x, requiredLibraryText.y + requiredLibraryText.height + 2, 
			FlxUIDropDownMenu.makeStrIdLabelArray(Resources.getTxt("data/libraries").split('\n')), (selection:String) -> {
                trace('Loading Library: $selection');

                this.active = false;

                var future = Resources.changeLibrary(selection);
                future.onComplete((v) -> {
                    this.active = true;
                    trace('Library Loaded!');
                });
                future.onError((e)->{
					this.active = true;
					trace('Library Error! ($e).');
                });

                this.requiredLibrary = selection;
            });

        @:privateAccess
        if (Resources.selectedLibrary != null)
            requiredLibrary.selectedLabel = Resources.selectedLibrary;
        else
            requiredLibrary.selectedLabel = 'default';
        
        editorTabGroup.add(requiredLibrary);

        // Note Tab
        var noteTabGroup:FlxUI = new FlxUI(null, uiMenu);
        noteTabGroup.name = 'Note';

        // Section Tab
        var sectionTabGroup:FlxUI = new FlxUI(null, uiMenu);
        sectionTabGroup.name = 'Section';

        // Song Tab
        var songTabGroup:FlxUI = new FlxUI(null, uiMenu);
        songTabGroup.name = 'Song';

        var songNameInput:FlxInputText = new FlxInputText(((uiMenu.width - 150) - 8) - 8, 8, 150, _song.song);
        songNameInput.callback = (prevStr:String, newStr:String) -> {
            _song.song = songNameInput.text;
        };
        songTabGroup.add(songNameInput);

        var reloadAudioButton:FlxButton = new FlxButton(0, 0, "Reload Audio", reloadAudio);
        reloadAudioButton.setPosition(songNameInput.x + ((songNameInput.width / 2) - (reloadAudioButton.width / 2)), (songNameInput.y + songNameInput.height) + 2);
        songTabGroup.add(reloadAudioButton);

        var bpmText:FlxText = new FlxText(8, 8, 0, "BPM: ");
        songTabGroup.add(bpmText);

        var bpmStepper:NumericStepper = new NumericStepper(bpmText.x + bpmText.width + 2, bpmText.y, 0.5, _song.bpm, 60, 522, 2);
        bpmStepper.onValueChanged = (bpm:Float) -> {
            _song.bpm = bpm;

            Conductor.mapBPMChanges(_song);
            Conductor.changeBPM(bpm);
        };
        songTabGroup.add(bpmStepper);

        var defaultSectionLengthText:FlxText = new FlxText(bpmText.x, uiMenu.height - 32, 0, "Default Section Length: ");
        songTabGroup.add(defaultSectionLengthText);

        var defaultSectionLengthStepper:NumericStepper = new NumericStepper(defaultSectionLengthText.x + defaultSectionLengthText.width + 2, 
            defaultSectionLengthText.y, 2, 16, 4, 16, 0);
        defaultSectionLengthStepper.onValueChanged = (length:Float) -> {
            var trueLength:Int = Math.floor(length);

            _song.defaultLengthInSteps = trueLength;
        };

        songTabGroup.add(defaultSectionLengthStepper);

        // Add Groups
        var groups:Array<FlxUI> = [editorTabGroup, noteTabGroup, sectionTabGroup, songTabGroup];
        for (group in groups)
            uiMenu.addGroup(group);
    }

	override public function update(elapsed:Float)
	{
        if (curSectionData != null) {
			switch (curSectionData.sectionFocus)
			{
				case 0:
					opponentIcon.alpha = 1;
					playerIcon.alpha = 0.4;
				case 1:
					opponentIcon.alpha = 0.4;
					playerIcon.alpha = 1;
			}
        }

		super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE) {
            PlayState._song = _song;
			LoadingState.loadAndSwitchState(new PlayState(), requiredLibrary);
        }

		dumbMouseFix.setPosition(FlxG.mouse.x + chartCam.scroll.x, FlxG.mouse.y + chartCam.scroll.y);

        Conductor.songPosition = inst.time;
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps), opponentGridBG);

        if (!FlxG.mouse.overlaps(uiMenu)) {
            uiMenu.active = false;

            if (FlxG.keys.justPressed.A || FlxG.keys.justPressed.D) {
                if (FlxG.keys.justPressed.A && curSection > 0)
                    changeSection(curSection - 1);
                else if (FlxG.keys.justPressed.D && sectionStartTime(curSection + 1) < inst.length)
                    changeSection(curSection + 1);

                Conductor.songPosition = inst.time = sectionStartTime(curSection);
            }

            inst.pitch = 1;

            if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
                if (FlxG.keys.pressed.W) {
                    inst.time -= 1000 * elapsed;
					inst.pause();
                } else if (FlxG.keys.pressed.S) {
                    if (!inst.playing)
                        inst.time += 1000 * elapsed;
                    else
                        inst.pitch = 1.25;
                }
            }

            if (FlxG.keys.justPressed.SPACE) {
                if (inst.playing)
                    inst.pause();
                else {
					inst.resume();

                    if (!inst.playing) {
                        inst.play(false, Conductor.songPosition);
                    }
                }
            }
        } else {
            uiMenu.active = true;
        }

        if (Conductor.songPosition >= sectionStartTime() + (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)) {
            trace('Moving to next section!');
            changeSection(curSection + 1);
        } else if (Conductor.songPosition < sectionStartTime()) {
			if (_song.notes[curSection - 1] != null) {
				trace('Moving to previous section!');
				changeSection(curSection - 1);
            } else {
                inst.time = sectionStartTime();
            }
        }

        if (dumbMouseFix.overlaps(sectionGridGroup)) {
            var gridBG:FlxSprite = null;
            sectionGridGroup.forEachAlive((sectionGrid) -> {
				if (dumbMouseFix.overlaps(sectionGrid))
                    curSectionGridBG = gridBG = sectionGrid;
            });

			var mouseXInGrid = dumbMouseFix.x - gridBG.x;
			var mouseYInGrid = dumbMouseFix.y - gridBG.y;

            mouseXInGrid = Math.max(0, Math.min(mouseXInGrid, gridBG.clipRect.width));
			mouseYInGrid = Math.max(0, Math.min(mouseYInGrid, gridBG.clipRect.height));

            if (!FlxG.keys.pressed.ALT) {
			    chartCursor.setPosition(
                    Math.floor((mouseXInGrid / noteWidth)) * noteWidth + gridBG.x,
                    Math.floor((mouseYInGrid / noteWidth)) * noteWidth + gridBG.y
                );
            }
            else {
				chartCursor.setPosition(
				    Math.floor((mouseXInGrid / noteWidth)) * noteWidth + gridBG.x,
					Math.floor((mouseYInGrid / (noteWidth / 4))) * (noteWidth / 4) + gridBG.y
                );
            }

            if (FlxG.mouse.justPressed) {
                var safeToAdd:Bool = true;

                // Pretty Unoptimal, but I'm lazy and tired.
                for (note in renderedNotes) {
					if (Std.isOfType(note, Note) && dumbMouseFix.overlaps(note))
					{
						var swagNote:Note = cast(note, Note);

						if (swagNote.strumTime <= (sectionStartTime() + getStrumTime(dumbMouseFix.y)) + (Conductor.stepCrochet / 4)) {
							removeNote(swagNote.strumTime, Note.convertFromEnum(swagNote.direction), gridBG);

							safeToAdd = false;

							clearRenderedNotes();

							buildSectionNotes(curSection, opponentGridBG);
							buildSectionNotes(curSection, playerGridBG);

							break;
                        }
					}
                }

                if (safeToAdd) {
					addNote(getStrumTime(chartCursor.y, gridBG), Math.floor(mouseXInGrid / noteWidth), gridBG);
                }
            }
        }

		inst.update(elapsed);
		vocals.update(elapsed);
	}

    private function getStrumTime(yPos:Float, ?sectionGrid:FlxSprite = null):Float
    {
        var gridBG:FlxSprite = sectionGrid;
        if (sectionGrid == null)
            gridBG = curSectionGridBG;

		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
    }

	private function getYfromStrum(strumTime:Float, ?sectionGrid:FlxSprite = null):Float
	{
		var gridBG:FlxSprite = sectionGrid;
		if (sectionGrid == null)
			gridBG = curSectionGridBG;

		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function sectionStartTime(?section:Null<Int>):Float
	{
        if (section == null)
            section = curSection;

		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...section)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += (_song.notes[i].lengthInSteps / 4) * (1000 * 60 / daBPM);
		}
		return daPos;
	}

    private function createNoteObjects(note:SectionNote, sectionGrid:FlxSprite):Array<FlxSprite> {
		var daNote:Note = new Note(note.strumTime, Note.convertToEnum(note.arrow));

		daNote.setGraphicSize(noteWidth);
		daNote.updateHitbox();

		daNote.x = sectionGrid.x + (noteWidth * note.arrow);
		daNote.y = Math.floor(getYfromStrum(note.strumTime, sectionGrid));

		var sustainNote:FlxSprite = null;
		if (note.sustainLength > 0)
		{
			sustainNote = new FlxSprite(daNote.x + (noteWidth / 2), daNote.y + (noteWidth / 2));
			sustainNote.makeGraphic(Math.floor(noteWidth / 4),
				Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, sectionGrid.height)));
		}

		return [daNote, sustainNote];
    }

    private function buildSectionNotes(section:Int, sectionGrid:FlxSprite):Void {
        var sectionData:SongSection = _song.notes[section];
        var sectionNotes:Array<SectionNote> = [];

        if (sectionData == null) {
            var bpmToUse:Float = _song.bpm;
            if (_song.notes[section - 1] != null)
				bpmToUse = _song.notes[section - 1].bpm;

            sectionData = _song.notes[section] = {
                bpm: _song.bpm,
                changeBPM: false,
                lengthInSteps: _song.defaultLengthInSteps,

                sectionFocus: 0,

                opponentNotes: [],
                playerNotes: []
            }
        }

        switch (sectionTypeMap.get(sectionGrid)) {
            default: 
                sectionNotes = sectionData.opponentNotes;
            case 1:
                sectionNotes = sectionData.playerNotes;
        }

		for (note in sectionNotes)
		{
			var swag:Array<FlxSprite> = createNoteObjects(note, sectionGrid);

			renderedNotes.add(swag[0]);
			if (swag[1] != null)
				renderedNotes.add(swag[1]);
		}
    }

    private function addNote(strumTime:Float, arrow:Int, sectionGrid:FlxSprite):Void {
		var sectionData:SongSection = _song.notes[curSection];
		var sectionNotes:Array<SectionNote> = [];

		switch (sectionTypeMap.get(sectionGrid))
		{
			default:
				sectionNotes = sectionData.opponentNotes;
			case 1:
				sectionNotes = sectionData.playerNotes;
		}
        
		var newNote:SectionNote = {
			arrow: arrow,
			strumTime: strumTime,
			sustainLength: 0
		};

        sectionNotes.push(newNote);

		var swag:Array<FlxSprite> = createNoteObjects(newNote, sectionGrid);
		renderedNotes.add(swag[0]);
		if (swag[1] != null)
			renderedNotes.add(swag[1]);
    }

    private function clearRenderedNotes():Void {
        renderedNotes.forEachAlive((object) -> {
            object.kill();
            renderedNotes.remove(object);
            object.destroy();
        });

        renderedNotes.clear();
    }

    private function removeNote(strumTime:Float, arrow:Int, sectionGrid:FlxSprite):Void {
		var sectionData:SongSection = _song.notes[curSection];
		var sectionNotes:Array<SectionNote> = [];

		switch (sectionTypeMap.get(sectionGrid))
		{
			default:
				sectionNotes = sectionData.opponentNotes;
			case 1:
				sectionNotes = sectionData.playerNotes;
		}

        for (note in sectionNotes) {
            if (note.strumTime == strumTime && note.arrow == arrow) {
                sectionNotes.remove(note);
                break;
            }
        }
    }

    private function changeSection(section:Int) {
        clearRenderedNotes();

        curSection = section;

		buildSectionNotes(section, opponentGridBG);
		buildSectionNotes(section, playerGridBG);

		curSectionData = _song.notes[section];

		updateSectionLength(opponentGridBG, section);
		updateSectionLength(playerGridBG, section);

        var startTime:Float = sectionStartTime(section);
        if (inst.time < startTime)
            inst.time = startTime;

        Conductor.songPosition = inst.time;
    }

	private function updateSectionLength(sectionGrid:FlxSprite, ?section:Null<Int> = null) {
        if (section == null)
            section = curSection;

		var clipRect = new FlxRect(0, 0, noteWidth * 4, _song.notes[section].lengthInSteps * noteWidth);
        sectionGrid.clipRect = clipRect;
    }

    private function reloadAudio():Void {
		inst = Resources.getAudio('songs/${_song.song}/Inst');
		vocals = new VocalGroup(inst);

		inst.autoDestroy = false;

		var playerVocals:FlxSound = Resources.getAudio('songs/${_song.song}/Vocals-Player');
		var opponentVocals:FlxSound = Resources.getAudio('songs/${_song.song}/Vocals-Opponent');

		playerVocals.autoDestroy = false;
		opponentVocals.autoDestroy = false;

		vocals.add(playerVocals, 'player');
		vocals.add(opponentVocals, 'opponent');

		inst.play();
		inst.pause();
    }
}