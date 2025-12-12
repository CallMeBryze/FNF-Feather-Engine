package states.substates;

import engine.UserData;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxRect;
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
            description_text: "Moves the Strumlines to the bottom of the screen.",
            variable_name: "downscroll"
        },
        {
            preview_text: "Middlescroll",
            description_text: "Centers your Strumline.",
            variable_name: "middlescroll"
        },
        {
            preview_text: "Framerate",
            description_text: "" // figure it tf out
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

    private var lastOption:OptionText;
    private var curOption:OptionText;

    private var descText:FlxText;
    private var settingText:FlxText;

    private var cycleTimer:FlxTimer = new FlxTimer();

    override public function create():Void {
        var stupidAssCamera:FlxCamera = new FlxCamera();
        stupidAssCamera.bgColor = FlxColor.TRANSPARENT;

        FlxG.cameras.add(stupidAssCamera, true);
        camera = stupidAssCamera;

        var bg:FlxSprite = new FlxSprite().makeGraphic(Math.floor(FlxG.width / 2), FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.4;
        bg.scrollFactor.set();
        add(bg);

        super.create();

        var underlay:FlxSprite = new FlxSprite(FlxG.width / 2).makeGraphic(Math.floor(FlxG.width / 2), FlxG.height, FlxColor.WHITE);
        underlay.alpha = 0.4;
        underlay.scrollFactor.set();
        add(underlay);
        
        for (i in 0...options.length) {
            var option = options[i];

            var optionText:OptionText = OptionText.make(option.preview_text);

            optionText.x = Math.max(FlxG.width / 2, FlxG.width - (optionText.width + 8));
            if (optionTexts.members[i - 1] != null)
                optionText.y = (optionTexts.members[i - 1].y + optionText.height) + 16;

            optionText.ID = i;
            optionText.data = option;

            optionTexts.add(optionText);

            optionText.isSelected = (i == curSelected);
            if (i == curSelected)
                curOption = optionText;
        }

        // Description Text
        descText = new FlxText(FlxG.width / 2, 0, FlxG.width / 2);
        descText.setFormat(null, 16, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        descText.borderSize = 2;

        descText.scrollFactor.y = 0;

        // Not to be confused with option text.
        settingText = new FlxText(0, 0, FlxG.width / 2, "");
        settingText.setFormat(null, 72, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        settingText.borderSize = 7;

        settingText.screenCenter(Y);
        settingText.scrollFactor.y = 0;

        // Option Selections
        add(optionTexts);
        add(descText);

        // Option Information for lack of a better term?
        add(settingText);

        camFollow.setPosition(FlxG.width / 2, curOption.y + (curOption.height / 2));
        add(camFollow);

        camera.follow(camFollow, LOCKON, GameUtil.getCameraLerp(0.05, FlxG.elapsed));
    }

    private var safeToCycle:Bool = true;
    override public function update(elapsed):Void {
        if ((Controls.downJustPressed || Controls.upJustPressed) || lastOption != curOption) {
            if (Controls.downJustPressed) {
                if (curSelected < optionTexts.members.length - 1)
                    ++curSelected;
                else
                    curSelected = 0;
    
                FlxG.sound.play(Resources.getAudio('sfx/scrollMenu'), 0.7);
            } else if (Controls.upJustPressed) {
                if (curSelected > 0)
                    --curSelected;
                else
                    curSelected = optionTexts.members.length - 1;
    
                FlxG.sound.play(Resources.getAudio('sfx/scrollMenu'), 0.7);
            }
            
            for (option in optionTexts.members) {
                if (option.ID == curSelected) {
                    settingText.visible = false;
    
                    option.isSelected = true;
                    camFollow.setPosition(FlxG.width / 2, option.y + (option.height / 2));
    
                    curOption = option;
                    
                    descText.text = curOption.data.description_text;
                    switch (option.data.preview_text) {
                        default:
                            if (option.data.variable_name != null) {
                                settingText.visible = true;
                                settingText.text = '${cast(Reflect.getProperty(FlxG.save.data, option.data.variable_name), Bool)}'.toUpperCase();
                            }
    
                        case 'Framerate':
                            settingText.visible = true;

                        case 'Controls':
                            settingText.visible = true;

                        case 'Back':
                            // Absolutely nothing!
                    }
                } else {
                    option.isSelected = false;
                }
            }
        }

        super.update(elapsed);

        if (Controls.confirm) {
            switch (curOption.data.preview_text) {
                default:
                    if (curOption.data.variable_name != null) {
                        var property = Reflect.getProperty(FlxG.save.data, curOption.data.variable_name);

                        if (property != null) {
                            FlxG.sound.play(Resources.getAudio('sfx/confirmMenu'), 0.7);
    
                            try {
                                // Replace with popup menu for selections later
                                Reflect.setProperty(FlxG.save.data, curOption.data.variable_name, !cast(property, Bool));
                            } catch (e:Dynamic) {
                                trace(e);

                                throw e; // yeet
                            }

                            settingText.text = '${!cast(property, Bool)}'.toUpperCase();
                        } else {
                            FlxG.sound.play(Resources.getAudio('sfx/cancelMenu'), 0.7);
                            trace('ERROR! ${curOption.data}');
                        }
                    }
                    
                case 'Framerate':
                    // Absolutely nothing

                case 'Controls':
                    FlxG.sound.play(Resources.getAudio('sfx/confirmMenu'), 0.7);

                    // Open Keybind Substate
                    
                case 'Back':
                    close();
            }
        }

        switch (curOption.data.preview_text) {
            case 'Framerate':
                if (safeToCycle) {
                    if (Controls.leftPressed || Controls.rightPressed) {
                        var newFPS:Int = cast(FlxG.save.data.fps, Int);

                        if (Controls.leftPressed) {
                            --newFPS;
                        } else {
                            ++newFPS;
                        }

                        safeToCycle = false;
                        cycleTimer.start(0.1, (timer) -> {
                            safeToCycle = true;
                        });
                        
                        FlxG.updateFramerate = FlxG.drawFramerate = FlxG.save.data.fps = Math.min(500, Math.max(30, newFPS));
                    }
                }

                settingText.text = '${FlxG.save.data.fps} FPS';

            case 'Controls':
                if (lastOption != curOption) {
                    var map = Controls.controlMapping;
    
                    // I'm so fucking sorry lmfao
                    settingText.text = '[${map.get('left')[0].toString().toUpperCase()},${map.get('down')[0].toString().toUpperCase()},${map.get('up')[0].toString().toUpperCase()},${map.get('right')[0].toString().toUpperCase()}]';
                }
        }
            
        lastOption = curOption;

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