package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

using StringTools;

class StrumNote extends FlxSprite
{
	public var ogScale:Float;
	public var multAlpha(default, set):Float = 1;
	public var shouldChangeAlpha:Bool = false;
	var alphaTimer:FlxTimer;
	var twn:FlxTween;
	var finalTwn:FlxTween;

	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;

	public function new(x:Float, y:Float, leData:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		super(x, y);
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		
		if (alpha < 0)
			alpha = 0;

		if (shouldChangeAlpha)
		{
			alpha += elapsed / 8;
			//multAlpha = alpha;
			if (alpha >= 1)
			{
				alpha = 1;
				shouldChangeAlpha = false;
			}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		if (twn != null)
		{
			twn.cancel();
			twn = null;
		}
		if (twn == null)
		{
			if (finalTwn != null)
			{
				finalTwn.cancel();
				finalTwn = null;
			}
			if (anim != "confirm")
				finalTwn = FlxTween.tween(scale, {y: ogScale}, Conductor.stepCrochet / 200, {ease: FlxEase.expoOut, onUpdate: function(_) {
					centerOffsets();
					offset.y *= scale.y / ogScale;
				}, onComplete: function(twn)
				{
					finalTwn = null;
				}});
		}
		animation.play(anim, force);
		centerOffsets();
		if(animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

			if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
				updateConfirmOffset();
				if (twn == null)
				twn = FlxTween.tween(scale, {y: ogScale * 0.8}, Conductor.stepCrochet / 250, {ease: FlxEase.bounceOut, onUpdate: function(twn)
				{
					updateConfirmOffset();
					//trace(ogScale, scale.y, ogScale - scale.y);
					//offset.y -= Math.abs(scale.y - ogScale) * ((160 * (ogScale)) * FlxG.elapsed);
				}, onComplete: function(_) {
					twn = null;
				}});
			}				
		}
	}

	function updateConfirmOffset() { //TO DO: Find a calc to make the offset work fine on other angles
		centerOffsets();
		offset.x -= 13;
		offset.y -= 13;

		offset.y *= scale.y / ogScale;
	}

	function set_multAlpha(value:Float):Float 
	{
		alpha = value;
		shouldChangeAlpha = false;
		if (alphaTimer != null)
			alphaTimer.cancel();

		alphaTimer = new FlxTimer().start(2.5, (tmr) -> {
			shouldChangeAlpha = true;
		});

		return value;
	}
}
