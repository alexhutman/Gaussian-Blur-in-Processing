
PImage img;
String location = "papi.jpg";
int kernelsize = 3;
int kernelwidth = floor((float)(kernelsize)/2);
double sigma = 1.5;
double[][] weightmatrix = new double[kernelsize][kernelsize];

double blur(int x, int y) {
  double twoSigma_ = 2*sigma*sigma;
  if (x == 0 && y == 0) {
    return 1/(PI*twoSigma_);
  } else {
    double sum = x*x + y*y;
    return (1/(PI*twoSigma_))*Math.pow(Math.E, -sum/(twoSigma_));
  }
}

void createWM() {
  double sum = 0;
  for (int i = 0; i < kernelsize; i++) {
    for (int j = 0; j < kernelsize; j++) {
      weightmatrix[i][j] = blur(j - kernelwidth, kernelwidth - i);
      sum =+ weightmatrix[i][j];
    }
  }
  for (int i = 0; i < kernelsize; i++) {
    for (int j = 0; j < kernelsize; j++) {
      weightmatrix[i][j] /= sum;
    }
  }
}

void setup () {
  if (kernelsize % 2 == 0) {
    System.out.println("Please enter an odd number for the kernel size! \n Closing in 3 seconds...");
    try {
      Thread.sleep(3000);
      System.exit(0);
    }
    catch (InterruptedException ex) {
      Thread.currentThread().interrupt();
    }
  } else {
    img = loadImage(location);
    surface.setSize(img.width, img.height);
    createWM();
  }
}


void draw() {
  loadPixels();
  img.loadPixels();
  int lastindex = (width-1) + (height-1)*width;

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int loc = x + y*width;
      double kernel[][][] = new double [kernelsize][kernelsize][3];

      int xoff = loc%width - kernelwidth;
      int yoff = (loc-kernelwidth*width)/width;
      double sumR = 0;
      double sumG = 0;
      double sumB = 0;

      for (int i = 0; i < kernelsize; i++) {
        for (int j = 0; j < kernelsize; j++) {
          int index = j + xoff + width*(i + yoff);
          if (index < 0 || index > lastindex) {
            kernel[i][j][0] = 0.0;
            kernel[i][j][1] = 0.0;
            kernel[i][j][2] = 0.0;
          } else {
            sumR += weightmatrix[i][j]*red(img.pixels[index]);
            sumG += weightmatrix[i][j]*green(img.pixels[index]);
            sumB += weightmatrix[i][j]*blue(img.pixels[index]);
          }
        }
      }
      pixels[loc] = color(Math.round(sumR), Math.round(sumG), Math.round(sumB));
    }
  }
  updatePixels();
}
