package states.debug;

import engine.Song;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup;
import objects.HealthIcon;
import states.template.MusicBeatState;

class ChartingState extends MusicBeatState
{
    private var chartElements:FlxGroup = new FlxGroup();
    private var uiElements:FlxGroup = new FlxGroup();

    private var playerIcon:HealthIcon;
    private var opponentIcon:HealthIcon;

    private var gridBG:FlxSprite;

    private var lastSection:Int = 0;
    private var curSection:Int = 0;

    private var _song:Song;

    private var noteWidth:Int = 96;

    override public function create()
    {
        _song = PlayState._song;

		gridBG = FlxGridOverlay.create(noteWidth, noteWidth, noteWidth * 8, noteWidth * 16);
        chartElements.add(gridBG);

        gridBG.screenCenter(XY);

        super.create();

        add(chartElements);
        add(uiElements);
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}