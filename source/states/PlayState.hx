package states;

import engine.Conductor;
import engine.Resources;
import engine.Song;
import engine.VocalGroup;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.Character;
import objects.Player;
import objects.arrows.Note;
import objects.arrows.Strumline;
import states.debug.ChartingState;
import states.template.MusicBeatState;

class PlayState extends MusicBeatState
{
    // assets
    public static var arrowAtlas:SparrowTracker;
    public static var strumAtlas:SparrowTracker;
    public static var sustainGrapihc:FlxGraphic;

	private var gameCam:FlxCamera;
	private var hudCam:FlxCamera;

	private var player:Player;
	private var dancer:Character;
	private var opponent:Character;

    private var strumLine:Strumline;

    public static var _song:Song = {
        song: "test",
        bpm: 150,
        stage: "stage",
        player: "bf",
        dancer: "gf",
        opponent: "dad",
        notes: [],
        defaultLengthInSteps: 16,
        scrollSpeed: 1.2
    };

	private var inst:FlxSound;
	private var vocals:VocalGroup;

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

        Conductor.songPosition = 0;

        Conductor.changeBPM(_song.bpm);
        Conductor.mapBPMChanges(_song);

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
				object.alpha = FlxMath.lerp(object.alpha, Math.max(originalAlpha - 0.75, 0), FlxMath.getElapsedLerp(0.01, elapsed));
			};

			stageLayerBack.forEachOfType(FlxSprite, transitionObjects);
            stageLayerFront.forEachOfType(FlxSprite, transitionObjects);
        }

		super.update(elapsed);

        inst.update(elapsed);
        vocals.update(elapsed);

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

        if (FlxG.keys.pressed.F9) {
            player.gameOver(()->{
                hudCam.fade(FlxColor.BLACK, 3, false, ()->{
					FlxG.switchState(() -> new PlayState());
                });
            });
        } else if (FlxG.keys.justPressed.F7) {
            FlxG.switchState(() -> new ChartingState());
        }
	}
}
