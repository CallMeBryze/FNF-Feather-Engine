package;

import engine.UserData;
import engine.WindowUtil;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
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
		UserData.init();

		var aspectRatio:Array<Float> = UserData.saveData.options.aspectRatio;
        var gameResolution:Array<Int> = WindowUtil.calcGameBounds(aspectRatio[0], aspectRatio[1], 720);

		addChild(new FlxGame(gameResolution[0], gameResolution[1], InitialState));

        FlxSprite.defaultAntialiasing = false;
        FlxG.resizeWindow(gameResolution[0], gameResolution[1]);
	}
}