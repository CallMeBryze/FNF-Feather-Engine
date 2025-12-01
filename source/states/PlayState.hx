package states;

import engine.Resources;
import engine.Song;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import objects.Character;
import objects.arrows.Note;
import objects.arrows.Strumline;

class PlayState extends FlxState
{
	private var gameCam:FlxCamera;
	private var hudCam:FlxCamera;

	private var player:Character;
	private var dancer:Character;
	private var opponent:Character;

    private var strumLine:Strumline;

    public static var _song:Song = {
        bpm: 120,
        stage: "stage",
        player: "bf",
        opponent: "daddy dearest",
        dancer: "girlfriend",
        notes: []
    };

    // Stage Layers
	private var stageLayerBack:FlxGroup = new FlxGroup();
    private var stageLayerCharacters:FlxGroup = new FlxGroup();
	private var stageLayerFront:FlxGroup = new FlxGroup();

	override public function create()
	{
		gameCam = new FlxCamera();
		gameCam.zoom = 0.7;
		FlxG.cameras.add(gameCam, true);

		camera = gameCam;

		hudCam = new FlxCamera();
		hudCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCam, false);

		super.create();

		player = new Character(500, 250, _song.player);
        stageLayerCharacters.add(player);

        switch (_song.stage) {
            default:
                gameCam.zoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Resources.getImage("stages/stage/stageback"));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;

				stageLayerBack.add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Resources.getImage("stages/stage/stagefront"));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				stageLayerBack.add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-350, -300).loadGraphic(Resources.getImage("stages/stage/stagecurtains"));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				stageLayerFront.add(stageCurtains);
        }

        add(stageLayerBack);
        add(stageLayerCharacters);
        add(stageLayerFront);

        strumLine = new Strumline(0, 0);
        strumLine.camera = hudCam;
        add(strumLine);

        strumLine.screenCenter(X);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

        if (player.animation.finished)
            player.dance();

        if (FlxG.keys.pressed.LEFT)
            gameCam.scroll.x -= 10;
        else if (FlxG.keys.pressed.RIGHT)
			gameCam.scroll.x += 10;

		if (FlxG.keys.pressed.UP)
			gameCam.scroll.y -= 10;
        else if (FlxG.keys.pressed.DOWN)
			gameCam.scroll.y += 10;
	}
}
