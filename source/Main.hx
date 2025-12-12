package;

import engine.UserData;
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
    public static final featherEngineVersion:String = "1.1.0";

	public function new()
	{
		// Shh...
		Dirty.secretBackTexts.push("Gettin' freaky on a " + convertDay(Date.now().getDay()) + " night, yeah!");

		super();

		Assets.loadLibrary("shared");
		addChild(new FlxGame(0, 0, InitialState));

        FlxSprite.defaultAntialiasing = false;
	}

	// Used for an easter egg, dw.
	private function convertDay(day:Int):String {
		switch (day) {
			default:
				return 'Sunday';
			case 1:
				return 'Monday';
			case 2:
				return 'Tuesday';
			case 3:
				return 'Wednesday';
			case 4:
				return 'Thursday';
			case 5:
				return 'Friday';
			case 6:
				return 'Saturday';
		}
	}
}

/**
 * Used to hide variables you don't want to be visible anywhere else.
 * Like for easter-eggs and shit.
 */
 class Dirty {
    /**
     * Secret Texts for the back button in the options menu.
     */
    public static var secretBackTexts:Array<String> = [ // Can't make this a final for reasons you can find if you scroll up
        "No, it doesn't mean backshots.",
        "How many options are there? 6? Maybe 7?",
		"You should've dodged, dumbass!",
		"Aw, shucks!",
		"Heh, powers.",
		"Sunday, goodness... Keep it down!",
		"Pibby Mods are mid.",
		"These are random, if you couldn't tell.",
		"\"big dick randy\" -AirHater",
		"\"sylvester silverstar\" -Silverstar",
		"Check out Aether Engine!", // Silverstar didn't tell me to put this here lol
		"FNF came out in 2020. Let that sink in."
    ];
}