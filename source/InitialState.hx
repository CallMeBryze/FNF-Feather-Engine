package;

import engine.Controls;
import engine.UserData;
import flixel.FlxG;
import flixel.FlxState;
import objects.AtlasText.AtlasFont;
import states.LoadingState;
import states.TitleState;

/**
 * Only exists because FlxGame is STUPID!!!
 */
class InitialState extends FlxState {
    override public function create():Void {
		FlxG.autoPause = false; // disgusting.

        UserData.init();
		FlxG.switchState(() -> new LoadingState(true, new TitleState()));
    }
}