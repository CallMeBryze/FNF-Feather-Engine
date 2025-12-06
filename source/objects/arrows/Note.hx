package objects.arrows;

import engine.Conductor;
import engine.Resources;
import engine.Song.HitType;
import engine.UserData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.math.FlxPoint;
import haxe.Json;
import objects.arrows.Strumline.StrumNote;
import states.PlayState;

typedef NoteStyle = {
    var strumArrowsPath:String;
    var noteArrowsPath:String;
    var noteSplashesPath:String;

    var scale:Float;
    var splashAnimations:Int;

    var antialiasing:Bool;
    var strumLineOffset:Array<Int>;
    var strumOffsets:Array<NoteAnimationOffsets>;
}

typedef NoteAnimationOffsets = {
    var name:String;
    var x:Float;
    var y:Float;
}

class Note extends FlxSprite {
    @:deprecated
    public static final defaultNoteWidth:Int = 150;

    private var properties:NoteStyle;

    public var direction:NoteDirection;
    public var isSustain:Bool = false;

	public var scoreMultiplier:Float = 1;
    public var noteFocus:HitType = OPPONENT;

    public var strumTime:Float;
    public var sustainLength:Float;

    public var strumParent:StrumNote;
    public var prevNote:Note;

    public var noteParent:Note;
    public var isParent:Bool = false;

    public var wasHit:Bool = false;
    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;

    public var wasMissed:Bool = false;

    override public function new(strumTime:Float, direction:NoteDirection = LEFT, ?isSustain:Bool = false, ?prevNote:Note = null) {
		properties = Json.parse(Resources.getTxt("data/styles/default", "json"));

		if (PlayState.arrowAtlas == null || (PlayState.arrowAtlas != null && PlayState.arrowAtlas.identifier != properties.noteArrowsPath)) {
			PlayState.arrowAtlas = {
				identifier: properties.noteArrowsPath,
				sparrow: Resources.getSparrowAtlas(properties.noteArrowsPath)
            }
        }

        this.strumTime = strumTime;

        this.isSustain = isSustain;
        this.prevNote = prevNote;

        super(x, y);

        this.direction = direction;

        antialiasing = properties.antialiasing;

		frames = PlayState.arrowAtlas.sparrow;

        addAnim("noteLEFT", "noteLeft");
        addAnim("noteUP", "noteUp");
        addAnim("noteDOWN", "noteDown");
		addAnim("noteRIGHT", "noteRight");

		addAnim("sustainLEFTpiece", "sustainLeftPiece");
		addAnim("sustainUPpiece", "sustainUpPiece");
		addAnim("sustainDOWNpiece", "sustainDownPiece");
		addAnim("sustainRIGHTpiece", "sustainRightPiece");

		addAnim("sustainLEFTend", "sustainLeftEnd");
		addAnim("sustainUPend", "sustainUpEnd");
		addAnim("sustainDOWNend", "sustainDownEnd");
		addAnim("sustainRIGHTend", "sustainRightEnd");

		switch (direction)
		{
			case LEFT:
				animation.play("noteLEFT");
			case DOWN:
				animation.play("noteDOWN");
			case UP:
				animation.play("noteUP");
			case RIGHT:
				animation.play("noteRIGHT");
		}

		scale.set(properties.scale, properties.scale);
		updateHitbox();

		if (isSustain && prevNote != null) {
            scoreMultiplier = 0.2;

			switchSustainAnimation(false, direction);
        }
    }

    override function update(elapsed):Void {
        super.update(elapsed);

		canBeHit = false;
		tooLate = false;

		if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset) {
			tooLate = true;
		} else if (Math.abs(strumTime - Conductor.songPosition) <= Conductor.safeZoneOffset) {
            if (isSustain && (prevNote != null && prevNote.wasHit) || !isSustain)
			    canBeHit = true;
		}
    }

    public function switchSustainAnimation(isEndPiece:Bool, direction:NoteDirection):Void {
        switch (isEndPiece) {
            case false:
                switch (direction) {
					case LEFT:
						animation.play("sustainLEFTpiece");
					case DOWN:
						animation.play("sustainDOWNpiece");
					case UP:
						animation.play("sustainUPpiece");
					case RIGHT:
						animation.play("sustainRIGHTpiece");
				}

                if (prevNote.isSustain) {
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState._songData.scrollSpeed;
					prevNote.updateHitbox();
                }

            case true:
                switch (direction) {
                    case LEFT:
                        animation.play("sustainLEFTend");
                    case DOWN:
                        animation.play("sustainDOWNend");
                    case UP:
                        animation.play("sustainUPend");
                    case RIGHT:
                        animation.play("sustainRIGHTend");
                }
        }

		updateHitbox();
    }

	private function addAnim(name:String, prefix:String):Void
	{
		animation.addByPrefix(name, prefix, 24, true);
	}

    public static function convertFromEnum(direction:NoteDirection):Int {
        switch (direction) {
            case LEFT:
                return 0;
            case DOWN:
                return 1;
            case UP:
                return 2;
            case RIGHT:
                return 3;
        }

        return 0;
    }

    public static function convertToEnum(data:Int):NoteDirection {
        switch (data) {
            case 0:
                return LEFT;
            case 1:
                return DOWN;
            case 2:
                return UP;
            case 3:
                return RIGHT;
        }

        return LEFT;
    }
}

enum NoteDirection {
    LEFT;
    DOWN;
    UP;
    RIGHT;
}