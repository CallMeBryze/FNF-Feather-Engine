package objects.arrows;

import flixel.FlxG;
import flixel.group.FlxSpriteContainer;
import objects.arrows.Note;

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
}