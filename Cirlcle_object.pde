class Circle{
  int x;
  int y;
  int z;
  int size;
  int hue;
  int brightness;
  int secondBrightness;
  int saturation;
  float tintVal;
  Boolean fading; 
  int senseTimer;

  
  Circle(){ 
    hue = int(random(360));
    brightness = 0;
    secondBrightness = (int(random(50)) + 50);
    saturation = (int(random(70)) + 30);
    tintVal = 255;
    fading = false;
    x = -200;
    y = -200;
    size = 200;
    senseTimer = sensitivity;
  }
  
  void display(){
    pushMatrix();
    fill(hue, saturation, brightness, tintVal);
    ellipseMode(CENTER); 
    translate(x, y, z);
    ellipse(0, 0, size, size);
    popMatrix();
    if (fading == true){
      tintVal = tintVal - fadeFact;
      brightness = secondBrightness;
      senseTimer--;
    }
    if (tintVal < 0){
      z--;
    }
  }
  
   void fade() {
    x = int(random(width));
    y = int(random(height));
    tintVal = 255;
    fading = true;
    
    if(monochromeMode == false){
      hue = int(registeredPitch % 360); 
    }
    if(monochromeMode == true){
      hue = knob4;
    }
    size = knob2;
    z = knob3;
    senseTimer = sensitivity;
   }
}
