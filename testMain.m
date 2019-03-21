pitchAngle = 20;
pinionTeeth = 22;
gearTeeth = 60;
diametral = 4;
width = 3.25;
Qv = 6;
St = 32125;
Sc = 109600;

[bendStress, bendEndurance, bendFOS, contactStress, wearEnd, wearFOS] = testingFunction(pinionTeeth,gearTeeth,pinionTeeth,gearTeeth,diametral,diametral,Qv,width,0,0,0,0,0,0,0,0,0.35,0.41,0.35,0.41,pitchAngle,0.331,0.422,0.331,0.422)