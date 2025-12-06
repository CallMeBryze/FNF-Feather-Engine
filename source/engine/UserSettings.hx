package engine;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import haxe.Json;
#if cpp
import openfl.filesystem.File;
import sys.FileSystem;
#end

class UserSettings {
    public static var settings:SavedSettings;

    public static var downscroll(get, never):Null<Bool>;

    public static function init():Void {
        Controls.init();

        // Default Values
        settings = {
            fps: 144,
            downscroll: false,
            keybinds: []
        }

        for (key in Controls.controlMapping.keyValueIterator()) {
            settings.keybinds.push({
                control: key.key,
                keys: key.value
            });
        }

        #if cpp
        if (FileSystem.exists("settings.json")) {
			settings = Json.parse(File.getFileText("settings.json"));

            for (keybind in settings.keybinds) {
                Controls.controlMapping.set(keybind.control, keybind.keys);
            }
        } else {
            File.saveText("settings.json", Json.stringify(settings, null, '\t'));
        }
        #end

        FlxG.updateFramerate = FlxG.drawFramerate = settings.fps;
    }

    public static function exportSettings():Void {
		File.saveText("settings.json", Json.stringify(settings, null, '\t'));
    }

	static function get_downscroll():Bool
		return settings.downscroll;
}

typedef UserKeybind = {
	var control:String;
    var keys:Array<FlxKey>;
}

typedef SavedSettings = {
    var fps:Int;
    var downscroll:Bool;
    var keybinds:Array<UserKeybind>;
}