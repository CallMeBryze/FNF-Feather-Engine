package objects.editor;

import flixel.addons.ui.FlxUINumericStepper;

class NumericStepper extends FlxUINumericStepper {
    public var onValueChanged:Float->Void;

    override private function _onPlus():Void {
        super._onPlus();

		if (onValueChanged != null)
            onValueChanged(this.value);
    }

	override private function _onMinus():Void
	{
		super._onMinus();

        if (onValueChanged != null)
		    onValueChanged(this.value);
	}
}