package engine;

import engine.UserData.ScoreData;
import haxe.Json;
import states.LoadingState;
import states.PlayState;

class GameUtil {
    public static function loadSongAndPlay(songName:String, ?requiredLibrary:String, ?difficulty:String = 'normal'):Void {
        PlayState.isStoryMode = false;

        prepareSong(songName, difficulty);
		LoadingState.loadAndSwitchState(new PlayState(), requiredLibrary);
    }

    public static function loadWeekAndPlay(weekName:String, songNames:Array<String>, ?requiredLibrary:String, ?difficulty:String = 'normal'):Void {
        PlayState.isStoryMode = true;
        PlayState.weekName = weekName;
        PlayState.gameDifficulty = difficulty;
        PlayState.songPlaylist = songNames;
        PlayState.totalWeekScore = 0;

        prepareSong(songNames[0], difficulty);
		LoadingState.loadAndSwitchState(new PlayState(), requiredLibrary);
    }

    /**
     * Sets the Song Data in PlayState to the inputted song.
     * @param songName Name of the song.
     * @param difficulty Difficulty (set to `normal` by default).
     */
    public static function prepareSong(songName:String, ?difficulty:String = 'normal'):Void {
		PlayState._songData = Json.parse(Resources.getTxt('data/charts/$songName/$songName-$difficulty', "json"));
    }

    private static function removeOverlapScore(scores:Array<ScoreData>, name:String, ?difficulty:String = 'normal'):Void {
        for (score in scores) {
            if (score.name == name && score.difficulty == difficulty) {
                scores.remove(score);
                break;
            }
        }
    }

    public static function saveSongScore(name:String, score:Int, ?difficulty:String = 'normal'):Void {
		var songScores = UserData.saveData.highscores.songs;
        removeOverlapScore(songScores, name, difficulty);

        songScores.push({
            name: name,
            difficulty: difficulty,
            score: score
        });

        UserData.export();
    }

    public static function saveWeekScore(name:String, score:Int, ?difficulty:String = 'normal'):Void {
		var weekScores = UserData.saveData.highscores.weeks;
		removeOverlapScore(weekScores, name, difficulty);

		weekScores.push({
			name: name,
			difficulty: difficulty,
			score: score
		});

		UserData.export();
    }
}