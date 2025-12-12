package states;

import engine.Conductor;
import engine.Controls;
import engine.GameUtil;
import engine.Resources;
import engine.Song;
import engine.SongGroup;
import engine.UserData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.AtlasText;
import objects.Character;
import objects.HealthIcon;
import objects.Player;
import objects.arrows.Note;
import objects.arrows.NoteSplash;
import objects.arrows.Strumline;
import states.debug.ChartingState;
import states.substates.PauseSubState;
import states.template.MusicBeatState;

using StringTools;

class PlayState extends MusicBeatState
{
    public static var arrowAtlas:SparrowTracker;
    public static var strumAtlas:SparrowTracker;
    public static var splashAtlas:SparrowTracker;

    public static var songPlaylist:Array<String>;
    public static var isStoryMode:Bool = false;
    public static var weekName:String;
    public static var gameDifficulty:String;

	public static var totalWeekScore:Int = 0;

    private var defaultCamZoom:Float = 0.9;

	private var gameCam:FlxCamera;
	private var hudCam:FlxCamera;

	private var player:Player;
	private var dancer:Character;
	private var opponent:Character;

	private var opponentStrumLine:Strumline;
    private var playerStrumLine:Strumline;

    private var camFollow:FlxObject;
    private var camZooming:Bool = true;

    private var songNotes:FlxTypedGroup<Note> = new FlxTypedGroup();

	private var renderedNotes:FlxTypedGroup<Note> = new FlxTypedGroup();
	private var renderedSustains:FlxTypedGroup<Note> = new FlxTypedGroup();
    private var renderedSplashes:FlxTypedGroup<NoteSplash> = new FlxTypedGroup();

    private var health:Float = 1;

    private var healthBar:FlxBar;
    private var scoreTxt:FlxText;

	private var opponentIcon:HealthIcon;
    private var playerIcon:HealthIcon;

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

	private var isDownscroll:Bool = false;
    private var isMiddlescroll:Bool = false;

    private var curScore:Int = 0;
    private var curCombo:Int = 0;

    private var gameStyle:String = "default";

    // Stage Layers
	private var stageLayerBack:FlxGroup = new FlxGroup();
    private var stageLayerCharacters:FlxGroup = new FlxGroup();
	private var stageLayerFront:FlxGroup = new FlxGroup();

    // Sounds
	var gameOverMusic:FlxSound;
	var gameOverEnd:FlxSound;

	override public function create()
	{
		gameOverMusic = new FlxSound().loadEmbedded(Resources.getAudio("music/gameover/gameOver"));
		gameOverMusic.volume = 0.7;
        gameOverMusic.looped = true;

		gameOverEnd = new FlxSound().loadEmbedded(Resources.getAudio("music/gameover/gameOverEnd"));
		gameOverEnd.volume = 0.7;
		gameOverEnd.looped = false;

        // Store settings here so it doesn't have to call a function every time.
		isDownscroll = UserData.downscroll;
        isMiddlescroll = UserData.middlescroll;

		previousFrameTime = FlxG.game.ticks;

		gameCam = new FlxCamera();
		gameCam.zoom = 0.7;
		FlxG.cameras.add(gameCam, true);

		camera = gameCam;

		hudCam = new FlxCamera();
		hudCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCam, false);

