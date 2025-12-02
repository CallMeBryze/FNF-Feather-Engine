package states.debug;

import engine.Conductor;
import engine.Resources;
import engine.Song;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import objects.HealthIcon;
import objects.arrows.Note;
import states.template.MusicBeatState;

class ChartingState extends MusicBeatState
{
    private var chartCam:FlxCamera;
    private var uiCam:FlxCamera;
    private var topCam:FlxCamera;

    private var chartElements:FlxGroup = new FlxGroup();
    private var uiElements:FlxGroup = new FlxGroup();

    private var renderedNotes:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

    private var playerIcon:HealthIcon;
    private var opponentIcon:HealthIcon;

	private var sectionGridGroup:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	private var opponentGridBG:FlxSprite;
	private var playerGridBG:FlxSprite;

    private var sectionTypeMap:Map<FlxSprite, Int> = new Map();

    private var chartCursor:FlxSprite;

    private var lastSection:Int = 0;
    private var curSection:Int = 0;

    private var curSectionData:SongSection;
    private var curSectionGridBG:FlxSprite;

    private var _song:Song;

    private var noteWidth:Int = 32;

    override public function create()
    {
        var bgCam:FlxCamera = new FlxCamera();
        FlxG.cameras.add(bgCam, false);

        var bg:FlxSprite = new FlxSprite(0, 0, Resources.getImage("menuDesat"));
        bg.color = FlxColor.GRAY;
        bg.camera = bgCam;
        add(bg);

        chartCam = new FlxCamera(0, 0, 960, 720);
        FlxG.cameras.add(chartCam, true);

        uiCam = new FlxCamera(960, 0, 320, 720);
        FlxG.cameras.add(uiCam, false);

        // Fixes issues with the transitioning between states
        topCam = new FlxCamera();
        FlxG.cameras.add(topCam, false);

        topCam.bgColor = chartCam.bgColor = uiCam.bgColor = FlxColor.TRANSPARENT;

		this.camera = chartCam;

        _song = PlayState._song;

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

		chartElements.camera = chartCam;
		uiElements.camera = uiCam;

        super.create();

		buildSectionNotes(curSection, opponentGridBG);
        buildSectionNotes(curSection, playerGridBG);

        curSectionData = _song.notes[curSection];

        add(chartElements);
        add(uiElements);
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

        if (FlxG.mouse.overlaps(sectionGridGroup)) {
            var gridBG:FlxSprite = null;
            sectionGridGroup.forEachAlive((sectionGrid) -> {
                if (FlxG.mouse.overlaps(sectionGrid))
                    curSectionGridBG = gridBG = sectionGrid;
            });

            var mouseXInGrid = FlxG.mouse.x - gridBG.x;
            var mouseYInGrid = FlxG.mouse.y - gridBG.y;

            mouseXInGrid = Math.max(0, Math.min(mouseXInGrid, gridBG.width));
			mouseYInGrid = Math.max(0, Math.min(mouseYInGrid, gridBG.height));

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

                // Pretty Unoptimal, but I'm lazy.
                for (note in renderedNotes) {
					if (Std.isOfType(note, Note) && FlxG.mouse.overlaps(note))
					{
						var swagNote:Note = cast(note, Note);

                        if (swagNote.strumTime <= getStrumTime(FlxG.mouse.y) + (Conductor.stepCrochet / 4)) {
							removeNote(swagNote.strumTime, Note.convertFromEnum(swagNote.direction), gridBG);

							safeToAdd = false;
							trace('Removed Note!');

							clearRenderedNotes();

							buildSectionNotes(curSection, opponentGridBG);
							buildSectionNotes(curSection, playerGridBG);

							break;
                        }
					}
                }

                if (safeToAdd) {
					addNote(getStrumTime(chartCursor.y), Math.floor(mouseXInGrid / noteWidth), gridBG);
                    trace('Added Note!');
                }
            }
        }
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

    private function createNoteObjects(note:SectionNote, sectionGrid:FlxSprite):Array<FlxSprite> {
		var daNote:Note = new Note(note.strumTime, Note.convertToEnum(note.arrow));
		daNote.x = sectionGrid.x + (noteWidth * note.arrow);
		daNote.y = Math.floor(getYfromStrum((note.strumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps), sectionGrid));

		daNote.setGraphicSize(noteWidth);
		daNote.updateHitbox();

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
}