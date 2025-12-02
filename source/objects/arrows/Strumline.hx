package objects.arrows;

import engine.Resources;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxPoint;
import haxe.Json;
import objects.arrows.Note;
import states.PlayState;

class Strumline extends FlxSpriteContainer {
    public var strums:Array<StrumRow> = [];

    override public function new(x:Float, y:Float) {
        super(x, y);

        for (i in 0...4) {
            var direction:NoteDirection = LEFT;

            switch (i) {
                case 0:
                    direction = LEFT;
                case 1:
					direction = DOWN;
                case 2:
					direction = UP;
                case 3:
					direction = RIGHT;
            }

			var strumRow = new StrumRow((Note.defaultNoteWidth * 0.7) * i, 0, direction, i);

            strums.push(strumRow);
            add(strumRow);
        }
    }
}

class StrumNote extends FlxSprite
{
	private var properties:NoteStyle;
	private var offsets:Map<String, FlxPoint> = new Map();

	override public function new(x:Float, y:Float, direction:NoteDirection = LEFT)
	{
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

		var directionStr:String;
		switch (direction)
		{
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

	public function playAnim(name:String = 'static', ?force:Bool = false):Void
	{
		animation.play(name, force);

		this.centerOffsets();

		if (offsets.exists(getCurrentAnimation())) {
			var swagOffsets:FlxPoint = offsets.get(getCurrentAnimation());

			this.offset.x += swagOffsets.x;
			this.offset.y += swagOffsets.y;
		} else {
			this.centerOrigin();
		}
	}

	private function addAnim(name:String, prefix:String, ?loop:Bool = false):Void
	{
		animation.addByPrefix(name, prefix, 24, loop);
	}

	public function getCurrentAnimation():String
	{
		if (this.animation == null || this.animation.curAnim == null)
			return "";

		return this.animation.curAnim.name;
	}
}

class StrumRow extends FlxSpriteContainer {
    private var notes:Array<Note> = [];
    private var strumNote:StrumNote;

    public var direction:NoteDirection;

    override public function new (x:Float, y:Float, direction:NoteDirection, id:Int) {
        super(x, y);

        this.ID = id;
        this.direction = direction;

		strumNote = new StrumNote(0, 0, direction);
        add(strumNote);
    }
}

enum PressType {
    NONE;
    JUST_PRESSED;
    PRESSED;
    RELEASED;
}