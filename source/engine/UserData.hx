package engine;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import haxe.Json;
#if cpp
import openfl.filesystem.File;
import sys.FileSystem;
#end

// TODO: REWRITE THIS LATER!!! THIS IS STUPID AS HELL!!!

/**
 * I am very well aware that FlxG.save.data exists.
 * But for portability reasons, and easy user modification, we're doing this.
 */
class UserData {
    public static var saveData:SaveData;

    public static var downscroll(get, never):Null<Bool>;
    public static var middlescroll(get, never):Null<Bool>;

    public static function init():Void {
        Controls.init();

        // Default Values
        saveData = {
            options: {
				fps: 144,
				downscroll: false,
                middlescroll: false,
                fullscreen: false,
                aspectRatio: [16, 9],
				keybinds: []
            },
            highscores: {
                songs: [],
                weeks: []
            }
        }

        for (key in Controls.controlMapping.keyValueIterator()) {
            saveData.options.keybinds.push({
                control: key.key,
                keys: key.value
            });
        }

        #if cpp
        if (FileSystem.exists("saveData.json")) {
		    saveData = Json.parse(File.getFileText("saveData.json"));

			for (keybind in saveData.options.keybinds) {
                Controls.controlMapping.set(keybind.control, keybind.keys);
            }
        } else {
			export();
        }
        #end
    }

    public static function export():Void {
		File.saveText("saveData.json", Json.stringify(saveData, null, '\t'));
    }

	static function get_downscroll():Bool
		return saveData.options.downscroll;

    static function get_middlescroll():Null<Bool> {
        return saveData.options.middlescroll;
    }
}

typedef UserKeybind = {
	var control:String;
    var keys:Array<FlxKey>;
}

typedef SaveData = {
    var options:OptionData;
    var highscores:HighscoreData;
}

typedef HighscoreData = {
    var songs:Array<ScoreData>;
    var weeks:Array<ScoreData>;
}

typedef ScoreData = {
    var name:String;
    var difficulty:String;
    var score:Int;
}

typedef OptionData = {
    var fps:Int;
    var downscroll:Bool;
    var middlescroll:Bool;
    var fullscreen:Bool;
    var aspectRatio:Array<Float>;
    var keybinds:Array<UserKeybind>;
}