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
	public function new()
	{
		super();

		Assets.loadLibrary("shared");

		addChild(new FlxGame(0, 0, InitialState, 144, 144));
        FlxSprite.defaultAntialiasing = false;
	}
}
