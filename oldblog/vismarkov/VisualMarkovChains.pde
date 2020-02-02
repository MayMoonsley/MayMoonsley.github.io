float randSign(float x) {
  if (random(2) < 1) {
    return x;
  }
  return x * -1;
}

float avg(int[] arr) {
  float sum = 0;
  for (int i=0; i<arr.length; i++) {
    sum += arr[i];
  }
  return sum/arr.length;
}

float avg(float[] arr) {
  float sum = 0;
  for (int i=0; i<arr.length; i++) {
    sum += arr[i];
  }
  return sum/arr.length;
}

float mad(int[] arr) {
  float mean = avg(arr);
  float[] diffs = new float[arr.length];
  for (int i=0; i<diffs.length; i++) {
    diffs[i] = abs(mean - diffs[i]);
  }
  return avg(diffs);
}

float mad(float[] arr) {
  float mean = avg(arr);
  float[] diffs = new float[arr.length];
  for (int i=0; i<diffs.length; i++) {
    diffs[i] = abs(mean - diffs[i]);
  }
  return avg(diffs);
}

int pixelIndex(int x, int y, int w) {
  return x + y * w;
}

class VisualMarkovNode {
  int[][] vals;
  int pointer, r, g, b;
  
  VisualMarkovNode(int _r, int _g, int _b) {
    this.r = _r;
    this.g = _g;
    this.b = _b;
    this.vals = new int[3][16];
    this.pointer = 0;
    this.addVal(floor(random(256)), floor(random(256)), floor(random(256)));
  }
  
  void addVal(int r, int g, int b) {
    if (this.pointer == this.vals[0].length) {
      this.embiggen();
    }
    this.vals[0][this.pointer] = r;
    this.vals[1][this.pointer] = g;
    this.vals[2][this.pointer] = b;
    this.pointer++;
  }
  
  void embiggen() {
    this.vals[0] = expand(this.vals[0], this.vals[0].length * 2);
    this.vals[1] = expand(this.vals[1], this.vals[1].length * 2);
    this.vals[2] = expand(this.vals[2], this.vals[2].length * 2);
  }
  
  /*color nextVal() {
    float avgR = avg(this.vals[0]);
    float madR = sqrt(mad(this.vals[0]));
    float avgG = avg(this.vals[1]);
    float madG = sqrt(mad(this.vals[1]));
    float avgB = avg(this.vals[2]);
    float madB = sqrt(mad(this.vals[2]));
    
    float newR = abs(avgR + randSign(madR))%256;
    float newG = abs(avgG + randSign(madG))%256;
    float newB = abs(avgB + randSign(madB))%256;
    return color(newR, newG, newB);
  }*/
  
  color nextVal() {
    int index = floor(random(this.pointer));
    return color(this.vals[0][index], this.vals[1][index], this.vals[2][index]);
    
  }
  
  color myVal() {
    return color(this.r, this.g, this.b);
  }
  
}

class VisualMarkov {
  VisualMarkovNode[] nodes;
  int pointer;
  
  VisualMarkov() {
    this.nodes = new VisualMarkovNode[32];
    this.pointer = 0;
  }
  
  int perfectIndex(int r, int g, int b) {
    for (int i=0; i<this.nodes.length; i++) {
      if (this.nodes[i] != null && this.nodes[i].r == r && this.nodes[i].g == g && this.nodes[i].b == b) {
        return i;
      }
    }
    return -1;
  }
  
  int idealIndex(int r1, int g1, int b1) {
    int mindex = -1;
    int mindist = 2000000;
    for (int i=0; i<this.nodes.length; i++) {
      if (this.nodes[i] != null) {
        int curdist = abs(r1 - this.nodes[i].r) + abs(g1 - this.nodes[i].g) + abs(b1 - this.nodes[i].b);
        if (curdist < mindist) {
          mindex = i;
          mindist = curdist;
        }
      }
    }
    return mindex;
  }
  
  color nextFrom(color c) {
    return nextFrom(c >> 16 & 0xFF, c >> 8 & 0xFF, c & 0xFF);
  }
  
  color nextFrom(int r, int g, int b) {
    int index = this.idealIndex(r, g, b);
    return this.nodes[index].nextVal();
  }
  
  void addConnection(color c1, color c2) {
    this.addConnection(c1 >> 16 & 0xFF, c1 >> 8 & 0xFF, c1 & 0xFF, c2 >> 16 & 0xFF, c2 >> 8 & 0xFF, c2 & 0xFF);
  }
  
