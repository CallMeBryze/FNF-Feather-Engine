package engine;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Controls {
    public static var controlMapping:Map<String, Array<FlxKey>> = new Map();
    
    public static var pressedInputArray(get, never):Array<Bool>;
    public static var justPressedInputArray(get, never):Array<Bool>;

    /**
     * Set default controls/inputs.
     */
    public static function init():Void {
        // LEFT, DOWN, UP, RIGHT
        controlMapping.set("left", [D, LEFT]);
        controlMapping.set("down", [F, DOWN]);
        controlMapping.set("up", [J, UP]);
        controlMapping.set("right", [K, RIGHT]);

        // CONFIRM, BACK/PAUSE.
        controlMapping.set("confirm", [ENTER, SPACE]);
        controlMapping.set("back", [ESCAPE, BACKSPACE]);
    }

    static function get_pressedInputArray():Array<Bool> {
        return [leftPressed, downPressed, upPressed, rightPressed];
    }

    static function get_justPressedInputArray():Array<Bool> {
        return [leftJustPressed, downJustPressed, upJustPressed, rightJustPressed];
    }
    
    public static var confirm(get, never):Bool;
    public static var back(get, never):Bool;

    static function get_confirm():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyJustPressed(controlMapping.get("confirm"));

        return pressed;
    }

    static function get_back():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyJustPressed(controlMapping.get("back"));

        return pressed;
    }

    public static var leftPressed(get, never):Bool;
    public static var downPressed(get, never):Bool;
    public static var upPressed(get, never):Bool;
    public static var rightPressed(get, never):Bool;

    static function get_leftPressed():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyPressed(controlMapping.get("left"));

        return pressed;
    }

    static function get_downPressed():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyPressed(controlMapping.get("down"));

        return pressed;
    }

    static function get_upPressed():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyPressed(controlMapping.get("up"));

        return pressed;
    }

    static function get_rightPressed():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyPressed(controlMapping.get("right"));

        return pressed;
    }

    public static var leftJustPressed(get, never):Bool;
    public static var downJustPressed(get, never):Bool;
    public static var upJustPressed(get, never):Bool;
    public static var rightJustPressed(get, never):Bool;

    static function get_leftJustPressed():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyJustPressed(controlMapping.get("left"));

        return pressed;
    }

    static function get_downJustPressed():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyJustPressed(controlMapping.get("down"));

        return pressed;
    }

    static function get_upJustPressed():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyJustPressed(controlMapping.get("up"));

        return pressed;
    }

    static function get_rightJustPressed():Bool {
        var pressed:Bool = false;

        pressed = FlxG.keys.anyJustPressed(controlMapping.get("right"));

        return pressed;
    }
}
