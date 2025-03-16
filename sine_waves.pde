class SineWave{
float theta; // Start of angle
float amplitude;  // Height of wave
float period;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave

  SineWave(float start, float freq){
    theta = start;
    period = freq;
    dx = (TWO_PI / period) * xspacing;
    yvalues = new float[w/xspacing];
  }

  void sineWaveCalc(float amp) {
    theta += knob1a;
    amplitude = amp;
    float x = theta;
    for (int i = 0; i < yvalues.length; i++) {
      yvalues[i] = sin(x)*amplitude;
      x+=dx;
    }
  }

  void renderSineWave(color c, int trans) {
    noStroke();
    colorMode(HSB, 360, 100, 100);
    fill(c, trans);
    // A simple way to draw the wave with an ellipse at each location
    for (int x = 0; x < yvalues.length; x++) {
      ellipse(x*xspacing, height/2+yvalues[x], 16, 16);
    }
  }
}
