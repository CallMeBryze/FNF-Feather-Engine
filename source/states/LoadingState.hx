package states;

import engine.Resources;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import states.template.MusicBeatState;

using StringTools;

typedef AssetTracker = {
    var key:String;
    var type:FlxAssetType;
}

class LoadingState extends MusicBeatState {
    private final defaultCacheProgressText:String = "Waiting...";

    public static final allAssetTypes:Array<FlxAssetType> = [
        IMAGE,
        SOUND,
	    FONT,
        TEXT,
        BINARY
    ];

    private static var targetState:FlxState;
	private static var assetsToCache:Array<AssetTracker> = [];

    private static function getAssetsInLibrary(library:String) {
        var startingDir:String = 'assets/$library/';

        for (type in allAssetTypes) {
            for (asset in FlxG.assets.list(type)) {
                if (asset.startsWith(startingDir))
                {
                    #if debug
                    trace('Adding "$asset" to cache list!');
                    #end

                    assetsToCache.push({
                        key: '$library:$asset',
                        type: type
                    });
                }
            }
        }
    }

    public static var lastCachedLibrary:String;

    /**
     * Self explanatory, isn't it?
     * @param state State to load.
     * @param library Global Library to load.
     */
    public static function loadAndSwitchState(state:FlxState, ?library:String = null):Void {
        assetsToCache = [];

        if (library != null && library != lastCachedLibrary) {
			FlxG.state.active = false;

			var futureLibrary = Resources.changeLibrary(library);
			futureLibrary.onComplete((v) -> {
                lastCachedLibrary = library;

				getAssetsInLibrary(library);
				FlxG.state.active = true;

                targetState = state;

				if (assetsToCache.length > 0)
					FlxG.switchState(() -> new LoadingState());

                return;
			});

			futureLibrary.onError((e) -> {
				trace('Error on preparing library cache! ($e).');

				FlxG.state.active = true;
				FlxG.switchState(() -> state);

				return;
			});
        } else {
			FlxG.switchState(() -> state);
        }
    }

    override public function new(?prepareGame:Bool = false, ?target:FlxState) {
        super();

        if (target != null) {
			targetState = target;
        }

        if (prepareGame) {
            getAssetsInLibrary('shared');
        }
    }

    private var progressBar:FlxBar;
    private var currentCacheText:FlxText;

    private var cacheProgress:Int = 0;

    private var finishedTransition:Bool = false;

    override public function create():Void {
		var bg:FlxSprite = new FlxSprite().loadGraphic(Resources.getImage("funkay"));
		bg.antialiasing = true;
		bg.setGraphicSize(1280);
        bg.updateHitbox();
        bg.screenCenter(XY);
		add(bg);

        progressBar = new FlxBar(0, 0, LEFT_TO_RIGHT, FlxG.width - 256, 32, this, "cacheProgress", 0, assetsToCache.length - 1);
        progressBar.createColoredFilledBar(FlxColor.WHITE, true, FlxColor.BLACK, 4);
        progressBar.updateHitbox();
        progressBar.screenCenter(X);
        progressBar.y = FlxG.height - (progressBar.height + 32);
        add(progressBar);

		currentCacheText = new FlxText(progressBar.x, progressBar.y + progressBar.height, progressBar.width, defaultCacheProgressText, 16);
        currentCacheText.setFormat(null, 16, FlxColor.BLACK, FlxTextAlign.LEFT);
        add(currentCacheText);

        super.create();

        new FlxTimer().start(1, (timer) -> {
            if (assetsToCache.length > 0) {
				var targetAsset:AssetTracker = assetsToCache.pop();

                try {
					FlxG.assets.getAsset(targetAsset.key, targetAsset.type, true);
                } catch (e:Dynamic) {
                    trace('Error! ($e)');
                }

                ++cacheProgress;

				#if debug
				trace('Cached Asset: ${targetAsset.key}');
				#end

				timer.reset(1.0 / FlxG.updateFramerate);
            } else {
                timer.destroy();
				FlxG.switchState(() -> targetState);
            }
        });
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

		if (assetsToCache[assetsToCache.length - 1] != null) {
			currentCacheText.text = assetsToCache[assetsToCache.length - 1].key;
        } else {
            currentCacheText.text = "Finished!";
        }
    }
}