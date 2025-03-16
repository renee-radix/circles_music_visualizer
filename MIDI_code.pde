public class MidiReceiver {
  void controllerChange(int channel, int number, int value) {
    
   // knob1 is for tint values for circles
   // knob1a is the speed of the sine waves (can go backwards)
   // knob1b is for transparency of sine waves
   // knob1c is for the background hue
   
    if(number == 14) {
      if(midiMode == 1){
        knob1 = value;
        fadeFact = map(knob1, 0, 127, 0., 10.);
      }
      if(midiMode == 2){
        knob1a = value;
        knob1a = map(knob1a, 0, 127, -0.12, 0.12);
      }
      if(midiMode == 3){
        knob1b = value;
        knob1b = int(map(knob1b, 0, 127, 0, 255));
      }
      if(midiMode == 4){
        knob1c = value;
        knob1c = int(map(knob1c, 0, 127, 0, 360));
      }
    }
    
    // knob2 for circle size 
    // knob2a for line circle transparency
    // knob2b is for hue of first wave
    // knob2c is for background saturation
    
    if(number == 15) {
      if(midiMode == 1){
        knob2 = value;
        knob2 = int(map(knob2, 0, 127, 25, 200));
      }
      if(midiMode == 2){   
        knob2a = value;
        knob2a = int(map(knob2a, 0, 127, 0, 255));
      }
      if(midiMode == 3){
        knob2b = value;
        knob2b = int(map(knob2b, 0, 127, 0, 360));
      }
      if(midiMode == 4){
        knob2c = value;
        knob2c = int(map(knob2c, 0, 127, 0, 100));
      }
    }
    
    // knob3 for circle positioning on z axis
    // knob3a for darkness of lines
    // knob3c for background brightness
    
    if(number == 16) {
      if(midiMode == 1){
        knob3 = value;
        knob3 = int(map(knob3, 0, 127, -100, 200));
      }
        
      //if(midiMode == 2){   REASSIGN
      //  knob3a = value;
      //  knob3a = int(map(knob3a, 0, 127, 50, 255));
      //}
      if(midiMode == 3){
        knob3b = value;
        knob3b = int(map(knob3b, 0, 127, 0, 360));
      }
      if(midiMode == 4){
        knob3c = value;
        knob3c = int(map(knob3c, 0, 127, 0, 100));
      }
    }
    
    if(number == 17) {
      if(midiMode == 1){
        knob4 = value;
        knob4 = int(map(knob4, 0, 127, 0, 360));
      }
      if(midiMode == 2){
        knob4a = value;
        knob4a = int(map(knob4a, 0, 127, 0, 255));
      }
      if(midiMode == 3){
        knob4b = value;
        knob4b = int(map(knob4b, 0, 127, 0, 360));
      }
    }
    //println("Controller Change:");
    //println("--------");
    //println("Channel:"+channel);
    //println("Number:"+number);
    //println("Value:"+value);
  }
  
  void noteOn(int channel, int pitch, int velocity) {
    if(pitch == 36){
      midiMode = 1;
    }
    if(pitch == 38){
      midiMode = 2;
    }
    if(pitch == 42){
      midiMode = 3;
    }
    if(pitch == 46){
      midiMode = 4;
    }
    if(pitch == 48){ //Low C on my midi keyboard
      circlesOn = !circlesOn;
    }
    if(pitch == 50){ //Low D on midi keyboard
      monochromeMode = !monochromeMode;
    }
    if(pitch == 52){ //Low E
      rushTrigger = !rushTrigger;
    }
    
    println(monochromeMode);
  }
}
