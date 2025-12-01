package objects.arrows;

import engine.Resources.ResourceWithIdentifier;
import engine.Resources;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import objects.arrows.Styles.NoteStyle;

class Note extends FlxSprite {
    public static final defaultNoteWidth:Int = 150;

    public var direction:NoteDirection;

    override public function new(x:Float, y:Float, direction:NoteDirection = LEFT) {
		if (!Resources.universalCache.exists("arrowNotes"))
			Resources.universalCache.set("arrowNotes", Resources.getSparrowAtlas("ui/notes/notes"));

        super(x, y);

        this.direction = direction;

        antialiasing = true;

		frames = Resources.universalCache.get("arrowNotes");
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
}

class StrumNote extends FlxSprite {
    override public function new(x:Float, y:Float, direction:NoteDirection = LEFT) {
        if (!Resources.universalCache.exists("strumNotes"))
			Resources.universalCache.set("strumNotes", Resources.getSparrowAtlas("ui/notes/noteStrumline"));

        super(x, y);

        antialiasing = true;

		frames = Resources.universalCache.get("strumNotes");
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

        if (getCurrentAnimation() == 'confirm') {
            this.offset.x -= 13;
            this.offset.y -= 13;
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