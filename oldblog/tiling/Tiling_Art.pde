PImage r;
int scale = 4;
boolean showBorders = true;
boolean showCursor = true;
boolean unsavedEdits = false;
int shade = 4;
int maxShade = 4;
int wash = 0;
int maxWash = 5;
int hue = 0;
color brush = color(0);
color[] palette = new color[] {color(0), color(255, 0, 0), color(255, 128, 0), color(255, 255, 0), color(0, 255, 0), color(0, 255, 255), color(0, 0, 255), color(255, 0, 255), color(128, 0, 128), color(255)};
int[][] paletteNums = new int[][] {{2, 0, 0}, {2, 1, 0}, {2, 2, 0}, {0, 2, 0}, {0, 2, 2}, {0, 0, 2}, {2, 0, 2}};

final char OS_SPECIFIC_SLASH = '/'; //CHANGE THIS IF YOU'RE ON WINDOWS!!!

int sign(float x) {
  if (x > 0) {
    return 1;
  } else if (x < 0) {
    return -1;
  }
  return 0;
}

void setup() {
  size(768, 768);
  noSmooth();
  noFill();
  initImg();
  updateBrush();
}

void draw() {
  background(255);
  pushMatrix();
  scale(scale, scale);
  int xOffset = xOffset();
  int yOffset = yOffset();
  for (int x=0; x<width; x += r.width) {
    for (int y=0; y<height; y += r.height) {
      noFill();
      image(r, x, y);
      if (showBorders) {
        stroke(128);
        rect(x, y, r.width, r.height);
      }
      if (showCursor) {
        noStroke();
        fill(brush);
        rect(x + xOffset, y + yOffset, 1, 1);
      }
    }
  }
  popMatrix();
  fill(brush);
  noStroke();
  rect(8, 8, 24, 24);
}

void initImg() {
  r = createImage(64, 64, RGB);
  for (int i=0; i<r.pixels.length; i++) {
    r.pixels[i] = color(255);
  }
}

int xOffset() {
  return (mouseX/scale)%r.width;
}

int yOffset() {
  return (mouseY/scale)%r.height;
}

int index() {
  return xOffset() + yOffset() * r.width;
}

int index(int x, int y) {
  return x + y * r.width;
}

void floodFill(int x, int y, color start, color fill, boolean dither) {
  while (x < 0) {
    x += r.width;
  }
  while (y < 0) {
    y += r.height;
  }
  x %= r.width;
  y %= r.height;
  int index = index(x, y);
  color there = r.pixels[index];
  if (there != start || there == fill) {
    return;
  }
  if (!dither || x%2 == y%2) {
    r.pixels[index] = fill;
  }
  floodFill(x - 1, y, start, fill, dither);
  floodFill(x + 1, y, start, fill, dither);
  floodFill(x, y - 1, start, fill, dither);
  floodFill(x, y + 1, start, fill, dither);
}

void ditherFill() {
  floodFill(xOffset(), yOffset(), r.pixels[index()], brush, true);
}

void saveImage() {
  unsavedEdits = false;
  r.save(day() + "-" + month() + "-" + year() + "-" + hour() + "-" + minute() + "-" + second() + ".png");
}

void updateBrush() {
  int[] chroma = new int[3];
  int maxBrightness = ceil(shade/float(maxShade) * 255);
  if (wash == maxWash) {
    brush = color(maxBrightness, maxBrightness, maxBrightness);
    return;
  }
  int washNum = ceil(.4 * wash/(float(maxWash) - 1) * maxBrightness);
  for (int i=0; i<3; i++) {
    switch (paletteNums[hue][i]) {
      case 0:
        chroma[i] = washNum;
        break;
      case 1:
        chroma[i] = maxBrightness/2;
        break;
      case 2:
        chroma[i] = maxBrightness;
        break;
    }
  }
  brush = color(chroma[0], chroma[1], chroma[2]);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    r.pixels[index()] = brush;
  } else {
    floodFill(xOffset(), yOffset(), r.pixels[index()], brush, false);
  }
  unsavedEdits = true;
  r.updatePixels();
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    r.pixels[index()] = brush;
  }
  unsavedEdits = true;
  r.updatePixels();
}

void mouseWheel(MouseEvent event) {
  scale = constrain(scale + sign(event.getCount()), 1, 8);
}

void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        shade++;
        if (shade > maxShade) {
          shade = maxShade;
        }
        updateBrush();
        break;
      case DOWN:
        shade--;
        if (shade < 0) {
          shade = 0;
        }
        updateBrush();
        break;
      case LEFT:
        hue--;
        if (hue < 0) {
          hue = paletteNums.length - 1;
        }
        updateBrush();
        break;
      case RIGHT:
        hue++;
        if (hue >= paletteNums.length) {
          hue = 0;
        }
        updateBrush();
        break;
    }
    return;
  }
  switch (key) {
    case '1':
      wash--;
      if (wash < 0) {
        wash = 0;
      }
      updateBrush();
      break;
    case '2':
      wash++;
      if (wash > maxWash) {
        wash = maxWash;
      }
      updateBrush();
      break;
    case 'b':
    case 'B':
      showBorders = !showBorders;
      break;
    case 'c':
    case 'C':
      showCursor = !showCursor;
      break;
    case 'd':
    case 'D':
      ditherFill();
      r.updatePixels();
      unsavedEdits = true;
      break;
    case 's':
    case 'S':
      saveImage();
      break;
    case 'n':
    case 'N':
      if (unsavedEdits) {
        saveImage();
      }
      initImg();
      break;
  }
}