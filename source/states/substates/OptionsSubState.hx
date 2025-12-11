package states.substates;

import engine.Resources;
import engine.Controls;
import engine.GameUtil;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUISubState;
import objects.AtlasText;

class OptionsSubState extends FlxUISubState {
    private var optionTexts:FlxTypedGroup<OptionText> = new FlxTypedGroup();
    
    private final options:Array<OptionInfo> = [
        {
            preview_text: "Downscroll",
            description_text: "Moves the Strumline to the bottom of the screen.",
            variable_name: "downscroll"
        },
        {
            preview_text: "Middlescroll",
            description_text: "Centers the Player Strumline.",
            variable_name: "middlescroll"
        },
        {
            preview_text: "Controls",
            description_text: "Set your Keybinds."
        },
        {
            preview_text: "Back",
            description_text: ""
        }
    ];

    private var camFollow:FlxObject = new FlxObject();

    private var curSelected:Int = 0;
    private var curOption:OptionText;

    override public function create():Void {
        var stupidAssCamera:FlxCamera = new FlxCamera();
        stupidAssCamera.bgColor = FlxColor.TRANSPARENT;

        FlxG.cameras.add(stupidAssCamera, true);
        camera = stupidAssCamera;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.4;
        bg.scrollFactor.set();
        add(bg);

        super.create();

        for (i in 0...options.length) {
            var option = options[i];

            var optionText:OptionText = OptionText.make(option.preview_text);
            optionText.screenCenter(X);
            optionText.y = 64 * i;

            optionText.ID = i;
            optionText.data = option;
            optionText.isSelected = (i == curSelected);

            optionTexts.add(optionText);

            if (i == 0)
                curOption = optionText;
        }

        add(optionTexts);

        camFollow.setPosition(curOption.x + (curOption.width / 2), curOption.y + (curOption.height / 2));
        add(camFollow);

        camera.follow(camFollow, LOCKON, GameUtil.getCameraLerp(0.05, FlxG.elapsed));
    }

    override public function update(elapsed):Void {
        super.update(elapsed);

        if (Controls.downJustPressed) {
			if (curSelected < optionTexts.members.length - 1)
				++curSelected;
			else
				curSelected = 0;

			FlxG.sound.play(Resources.getAudio('sfx/scrollMenu'), 0.7);
        }
        else if (Controls.upJustPressed) {
			if (curSelected > 0)
				--curSelected;
			else
				curSelected = optionTexts.members.length - 1;

			FlxG.sound.play(Resources.getAudio('sfx/scrollMenu'), 0.7);
        }

        for (option in optionTexts.members) {
            if (option.ID == curSelected) {
                option.isSelected = true;
                camFollow.setPosition(option.x + (option.width / 2), option.y + (option.height / 2));

                curOption = option;
            } else {
                option.isSelected = false;
            }
        }

        if (Controls.confirm) {
            if (curOption.text != 'Back')
                FlxG.sound.play(Resources.getAudio('sfx/confirmMenu'), 0.7);

            switch (curOption.text) {
                default:
                    try {
                        // Replace with popup menu for selections later
                        Reflect.setProperty(FlxG.save.data, curOption.data.variable_name, !cast(Reflect.getProperty(FlxG.save.data, curOption.data.variable_name), Bool));
                    } catch (e:Dynamic) {
                        throw e; // yeet
                    }
                case 'Controls':
                    // IMPLEMENT LATER
                case 'Back':
                    close();
            }
        }

        if (Controls.back)
            close();
    }

    override public function close():Void {
        FlxG.sound.play(Resources.getAudio('sfx/cancelMenu'), 0.7);

        if (Std.isOfType(FlxG.state, PlayState)) {
            FlxG.sound.music.stop(); // Stop the stupid ass pause music

            var stateClass = Type.getClass(FlxG.state);
            FlxG.switchState(() -> Type.createInstance(stateClass, []));
        }

        super.close();
    }
}

class OptionText extends AtlasText {
    public var isSelected:Bool = false;
    public var data:OptionInfo;

    override public function update(elapsed):Void {
        super.update(elapsed);

        if (!isSelected) {
            this.alpha = 0.4;
        } else {
            this.alpha = 1;
        }
    }

    public static function make(str:String):OptionText {
        var optionShit:OptionText = new OptionText(0, 0, str, BOLD);
        optionShit.update(FlxG.elapsed);

        return optionShit;
    }
}

typedef OptionInfo = {
    var preview_text:String;
    var description_text:String;
    var ?variable_name:String;
}