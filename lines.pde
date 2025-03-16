void soundLineHor(float startX, float startY, float minLength, float maxLength, int directionality){
  float scaledLoudness = loudness * 1;
  float longness = map(scaledLoudness, 0, 100, minLength, maxLength) * directionality;
  stroke(255, knob4a);
  line(startX, startY, startX + longness, startY);
}

void soundLineVer(float startX, float startY, float minLength, float maxLength, int directionality){
  float scaledLoudness = loudness * 1;
  float longness = map(scaledLoudness, 0, 100, minLength, maxLength) * directionality;
  stroke(255, knob4a);
  line(startX, startY, startX, startY + longness);
}

void soundLineDiag(float startX, float startY, float minLength, float maxLength, int xDirectionality, int yDirectionality){
  float scaledLoudness = loudness * 1;
  float longness = map(scaledLoudness, 0, 100, minLength, maxLength);
  stroke(255, knob4a);
  float newX = startX + (longness * xDirectionality);
  float newY = startY + (longness * yDirectionality);
  line(startX, startY, newX, newY);
}

/*
startX and startY are where the lines begin on the X and Y axis respectively
minLength is the length of the line with no audio input, maxLength is length of the line with full audio input
directionality is which direction the line is heading in. It should be either -1 or 1, either down and to the right for positive or up and to the left for negative.
xDirectionality and yDirectionality are the same, just offering more detail for diagonal lines


*/
