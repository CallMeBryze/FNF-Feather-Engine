package objects.arrows;

import engine.Resources;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.math.FlxPoint;
import haxe.Json;
import states.PlayState;

typedef NoteStyle = {
    var strumArrowsPath:String;
    var noteArrowsPath:String;
    var noteHoldsPath:String;

    var antialiasing:Bool;
    var strumOffsets:Array<NoteAnimationOffsets>;
}

typedef NoteAnimationOffsets = {
    var name:String;
    var x:Float;
    var y:Float;
}

class Note extends FlxSprite {
    public static final defaultNoteWidth:Int = 150;

    private var properties:NoteStyle;

    public var direction:NoteDirection;
    public var isSustain:Bool = false;
    public var sustainLength:Float = 0;

	public var scoreMultiplier:Float = 1;

    public var strumTime:Float;
    public var prevNote:Note;

    override public function new(strumTime:Float, direction:NoteDirection = LEFT, ?isSustain:Bool = false, ?sustainLength:Float = 0, ?prevNote:Note = null) {
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
        this.sustainLength = sustainLength;

        super(x, y);

        this.direction = direction;

        antialiasing = properties.antialiasing;

		frames = PlayState.arrowAtlas.sparrow;
        scale.set(0.7, 0.7);
        updateHitbox();

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

        if (!isSustain) {
			switch (direction)
			{
				case LEFT:
					animation.play("noteLEFT");
				case UP:
					animation.play("noteUP");
				case DOWN:
					animation.play("noteDOWN");
				case RIGHT:
					animation.play("noteRIGHT");
			}
        } else {
            scoreMultiplier = 0.2;

            if (prevNote != null) {
				switch (direction)
				{
					case LEFT:
						animation.play("sustainLEFTend");
					case UP:
						animation.play("sustainUPend");
					case DOWN:
						animation.play("sustainDOWNend");
					case RIGHT:
						animation.play("sustainRIGHTend");
				}
            } else {
				switch (direction)
				{
					case LEFT:
						animation.play("sustainLEFTpiece");
					case UP:
						animation.play("sustainUPpiece");
					case DOWN:
						animation.play("sustainDOWNpiece");
					case RIGHT:
						animation.play("sustainRIGHTpiece");
				}
            }
        }
    }

	private function addAnim(name:String, prefix:String):Void
	{
		animation.addByPrefix(name, prefix, 24, true);
	}

    public static function convertFromEnum(direction:NoteDirection):Int {
        switch (direction) {
            case LEFT:
                return 0;
            case UP:
                return 1;
            case DOWN:
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
                return UP;
            case 2:
                return DOWN;
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