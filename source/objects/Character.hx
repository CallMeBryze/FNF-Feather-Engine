package objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Character extends FlxSprite {
    override public function new(x:Float, y:Float, character:String, scrollFactor:FlxPoint)
    {
        super(x, y);

        

        this.scrollFactor.set(scrollFactor.x, scrollFactor.y);
    }
}