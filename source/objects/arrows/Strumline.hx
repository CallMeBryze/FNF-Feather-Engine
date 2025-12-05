package objects.arrows;

import engine.Conductor;
import engine.Conductor;
import engine.Resources;
import engine.Song.SectionNote;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteContainer;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import haxe.Json;
import objects.arrows.Note;
import states.PlayState;

class Strumline extends FlxSpriteContainer {
    public var strums:FlxTypedGroup<StrumNote> = new FlxTypedGroup();

    override public function new(x:Float, y:Float) {
        super(x, y);

        var lastStrum:StrumNote = null;
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
			
            var startX:Float = 0;
            if (lastStrum != null)
                startX = lastStrum.width;

            var strumNote:StrumNote = new StrumNote((startX * 0.7) * i, 0, direction);
			add(strumNote);

            lastStrum = strumNote;
            strums.add(strumNote);
        }
    }
}

class StrumNote extends FlxSprite
{
	private var properties:NoteStyle;
	private var offsets:Map<String, FlxPoint> = new Map();

    public var direction:NoteDirection = LEFT;

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

        this.direction = direction;

		super(x, y);

		antialiasing = properties.antialiasing;

		frames = PlayState.strumAtlas.sparrow;
		scale.set(properties.scale, properties.scale);
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

    override function update(elapsed:Float):Void {
        super.update(elapsed);
    }

	public function playAnim(name:String = 'static', ?force:Bool = false):Void {
		animation.play(name, force);

		this.centerOffsets();
		this.centerOrigin();

		if (offsets.exists(getCurrentAnimation())) {
			var swagOffsets:FlxPoint = offsets.get(getCurrentAnimation());

			this.offset.x += swagOffsets.x;
			this.offset.y += swagOffsets.y;
		}
	}

	private function addAnim(name:String, prefix:String, ?loop:Bool = false):Void {
		animation.addByPrefix(name, prefix, 24, loop);
	}

	public function getCurrentAnimation():String {
		if (this.animation == null || this.animation.curAnim == null)
			return "";

		return this.animation.curAnim.name;
	}
}