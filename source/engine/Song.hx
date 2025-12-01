package engine;

typedef Song = {
    var song:String;
    var bpm:Float;
    var defaultLengthInSteps:Int;

    var stage:String;
    var player:String;
    var opponent:String;
    var dancer:String;

    var notes:Array<SongSection>;
}

typedef SongSection = {
    var bpm:Float;
    var changeBPM:Bool;
    var lengthInSteps:Int;

    /**
     * 0: Opponent.
     * 1: Player.
     * 2: Dancer.
     */
    var sectionFocus:Int;

    var ?playerNotes:Array<SectionNote>;
    var ?dancerNotes:Array<SectionNote>;
    var ?opponentNotes:Array<SectionNote>;
}

typedef SectionNote = {
    var strumTime:Float;
    var data:Int;
}