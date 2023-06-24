//todo: Apparently not all of this works
var fastCar;
var fastCarCanDrive = true;

function resetFastCar(?tmr) {
	fastCar.x = -12600;
	fastCar.y = FlxG.random.float(140, 250);
	fastCar.visible = false;
	fastCar.moves = false;
	fastCarCanDrive = true;
}

function fastCarDrive() {
	FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);
	fastCar.velocity.x = (FlxG.random.float(510, 660) / FlxG.elapsed);
	fastCar.visible = true;
	fastCar.moves = true;
	fastCarCanDrive = false;
	new FlxTimer().start(2, resetFastCar);
}

function beatHit() {
	if (Math.random() <= 0.1 && fastCarCanDrive) {
		fastCarDrive();
	}
}

function stageInit(name, mod, stage) {
	if (name == "newlimo") {
		fastCar = stage.elementsNamed["fastCar"];
	}
}