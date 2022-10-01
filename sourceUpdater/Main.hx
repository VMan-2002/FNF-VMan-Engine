package;

import Reflect;
import Sys;
import flixel.math.FlxMath;
import haxe.Http;
import haxe.Json;
import haxe.Timer;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.net.URLStream;
import openfl.text.TextField;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef GamebananaFileResult = {
	_sFile:String,
	_tsDateAdded:Int,
	_sDownloadUrl:String,
	_bContainsExe:Bool
}

class Main extends Sprite
{
	#if (debug && !html5)
	public static var debug:debugger.Local;
	#end
	var textThing = new TextField();
	var titleText = new TextField();
	
	var defaultModContentFolders:Array<String> = [
		"data",
		"images",
		"songs"
	];

	public static function main():Void
	{
		#if (debug && !html5)
		debug = new debugger.Local(false);
		#end
		
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	var launchFolder:String;
	public function getPath(p:String) {
		return launchFolder + p;
	}
	
	var triedProtocolInstall = false;

	private function init(?E:Event):Void
	{
		addChild(titleText);
		titleText.background = true;
		titleText.text = "Initializing...";
		titleText.width = 1000;
		titleText.height = 30;

		addChild(textThing);
		textThing.background = true;
		textThing.width = 1000;
		textThing.height = 30;
		textThing.y = 40;
		
		launchFolder = Sys.programPath().substr(0, Sys.programPath().lastIndexOf("\\"))+"\\";
		trace("Launch folder: "+launchFolder);
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		trace("Checking if browser protocol is installed");
		var protocolName = "fnfvmanengine";
		if (FileSystem.exists(getPath("PsychEngine.exe"))) {
			protocolName = "psychinstall";
		}
		trace("Using protocol: "+protocolName);
		var protocolCheck = new sys.io.Process("reg query HKCR\\"+protocolName+"").stdout.readAll().toString();
		if (protocolCheck.contains("URL:"+protocolName+" Protocol") && protocolCheck.contains("URL Protocol")) {
			trace("Browser protocol is installed");
		} else if (!triedProtocolInstall) {
			triedProtocolInstall = true;
			trace("Browser protocol is NOT installed, try install");
			//var msgbox = new MessageBox();
			//todo: wtf am i doning
			/*msgbox.title = "Info";
			msgbox.text = "The browser protocol is not installed. If installed,\nyou can download mod packs using special links on GameBanana pages.\n\nInstall the browser protocol?";
			msgbox.type = TYPE_YESNO;
			msgbox.onDialogClosed = function(evnt) {
				if (evnt == DialogButton.YES) {*/
					var elevateCheck = new sys.io.Process("net file").stdout.readAll().toString().toLowerCase().contains("access is denied");
					if (!elevateCheck) {
						trace(Sys.programPath());
						var commands = [
							"HKCR\\"+protocolName+" /d \"URL:"+protocolName+" Protocol\"",
							"HKCR\\"+protocolName+" /v \"URL Protocol\"",
							"HKCR\\"+protocolName+"\\shell",
							"HKCR\\"+protocolName+"\\shell\\open",
							"HKCR\\"+protocolName+"\\shell\\open\\command /d \"\\\""+Sys.programPath()+"\\\" \\\"%1\\\"\""
						];
						trace("running cmds");
						for (cmd in commands) {
							trace("reg add "+cmd);
							new sys.io.Process("reg add "+cmd);
						}
						trace("Attempted installing the protocol");
					} else {
						//var msgbox = new MessageBox();
						//msgbox.title = "Info";
						//msgbox.text = "Please run as administrator first";
						trace("Please run as administrator to install the browser protocol");
						textThing.text = "Please run as administrator to install the browser protocol";
						stage.invalidate();
						//init();
					}
			//	}
			//};
			
			return;
		}

		trace("Updater");
		var launchArgs = Sys.args().join(" ");
		trace(launchArgs);
		
		if (launchArgs.startsWith(protocolName+"://")) {
			trace("Got browser protocol url");
			var thingToDo = launchArgs.split("/").slice(2);
			switch(thingToDo.shift()) {
				case "install_gb":
					trace("Install from GameBanana");
					var url = 'https://api.gamebanana.com/Core/Item/Data?itemtype=Mod&itemid=${thingToDo[0]}&fields=Files().aFiles(),name';
					trace(url);
					var req = new Http(url);
					req.onData = function(data:String) {
						trace(data);
						var parsedStuff:Array<Dynamic> = cast Json.parse(data);
							var itemName:String = cast parsedStuff[1];
							title = 'Downloading mod: '+itemName;
						trace(title);
						titleText.text = title;
						for (thingId in Reflect.fields(parsedStuff[0])) {
							var thing:GamebananaFileResult = cast Reflect.field(parsedStuff[0], thingId);
							if (thing._sFile.endsWith(".zip")) {
								if (thing._bContainsExe) {
									trace("The file being downloaded contains a .exe file. It will still be downloaded, but you should check it's contents.");
								}
								return downloadModFile(thing._sDownloadUrl, thing._sFile);
							}
						}
						trace("Couldn't find a .zip file to download.");
					};
					req.request(false);
				case "feri":
					var req = new URLRequest("https://static.wikia.nocookie.net/advendure-plantoids/images/1/12/FeriAzazel3Art.png?format=original");
					req.contentType = "image/png";
					var loader = new URLLoader();
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					loader.load(req);
					loader.addEventListener(Event.COMPLETE, function(dat:Event) {
						File.saveBytes(getPath("feri.png"), dat.target.data);
					});
				default:
					trace("Dunno what to do. Launch arguments are "+launchArgs);
					textThing.text = "Dunno what to do. Launch arguments are "+launchArgs;
			}
			return;
		}
		Sys.exit(0);
	}
	
	var title:String = "Updater";
	
	inline function ensureModsFolder() {
		if (!FileSystem.exists(getPath("mods")) || !FileSystem.isDirectory(getPath("mods"))) {
			FileSystem.createDirectory(getPath("mods"));
		}
	}
	
	function downloadFile(url:String, result:String, contentType:String) {
		trace("Attempting download of "+url);
		var uncompress:Void->Void = function() {
			textThing.text = "Download Finished, extracting now...";
			stage.invalidate();
			Timer.delay(function() {
				var folder = result.substr(0, result.length - 4);
				unzip(getPath(result), getPath(folder));
				ensureModsFolder();
				var items = FileSystem.readDirectory(getPath(folder));
				var cnt = 0;
				var bypass = false;
				var movefolder = folder;
				var targetfolder = folder;
				for (item in items) {
					if (FileSystem.isDirectory(getPath(folder+"/"+item))) {
						cnt++;
						if (defaultModContentFolders.contains(item)) {
							bypass = true;
							break;
						}
						if (FileSystem.exists(getPath(folder+"/"+item+"/data"))) {
							movefolder = folder+"/"+item;
							targetfolder = item;
						}
					} else if (item == "pack.json") {
						bypass = true;
						break;
					}
				}
				if (cnt > 6 || bypass) {
					movefolder = folder;
					targetfolder = folder;
				}
				targetfolder = getPath("mods/"+targetfolder);
				trace("Move "+movefolder);
				if (FileSystem.exists(targetfolder) && FileSystem.isDirectory(targetfolder)) {
					trace("The target folder already exists");
					textThing.text = "The target folder already exists";
					stage.invalidate();
					return;
				} else {
					FileSystem.rename(getPath(movefolder), targetfolder);
				}
				folder = getPath(folder);
				if (FileSystem.exists(folder) && FileSystem.isDirectory(folder) && FileSystem.readDirectory(folder).length == 0) {
					FileSystem.deleteDirectory(folder);
				}
				Sys.exit(0);
			}, 1);
		}
		if (!FileSystem.exists(getPath(result))) {
			var reader = new URLStream();
			var writer = File.append(getPath(result), true);
			var req = new URLRequest(url);
			req.contentType = contentType;
			/*var waits = 20;
			while (!reader.connected && reader.bytesAvailable <= 0) {
				trace("Waiting... "+waits);
				Sys.sleep(0.5);
				waits--;
				if (waits < 0) {
					trace("Timed out");
					return false;
				}
			}*/
			textThing.text = "Waiting to start download...";
			stage.invalidate();
			reader.addEventListener(Event.OPEN, function(ev) {
				trace("Download started");
			});
			var downProg:Void->Void = function() {
				var bytes = new ByteArray(64);
				var readAmount:Int;
				var pos:Int = 0;
				while (reader.bytesAvailable > 0 || reader.connected) {
					readAmount = reader.bytesAvailable >= 64 ? 64 : reader.bytesAvailable;
					reader.readBytes(bytes, pos, readAmount);
					writer.writeBytes(bytes, pos, readAmount);
					pos += readAmount;
					//trace(reader.bytesAvailable + " bytes left.");
				}
			}
			reader.addEventListener(ProgressEvent.PROGRESS, function(ev) {
				downProg();
				textThing.text = "Download progress: "+FlxMath.roundDecimal((ev.bytesLoaded / ev.bytesTotal) * 100, 2)+"%";
				stage.invalidate();
				if (ev.bytesTotal > 0) {
					trace("Download progress: "+FlxMath.roundDecimal((ev.bytesLoaded / ev.bytesTotal) * 100, 2)+"%");
				} else {
					trace("Download progress");
				}
			});
			reader.addEventListener(Event.COMPLETE, function(ev) {
				downProg();
				trace("Download Finished");
				reader.close();
				writer.close();
				uncompress();
			});
			reader.load(req);
		} else {
			trace("File already exists");
			uncompress();
		}
		return true;
	}
	
	inline function downloadModFile(url:String, result:String) {
		downloadFile(url, result, "zip");
	}
	
	//https://gist.github.com/ruby0x1/8dc3a206c325fbc9a97e
	public static function unzip( _path:String, _dest:String, ignoreRootFolder:String = "" ) {

		var _in_file = sys.io.File.read( _path );
		var _entries = haxe.zip.Reader.readZip( _in_file );

			_in_file.close();

		for(_entry in _entries) {
			
			var fileName = _entry.fileName;
			if (fileName.charAt (0) != "/" && fileName.charAt (0) != "\\" && fileName.split ("..").length <= 1) {
				var dirs = ~/[\/\\]/g.split(fileName);
				if ((ignoreRootFolder != "" && dirs.length > 1) || ignoreRootFolder == "") {
					if (ignoreRootFolder != "") {
						dirs.shift ();
					}
				
					var path = "";
					var file = dirs.pop();
					for( d in dirs ) {
						path += d;
						sys.FileSystem.createDirectory(_dest + "/" + path);
						path += "/";
					}
				
					if( file == "" ) {
						if( path != "" ) trace("created " + path);
						continue; // was just a directory
					}
					path += file;
					trace("unzip " + path);
				
					var data = haxe.zip.Reader.unzip(_entry);
					var f = File.write (_dest + "/" + path, true);
					f.write(data);
					f.close();
				}
			}
		} //_entry

		Sys.println('');
		Sys.println('unzipped successfully to ${_dest}');

	} //unzip
}
