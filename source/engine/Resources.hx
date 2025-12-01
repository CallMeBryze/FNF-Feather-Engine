package engine;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.utils.AssetCache;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetType;
import openfl.utils.Future;

class Resources {
    public static var universalCache:Map<String, Dynamic> = new Map();
    private static var selectedLibrary:String = null;

    /**
     * Change the Library to be loaded, and clear cache.
     * Warning! This returns a Future! Assets in the library are not immediately loaded,
     * so if you need an asset immediately, RUN A CHECK FIRST!
     * @param name Library Name
     * @return Future<AssetLibrary>
     */
    public static function changeLibrary(name:String):Future<AssetLibrary> {
        universalCache.clear();

        if (selectedLibrary != null) {
			Assets.cache.clear(selectedLibrary);
			Assets.unloadLibrary(selectedLibrary);
        }

        selectedLibrary = name;
        return Assets.loadLibrary(name);
    }

    private static function detectLibrary(key:String):String {
        if (selectedLibrary != null) {
			if (Assets.exists('$selectedLibrary:$key'))
			{
				return selectedLibrary;
			}
			else if (Assets.exists(key))
			{
				return 'default';
			}
			else
			{
				trace('Library of asset isn\'t loaded, or asset cannot be found!');
				return 'default';
			}
        }
        else {
            return 'default';
        }
    }

    /**
     * Retrieve the Bitmap Data from a path.
     * @param path Starts in the `assets/images` directory. Automatically adds the `.png` extension at the end.
     * @param library Library to access.
     */
    public static function getImage(path:String, ?library:String = null):FlxGraphic
    {
        var key:String = Path.normalize('assets/images/$path.png');

        var finalKey:String = key;
        if (library != null)
            finalKey = '$library:$key'
        else
			finalKey = '${detectLibrary(key)}:$key';

        var graphic:FlxGraphic;
        graphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(finalKey));
        graphic.persist = true;

        return graphic;
    }

    /**
     * Retrieve Text File Contents from a path.
     * @param path Starts in the `assets` directory. Automatically adds the `.txt` extension at the end.
     * @param txt Define the extension to be used.
	 * @param library Library to access.
     */
    public static function getTxt(path:String, ?ext:String = 'txt', ?library:String = null):String
    {
        var key:String = Path.normalize('assets/$path.$ext');

        var finalKey:String = key;
		if (library != null)
			finalKey = '$library:$key'
		else
			finalKey = '${detectLibrary(key)}:$key';

        return Assets.getText(finalKey);
    }

    /**
     * [Description]
     * @param path Starts in the `assets/images` directory. Do not include an extension.
     * @return FlxAtlasFrames
     */
    public static function getSparrowAtlas(path:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(getImage('$path'), getTxt('images/$path', 'xml'));
    }
}

/*typedef ResourceElementJson = {
    var path:String;
    var type:AssetType;
    var ?library:String;
}*/

typedef ResourceWithIdentifier = {
    var identifier:String;
    var resource:Dynamic;
}