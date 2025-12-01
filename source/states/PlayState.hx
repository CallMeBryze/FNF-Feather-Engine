package states;

import engine.Resources;
import engine.Song;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.Character;
import objects.Player;
import objects.arrows.Note;
import objects.arrows.Strumline;
import states.template.MusicBeatState;

class PlayState extends MusicBeatState
{
    // assets
    public static var arrowAtlas:SparrowTracker;
    public static var strumAtlas:SparrowTracker;

	private var gameCam:FlxCamera;
	private var hudCam:FlxCamera;

	private var player:Player;
	private var dancer:Character;
	private var opponent:Character;

    private var strumLine:Strumline;

    public static var _song:Song = {
        song: "test",
        bpm: 120,
        stage: "stage",
        player: "bf",
        opponent: "dad",
        dancer: "girlfriend",
        notes: [],
        defaultLengthInSteps: 16
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

		player = new Player(500, 250, _song.player);
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

    private var inGameOver:Bool = false;
    private var objectAlphaMap:Map<FlxSprite, Float> = new Map();

	override public function update(elapsed:Float)
	{
        if (player.isDead) {
            if (!inGameOver) {
				gameCam.focusOn(player.getGraphicMidpoint());

				var getAlpha:FlxSprite->Void = (object) ->
				{
                    objectAlphaMap.set(object, object.alpha);
				};

				stageLayerBack.forEachOfType(FlxSprite, getAlpha);
				stageLayerFront.forEachOfType(FlxSprite, getAlpha);

				inGameOver = true;
            }

			var transitionObjects:FlxSprite->Void = (object) -> {
				var originalAlpha:Float = objectAlphaMap.get(object);
				object.alpha = FlxMath.lerp(object.alpha, Math.max(originalAlpha - 0.6, 0), FlxMath.getElapsedLerp(0.01, elapsed));
			};

			stageLayerBack.forEachOfType(FlxSprite, transitionObjects);
            stageLayerFront.forEachOfType(FlxSprite, transitionObjects);
        }

		super.update(elapsed);

        if (!player.busy && player.animation.finished)
            player.dance();

        if (FlxG.keys.pressed.LEFT)
            gameCam.scroll.x -= 10;
        else if (FlxG.keys.pressed.RIGHT)
			gameCam.scroll.x += 10;

		if (FlxG.keys.pressed.UP)
			gameCam.scroll.y -= 10;
        else if (FlxG.keys.pressed.DOWN)
			gameCam.scroll.y += 10;

        if (FlxG.keys.pressed.F7) {
            player.gameOver(()->{
                hudCam.fade(FlxColor.BLACK, 3, false, ()->{
					FlxG.switchState(() -> new PlayState());
                });
            });
        }
	}
}
