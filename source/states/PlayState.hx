package states;

import flixel.FlxState;
import objects.Character;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();

        var boyfriend:Character = new Character(500, 250);
        add(boyfriend);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
