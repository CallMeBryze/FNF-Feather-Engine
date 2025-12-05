package engine;

import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;

class SongGroup extends FlxBasic {
    public var inst:FlxSound;

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

    override public function new (inst:FlxSound) {
        super();

        this.inst = inst;
    }

    override public function update(elapsed):Void {
        super.update(elapsed);

        inst.update(elapsed);

        tracks.forEach((track) -> {
            track.update(elapsed);

            if (inst.playing) {
                if (!track.playing)
                    track.play(false, inst.time);

                track.pitch = inst.pitch;

                if (inst.time - track.time <= -20 || inst.time - track.time >= 20)
					track.time = inst.time;
            } else {
                track.pause();
            }
        });
    }

    override public function kill():Void {
        inst.stop();
        inst.kill();
        inst.destroy();

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

			sound.time = inst.time;
			sound.volume = inst.volume;
			if (inst.playing)
				sound.play(false, inst.time);
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