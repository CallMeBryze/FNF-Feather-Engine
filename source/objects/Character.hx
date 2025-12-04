package objects;

import engine.Conductor;
import engine.Resources;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;

using StringTools;

class Character extends FlxSprite {
    private var animOffsets:Map<String, FlxPoint> = new Map();

    public var isPlayer:Bool = false;
    public var busy:Bool = false;

    private var holdDuration:Float = 5;
    public var holdTimer:Float = 0;

    public var character:String;

    override public function new(x:Float, y:Float, ?character:String = 'bf')
    {
        this.character = character;

        super(x, y);

        switch (character) {
            default:
                this.frames = Resources.getSparrowAtlas("characters/BOYFRIEND", "shared");
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
            case 'dad':
				this.frames = Resources.getSparrowAtlas("characters/daddyDearest", "week1");
				antialiasing = true;

                addAnim("idle", "idle", new FlxPoint(0, 0));

				addAnim("singLEFT", "singLEFT", new FlxPoint(-10, 10));
                addAnim("singDOWN", "singDOWN", new FlxPoint(0, -30));
                addAnim("singUP", "singUP", new FlxPoint(-6, 50));
				addAnim("singRIGHT", "singRIGHT", new FlxPoint(0, 27));

                playAnim("idle");
            case 'gf':
                this.frames = Resources.getSparrowAtlas("characters/GF_assets", "shared");
                antialiasing = true;

				addAnim("danceLeft", "GF Dancing Beat", new FlxPoint(0, -9), 24, false, [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
				addAnim("danceRight", "GF Dancing Beat", new FlxPoint(0, -9), 24, false, [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]);

				addAnim("sad", "gf sad", new FlxPoint(2, -21), 24, false, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

                addAnim("cheer", "GF Cheer", new FlxPoint());
                addAnim("scared", "GF FEAR", new FlxPoint(-2, -17));

                playAnim('danceLeft');
        }
    }

    override public function update(elapsed:Float) {
        if (animation.curAnim.name.startsWith('sing') && animation.finished) {
            holdTimer += elapsed;

			var timeToHold:Float = (Conductor.stepCrochet * holdDuration) * 0.001;
            if (holdTimer >= timeToHold) {
                dance();
                holdTimer = 0;
            }
        } else {
            holdTimer = 0;
        }

        super.update(elapsed);
    }

	private function addAnim(name:String, prefix:String, offsets:FlxPoint, ?fps:Int = 24, ?loop:Bool = false, ?indicies:Array<Int> = null):Void 
    {
        if (indicies == null)
            animation.addByPrefix(name, prefix, fps, loop);
        else
            animation.addByIndices(name, prefix, indicies, null, fps, loop);

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