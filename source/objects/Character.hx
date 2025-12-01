package objects;

import engine.Resources;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;

using StringTools;

class Character extends FlxSprite {
    private var animOffsets:Map<String, FlxPoint> = new Map();

    public var busy:Bool = false;

    override public function new(x:Float, y:Float, ?character:String = 'bf')
    {
        super(x, y);

        switch (character) {
            default:
                this.frames = Resources.getSparrowAtlas("characters/BOYFRIEND");
				antialiasing = true;

                addAnim("idle", "BF idle dance0", new FlxPoint(-5, 0));

				addAnim("singLEFT", "BF NOTE LEFT0", new FlxPoint(12, -6));
				addAnim("singDOWN", "BF NOTE DOWN0", new FlxPoint(-10, -50));
				addAnim("singUP", "BF NOTE UP0", new FlxPoint(-29, 27));
				addAnim("singRIGHT", "BF NOTE RIGHT0", new FlxPoint(-38, -7));

				addAnim("singLEFTmiss", "BF NOTE LEFT MISS0", new FlxPoint(12, 24));
				addAnim("singDOWNmiss", "BF NOTE DOWN MISS0", new FlxPoint(-11, 19));
				addAnim("singUPmiss", "BF NOTE UP MISS0", new FlxPoint(-29, 27));
				addAnim("singRIGHTmiss", "BF NOTE RIGHT MISS0", new FlxPoint(-30, 21));

				addAnim("cheer", "BF HEY!!0", new FlxPoint(7, 4));

				addAnim("dies", "BF dies0", new FlxPoint(-37, 11));
				addAnim("deathLoop", "BF Dead Loop0", new FlxPoint(-37, 5), 24, true);
				addAnim("deathConfirm", "BF Dead confirm0", new FlxPoint(-37, 69));

                playAnim("idle");

                flipX = true;
        }
    }

    private function addAnim(name:String, prefix:String, ?offsets:FlxPoint, ?fps:Int = 24, ?loop:Bool = false):Void 
    {
        animation.addByPrefix(name, prefix, fps, loop);
        animOffsets.set(name, offsets);
    }

    public function playAnim(name:String, ?force:Bool = true):Void
    {
        animation.play(name, force);

		var offsets:FlxPoint = animOffsets.get(name);
        this.offset.set(offsets.x, offsets.y);
    }

    public function dance():Void
    {
        if (animation.curAnim.name.startsWith('dance') || !animation.exists('idle')) {
			if (animation.curAnim.name.endsWith('Left'))
                playAnim('danceRight');
            else
                playAnim('danceLeft');
        } else {
            playAnim('idle');
        }
    }
}