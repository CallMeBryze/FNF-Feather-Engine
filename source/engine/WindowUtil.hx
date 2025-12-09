package engine;

class WindowUtil {
    public static function calcGameBounds(aspectWidth:Float, aspectHeight:Float, resolution:Int):Array<Int> {
        var height:Int = resolution;
        var width:Int = Math.floor(height * (aspectWidth / aspectHeight));

        return [width, height];
    }
}