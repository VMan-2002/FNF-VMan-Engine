package;

//this possibly will never exist in html5
import Sys;
import flixel.FlxBasic;
import flixel.FlxSprite;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import sys.io.Process;

enum WallpaperSize {
	Unsized;
	Fill;
	Stretch;
	Fit;
}
class WallpaperInfo {
	public var image:Dynamic;
	public var size:WallpaperSize;
	public var tile:Bool;
}

class DesktopUtil {
	//todo: this
	//also this would require admin permissions (because regedit)

	public static var wallpaperSupported(default, never) = #if (windows) true #else false;
	public static var wallpaperChanged(default, null) = false;
	static final wallpaperInfoName:String = "UserWallpaperInfo_" + #if windows "Windows"; #else "Unknown"; #end

	#if windows
	static final wallpaperKeys = [
		"WallPaper",
		"WallpaperOriginX",
		"WallpaperOriginY",
		"WallpaperStyle",
		"TileWallpaper"
	];
	#end

	public static function setWallpaper(image:Dynamic) {
		if (Std.isOfType(image, WallpaperInfo)) {
			
		} else if (Std.isOfType(image, String)) {

		} else if (Std.isOfType(image, FlxSprite)) {

		} else if (Std.isOfType(image, Bitmap)) {
			
		} else if (Std.isOfType(image, BitmapData)) {
			
		} else {
			trace("Attempted to set wallpaper but type of input is unknown");
		}
		return false;
	}

	public static function resetWallpaper() {
		if (wallpaperChanged) {
			wallpaperChanged = false;
		}
	}

	public static function doNotification(title:String, desc:String, icon:Dynamic) {
		
	}
}