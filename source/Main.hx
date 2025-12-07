package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import openfl.display.Sprite;
import openfl.utils.Assets;
import states.LoadingState;
import states.TitleState;

class Main extends Sprite
{
    public static final featherEngineVersion:String = "1.0.1";

	public function new()
	{
		super();

		Assets.loadLibrary("shared");

		addChild(new FlxGame(0, 0, InitialState));
        FlxSprite.defaultAntialiasing = false;
	}
}