  void addConnection(int r1, int g1, int b1, int r2, int g2, int b2) {
    this.nodes[idealIndex(r1, g1, b1)].addVal(r2, g2, b2);
  }
  
  void addNode(color c) {
    this.addNode(c >> 16 & 0xFF, c >> 8 & 0xFF, c & 0xFF);
  }
  
  void addNode(int r, int g, int b) {
    if (this.perfectIndex(r, g, b) != -1) {
      return;
    }
    if (this.pointer == this.nodes.length) {
      this.nodes = (VisualMarkovNode[]) expand(this.nodes, this.nodes.length * 2);
    }
    this.nodes[this.pointer] = new VisualMarkovNode(r, g, b);
    this.pointer++;
  } 
  
  void digest(PImage image) {
    if (image == null) {
      return;
    }
    image.loadPixels();
    //load pixel connections
    for (int i=0; i<image.pixels.length; i++) {
      this.addNode(image.pixels[i]);
      if (i%image.width != 0) {
        this.addConnection(image.pixels[i - 1], image.pixels[i]);
      } else {
        println("digesting row " + (i/image.width) + " of " + (image.height) + "...");
      }
    }
    for (int x=0; x<image.width; x++) {
      for (int y=0; y<image.height; y++) {
        int index = x + y * image.width;
        int prev = x + (y - 1) * image.width;
        if (prev >= 0) {
          this.addConnection(image.pixels[prev], image.pixels[index]);
        }
      }
      println("digesting column " + x + " of " + image.width + "...");
    }
    println("image digested.");
  }
  
  PImage generate(int w, int h) {
    PImage r = createImage(w, h, RGB);
    color prev = this.nodes[floor(random(this.pointer))].myVal();
    r.pixels[0] = prev;
    for (int i=1; i<w*h; i++) {
      prev = this.nextFrom(prev);
      r.pixels[i] = prev;
      if (i%w == 0) {
        println("generating row " + i/w + " of " + h + "...");
      }
    }
    println("image generated.");
    r.updatePixels();
    return r;
  }
  
  PImage dripGen(int w, int h) {
    PImage r = createImage(w, h, RGB);
    color prev = this.nodes[floor(random(this.pointer))].myVal();
    r.pixels[0] = prev;
    for (int x=1; x<w; x++) {
      prev = this.nextFrom(prev);
      r.pixels[x] = prev;
      for (int y=1; y<h; y++) {
        prev = r.pixels[(y - 1) * w + x];
        r.pixels[y * w + x] = this.nextFrom(prev);
      }
    }
    r.updatePixels();
    return r;
  }
  
  PImage radialGen(int w, int h) {
    PImage r = createImage(w, h, RGB);
    int centerX = w/2;
    int centerY = h/2;
    color prev = this.nodes[floor(random(this.pointer))].myVal();
    color centerColor = prev;
    r.pixels[centerX + centerY * w] = prev;
    for (float i=0;i<TWO_PI;i+=PI/10000) {
      int x = centerX;
      int y = centerY;
      int d = 0;
      prev = centerColor;
      while (x >= 0 && x < w && y >= 0 && y < h) {
        x = floor(centerX + d * cos(i));
        y = floor(centerY - d * sin(i));
        prev = this.nextFrom(prev);
        if (x + y * w >= r.pixels.length || x + y * w < 0) {
          break;
        }
        r.pixels[x + y * w] = prev;
        d++;
      }
    }
    r.updatePixels();
    return r;
  }
  
  PImage castGen(int w, int h) {
    PImage r = createImage(w, h, RGB);
    int centerX = w/2;
    int centerY = h/2;
    r.updatePixels();
    return r;
  }
  
}

void setup() {
  size(800,200);
  PImage apples = loadImage("geo.png");
  apples.resize(200, 200);
  apples.filter(POSTERIZE, 8);
  VisualMarkov andrey = new VisualMarkov();
  andrey.digest(apples);
  background(0);
  fill(255);
  for (int i=0; i<10; i++) {
    rect(0,0,width * i/float(10),height);
    andrey.generate(400,400).save("generate" + i + ".png");
    andrey.dripGen(400,400).save("dripGen" + i + ".png");
    andrey.radialGen(400,400).save("radGen" + i + ".png");
  }
}