package states.substates;

import flixel.addons.ui.FlxUISubState;
import objects.AtlasText;

// TODO: Work on this

class OptionsSubState extends FlxUISubState {
    override function create():Void {
        super.create();
    }

    override function update(elapsed):Void {
        super.update(elapsed);
    }
}

class OptionText extends AtlasText {
    public var isSelected:Bool = false;

    override public function update(elapsed):Void {
        super.update(elapsed);

        if (!isSelected) {
            this.alpha = 0.4;
        } else {
            this.alpha = 1;
        }
    }

    public static function make(str:String):OptionText {
        return new OptionText(0, 0, str, BOLD);
    }
}