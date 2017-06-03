import java.util.Arrays;
import java.time.Duration;
import java.time.Instant;

PImage img;
String location = "macplus.jpg";
int imgWidth;
int imgHeight;
int kernelsize = 9; 
int kernelwidth = kernelsize/2;
double sigma = 20;
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
    for (int j = 0; j <= i; j++) {
      double val = blur(j - kernelwidth, kernelwidth - i);
      if (i != j) {
        weightmatrix[i][j] = val;
        weightmatrix[j][i] = val;
        sum += 2*val;
      } else {
        weightmatrix[i][j] = val;
        sum += val;
      }
    }
  }
  for (int i = 0; i < kernelsize; i++) {
    for (int j = 0; j < kernelsize; j++) {
      weightmatrix[i][j] /= sum;
    }
  }
}

void setup () {
  if (kernelsize <= 0 || kernelsize % 2 == 0) {
    System.out.println("Please enter a positive odd number for the kernel size! \n Closing in 3 seconds...");
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
    imgWidth = img.width;
    imgHeight = img.height;
    createWM();
  }
  noLoop();
}


void draw() {
  //Instant start = Instant.now();                   // Time calculation
  loadPixels();
  img.loadPixels();
  int lastindex = (imgWidth-1) + (imgHeight-1)*imgWidth;

  for (int x = 0; x < imgWidth; x++) {
    for (int y = 0; y < imgHeight; y++) {
      int loc = x + y*imgWidth;
      boolean xOffscreen = (x - kernelwidth) < 0;
      boolean yOffscreen = (y - kernelwidth) < 0;
      int xoff = loc%imgWidth - kernelwidth;
      int yoff = (loc-kernelwidth*imgWidth)/imgWidth;
      float sumR = 0;
      float sumG = 0;
      float sumB = 0;
      //float sumA = 0;

      for (int i = 0; i < kernelsize; i++) {
        for (int j = 0; j < kernelsize; j++) {
          int index = j + xoff + imgWidth*(i + yoff);
          double matrixVal = weightmatrix[i][j];
          color curColor;
          if (xOffscreen || yOffscreen || index < 0 || index > lastindex) {
            curColor = img.pixels[loc];
          } else {
            curColor = img.pixels[index];
          }
          sumR += matrixVal*(curColor >> 16 & 0xFF);
          sumG += matrixVal*(curColor >> 8 & 0xFF);
          sumB += matrixVal*(curColor & 0xFF);
          //sumA += matrixVal*alpha(curColor);
        }
      }
      pixels[loc] = color(sumR, sumG, sumB); //color(sumR, sumG, sumB, sumA);
    }
  }
  updatePixels();
  save(location.split("\\.")[0] + " blurred.jpg");
  //Instant end = Instant.now();                        // Time calculation
  //println(Duration.between(start, end).toMillis());   // Time calculation
}
