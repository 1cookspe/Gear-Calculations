% % Client to test different configurations
clear all;


% Testing gear stuff
% GearRatioCalc(55,575)

% 4 and 5 gear ratios

%% grade 1 material steel
% 20 diametral pitch
% 20 tooth steel with 100 tooth iron, 20 tooth steel with 80 iron
setSteel_20_1 = [20,100,20,80,20,20,10,0.50,1,2,1,2,0.34,0.43,0.335,0.42,20];
setSteel_20_2 = [20,80,20,100,20,20,10,0.50,1,2,1,2,0.335,0.42,0.34,0.43,20];
% 16 tooth steel with 70 tooth steel, 16 tooth steel with 70 tooth steel
setSteel_20_3 = [16,70,16,70,20,20,10,0.50,1,1,1,1,0.27,0.41,0.27,0.41,20];

% 16 diametral pitch
setSteel_16_1 = [16,64,16,80,16,16,10,0.750,1,1,1,1,0.27,0.41,0.27,0.41,20];
setSteel_16_2 = [16,80,16,64,16,16,10,0.750,1,1,1,1,0.27,0.41,0.27,0.41,20];
setSteel_16_3 = [20,80,16,80,16,16,10,0.750,1,1,1,1,0.335,0.42,0.27,0.41,20];
setSteel_16_4 = [16,80,20,80,16,16,10,0.750,1,1,1,1,0.27,0.41,0.335,0.42,20];

% 10 diametral pitch
setSteel_10_1 = [16,70,16,70,10,10,10,1.250,1,2,1,2,0.27,0.41,0.27,0.41,20];
setSteel_10_2 = [20,80,20,100,10,10,10,1.250,1,2,1,2,0.335,0.42,0.27,0.41,20];
setSteel_10_3 = [20,100,20,80,10,10,10,1.250,1,2,1,2,0.27,0.41,0.335,0.42,20];

% 8 diametral pitch
setSteel_8_1 = [16,80,16,64,10,10,10,1.50,1,2,1,2,0.27,0.42,0.27,0.41,20];
setSteel_8_2 = [16,80,16,64,10,10,10,1.50,1,2,1,2,0.27,0.41,0.27,0.42,20];

%% cast iron


%% set up array
array = [setSteel_20_1; setSteel_20_2; setSteel_20_3; setSteel_16_1; setSteel_16_2; setSteel_16_3; setSteel_16_4; setSteel_10_1; setSteel_10_2; setSteel_10_3; setSteel_8_1; setSteel_8_2];

%% run through each configuration
% every row is a config

% 16 pinion to 64 gear, 16 pinion to 64 gear
% all steel

for i = 1:(size(array,1))
    
    [bendingStress, currentEndStrength, currentFOSBend, contactStress, currentWearStrength, currentFOSContact] = gearAnalysis(array(i,1), array(i,2), array(i,3), array(i,4), array(i,5), array(i,6), array(i,7), array(i,8), array(i,9), array(i,10), array(i,11), array(i,12), array(i,13), array(i,14), array(i,15), array(i,16), array(i,17));
    
    if(i==1) 
        results = [currentFOSBend, currentFOSContact, currentEndStrength, currentWearStrength];
        FOSGraph = [min(currentFOSBend), min(currentFOSContact)]
    else
        results = [results; [currentFOSBend, currentFOSContact, currentEndStrength, currentWearStrength]];
        FOSGraph = [FOSGraph; [min(currentFOSBend), min(currentFOSContact)]]
    end
        
    
    


end



setNames = {'Concept 1'; 'Concept 2'; 'Concept 2'; 'Concept 2'; 'Concept 2'; 'Concept 2'; 'Concept 2'; 'Concept 2'; 'Concept 2'; 'Concept 2'; 'Concept 2'; 'Concept 2'};

hold on
graph = bar(FOSGraph)

set(gca, 'xticklabel', setNames)
title('Bending Factors of Safety for each Concept')
plot(xlim,[1 1],'k--')
setLegend = {'Bending','Wear'}
% colormap(graph,'summer')
legend(graph,setLegend)


hold off












    % [CI1664BS,CI1664FOS,CI1664ES] = calculateBending(16,64,16,64,8,Qv,1.5,0,0,0,0,2.25,8.25,2.25,8.25,1.56,2.5,1.56,2.5,St,St,St,St,0.27,0.41,0.27,0.41)


