package objects;

import flixel.FlxG;

class Player extends Character {
    public var isDead:Bool = false;
    private var deathConfirmEvent:Void->Void;

    override public function new (x:Float, y:Float, character:String) {
        isPlayer = true;

        super(x, y, character);

		this.flipX = !this.flipX;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (animation.curAnim != null && isDead) {
            if (animation.curAnim.name == 'dies' && animation.curAnim.finished) {
                playAnim("deathLoop");
            }

            // Swap for Confirm Input
            if (deathConfirmEvent != null && FlxG.keys.justPressed.ENTER) {
                playAnim("deathConfirm");

                deathConfirmEvent();
                deathConfirmEvent = null;
            }
        }
    }

    public function gameOver(onConfirm:Void->Void):Void {
        busy = isDead = true;
        deathConfirmEvent = onConfirm;

        playAnim("dies");
    }
}