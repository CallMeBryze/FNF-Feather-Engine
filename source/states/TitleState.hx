package states;

import flixel.FlxG;
import flixel.FlxState;

class TitleState extends FlxState {
    override public function create() {
        super.create();

        FlxG.switchState(() -> new PlayState());
    }
}