		var inst:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio('songs/${_songData.song}/Inst'));
        inst.volume = 0.7;
		inst.looped = false;

        // End song
        inst.onComplete = endSong;

		song = new SongGroup(inst);

		var playerVocals:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio('songs/${_songData.song}/Vocals-Player'));
		var opponentVocals:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio('songs/${_songData.song}/Vocals-Opponent'));

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

		camFollow = new FlxObject();
        changeCameraFocus(0);
        add(camFollow);

        camera.follow(camFollow, LOCKON, GameUtil.getCameraLerp(0.05, FlxG.elapsed));

        switch (_songData.stage) {
            default:
                gameStyle = 'default';
                defaultCamZoom = 0.9;

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

        gameCam.zoom = defaultCamZoom;

        add(stageLayerBack);
        add(stageLayerCharacters);
        add(stageLayerFront);

		opponentStrumLine = new Strumline(64, 0, gameStyle);
        opponentStrumLine.camera = hudCam;

		playerStrumLine = new Strumline(0, 0, gameStyle);
        playerStrumLine.x = (gameCam.width - playerStrumLine.width) - 64;
        playerStrumLine.camera = hudCam;

		if (isDownscroll) {
			var offset:Float = 0; // Don't personally need this yet
			opponentStrumLine.y = playerStrumLine.y = FlxG.height - opponentStrumLine.height + offset;
        }

        if (isMiddlescroll) {
            // opponentStrumLine.x = -(opponentStrumLine.width * 2);
            opponentStrumLine.visible = false;
            playerStrumLine.screenCenter(X);
        }

        add(playerStrumLine);
        add(opponentStrumLine);
        
        var tempSplash:NoteSplash = new NoteSplash(gameStyle);
        tempSplash.group = renderedSplashes;

        renderedNotes.camera = hudCam;
        renderedSustains.camera = hudCam;

        add(renderedSustains);
		add(renderedNotes);
        add(renderedSplashes);

        var healthBarBG:FlxSprite = new FlxSprite().makeGraphic(Math.floor(FlxG.width / 2) + 8, 16 + 8, FlxColor.BLACK);
        healthBarBG.camera = hudCam;

        healthBar = new FlxBar(0, FlxG.height * 0.9, RIGHT_TO_LEFT, Math.floor(FlxG.width / 2), 16, this, 'health', 0, 2);
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.updateHitbox();
		healthBar.screenCenter(X);
        healthBar.percent = 50;

        if (isDownscroll)
            healthBar.y = FlxG.height * 0.1;

        healthBar.camera = hudCam;

		healthBarBG.setPosition(healthBar.x - 4, healthBar.y - 4);

        add(healthBarBG);
        add(healthBar);

        scoreTxt = new FlxText(healthBarBG.x, healthBarBG.y + healthBarBG.height + 2, 0, "Score: 0");
        scoreTxt.setFormat(null, 16, FlxColor.WHITE, LEFT);
        scoreTxt.camera = hudCam;

        add(scoreTxt);

        playerIcon = new HealthIcon(player.character, true, player.antialiasing, healthBar);
        playerIcon.camera = hudCam;
        add(playerIcon);

        opponentIcon = new HealthIcon(opponent.character, false, opponent.antialiasing, healthBar);
        opponentIcon.camera = hudCam;
        add(opponentIcon);

        updateIconPosition();

        sectionData = _songData.notes[0];
        generateSong();

        startCountdown();
	}

    private function startCountdown():Void {
        inCountdown = true;

        var iterations:Int = 0;
		var beatTime:Float = Conductor.crochet;

		Conductor.songPosition = -(beatTime * 4);

        var quickTween:FlxSprite->Void = (sprite) -> {
			FlxTween.tween(sprite, {y: sprite.y + (sprite.height / 4), alpha: 0}, beatTime / 1000, {ease: FlxEase.cubeInOut, onComplete: (tween) -> {
                sprite.kill();
                sprite.destroy();
            }});
        };

        new FlxTimer().start(beatTime / 1000, (timer) -> {
            if (player.animation.finished)
                player.dance();

            if (opponent.animation.finished)
                opponent.dance();

            if (iterations % 2 == 0 && dancer.animation.finished)
                dancer.dance();

            switch (_songData.stage) {
                default:
                    switch (iterations) {
                        case 0:
							var three:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio("sfx/introTHREE"));
                            three.volume = 0.7;
                            three.play();

                        case 1:
                            var ready:FlxSprite = new FlxSprite().loadGraphic(Resources.getImage('ui/ready'));
                            ready.setGraphicSize(ready.width * 0.7);
                            ready.updateHitbox();
                            ready.screenCenter(XY);
                            ready.camera = hudCam;
                            ready.antialiasing = true;

                            quickTween(ready);

                            add(ready);

							var two:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio("sfx/introTWO"));
                            two.volume = 0.7;
                            two.play();

						case 2:
							var set:FlxSprite = new FlxSprite().loadGraphic(Resources.getImage('ui/set'));
							set.setGraphicSize(set.width * 0.7);
							set.updateHitbox();
							set.screenCenter(XY);
							set.camera = hudCam;
							set.antialiasing = true;

							quickTween(set);

							add(set);

							var one:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio("sfx/introONE"));
							one.volume = 0.7;
							one.play();

                        case 3:
							var go:FlxSprite = new FlxSprite().loadGraphic(Resources.getImage('ui/go'));
							go.setGraphicSize(go.width * 0.7);
							go.updateHitbox();
							go.screenCenter(XY);
							go.camera = hudCam;
							go.antialiasing = true;

							quickTween(go);

							add(go);

							var goSfx:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio("sfx/introGO"));
							goSfx.volume = 0.7;
							goSfx.play();

                        default: // 4th beat
                            startSong();

                            timer.destroy();
                            return;
                    }
            }

            ++iterations;
            timer.reset(beatTime / 1000);
        });
    }

    private function startSong():Void {
		Conductor.songPosition = songPos = 0;

		song.music.play();

		songStarted = true;
		inCountdown = false;
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

    private function updateIconPosition():Void {
		opponentIcon.y = healthBar.y - (opponentIcon.width / 2);
		playerIcon.y = healthBar.y - (playerIcon.width / 2);

		playerIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
		opponentIcon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (opponentIcon.width - 26);
    }

	override public function update(elapsed:Float)
	{
		song.update(elapsed);

		if (health > 2)
			health = 2;
		else if ((health <= 0 || FlxG.keys.justPressed.F9) && !player.isDead) {
            song.music.stop();
			player.alpha = 1;

			var gameOver:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio("sfx/gameover/fnf_loss_sfx"));
			gameOver.volume = 0.7;
			gameOver.play();

            player.gameOver(() -> {
                gameOverMusic.play();
            }, () -> {
                gameOverMusic.stop();
                gameOverEnd.play();

				gameCam.fade(FlxColor.BLACK, 5, false, () -> {
					FlxG.switchState(() -> new PlayState());
				});
            });
		}

        if (player.isDead) {
            if (!inGameOver) {
				camFollow.setPosition(player.getGraphicMidpoint().x , player.getGraphicMidpoint().y);

				var getAlpha:FlxSprite->Void = (object) -> {
                    objectAlphaMap.set(object, object.alpha);
				};

				stageLayerBack.forEachOfType(FlxSprite, getAlpha);
				stageLayerFront.forEachOfType(FlxSprite, getAlpha);
                stageLayerCharacters.forEachOfType(Character, getAlpha);

				inGameOver = true;
                hudCam.visible = false;
            }

			var transitionObjects:FlxSprite->Void = (object) -> {
				var originalAlpha:Float = objectAlphaMap.get(object);
				object.alpha = FlxMath.lerp(object.alpha, Math.max(originalAlpha - 0.75, 0), FlxMath.getElapsedLerp(0.0075, elapsed));
			};

			stageLayerBack.forEachOfType(FlxSprite, transitionObjects);
            stageLayerFront.forEachOfType(FlxSprite, transitionObjects);
            stageLayerCharacters.forEachOfType(Character, transitionObjects);

			player.alpha = 1;
			gameCam.zoom = FlxMath.lerp(gameCam.zoom, defaultCamZoom, FlxMath.getElapsedLerp(0.095, elapsed));

			super.update(elapsed);
			return; // Don't bother updating anything else
        }

		playerIcon.setGraphicSize(Std.int(FlxMath.lerp(playerIcon.width, 150, FlxMath.getElapsedLerp(0.085, elapsed))));
		playerIcon.updateHitbox();

		opponentIcon.setGraphicSize(Std.int(FlxMath.lerp(opponentIcon.width, 150, FlxMath.getElapsedLerp(0.085, elapsed))));
		opponentIcon.updateHitbox();

		updateIconPosition();

		super.update(elapsed);

        scoreTxt.text = 'Score: ' + curScore;

        if ((inCountdown || songStarted) && !inGameOver) {
            for (strum in opponentStrumLine.strums) {
                if (strum.animation.finished)
                    strum.playAnim("static");
            }

            if (!songStarted && inCountdown) {
                Conductor.songPosition += elapsed * 1000;
            }
            else { // Song Started
				Conductor.songPosition = song.music.time;

				if (camZooming) {
					gameCam.zoom = FlxMath.lerp(gameCam.zoom, defaultCamZoom, FlxMath.getElapsedLerp(0.095, elapsed));
					hudCam.zoom = FlxMath.lerp(hudCam.zoom, 1, FlxMath.getElapsedLerp(0.095, elapsed));
				}

				// Pause Menu
				if (Controls.back) {
					song.music.pause();
					song.update(0); // Update other tracks

					openSubState(new PauseSubState());
				}
            }

            if (inCountdown) {
                songPos = Conductor.songPosition;
            } else { // Interpolation
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
			var targetY:Float = (strumNote.y + (strumNote.height / 2)) - (note.height / 2);

            note.x = strumNote.x + ((strumNote.width / 2) - (note.width / 2));

			if (!isDownscroll) { // UPSCROLL
                note.y = targetY - ((songPos - note.strumTime) * final_scrollSpeed);

                if (note.y <= hudCam.height) {
                    note.active = note.visible = true;
                }
                else {
                    note.active = note.visible = false;
                    return; // Why bother?
                }
            } else { // DOWNSCROLL
                note.y = targetY + ((songPos - note.strumTime) * final_scrollSpeed);

                if (note.y >= -note.height) {
                    note.active = note.visible = true;
                }
                else {
                    note.active = note.visible = false;
                    return; // Why bother?
                }
            }

            if (note.noteFocus == PLAYER) {
                if (note.tooLate) {
                    note.active = false;

                    if (!note.wasMissed && (!note.wasHit && note.noteFocus == PLAYER)) {
                        note.wasMissed = true;

                        if (!note.isSustain)
                            missNote(player, note.direction, true, true);
                        else
						    health -= 0.025;
                    }
                }
			} else if (note.noteFocus == OPPONENT) {
                if (isMiddlescroll)
                    note.visible = false;

				if (!note.wasHit && Conductor.songPosition >= note.strumTime) {
					singNote(opponent, note, false);
					note.wasHit = true;

					if (!note.isSustain) {
						removeNote(note);
                        return;
                    }
                }

                if (note.isSustain)
				    handleSustains(note);
            }

            if (note.tooLate && !isDownscroll) {
                if (note.y <= -note.height) {
					removeNote(note);
                    return;
                }
			} else if (note.tooLate && isDownscroll) {
                if (note.y >= hudCam.height) {
					removeNote(note);
                    return;
                }
            }
        });

        if (FlxG.keys.justPressed.F7) {
            FlxG.switchState(() -> new ChartingState());

            song.kill();
        }

		handleInput(player);
	}

    override function closeSubState():Void {
        super.closeSubState();

        if (songStarted && !player.isDead) {
			song.music.play();
        }

		previousFrameTime = FlxG.game.ticks;
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

				var note:Note = new Note(noteData.strumTime, Note.convertToEnum(noteData.arrow), false, null, gameStyle);
                note.sustainLength = noteData.sustainLength;
                note.noteFocus = group.type;
                note.strumParent = strumLine.strums.members[noteData.arrow];
                note.active = note.visible = false;
				songNotes.add(note);

				var susLength:Int = Math.floor(note.sustainLength / Conductor.stepCrochet);
                if (susLength > 0 && susLength <= 1)
                    susLength = 2;

				var prevNote:Note = note;
				if (isSustain)
				{
					for (i in 0...susLength)
					{
						var sustainNote:Note = new Note((note.strumTime + (Conductor.stepCrochet * i)) + (Conductor.stepCrochet / 2), note.direction, true,
							prevNote, gameStyle);

						sustainNote.strumTime += Conductor.stepCrochet / 2;
                        sustainNote.noteParent = note;
						sustainNote.noteFocus = group.type;
						sustainNote.strumParent = prevNote.strumParent;
                        sustainNote.active = sustainNote.visible = false;
						songNotes.add(sustainNote);

                        var swagRect:FlxRect = null;
                        if (!isDownscroll) {
							swagRect = new FlxRect(0, 0, sustainNote.width / sustainNote.scale.x, sustainNote.height / sustainNote.scale.y);
                        } else {
							sustainNote.flipY = true;
							swagRect = new FlxRect(0, 0, sustainNote.frameWidth, sustainNote.frameHeight);
                        }
                        sustainNote.clipRect = swagRect;

                        if (i == susLength - 1) {
							sustainNote.switchSustainAnimation(true, sustainNote.direction);
                        }

						prevNote = sustainNote;
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

    private function handleSustains(note:Note):Void {
        if (note.clipRect == null)
            return;

		var strumNote:StrumNote = note.strumParent;
		var targetY:Float = ((strumNote.y + (strumNote.height / 2)) - (note.height / 2));

		if (!isDownscroll) {
			note.clipRect.y = ((targetY + (note.height / 2)) - note.y) / note.scale.y;
			note.clipRect.height -= note.clipRect.y;
		} else { // DOWNSCROLL
			note.clipRect.height = ((targetY + (note.height / 2) - note.y)) / note.scale.y;
			note.clipRect.y = note.frameHeight - note.clipRect.height;
		}
    }

    // I couldn't figure this out, so to be 100% transparent, I used ChatGPT.
    // I did code a version of this on my own (partially, based off of old FNF code), but it was super unoptimized and broken.
    // AI art bad btw.
	private function handleInput(?character:Character = null):Void
	{
		if (character == null)
			character = player;

		var justPressed = Controls.justPressedInputArray;
		var heldPressed = Controls.pressedInputArray;

		for (strum in playerStrumLine.strums) {
			var directionIndex = Note.convertFromEnum(strum.direction);
			if (!heldPressed[directionIndex] && strum.animation.finished)
				strum.playAnim("static");
		}

		var anyJustPressed = false;
		var anyHeldPressed = false;

		for (i in 0...justPressed.length) {
			if (justPressed[i])
				anyJustPressed = true;
			if (heldPressed[i])
				anyHeldPressed = true;
		}

		if (!anyJustPressed && !anyHeldPressed)
			return;

		var bestDirectionNotes = new Map<Int, Note>();
        var hitSustainNotes = new Map<Int, Note>();

		var duplicateNotes:Array<Note> = [];

		songNotes.forEachAlive(note -> {
			if (note.noteFocus != PLAYER || note.noteFocus == PLAYER && !note.canBeHit && !note.tooLate)
				return;

			var dirIndex = Note.convertFromEnum(note.direction);

			if (note.isSustain) {
				if (anyHeldPressed && heldPressed[dirIndex]) {
					if (note.canBeHit && (note.noteParent != null && note.noteParent.wasHit || note.noteParent == null)) {
                        if (!hitSustainNotes.exists(dirIndex))
                            hitSustainNotes.set(dirIndex, note);
                        
						singNote(character, note, true);
						note.wasHit = true;
                    }

                    if (note.wasHit) {
                        if (!hitSustainNotes.exists(dirIndex))
                            hitSustainNotes.set(dirIndex, note);

                        handleSustains(note);
                    } else if (note.prevNote != null && note.prevNote.wasHit) {
                        if (!hitSustainNotes.exists(dirIndex))
                            hitSustainNotes.set(dirIndex, note);

						handleSustains(note);
                    }
				}

				return;
			}

			if (anyJustPressed) {
				if (note.wasHit || note.tooLate)
					return;

				if (!bestDirectionNotes.exists(dirIndex)) {
					bestDirectionNotes.set(dirIndex, note);
					return;
				}

				var existing = bestDirectionNotes.get(dirIndex);
				var timeDifference = note.strumTime - existing.strumTime;

				if (timeDifference < 10 && timeDifference > -10)
					duplicateNotes.push(note);
				else if (note.strumTime < existing.strumTime)
					bestDirectionNotes.set(dirIndex, note);
			}
		});

		for (note in duplicateNotes)
			removeNote(note);

		for (i in 0...justPressed.length) {
			if (justPressed[i] && !bestDirectionNotes.exists(i) && !hitSustainNotes.exists(i)) {
				playerStrumLine.strums.members[i].playAnim("pressed");
				missNote(character, Note.convertToEnum(i), true, true);
			}
		}

		for (dirIndex => note in bestDirectionNotes) {
			if (justPressed[dirIndex]) {
				singNote(character, note, true);
				note.wasHit = true;
				removeNote(note);
			}
		}
	}

	private function singNote(character:Character, note:Note, ?isPlayer:Bool = false):Void {
		note.strumParent.playAnim('confirm');

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

		var forceAnimation:Bool = (character.animation.curAnim.name == animToSing && !note.isSustain);
		character.playAnim(animToSing, forceAnimation);

        if (isPlayer && !note.wasHit) {
            var vocal:FlxSound = song.vocals.get("player");
            vocal.volume = song.music.volume;

            if (!note.isSustain)
                health += 0.05;
            else
                health += 0.005;

            var safeZone:Float = Conductor.safeZoneOffset;

            var noteDiff:Float = Math.abs(note.strumTime - songPos);
            var score:Int = 300;
            
            var rating:String = "sick";
            var wowzers:Bool = true;

            var ratingSpr:FlxSprite = new FlxSprite();

            if (noteDiff > safeZone * 0.9) {
                rating = "shit";
                score = 50;

                wowzers = false;
            } else if (noteDiff > safeZone * 0.75) {
                rating = "bad";
                score = 100;

                wowzers = false;
            } else if (noteDiff > safeZone * 0.3) {
                rating = "good";
                score = 200;

                wowzers = false;
            }
            
            score = Math.floor(score * note.scoreMultiplier);

            if (!note.isSustain) {
                ++curCombo;

                var spriteTween:FlxSprite->Void = (sprite) -> {
					sprite.acceleration.y = 550;
					sprite.velocity.y -= FlxG.random.int(140, 175);
					sprite.velocity.x -= FlxG.random.int(0, 10);

                    FlxTween.tween(sprite, {alpha: 0}, (Conductor.crochet * 4) / 1000, {onComplete: (tween) -> {
                        sprite.kill();
                        sprite.destroy();
                    }, ease: FlxEase.cubeInOut});
                };

				if (wowzers)
					createSplash(note);

                ratingSpr.loadGraphic(Resources.getImage('ui/scoring/$rating'));
                ratingSpr.antialiasing = true;

                ratingSpr.setGraphicSize(ratingSpr.width * 0.7);
                ratingSpr.updateHitbox();
                
                ratingSpr.x = character.x - (ratingSpr.width / 2) + 4;
                ratingSpr.y = character.y - (ratingSpr.height / 2) + 4;

                spriteTween(ratingSpr);
				add(ratingSpr);

                var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Resources.getImage('ui/scoring/combo'));
				comboSpr.antialiasing = ratingSpr.antialiasing;

                comboSpr.setGraphicSize(comboSpr.width * 0.7);
                comboSpr.updateHitbox();

                comboSpr.setPosition(ratingSpr.x - (comboSpr.width / 2), ratingSpr.y - comboSpr.height);

                spriteTween(comboSpr);
                add(comboSpr);

                var comboShit:Array<String> = Std.string(curCombo).split("");
                while (comboShit.length < 3)
                    comboShit.insert(0, "0");

                for (i in 0...3) {
                    var comboNum:FlxSprite = new FlxSprite();
                    comboNum.loadGraphic(Resources.getImage('ui/scoring/num${comboShit[i]}'));
                    comboNum.antialiasing = comboSpr.antialiasing;

					comboNum.setGraphicSize(comboNum.width * 0.7);
					comboNum.updateHitbox();

                    comboNum.setPosition(comboSpr.x + comboSpr.width + ((comboNum.width * (i)) + 4), comboSpr.y);

                    spriteTween(comboNum);
                    add(comboNum);
                }
            }

            curScore += score;
		} else {
			var vocal:FlxSound = song.vocals.get("opponent");
			vocal.volume = song.music.volume;

			if (!note.isSustain && !isMiddlescroll) {
				createSplash(note);
			}
		}
    }

    private function createSplash(note:Note):Void {
		var splashNote:NoteSplash = cast(recycle(NoteSplash), NoteSplash);
		if (splashNote == null)
			splashNote = new NoteSplash();

		splashNote.group = renderedSplashes;
		splashNote.camera = hudCam;
		splashNote.playSplash(note.strumParent, note.direction);

        // We don't need to worry about removing it when it's done,
        // since it's coded to remove and kill its self from the group once it's done.
		renderedSplashes.add(splashNote);
    }

    private function missNote(character:Character, direction:NoteDirection, ?isPlayer:Bool = true, ?playSound:Bool = false):Void {
		var animToSing:String = "singLEFTmiss";

		switch (direction) {
			case LEFT:
				animToSing = 'singLEFTmiss';
			case DOWN:
				animToSing = 'singDOWNmiss';
			case UP:
				animToSing = 'singUPmiss';
			case RIGHT:
				animToSing = 'singRIGHTmiss';
		}

		character.playAnim(animToSing);

        if (playSound) {
            var missSound:FlxSound = new FlxSound().loadEmbedded(Resources.getAudio("sfx/missnote" + FlxG.random.int(1, 3)));
            missSound.volume = 0.1; // God this sound is loud
            missSound.play();
        }

        if (isPlayer) {
			health -= 0.0475;
            curScore -= 50;

            curCombo = 0;

			var vocal:FlxSound = song.vocals.get("player");
            vocal.volume = 0;
        } else {
			var vocal:FlxSound = song.vocals.get("opponent");
			vocal.volume = 0;
        }
    }

    private function removeNote(note:Note):Void {
		note.kill();

        if (renderedNotes.members.contains(note))
            renderedNotes.remove(note, true);
        else if (renderedSustains.members.contains(note))
            renderedSustains.remove(note, true);

		songNotes.remove(note, true);

	    note.destroy();
    }

    private function changeCameraFocus(focus:Int):Void {
		switch (focus) {
			case 0:
                var midpoint:FlxPoint = opponent.getMidpoint();

				camFollow.setPosition(midpoint.x + opponent.cameraPosition.x, midpoint.y + opponent.cameraPosition.y);

			case 1:
				var midpoint:FlxPoint = player.getMidpoint();

				camFollow.setPosition(midpoint.x + player.cameraPosition.x, midpoint.y + player.cameraPosition.y);
		}
    }

    private function endSong():Void {
        song.music.stop(); // Just in case?

        GameUtil.saveSongScore(_songData.song, curScore, gameDifficulty);
        totalWeekScore += curScore;

        if (isStoryMode) {
			songPlaylist.shift();

			var nextSong:String = songPlaylist[0];

            if (songPlaylist.length <= 0) {
                GameUtil.saveWeekScore(weekName, totalWeekScore, gameDifficulty);
                FlxG.switchState(() -> new TitleState());

                return;
            } else {
                GameUtil.prepareSong(nextSong, gameDifficulty);
				FlxG.switchState(() -> new PlayState());

                return;
            }
        } else {
			FlxG.switchState(() -> new TitleState());
			return;
        }
    }

    private var curSection:Int = 0;
    private var sectionData:SongSection;
    override function stepHit():Void {
		super.stepHit();

        if (songStarted) {
            if (curStep % sectionData.lengthInSteps == 0) {
                ++curSection;
                sectionData = _songData.notes[curSection];
            }
        }

        if (sectionData == null)
            sectionData = _songData.notes[0];

		changeCameraFocus(sectionData.sectionFocus);
        
        #if debug
        FlxG.watch.addQuick('curSection: ', curSection);
        #end
    }

    override function beatHit():Void {
		super.beatHit();

        if (songStarted) {
            if (curBeat % 4 == 0) {
                gameCam.zoom += 0.005;
                hudCam.zoom += 0.03;
            }

			playerIcon.setGraphicSize(playerIcon.width * 1.15);
			playerIcon.updateHitbox();

			opponentIcon.setGraphicSize(opponentIcon.width * 1.15);
			opponentIcon.updateHitbox();

			updateIconPosition();

            if (curBeat % 2 == 0) {
                if (dancer != null && !dancer.busy && dancer.animation.finished)
                    dancer.dance();
            }

            if (!player.busy && (player.animation.finished && !player.animation.curAnim.name.startsWith('sing')))
                player.dance();
            if (!opponent.busy && (opponent.animation.finished && !opponent.animation.curAnim.name.startsWith('sing')))
                opponent.dance();
        }
    }
}
