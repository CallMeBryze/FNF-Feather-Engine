package engine;

import objects.arrows.Note.NoteDirection;

typedef Song = {
    var bpm:Float;

    var stage:String;
    var player:String;
    var opponent:String;
    var dancer:String;

    var notes:Array<ChartNote>;
}

typedef ChartNote = {
    var strumTime:Float;
    var direction:NoteDirection;
}