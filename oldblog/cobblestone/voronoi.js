function Point(x, y, c) {
	this.x = x;
	this.y = y;
	this.c = c;
}

Point.prototype.distance = function(x, y) {
	var dx = x - this.x;
	var dy = y - this.y;
	return Math.sqrt(dx * dx + dy * dy);
}

var points = [];
var canvas;
var context;
var compPoint;

function pointsByCloseness(x, y) {
	compPoint = [x, y];
	var r = [];
	for (var i=0; i<points.length; i++) {
		r[i] = new Point(points[i].x, points[i].y, points[i].c);
	}
	r.sort(function(a, b) {
		return a.distance(compPoint[0], compPoint[1]) - b.distance(compPoint[0], compPoint[1]);
	})
	return r;
}

function randColor(min, max) {
	var d = max - min;
	return [Math.floor(min + Math.random() * d), Math.floor(min + Math.random() * d), Math.floor(min + Math.random() * d), 255];
}

function update() {
	points = [];
	var numPoints = document.getElementById("numPoints").value;
	//populate list of points
	for (var i=0; i<numPoints; i++) {
		points[i] = new Point(Math.random() * canvas.width, Math.random() * canvas.height, randColor(0, 128));
	}
	//cull
	var cullDist = document.getElementById("cullDist").value;
	for (var i=0; i<points.length; i++) {
		var list = pointsByCloseness(points[i].x, points[i].y);
		//0th point is the point we're evaluating...
		if (list[1].distance(points[i].x, points[i].y) < cullDist) { //if two points are too close, remove one
			points.splice(i, 1);
			i--;
		}
	}
	//paint
	var data = new Uint8ClampedArray(canvas.width * canvas.height * 4);
	var dist = document.getElementById("dist").value;
	for (var x=0; x<canvas.width; x++) {
		for (var y=0; y<canvas.height; y++) {
			var index = (x + y * canvas.width) * 4;
			var pointList = pointsByCloseness(x, y);
			var chroma;
			if (Math.abs(pointList[0].distance(x, y) - pointList[1].distance(x, y)) < dist) {
				chroma = [200, 200, 200, 255];
			} else {
				chroma = pointList[0].c;
			}
			//stick it in the data
			for (var i=0; i<chroma.length; i++) {
				data[index + i] = chroma[i];
			}
		}
	}
	context.putImageData(new ImageData(data, canvas.width, canvas.height), 0, 0);
}

function init() {
	canvas = document.getElementById("screen");
	context = canvas.getContext("2d");
	context.imageSmoothingEnabled = false;
	update();
}