package states;

import engine.Conductor;
import engine.Resources;
import engine.Song;
import engine.SongGroup;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.Character;
import objects.Player;
import objects.arrows.Note;
import objects.arrows.Strumline;
import states.debug.ChartingState;
import states.template.MusicBeatState;

using StringTools;

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

	private var opponentStrumLine:Strumline;
    private var playerStrumLine:Strumline;

    private var songNotes:FlxTypedGroup<Note> = new FlxTypedGroup();

	private var renderedNotes:FlxTypedGroup<Note> = new FlxTypedGroup();
	private var renderedSustains:FlxTypedGroup<Note> = new FlxTypedGroup();

    public static var _songData:Song = {
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

	private var song:SongGroup;

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

		var inst = Resources.getAudio('songs/${_songData.song}/Inst');
        inst.volume = 0.7;
		inst.autoDestroy = false;

		song = new SongGroup(inst);

		var playerVocals:FlxSound = Resources.getAudio('songs/${_songData.song}/Vocals-Player');
		var opponentVocals:FlxSound = Resources.getAudio('songs/${_songData.song}/Vocals-Opponent');

		playerVocals.autoDestroy = false;
		opponentVocals.autoDestroy = false;

		song.add(playerVocals, 'player');
		song.add(opponentVocals, 'opponent');

		inst.play();
		inst.pause();

        Conductor.changeBPM(_songData.bpm);
        Conductor.mapBPMChanges(_songData);

		Conductor.songPosition = -3000;

		super.create();

        dancer = new Character(400, 100, _songData.dancer);
        stageLayerCharacters.add(dancer);

        opponent = new Character(140, 50, _songData.opponent);
        stageLayerCharacters.add(opponent);

		player = new Player(940, 420, _songData.player);
		stageLayerCharacters.add(player);

        switch (_songData.stage) {
            default:
                gameCam.zoom = 0.9;

				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Resources.getImage("stages/stage/stageback", "week1"));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;

				stageLayerBack.add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Resources.getImage("stages/stage/stagefront", "week1"));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;

				stageLayerBack.add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-350, -300).loadGraphic(Resources.getImage("stages/stage/stagecurtains", "week1"));
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

        opponentStrumLine = new Strumline(64, 0);
        opponentStrumLine.camera = hudCam;

        playerStrumLine = new Strumline(0, 0);
        playerStrumLine.x = (gameCam.width - playerStrumLine.width) - 64;
        playerStrumLine.camera = hudCam;

        add(playerStrumLine);
        add(opponentStrumLine);

        renderedNotes.camera = hudCam;
        renderedSustains.camera = hudCam;

        add(renderedSustains);
		add(renderedNotes);

        generateSong();
	}

    // Game Over Stuff
    private var inGameOver:Bool = false;
    private var objectAlphaMap:Map<FlxSprite, Float> = new Map();

    // Misc.
    private var previousFrameTime:Int = 0;
    private var songPos:Float = 0;
    private var lastSongPos:Float = 0;

    // Checks
    private var inCountdown:Bool = false;
    private var songStarted:Bool = false;
    private var paused:Bool = false;

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

        if (FlxG.keys.justPressed.SPACE) {
            songStarted = true;
        }

		super.update(elapsed);

        song.update(elapsed);

        if ((inCountdown || songStarted) && !paused) {
            Conductor.songPosition += elapsed * 1000;
			checkSync();

            if (inCountdown) {
                songPos = Conductor.songPosition;

                // Implement later lol
                if (Conductor.songPosition >= 0) {
                    songPos = 0;

                    inCountdown = false;
                }
            } else {
                songPos += FlxG.game.ticks - previousFrameTime;
                previousFrameTime = FlxG.game.ticks;

                if (lastSongPos != Conductor.songPosition) {
                    songPos = (songPos + Conductor.songPosition) / 2;
                    lastSongPos = Conductor.songPosition;
                }
            }
        }

		var final_scrollSpeed:Float = 0.45 * PlayState._songData.scrollSpeed;
        songNotes.forEachAlive((note) -> {
            var strumNote:StrumNote = note.strumParent;
			var targetY:Float = ((strumNote.y - (strumNote.height / 2)) + (note.height / 2));

            note.y = targetY - ((songPos - note.strumTime) * final_scrollSpeed);
            note.x = strumNote.x + ((strumNote.width / 2) - (note.width / 2));

            if (note.y <= hudCam.height) {
                note.active = note.visible = true;
            }
            else {
                note.active = note.visible = false;
            }

			if (note.isSustain && note.y + note.offset.y <= (targetY + note.height)) {
                if (note.wasHit || (note.prevNote != null && note.prevNote.wasHit && !note.canBeHit)) {
					var swagRect = new FlxRect(0, (targetY + note.height) - note.y, note.width * 2, note.height * 2);
					swagRect.y /= note.scale.y;
					swagRect.height -= swagRect.y;

					note.clipRect = swagRect;
                }
			}

            if (note.canBeHit && !note.tooLate) {
                if (note.strumTime >= Conductor.songPosition) {
                    if (note.noteFocus == OPPONENT) {
						note.strumParent.playAnim('confirm');
						note.wasHit = true;

                        var animToSing:String = "singLEFT";

                        switch (note.direction) {
                            case LEFT:
                                animToSing = 'singLEFT';
                            case DOWN:
								animToSing = 'singDOWN';
                            case UP:
								animToSing = 'singUP';
                            case RIGHT:
								animToSing = 'singRIGHT';
                        }

						var forceAnimation:Bool = (opponent.animation.curAnim.name == animToSing && !note.isSustain);
						opponent.playAnim(animToSing, forceAnimation);

                        if (!note.isSustain)
						    removeNote(note);
                    }
                }
            } else if (note.tooLate && !note.isSustain) {
                note.active = false;

                if (note.y >= hudCam.height) {
					removeNote(note);
                }
            }
        });

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

            song.kill();
        }
	}

    private function generateSong() {
		var noteSections:Array<SectionWithIdentifier> = [];

        for (section in _songData.notes) {
            noteSections.push({notes: section.opponentNotes, type: OPPONENT});
			noteSections.push({notes: section.playerNotes, type: PLAYER});
        }

        for (group in noteSections) {
            var notes = group.notes;
			var strumLine:Strumline = opponentStrumLine;

            switch (group.type) {
                case OPPONENT:
                    strumLine = opponentStrumLine;
                case PLAYER:
                    strumLine = playerStrumLine;
            }

            for (noteData in notes) {
				var isSustain:Bool = false;
				if (noteData.sustainLength > 0)
					isSustain = true;

				var note:Note = new Note(noteData.strumTime, Note.convertToEnum(noteData.arrow));
                note.sustainLength = noteData.sustainLength;
                note.noteFocus = group.type;
                note.strumParent = strumLine.strums.members[noteData.arrow];
                note.active = note.visible = false;
				songNotes.add(note);

				var susLength:Int = Math.floor(note.sustainLength / Conductor.stepCrochet) + 1;

				var prevNote:Note = note;
				if (isSustain)
				{
					for (i in 0...susLength)
					{
						var sustainNote:Note = new Note((note.strumTime + (Conductor.stepCrochet * i)) + (Conductor.stepCrochet / 2), note.direction, true, prevNote);
						sustainNote.noteFocus = group.type;
						sustainNote.strumParent = prevNote.strumParent;
                        sustainNote.active = sustainNote.visible = false;
						songNotes.add(sustainNote);

						prevNote = sustainNote;

                        if (i == susLength - 1)
                            sustainNote.switchSustainAnimation(true, sustainNote.direction);

						renderedSustains.add(sustainNote);
					}
				}

				renderedNotes.add(note);
            }
        }

        songNotes.members.sort((note1, note2) -> {
            return Reflect.compare(note1.strumTime, note2.strumTime);
        });
    }

    private function removeNote(note:Note):Void {
		note.kill();
		songNotes.remove(note);

        if (renderedNotes.members.contains(note))
            renderedNotes.remove(note);
        else if (renderedSustains.members.contains(note))
            renderedSustains.remove(note);

		note.destroy();
    }

    private function checkSync():Void {
        if (Conductor.songPosition < 0) {
            song.inst.pause();
            return;
        } else if (!song.inst.playing) {
            song.inst.play();
        }

		if (song.inst.time - Conductor.songPosition <= -20 || song.inst.time - Conductor.songPosition >= 20) {
            #if debug
			FlxG.watch.addQuick('Last Desync: ', '${song.inst.time - Conductor.songPosition}ms');
            #end

			Conductor.songPosition = song.inst.time;
		}
    }

    override function stepHit():Void {
        super.stepHit();
    }

    override function beatHit():Void {
		super.beatHit();

        // I am very well aware the base game does it the other way around.
        // I just like this more.
        if (curBeat % 2 == 0) {
			if (!player.busy && (player.animation.finished && !player.animation.curAnim.name.startsWith('sing')))
				player.dance();
			if (!opponent.busy && (opponent.animation.finished && !opponent.animation.curAnim.name.startsWith('sing')))
				opponent.dance();
        }

        if (dancer != null && !dancer.busy && dancer.animation.finished)
            dancer.dance();
    }
}
