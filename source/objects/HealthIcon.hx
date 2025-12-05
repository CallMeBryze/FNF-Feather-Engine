package objects;

import engine.Resources;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.ui.FlxBar;

class HealthIcon extends FlxSprite
{
    public var curCharacter:String;
    public var isPlayer:Bool;

    public var type:HealthIconType = SIMPLE;

    private var linkedHealthBar:FlxBar;

	override public function new(character:String, isPlayer:Bool, ?antialiasing:Bool = true, ?healthBar:FlxBar = null, ?type:HealthIconType = SIMPLE)
    {
        this.type = type;
		this.isPlayer = isPlayer;
        linkedHealthBar = healthBar;

        super();

        this.antialiasing = antialiasing;

        flipX = isPlayer;
        swapIcon(character, type);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        flipX = isPlayer;

        if (linkedHealthBar != null && animation.curAnim != null) {
            if (isPlayer && linkedHealthBar.value < 0.4 || !isPlayer && linkedHealthBar.value > (1 - 0.4)) {
                switch (type) {
                    default:
                        animation.play('dying');
                    case ANIMATED:
                        if (animation.curAnim.name != 'dying') {
                            if (animation.curAnim.name == 'transitionToDying' && animation.curAnim.finished) {
                                animation.play('dying');
							} else if (animation.curAnim.name != 'transitionToDying') {
                                animation.play('transitionToDying');
                            }
                        }
                }
            } else {
				switch (type)
				{
					default:
						animation.play('idle');
					case ANIMATED:
						if (animation.curAnim.name != 'idle')
						{
							if (animation.curAnim.name == 'transitionToIdle' && animation.curAnim.finished) {
								animation.play('idle');
							} else if (animation.curAnim.name != 'transitionToIdle') {
								animation.play('transitionToIdle');
							}
						}
				}
            }
        }
    }

	public function swapIcon(character:String, ?type:HealthIconType = SIMPLE):Void
    {
        if (type == SIMPLE) {
            if (Resources.assetExists('images/icons/simple/icon-$character.png')) {
				loadGraphic(Resources.getImage('icons/simple/icon-$character'), true, 150, 150);
            } else {
				trace('Could not find Simple Icon for $character.');

				swapIcon('face', SIMPLE);
				return;
            }

			animation.add('idle', [0]);
			animation.add('dying', [1]);
        } else if (type == ANIMATED) {
			if (Resources.assetExists('images/icons/simple/icon-$character.xml')) {
				frames = Resources.getSparrowAtlas('icons/animated/icon-$character');
				animation.addByPrefix('idle', 'idle0', 24, true);
				animation.addByPrefix('transitionToIdle', 'transitionIdle0', 24, false);
				animation.addByPrefix('dying', 'dying0', 24, true);
				animation.addByPrefix('transitionToDying', 'transitionDying0', 24, false);

				setGraphicSize(150);
				updateHitbox();
            } else {
                trace('Could not find Animated Icon for $character.');

                swapIcon('face', SIMPLE);
                return;
            }
        }

        curCharacter = character;
        this.type = type;

        animation.play('idle');
    }
}

enum HealthIconType {
    SIMPLE;
    ANIMATED;
}