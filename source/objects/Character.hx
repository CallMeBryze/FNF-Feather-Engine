package objects;

import engine.Resources;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;

using StringTools;

class Character extends FlxSprite {
    override public function new(x:Float, y:Float, ?character:String = 'bf', ?scrollFactor:Null<FlxPoint>)
    {
        super(x, y);

        antialiasing = true;

        switch (character) {
            default:
                this.frames = Resources.getSparrowAtlas("characters/BOYFRIEND");

                addAnim("idle", "BF idle dance0");

                addAnim("singLEFT", "BF NOTE LEFT0");
                addAnim("singDOWN", "BF NOTE DOWN0");
                addAnim("singUP", "BF NOTE UP0");
                addAnim("singRIGHT", "BF NOTE RIGHT0");

                playAnim("idle");
        }
        
        if (scrollFactor != null)
            this.scrollFactor.set(scrollFactor.x, scrollFactor.y);
    }

    private function addAnim(name:String, prefix:String, ?fps:Int = 24, ?loop:Bool = false):Void 
    {
        animation.addByPrefix(name, prefix, fps, loop);
    }

    public function playAnim(name:String):Void
    {
        animation.play(name, true);
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