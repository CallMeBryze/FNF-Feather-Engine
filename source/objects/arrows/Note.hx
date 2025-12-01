package objects.arrows;

import engine.Resources.ResourceWithIdentifier;
import engine.Resources;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
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

    override public function new(x:Float, y:Float, direction:NoteDirection = LEFT) {
		properties = Json.parse(Resources.getTxt("data/styles/default", "json"));

		if (PlayState.arrowAtlas == null || (PlayState.arrowAtlas != null && PlayState.arrowAtlas.identifier != properties.noteArrowsPath)) {
			PlayState.arrowAtlas = {
				identifier: properties.noteArrowsPath,
				sparrow: Resources.getSparrowAtlas(properties.noteArrowsPath)
            }
        }

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

        switch (direction) {
            case LEFT:
                animation.play("noteLEFT");
            case UP:
                animation.play("noteUP");
            case DOWN:
                animation.play("noteDOWN");
            case RIGHT:
                animation.play("noteRIGHT");
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

class StrumNote extends FlxSprite {
	private var properties:NoteStyle;
    private var offsets:Map<String, FlxPoint> = new Map();

    override public function new(x:Float, y:Float, direction:NoteDirection = LEFT) {
		properties = Json.parse(Resources.getTxt("data/styles/default", "json"));
        for (offset in properties.strumOffsets)
            offsets.set(offset.name, new FlxPoint(offset.x, offset.y));

		if (PlayState.strumAtlas == null || (PlayState.strumAtlas != null && PlayState.strumAtlas.identifier != properties.strumArrowsPath))
		{
			PlayState.strumAtlas = {
				identifier: properties.strumArrowsPath,
				sparrow: Resources.getSparrowAtlas(properties.strumArrowsPath)
			}
		}

        super(x, y);

        antialiasing = properties.antialiasing;

		frames = PlayState.strumAtlas.sparrow;
		scale.set(0.7, 0.7);
        updateHitbox();

        fixOffsets();

        var directionStr:String;
        switch (direction) {
            case LEFT:
				directionStr = "Left";
            case DOWN:
                directionStr = "Down";
            case UP:
                directionStr = "Up";
            case RIGHT:
                directionStr = "Right";
        }

       addAnim("static", 'static$directionStr', true);
       addAnim("pressed", 'press$directionStr');
       addAnim("confirm", 'confirm$directionStr');

       playAnim("static");
    }

    public function playAnim(name:String = 'static', ?force:Bool = false):Void {
        animation.play(name, force);
        fixOffsets();
    }

    private function addAnim(name:String, prefix:String, ?loop:Bool = false):Void {
        animation.addByPrefix(name, prefix, 24, loop);
    }

	public function getCurrentAnimation():String
	{
		if (this.animation == null || this.animation.curAnim == null)
			return "";

		return this.animation.curAnim.name;
	}

    private function fixOffsets():Void
    {
        this.centerOffsets();

        if (offsets.exists(getCurrentAnimation())) {
			var swagOffsets:FlxPoint = offsets.get(getCurrentAnimation());

            this.offset.x += swagOffsets.x;
            this.offset.y += swagOffsets.y;
        } else {
            this.centerOrigin();
        }
    }
}

enum NoteDirection {
    LEFT;
    DOWN;
    UP;
    RIGHT;
}