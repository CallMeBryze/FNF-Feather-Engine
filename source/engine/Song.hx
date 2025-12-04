package engine;

typedef Song = {
    var song:String;
    var bpm:Float;

	var scrollSpeed:Float;
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
     */
    var sectionFocus:Int;

	var opponentNotes:Array<SectionNote>;
    var playerNotes:Array<SectionNote>;
}

typedef SectionNote = {
    var strumTime:Float;

    /**
     * AKA Direction
     */
    var arrow:Int;

    var ?noteType:String;
    var sustainLength:Float;
}

enum HitType {
    PLAYER;
    OPPONENT;
}

typedef SectionWithIdentifier = {
    var notes:Array<SectionNote>;
    var type:HitType;
}