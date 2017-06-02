import java.util.Arrays;

PImage img;
String location = "papi.jpg";
int kernelsize = 3; 
int kernelwidth = floor((float)(kernelsize)/2);
double sigma = 1;
double[][] weightmatrix = new double[kernelsize][kernelsize];

double blur(int x, int y) {
  double twoSigma_ = 2*sigma*sigma;
  if (x == 0 && y == 0) {
    return 1/(PI*twoSigma_);
  } else {
    double sum = x*x + y*y;
    return (1/(PI*twoSigma_))*Math.exp(-sum/(twoSigma_));
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

      int xoff = loc%width - kernelwidth;
      int yoff = (loc-kernelwidth*width)/width;
      double sumR = 0;
      double sumG = 0;
      double sumB = 0;
      double sumA = 0;

      for (int i = 0; i < kernelsize; i++) {
        for (int j = 0; j < kernelsize; j++) {
          int index = j + xoff + width*(i + yoff);
          if (index < 0 || index > lastindex) {
            continue;
          } else {
            double c = weightmatrix[i][j];
            sumR += c*red(img.pixels[index]);
            sumG += c*green(img.pixels[index]);
            sumB += c*blue(img.pixels[index]);
            sumA += c*alpha(img.pixels[index]);
          }
        }
      }
      pixels[loc] = color(Math.round(sumR), Math.round(sumG), Math.round(sumB), Math.round(sumA));
      //System.out.println(Arrays.deepToString(kernel));    //DON'T RUN WITH THIS UNCOMMENTED UNLESS YOU CHANGE THE X/Y LIMITS ON THE TOP LEVEL FOR LOOPS TO Z TO Z+2 OR A SIMILAR RANGE
    }
  }
  updatePixels();
}
