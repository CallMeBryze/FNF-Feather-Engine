package states.substates;

import engine.Controls;
import engine.GameUtil;
import engine.Resources;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUISubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import objects.AtlasText;

class PauseSubState extends FlxUISubState {
    private var curSelected:Int = 0;

	private var optionTexts:Array<AtlasText> = [];
    private final options:Array<String> = [
        "Resume",
        "Restart",
        "Quit"
    ];

    private var camFollow:FlxObject;

    override public function create() {
        var daCam:FlxCamera = new FlxCamera();
        daCam.bgColor = FlxColor.TRANSPARENT;
        this.camera = daCam;

        FlxG.cameras.add(daCam, false);

        super.create();

        FlxG.sound.playMusic(Resources.getAudio("music/breakfast"), 0);
        FlxG.sound.music.fadeIn(3, 0, 0.2);

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.4;
        bg.scrollFactor.set();
        add(bg);

        for (i in 0...options.length) {
            var optionText = createText(8, 0, options[i]);
            if (optionTexts[i - 1] != null)
				optionText.y = (optionTexts[i - 1].y + optionText.height) + 16;

            optionTexts.push(optionText);

            add(optionText);
        }

		var engineText = new FlxText(0, 0, 0, 'Feather Engine v${Main.featherEngineVersion}', 12);
		if (Application.current.meta.get("company") != 'CallMeBryze')
			engineText.text = 'Feather Engine v${Main.featherEngineVersion}\nMod v${Application.current.meta.get("version")}';

        engineText.setFormat(null, 12, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
        engineText.borderSize = 2;

        engineText.scrollFactor.set();
        engineText.setPosition((FlxG.width - engineText.width) - 8, (FlxG.height - engineText.height) - 8);
        
        add(engineText);

        var pauseText:AtlasText = new AtlasText(0, 8, "PAUSED", BOLD);
        pauseText.screenCenter(X);
        pauseText.scrollFactor.set();
        add(pauseText);

        camFollow = new FlxObject();
        add(camFollow);

        camera.setScrollBounds(0, FlxG.width, -FlxG.height, FlxG.height * 2);
		camera.follow(camFollow, LOCKON, GameUtil.getCameraLerp(0.05, FlxG.elapsed));
        camera.focusOn(new FlxPoint(0, optionTexts[0].y + (optionTexts[0].height / 2)));
    }

    private function createText(x:Float, y:Float, text:String):AtlasText {
        return new AtlasText(x, y, text, BOLD);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.downJustPressed) {
			if (curSelected < options.length - 1)
				++curSelected;
			else
				curSelected = 0;

			FlxG.sound.play(Resources.getAudio('sfx/scrollMenu'), 0.7);
        }
        else if (Controls.upJustPressed) {
			if (curSelected > 0)
				--curSelected;
			else
				curSelected = options.length - 1;

			FlxG.sound.play(Resources.getAudio('sfx/scrollMenu'), 0.7);
        }

        camFollow.setPosition(0, optionTexts[curSelected].y + (optionTexts[curSelected].height / 2));
        for (i in 0...optionTexts.length) {
            if (i != curSelected) {
				optionTexts[i].alpha = 0.4;
				optionTexts[i].x = FlxMath.lerp(optionTexts[i].x, 8, FlxMath.getElapsedLerp(0.1, elapsed));
            }
            else {
				optionTexts[i].alpha = 1;
				optionTexts[i].x = FlxMath.lerp(optionTexts[i].x, 32, FlxMath.getElapsedLerp(0.1, elapsed));
            }
        }

        if (Controls.confirm) {
            switch (options[curSelected].toLowerCase()) {
                case 'resume':
					FlxG.sound.play(Resources.getAudio('sfx/confirmMenu'), 0.7);
                    close();

                case 'restart':
					FlxG.sound.play(Resources.getAudio('sfx/confirmMenu'), 0.7);
                    LoadingState.loadAndSwitchState(new PlayState());

                default: // quit
                    trace('Not yet implemented!'); // User has to make their own menu.
                    FlxG.sound.play(Resources.getAudio('sfx/cancelMenu'), 0.7);
            }
        }
    }

    override public function close():Void {
        FlxG.sound.music.stop();

        super.close();
    }
}