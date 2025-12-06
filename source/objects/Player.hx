package objects;

import engine.Controls;
import engine.Resources;
import flixel.FlxG;
import flixel.sound.FlxSound;

class Player extends Character {
    public var isDead:Bool = false;

    private var deathSequenceEvent:Void->Void;
    private var deathConfirmEvent:Void->Void;

    override public function new (x:Float, y:Float, character:String) {
        isPlayer = true;

        super(x, y, character);
		cameraPosition.x = -cameraPosition.x;

		this.flipX = !this.flipX;
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (animation.curAnim != null && isDead) {
            if (animation.curAnim.name == 'dies' && animation.curAnim.finished) {
                playAnim("deathLoop");

                if (deathSequenceEvent != null) {
					deathSequenceEvent();
					deathSequenceEvent = null;
                }
            }

            // Swap for Confirm Input
            if (deathConfirmEvent != null && Controls.confirm) {
                playAnim("deathConfirm");

                deathConfirmEvent();
                deathConfirmEvent = null;
            }
        }
    }

    public function gameOver(onIntroSequenceCompleted:Void->Void, onConfirm:Void->Void):Void {
        busy = isDead = true;

        deathSequenceEvent = onIntroSequenceCompleted;
        deathConfirmEvent = onConfirm;

        playAnim("dies");

		var gameOver:FlxSound = Resources.getAudio("sfx/gameover/fnf_loss_sfx");
		gameOver.volume = 0.7;
		gameOver.play();
    }
}