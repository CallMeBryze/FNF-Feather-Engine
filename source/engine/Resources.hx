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

class ResourceManager {
    // Just leaving this for me as an example if I ever add more to the Engine.
    // public static var moddedAssetLibrary:AssetLibrary;
}

class Resources {
    /**
     * Retrieve the Bitmap Data from a path.
     * @param path Starts in the `assets/images` directory. Automatically adds the `.png` extension at the end.
     */
    public static function getImage(path:String):FlxGraphic
    {
        var key:String = Path.normalize('assets/images/$path.png');

        var graphic:FlxGraphic;
        graphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(key));
        graphic.persist = true;

        return graphic;
    }

    /**
     * Retrieve Text File Contents from a path.
     * @param path Starts in the `assets` directory. Automatically adds the `.txt` extension at the end.
     * @param txt Define the extension to be used.
     */
    public static function getTxt(path:String, ?ext:String = 'txt'):String
    {
        var key:String = Path.normalize('assets/$path.$ext');

        return Assets.getText(key);
    }

    public static function getSparrowAtlas(fileName:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(getImage('characters/$fileName'), getTxt('images/characters/$fileName', 'xml'));
    }
}

typedef ResourceElementJson = {
    var path:String;
    var type:AssetType;
    var ?library:String;
}