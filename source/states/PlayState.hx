package states;

import engine.Conductor;
import engine.Controls;
import engine.Resources;
import engine.Song;
import engine.SongGroup;
import engine.UserSettings;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
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

    private var camFollow:FlxObject;

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

    private var isDownscroll:Bool = false;

	override public function create()
	{
        // Store settings here so it doesn't have to call a function every time.
		isDownscroll = UserSettings.downscroll;

		previousFrameTime = FlxG.game.ticks;

		gameCam = new FlxCamera();
		gameCam.zoom = 0.7;
		FlxG.cameras.add(gameCam, true);

		camera = gameCam;

		hudCam = new FlxCamera();
		hudCam.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(hudCam, false);

		var inst = Resources.getAudio('songs/${_songData.song}/Inst');
        inst.volume = 0.7;
		inst.looped = false;

		song = new SongGroup(inst);

		var playerVocals:FlxSound = Resources.getAudio('songs/${_songData.song}/Vocals-Player');
		var opponentVocals:FlxSound = Resources.getAudio('songs/${_songData.song}/Vocals-Opponent');

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

        camera.follow(camFollow, LOCKON, FlxMath.getElapsedLerp(0.1, FlxG.elapsed));

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

		if (isDownscroll) {
			var offset:Float = 0; // Don't personally need this yet
			opponentStrumLine.y = playerStrumLine.y = FlxG.height - opponentStrumLine.height + offset;
        }

        add(playerStrumLine);
        add(opponentStrumLine);

        renderedNotes.camera = hudCam;
        renderedSustains.camera = hudCam;

        add(renderedSustains);
		add(renderedNotes);

        sectionData = _songData.notes[0];
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

        if (!songStarted && FlxG.keys.justPressed.SPACE) {
			previousFrameTime = FlxG.game.ticks;
            songStarted = true;
        }

		super.update(elapsed);

        song.update(elapsed);

        if ((inCountdown || songStarted) && !paused) {
            if (!songStarted) {
                Conductor.songPosition += elapsed * 1000;
            }
            else {
				Conductor.songPosition = song.inst.time;

				checkSync();
            }

            if (inCountdown) {
                songPos = Conductor.songPosition;

                // Implement later lol
                if (Conductor.songPosition >= 0) {
                    songPos = 0;

                    inCountdown = false;
                }
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
			var targetY:Float = ((strumNote.y + (strumNote.height / 2)) - (note.height / 2)) + note.stupidOffset;

            note.x = strumNote.x + ((strumNote.width / 2) - (note.width / 2));

			if (!isDownscroll) {
                note.y = targetY - ((songPos - note.strumTime) * final_scrollSpeed);

                if (note.y <= hudCam.height) {
                    note.active = note.visible = true;
                }
                else {
                    note.active = note.visible = false;
                }

                if (note.isSustain) {
					note.y += (note.height / 2);
                }
            } else { // DOWNSCROLL
                note.y = targetY + ((songPos - note.strumTime) * final_scrollSpeed);

                if (note.y >= -note.height) {
                    note.active = note.visible = true;
                }
                else {
                    note.active = note.visible = false;
                }

				if (note.isSustain) {
					note.y -= (note.height / 2);

					if (note.animation.curAnim.name.endsWith('end') && note.prevNote != null && note.prevNote.alive) {
						note.y = note.prevNote.y - note.height;
					}
                }
            }

            if (note.tooLate) {
				note.active = false;

				if (!note.wasMissed && (!note.wasHit && note.noteFocus == PLAYER)) {
					missNote(player, note.direction, true);
					note.wasMissed = true;
                }

				if (!isDownscroll) {
					if (note.y <= hudCam.height)
						removeNote(note);
                } else {
					if (note.y >= -note.height)
						removeNote(note);
                }

                return; // No need to run checks any further than this.
            }

            if (note.active && note.canBeHit && !note.tooLate) {
                if (note.noteFocus == OPPONENT && Conductor.songPosition >= note.strumTime) {
                    note.wasHit = true;
                    singNote(opponent, note, false);
                    handleSustains(note);

                    if (!note.isSustain)
                        removeNote(note);
                }
			}
        });

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

		handleInput(player);

        for (strum in opponentStrumLine.strums) {
            if (strum.animation.finished)
                strum.playAnim("static");
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

				var susLength:Int = Math.floor(note.sustainLength / Conductor.stepCrochet);

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

                        if (i == susLength - 1) {
							sustainNote.switchSustainAnimation(true, sustainNote.direction);
                        }

						if (isDownscroll)
                            sustainNote.flipY = true;

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
		var strumNote:StrumNote = note.strumParent;
		var targetY:Float = ((strumNote.y + (strumNote.height / 2)) - (note.height / 2));

		if (!isDownscroll) {
			if (note.wasHit || note.noteFocus == OPPONENT) {
				var swagRect:FlxRect = new FlxRect(0, 0, note.width / note.scale.x, note.height / note.scale.y);

				swagRect.y = ((targetY + (note.height / 2)) - note.y) / note.scale.y;
				swagRect.height -= swagRect.y;

				note.clipRect = swagRect;
			}
		} else { // DOWNSCROLL
			var swagRect:FlxRect = new FlxRect(0, 0, note.frameWidth, note.frameHeight);

			swagRect.height = ((targetY + (note.height / 2) - note.y)) / note.scale.y;
			swagRect.y = note.frameHeight - swagRect.height;
			note.clipRect = swagRect;
		}
    }

    // I couldn't figure this out, so to be 100% transparent, I used ChatGPT.
    // Look, I don't like using generative AI, I really don't. But I'm tired. This is a lot of work.
    // I did code a version of this on my own (partially, based off of old FNF code), but it was super unoptimized and broken.
    // It's not like this entire project was coded using AI, it was really only this. I promise.
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
		var duplicateNotes:Array<Note> = [];

		songNotes.forEachAlive(note -> {
			if (note.noteFocus != PLAYER || !note.canBeHit)
				return;

			var dirIndex = Note.convertFromEnum(note.direction);

			if (note.isSustain) {
				if (anyHeldPressed && heldPressed[dirIndex] && note.canBeHit) {
					note.wasHit = true;
					singNote(character, note, true);
                    handleSustains(note);
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
			if (justPressed[i] && !bestDirectionNotes.exists(i)) {
				playerStrumLine.strums.members[i].playAnim("pressed");
				missNote(character, Note.convertToEnum(i), true);
			}
		}

		for (dirIndex => note in bestDirectionNotes) {
			if (justPressed[dirIndex]) {
				note.wasHit = true;
				singNote(character, note, true);
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

        if (isPlayer) {
            var vocal:FlxSound = song.vocals.get("player");
            vocal.volume = song.inst.volume;
		} else {
			var vocal:FlxSound = song.vocals.get("opponent");
			vocal.volume = song.inst.volume;
		}
    }

    private function missNote(character:Character, direction:NoteDirection, ?isPlayer:Bool = true):Void {
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

        if (isPlayer) {
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
            renderedNotes.remove(note);
        else if (renderedSustains.members.contains(note))
            renderedSustains.remove(note);

		songNotes.remove(note);
		note.destroy();
    }

    private function checkSync():Void {
        if (Conductor.songPosition < 0) {
            song.inst.pause();
            return;
        } else if (Conductor.songPosition > song.inst.length) {
            song.inst.stop();
        } else if (!song.inst.playing) {
            song.inst.play();
        }

		/*if (song.inst.time - Conductor.songPosition <= -20 || song.inst.time - Conductor.songPosition >= 20) {
            #if debug
			FlxG.watch.addQuick('Last Desync: ', '${song.inst.time - Conductor.songPosition}ms');
            #end

			Conductor.songPosition = song.inst.time;
		}*/
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

    private var curSection:Int = 0;
    private var sectionData:SongSection;
    override function stepHit():Void {
		super.stepHit();

        if (curStep % sectionData.lengthInSteps == 0) {
            ++curSection;
            sectionData = _songData.notes[curSection];
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
