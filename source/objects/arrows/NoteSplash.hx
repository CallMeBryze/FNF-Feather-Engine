package objects.arrows;

import engine.Resources;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import objects.arrows.Note.NoteDirection;
import objects.arrows.Note.NoteStyle;
import objects.arrows.Strumline.StrumNote;
import states.PlayState;

class NoteSplash extends FlxSprite {
    private var properties:NoteStyle;

    public var group:FlxTypedGroup<NoteSplash>;

	override public function new()
	{
		properties = Json.parse(Resources.getTxt("data/styles/default", "json"));
		if (PlayState.splashAtlas == null || (PlayState.splashAtlas != null && PlayState.splashAtlas.identifier != properties.noteSplashesPath))
		{
			PlayState.splashAtlas = {
				identifier: properties.noteSplashesPath,
				sparrow: Resources.getSparrowAtlas(properties.noteSplashesPath)
			}
		}

        super();

		antialiasing = properties.antialiasing;
		frames = PlayState.splashAtlas.sparrow;

        for (direction in NoteDirection.getConstructors()) {
			for (i in 0...properties.splashAnimations) {
                animation.addByPrefix('$direction:${i + 1}', 'note impact ${i + 1} ${direction.toLowerCase()}', 24, false);
            }
        }

		scale.set(properties.scale, properties.scale);
		updateHitbox();

        centerOffsets();
        centerOrigin();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (animation.finished) {
            this.kill();

            if (group != null) {
				group.remove(this, true);
            } else {
                #if debug
                trace('Group is null! I can\'t free up memory!');
                #end
            }
        }
    }

    public function playSplash(strum:StrumNote, direction:NoteDirection):Void {
        animation.play('${direction.getName()}:${FlxG.random.int(1, properties.splashAnimations)}');
        animation.curAnim.frameRate = FlxG.random.int(12, 24);

		setPosition((strum.x + (strum.width / 2)) - (this.width / 2), (strum.y + (strum.height / 2)) - (this.height / 2));
    }
}