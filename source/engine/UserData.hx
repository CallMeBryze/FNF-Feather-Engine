package engine;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import haxe.Json;
#if cpp
import openfl.filesystem.File;
import sys.FileSystem;
#end

class UserData {
    public static var downscroll(get, never):Null<Bool>;
    public static var middlescroll(get, never):Null<Bool>;

    public static var highscores:HighscoreData = {
        songs: [],
        weeks: []
    };

    public static function init():Void {
        Controls.init();

        // Set Defaults
        if (FlxG.save.data.downscroll == null)
            FlxG.save.data.downscroll = false;

        if (FlxG.save.data.middlescroll == null)
            FlxG.save.data.middlescroll = false;

        // Set Keybinds
        if (FlxG.save.data.controls != null) {
            var keybinds:Array<UserKeybind> = FlxG.save.data.controls;

            for (control in keybinds)
                Controls.controlMapping.set(control.control, control.keys);
        } else {
            var keybinds:Array<UserKeybind> = [];

            for (control in Controls.controlMapping.keyValueIterator())
                keybinds.push({control: control.key, keys: control.value});

            FlxG.save.data.controls = keybinds;
        }

        // Set Framerate
        if (FlxG.save.data.fps != null && Std.isOfType(FlxG.save.data.fps, Int)) {
            FlxG.updateFramerate = FlxG.drawFramerate = FlxG.save.data.fps;
        } else {
            FlxG.save.data.fps = 144;
        }

        // Set Highscores
        if (FlxG.save.data.highscores != null) {
            var savedScores:HighscoreData = FlxG.save.data.highscores;

            if (savedScores != null && (savedScores.songs != null && savedScores.weeks != null))
                highscores = savedScores;
        }
    }

    public static function saveScores():Void {
        FlxG.save.data.highscores = highscores;
    }

	static function get_downscroll():Bool
		return FlxG.save.data.downscroll;

    static function set_downscroll(value:Bool):Bool {
        FlxG.save.data.downscroll = value;

        return FlxG.save.data.downscroll;
    }

    static function get_middlescroll():Bool
        return FlxG.save.data.middlescroll;

    static function set_middlescroll(value:Bool):Bool {
        FlxG.save.data.middlescroll = value;

        return FlxG.save.data.middlescroll;
    }
}

typedef UserKeybind = {
	var control:String;
    var keys:Array<FlxKey>;
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