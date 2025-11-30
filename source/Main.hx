package;

import engine.Resources;
import flixel.FlxGame;
import flixel.FlxSprite;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, states.PlayState));
        FlxSprite.defaultAntialiasing = false;
	}
}
