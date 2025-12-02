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
    private static var selectedLibrary:String = null;

    /**
     * Change the Library to be loaded, and clear cache.
     * Warning! This returns a Future! Assets in the library are not immediately loaded,
     * so if you need an asset immediately, RUN A CHECK FIRST!
     * @param name Library Name
     * @return Future<AssetLibrary>
     */
    public static function changeLibrary(name:String):Future<AssetLibrary> {
        if (selectedLibrary != null) {
			Assets.cache.clear(selectedLibrary);
			Assets.unloadLibrary(selectedLibrary);
        }

        selectedLibrary = name;
        return Assets.loadLibrary(name);
    }

    /**
     * Internal Function
     * @param path Starts in `assets` directory.
     * @param library 
     * @return Bool
     */
    private static function existsInLibrary(path:String, library:String):Bool {
		var key:String = Path.normalize('$library:assets/$library/$path');

        return Assets.exists(key);
    }

    /**
     * Retrieve the Bitmap Data from a path.
     * @param path Starts in the `assets/images` directory. Automatically adds the `.png` extension at the end.
     * @param library Library to access.
     */
    public static function getImage(path:String, ?library:String = null):FlxGraphic
    {
        if (library == null)
            library = selectedLibrary;

		var key:String = Path.normalize('assets/images/$path.png');
		if (library != null && existsInLibrary('images/$path.png', library))
			key = Path.normalize('$library:assets/$library/images/$path.png');

        var graphic:FlxGraphic;
        graphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(key));
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
		if (library == null)
			library = selectedLibrary;

        var key:String = Path.normalize('assets/$path.$ext');
		if (library != null && existsInLibrary('$path.$ext', library))
			key = Path.normalize('$library:assets/$library/$path.$ext');

        return Assets.getText(key);
    }

    /**
     * @param path Starts in the `assets` directory.
     * @param library String
     * @param type AssetType
     * @return Bool
     */
    public static function assetExists(path:String, ?library:String = null, ?type:AssetType):Bool
    {
		if (library == null)
			library = selectedLibrary;

        var key:String = Path.normalize('assets/$path');
        if (library != null && existsInLibrary(path, library))
			key = Path.normalize('$library:assets/$library/$path');

        return Assets.exists(key, type);
    }

    /**
     * @param path Starts in the `assets/images` directory. Do not include an extension.
     * @return FlxAtlasFrames
     */
    public static function getSparrowAtlas(path:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(getImage('$path'), getTxt('images/$path', 'xml'));
    }
}

/*typedef ResourceWithIdentifier = {
    var identifier:String;
    var resource:Dynamic;
}*/

typedef SparrowTracker = {
    var identifier:String;
    var sparrow:FlxAtlasFrames;
}