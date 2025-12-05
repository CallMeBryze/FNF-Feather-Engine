package engine;

import flixel.FlxG;

class UserSettings {
    public static var downscroll(get, set):Null<Bool>;

    public static function init():Void {
        // add logic to reading a json file or smth. i ain't making an options menu for v1 of this shit.
        // if i ever make an update to this engine i'll add one.
        // im timerd lolo

        // Default Values
		if (downscroll == null)
            downscroll = false;
    }

    static function set_downscroll(value:Bool):Bool
        return FlxG.save.data.downscroll = value;
	static function get_downscroll():Bool
		return FlxG.save.data.downscroll;
}