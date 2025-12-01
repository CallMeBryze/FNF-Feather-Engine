package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import openfl.display.Sprite;
import states.TitleState;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, TitleState, 240, 240));
        FlxSprite.defaultAntialiasing = false;
	}
}
