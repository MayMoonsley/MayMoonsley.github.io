function color(r, g, b) {
	return "rgb(" + Math.floor(r) + "," + Math.floor(g) + "," + Math.floor(b) + ")";
}

function LEDScreen(canvas, size, func) {
	this.canvas = canvas;
	this.context = this.canvas.getContext("2d");
	this.size = size;
	//function is the function called to determine cell color. func(x, y, frame)
	this.func = func;
	this.frame = 0;
}

LEDScreen.prototype.render = function() {
	var cellW = this.canvas.width/this.size;
	var cellH = this.canvas.height/this.size;
	this.context.strokeStyle = "#000";
	for (var x=0; x<this.size; x++) {
		for (var y=0; y<this.size; y++) {
			this.context.fillStyle = this.func(x, y, this.frame);
			this.context.fillRect(x * cellW, y * cellH, cellW, cellH);
			this.context.strokeRect(x * cellW, y * cellH, cellW, cellH);
		}
	}
	this.frame++;
}