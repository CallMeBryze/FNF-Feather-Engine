package engine;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;

class VocalGroup extends FlxBasic {
    private var tracker:FlxSound;

    public var vocals:Map<String, FlxSound> = new Map();
    private var tracks:FlxTypedGroup<FlxSound> = new FlxTypedGroup();

    override public function new (tracker:FlxSound) {
        super();

        this.tracker = tracker;
    }

    override public function update(elapsed):Void {
        super.update(elapsed);

        tracks.forEach((track) -> {
            track.update(elapsed);

            if (tracker.playing) {
                if (!track.playing)
                    track.play(false, tracker.time);

                track.pitch = tracker.pitch;

                if (tracker.time - track.time <= -20 || tracker.time - track.time >= 20)
					track.time = tracker.time;
            } else {
                track.pause();
            }
        });
    }

    public function add(sound:FlxSound, identifier:String):Void {
        if (!vocals.exists(identifier)) {
			tracks.add(sound);
			vocals.set(identifier, sound);

			sound.time = tracker.time;
			if (tracker.playing)
				sound.play(false, tracker.time);
        } else {
            trace('Vocal is null or Vocal with key $identifier already exists!');
        }
    }

    public function remove(identifier:String):Void {
		var sound:FlxSound = vocals.get(identifier);
        
        sound.stop();
        sound.kill();

		tracks.remove(sound);
        vocals.remove(identifier);
    }

    public function clear():Void {
        vocals.clear();

        tracks.kill();
        tracks.clear();
    }
}