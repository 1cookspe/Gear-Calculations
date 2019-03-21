%% Client to test different configurations
clear all;
% grade 1 material steel
Qv_steel = 7;
hardness_steel = 131;

St_steel = 77.3*hardness_steel +12800;
setSteelGrade1 = [16,64,16,64,8,Qv_steel,1.5,0,0,0,0,2.25,8.25,2.25,8.25,1.56,2.5,1.56,2.5,St_steel,St_steel,St_steel,St_steel,0.27,0.41,0.27,0.41]


% cast iron
Qv_iron = 6;
hardness_iron = 1;

array = [setSteelGrade1];

% every row is a config

% 16 pinion to 64 gear, 16 pinion to 64 gear
% all steel

for i = 1:size(array,1)
    
    [currentBS,currentFOSB,currentES] = calculateBending(array(i,1), array(i,2), array(i,3), array(i,4), array(i,5), array(i,6), array(i,7), array(i,8), array(i,9), array(i,10), array(i,11), array(i,12), array(i,13), array(i,14), array(i,15), array(i,16), array(i,17), array(i,18), array(i,19), array(i,20), array(i,21), array(i,22), array(i,23), array(i,24), array(i,25), array(i,26), array(i,27));
    [currentCSP1, currentCSG1, currentFOSP1CS, currentFOSG1CS] = Contact_Stresses()
    [currentCSP2, currentCSG2, currentFOSP2CS, currentFOSG2CS] = Contact_Stresses()
    
    
    if(i==1) 
        results = [currentFOSB, currentFOSP1CS, currentFOSG1CS, currentFOSP2CS, currentFOSG2CS,0,currentBS, currentCSP1, currentCSG1, currentCSP2, currentCSG2,0,currentES]
    else
        results = [results; [currentFOSB, currentFOSP1CS, currentFOSG1CS, currentFOSP2CS, currentFOSG2CS,0,currentBS, currentCSP1, currentCSG1, currentCSP2, currentCSG2,0,currentES]]
    end
        
    
    


end




















    % [CI1664BS,CI1664FOS,CI1664ES] = calculateBending(16,64,16,64,8,Qv,1.5,0,0,0,0,2.25,8.25,2.25,8.25,1.56,2.5,1.56,2.5,St,St,St,St,0.27,0.41,0.27,0.41)


