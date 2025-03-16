/* 
Circles by Renee Radix, Dec 8th 2024

Concept: Multiple layers of sound interactive art that can be triggered in to work together or independently.
Requires midi input to work, needs input from midi CCs 14-17 and midi notes 36, 38, 42, 46, 48, 50 and 52

Project works with current audio input source as set up by your computer 
(on a mac it's just whatever's in the settings, not sure how windows audio works, for linux you could probably use jack)
no audio output needed. 

The midi CC values are set to control different things depending on what the last midi note entered was, flipping between midi modes (since my controller has only 4 knobs)
Midi note 36 triggers midi mode 1, note 38 triggers mode 2, note 42 triggers mode 3 and note 46 mode 4
Different layers can be brought in and out with midi notes and CC values.

- When you load up the patch you'll see a bare minimum of lines that change size with sound. Their transparency is changed with CC 17 on mode 2
- In a similar style to the lines there are some static circles that can be brought in by turning up CC 15 on mode 2

- Pressing note 48 brings in some coloured circles that appear when there's a sound input and slowly fade. 
On midi mode 1 the time it takes for them to fade is controlled by CC 14, the size CC 15 and positioning on the Z axis CC 16.
The colours of the circles tracks the incoming pitch. As you go up in pitch the circles will cycle through hue values.
Pressing midi note 50 turns them to "monochrome mode" so that the hue is controlled by CC 17 on mode 1.
Pressing midi note 52 turns on "rush mode", so there is no gap between when each circle is triggered to appear, creating a bunch of circles all at once. 

- There are also some cool sine waves made out of circles that can be made visible using CC 14 on midi mode 3. Their hue values can be changed with CCs 15-17 on mode 3
Their speed can be changed with CC 14 on mode 2

- The H, S and B values of the background can be changed with CCs 14, 15 and 16 respectively on midi mode 4.

Cheat sheet:

Mode 1 (triggered by note 36/default):
14: Coloured circle fade time
15: Coloured circle size
16: Coloured circle Z axis positioning 
17: Coloured circle hue on monochrome mode

Mode 2 (triggered by note 38):
14: Speed of sine wave oscilation
15: Transparency for line circles
17: Transparency for lines

Mode 3 (triggered by note 42):
14: Sine waves transparency
15: Hue of first sine wave
16: Hue of second sine wave
17: Hue of third sine wave

Mode 4 (triggered by note 46):
14: Background hue
15: Background saturation
16: Background brightness

*/
import themidibus.*; 
import processing.sound.*;

//Midi variables 
MidiBus myBus;
MidiReceiver receiver = new MidiReceiver();

// MIDI mode 1 (circles):
int knob1; // for circle tint value
int knob2 = 200; // for circle size
int knob3; //circle positioning on z axis
int knob4 = 0; //circle hues on monochrome mode

// MIDI mode 2 (lines etc):
float knob1a = 0.02; //sine wave oscilation rate
int knob2a = 0; //transparency for line circles
//int knob3a = 75; // currently this doesn't do anything
int knob4a = 255; //transparency for lines

// MIDI mode 3 (sine waves):
int knob1b = 0; //transparency for waves
int knob2b = 291; //h value for first wave
int knob3b = 265; //h value for second wave
int knob4b = 61; //h value for third wave

// MIDI mode 4
int knob1c = 0; //background H
int knob2c = 0; //background S
int knob3c = 0; //background B

// toggling between two MIDI modes
int midiMode = 1;

// triggered with MIDI note 46, or pad P4
boolean rushTrigger = false;

// Audio variables
AudioIn in;
Amplitude amp;
PitchDetector pitchDect;
float inputLevel = 1; // change this to make microphone more or less sensitive. 1 is full volume, anything less than that attenuates it. Use this if sax comes in too hot 
float loudness;
float registeredPitch;
float pitchLow = 78;
float pitchHigh = 1160; // might need to adjust these depending on how they work with the sax
int loudnessThreshold = 20;
boolean soundDetected = false; // flips when loudness threshold is passed

int sineLoudness;


// Circles
Circle[] circles;
int tintVals = 255;
int clickCount = 0;
int beatCount = 0;
float fadeFact = 1;
int sensitivity; 
int origSensitivity = 10; // value exists to create pauses between each circle display triggering, increase or decrease it to change the pause. This values is fixed, sensitivity can change
int circleArrayAmt = 500; //change if you want the array to be bigger or smaller for some reason
boolean circlesOn = false; //Trigers circles on and off. Low C on keyboard
boolean monochromeMode = false; //Low D on keyboard. Makes circles all one colour, determined by knob3


//variables for the sine wave art
int xspacing = 16;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave (set automatically depending on size of the screen)

//sine waves themselves (add more if you want)
SineWave w1;
SineWave w2;
SineWave w3;

//colors for the sine waves
color w1c; 
color w2c;
color w3c;

//Z value for line circles, so they can be pushed to the back if they get too dim
int circleZ = 0;

void setup (){
  //size(800, 800, P3D);  
  fullScreen(P3D); //Swap this with size if you want to see it in full screen
  
  // Setting up variables for classes
  // MIDI:
  myBus = new MidiBus(receiver, 1, -1);
  
  // Circles
  circles = new Circle[circleArrayAmt];
  for(int i = 0; i < circleArrayAmt; i++){
    circles[i] = new Circle();
  }
  
  sensitivity = origSensitivity;
  
  // Sound
  pitchDect = new PitchDetector(this);
  pitchDect.input(new AudioIn(this, 0));
  in = new AudioIn(this, 0);
  in.start();
  amp = new Amplitude(this);
  amp.input(in); 
  
  // Setting the w variable for the sine waves to be in conujunction with the width of the screen
  w = width+16;
  
  // Waves
  w1 = new SineWave (0.0, 200.0);
  w2 = new SineWave (4.0, 200.0);
  w3 = new SineWave (5.0, 200.0);
  
}

