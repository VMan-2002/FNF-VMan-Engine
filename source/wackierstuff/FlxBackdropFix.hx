package wackierstuff;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

//https://github.com/HaxeFlixel/flixel-addons/pull/358
class FlxBackdropFix extends FlxBackdrop {
	override public function draw():Void {
		var isColored:Bool = (alpha != 1) || (color != 0xffffff);
		var hasColorOffsets:Bool = (colorTransform != null && (colorTransform.redOffset != 0 || colorTransform.greenOffset != 0 || colorTransform.blueOffset != 0 || colorTransform.alphaOffset != 0));
		for (camera in cameras) {
			if (!camera.visible || !camera.exists)
				continue;
			var ssw:Float = _scrollW * Math.abs(scale.x);
			var ssh:Float = _scrollH * Math.abs(scale.y);
			// Find x position
			if (_repeatX) {
				_ppoint.x = ((x - offset.x - camera.scroll.x * scrollFactor.x) % ssw);
				if (_ppoint.x > 0)
					_ppoint.x -= ssw;
			} else {
				_ppoint.x = (x - offset.x - camera.scroll.x * scrollFactor.x);
			}
			// Find y position
			if (_repeatY) {
				_ppoint.y = ((y - offset.y - camera.scroll.y * scrollFactor.y) % ssh);
				if (_ppoint.y > 0)
					_ppoint.y -= ssh;
			} else {
				_ppoint.y = (y - offset.y - camera.scroll.y * scrollFactor.y);
			}
			// Draw to the screen
			if (FlxG.renderBlit) {
				if (graphic == null)
					return;
				if (dirty)
					calcFrame(useFramePixels);

				_flashRect2.setTo(0, 0, graphic.width, graphic.height);
				camera.copyPixels(frame, framePixels, _flashRect2, _ppoint, colorTransform, blend, antialiasing, shader);
			} else {
				if (_tileFrame == null)
					return;

				var drawItem = camera.startQuadBatch(_tileFrame.parent, isColored, hasColorOffsets, blend, antialiasing, shader);

				_tileFrame.prepareMatrix(_matrix);

				var scaleX:Float = scale.x;
				var scaleY:Float = scale.y;
				if (useScaleHack) {
					scaleX += 1 / (_tileFrame.sourceSize.x * camera.totalScaleX);
					scaleY += 1 / (_tileFrame.sourceSize.y * camera.totalScaleY);
				}
				_matrix.scale(scaleX, scaleY);
				var tx:Float = _matrix.tx;
				var ty:Float = _matrix.ty;
				for (j in 0..._numTiles) {
					var currTileX = _tileInfo[j * 2];
					var currTileY = _tileInfo[(j * 2) + 1];
					_matrix.tx = tx + (_ppoint.x + currTileX);
					_matrix.ty = ty + (_ppoint.y + currTileY);
					drawItem.addQuad(_tileFrame, _matrix, colorTransform);
				}
			}
		}
	}
}