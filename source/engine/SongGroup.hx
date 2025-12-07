package engine;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;

class SongGroup extends FlxBasic {
    /**
     * Only contains the instrumental, but all tracks try to match every property possible other than volume.
     */
    public var music:FlxSound;

    public var vocals:Map<String, FlxSound> = new Map();
    private var tracks:FlxTypedGroup<FlxSound> = new FlxTypedGroup();

    public var isValid(get, never):Bool;

    private function get_isValid():Bool {
        var isValid:Bool = true;
        for (track in tracks) {
            if (track == null) {
                isValid = false;
                break;
            }
        }

        return isValid;
    }

    override public function new (music:FlxSound) {
        super();

        this.music = music;
    }

    override public function update(elapsed):Void {
        super.update(elapsed);

        music.update(elapsed);

        tracks.forEach((track) -> {
            track.update(elapsed);

            if (music.playing) {
                if (!track.playing)
                    track.play(false, music.time);

                track.pitch = music.pitch;

                if (music.time - track.time <= -20 || music.time - track.time >= 20)
					track.time = music.time;
            } else {
                track.pause();
            }
        });
    }

    override public function kill():Void {
        music.stop();
        music.kill();
        music.destroy();

        for (track in tracks) {
            track.stop();
            track.kill();
            track.destroy();
        }

        super.kill();
    }

    public function add(sound:FlxSound, identifier:String):Void {
        if (!vocals.exists(identifier)) {
			tracks.add(sound);
			vocals.set(identifier, sound);

			sound.time = music.time;
			sound.volume = music.volume;
			if (music.playing)
				sound.play(false, music.time);
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