void draw () {
  colorMode(HSB, 360, 100, 100);
  background(knob1c, knob2c, knob3c);
  noStroke();
  
  //initializing the circles, they're all invisible and offscreen
  for(int i = 0; i < circleArrayAmt; i++){
    circles[i].display();
  }
  //reset beat count if it gets too high (offsett by 10 is just in case it's too rapid entry so we don't get a null pointer error)
  if(beatCount > circleArrayAmt - 10){
    beatCount = 0;
  }
  circles[0].senseTimer = -1; // this was being a pain so I "moved it out of the way"
  
  if (rushTrigger == true){
    sensitivity = 0;
  }
  if (rushTrigger == false){
    sensitivity = origSensitivity;
  }
  
  // begins analyzing the amplitude of in, returning a number between 0 and 1
  in.amp(inputLevel);
  
  //Amplitude.analyze() should return a number between 0 and 1. for the laptop speakers it seems like it tops out at .5 which is why the range is only 0 to 0.5   
  float levels = constrain(amp.analyze(), 0.1, 0.5);
  loudness = map(levels, 0.1, 0.5, 20, 100); // current numbers for line in guitar
 
  // i.e. if the scaled amplitude crosses the threshold and it's been enough time, move the array index along one step and draw a circle   
  if (loudness > loudnessThreshold && circles[beatCount].senseTimer < 0 && circlesOn == true) {
    beatCount++; 
    circles[beatCount].fade();
  }
  // PitchDetector.analyze() returns 2 variables when in array mode, the pitch in hz and the confidence in a float between 0 and 1
  float[] pitchAndConfidence = new float[2];
  pitchDect.analyze(pitchAndConfidence);
  
  // if the pitch that comes in for whatever we just got is read at enough certainty store it in registeredPitch variable which is used to change the hue of the circle
  if (pitchAndConfidence[1] > 0.8){ //adjust the float value to adjust how sensitive the pitch shifting is to change (number between 0 and 1). note lower number for lower pitches, since those are harder to detect
    registeredPitch = pitchAndConfidence[0];
  }

  // draw the sound reactive lines in a square
  soundLineHor(width/8, height/2, 50, 200, 1);
  soundLineHor(((width/8) * 7), height/2, 50, 200, -1);
  
  soundLineVer(width/2, height/8, 50, 200, 1);
  soundLineVer(width/2, ((height/8) * 7), 50, 200, -1);
  
  soundLineDiag(width/6, height/6, 50, 200, 1, 1);
  soundLineDiag((width/6) * 5, height/6, 50, 200, -1, 1);
  soundLineDiag(width/6, (height/6) * 5, 50, 200, 1, -1);
  soundLineDiag((width/6) * 5, (height/6) * 5, 50, 200, -1, -1);
  
  strokeWeight(5);
  line((width/3) * 2, height/7, (width/2.5) * 1.5, height/3.5);
  line(width/3, height/7, width/2.5, height/3.5);
  line((width/3) * 2.1, height/1.15, (width/2.5) * 1.5, height/1.45);
  line(width/3, height/1.15, width/2.5, height/1.45);
  
  // throw in the sine waves
  
  // color variables for the waves (in draw code so that the knob value can be updated)
  colorMode(HSB, 360, 100, 100);
  w1c = color(knob2b, 72, 75);
  w2c = color(knob3b, 72, 75);
  w3c = color(knob4b, 72, 75);
  
  
 sineLoudness = int(map(loudness, 0, 100, 50, height/3));
  
  // sineWaveCalc just takes the height (amplitude) of the waves, in pixels
  w1.sineWaveCalc(sineLoudness);
  w2.sineWaveCalc(sineLoudness);
  w3.sineWaveCalc(sineLoudness);
  
  //renderSineWave takes the colour of the wave and a transparency value (0-255)
  w1.renderSineWave(w1c, knob1b);
  w2.renderSineWave(w2c, knob1b);
  w3.renderSineWave(w3c, knob1b);
  
  if(knob2a > 10){
    noFill();
    stroke(knob2a);
    ellipseMode(CENTER);
    pushMatrix();
    translate(width/2, height/2, circleZ);
    ellipse(0, 0, loudness, loudness);
    popMatrix();
    
    pushMatrix();
    translate((width/10) * 9, (height/10) * 9, circleZ);
    ellipse(0, 0, loudness, loudness);
    popMatrix();
    
    pushMatrix();
    translate(width/10, height/10, circleZ);
    ellipse(0, 0, loudness, loudness);
    popMatrix();
    
    pushMatrix();
    translate(width/10, (height/10) * 9, circleZ);
    ellipse(0, 0, loudness, loudness);
    popMatrix();
    
    pushMatrix();
    translate((width/10) * 9, height/10, circleZ);
    ellipse(0, 0, loudness, loudness);
    popMatrix();
  }
  
  if(knob2a < 10){
    circleZ = -500;
  }else{
    circleZ = 0;
  }
}

// Test with sax one more time, otherwise it's done
