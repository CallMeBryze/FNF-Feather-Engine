package engine;

import haxe.Json;
import states.LoadingState;
import states.PlayState;

class GameUtil {
    public static function loadSongAndPlay(songName:String, ?requiredLibrary:String):Void {
		LoadingState.loadAndSwitchState(new PlayState(), requiredLibrary);
		PlayState._songData = Json.parse(Resources.getTxt('data/charts/$songName/$songName', "json"));
    }

    public static function loadSongsAndPlay(songNames:Array<String>, ?requiredLibrary:String):Void {
        // TO BE ADDED
    }
}