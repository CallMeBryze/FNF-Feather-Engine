package;

import flixel.FlxG;
import flixel.FlxState;
import states.LoadingState;
import states.TitleState;

/**
 * Only exists because FlxGame is STUPID!!!
 */
class InitialState extends FlxState {
    override public function create():Void {
		FlxG.save.bind('featherEngine', 'CallMeBryze');
		FlxG.autoPause = false; // disgusting.

		FlxG.switchState(() -> new LoadingState(true, new TitleState()));
    }
}