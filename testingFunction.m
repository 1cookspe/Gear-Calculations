function [bS,bES,bFOS,cS,wES,wFOS] = testingFunction(pinion1Teeth,gear1Teeth,pinion2Teeth,gear2Teeth,diametralPitch1,diametralPitch2,qualityNumber,faceWidth,material1,material2,material3,material4,sRatio1,sRatio2,sRatio3,sRatio4,J1,J2,J3,J4,tPressAngle,Y1,Y2,Y3,Y4)
%calculateContact Calculates contact stress and wear factor of safety for
%gear and pinion

%% Variables for each configuration of 4 gears
NP = [pinion1Teeth, pinion1Teeth, pinion2Teeth, pinion2Teeth]; % number of teeth on pinion
NG = [gear1Teeth, gear1Teeth, gear2Teeth, gear2Teeth]; % number of teeth on gear
PD = [diametralPitch1, diametralPitch1, diametralPitch2, diametralPitch2]; % transverse diametral pitch
dP = [0, 0, 0, 0]; % pitch diameter of pinion, calculate later
nP = [1145, 1, 1, 1]; % pinion speed, in rev/min, calculate later
Qv = [qualityNumber, qualityNumber, qualityNumber, qualityNumber]; % gear quality number for calculating of Kv (p. 748)
F = [faceWidth, faceWidth, faceWidth, faceWidth]; % face width size of gear (from Boston datasheet)
sRatios = [sRatio1, sRatio2, sRatio3, sRatio4]; % s1/s for calculation of Cpm, Eq. 14-33, p. 752
Cpm = [1, 1, 1, 1]; % (pinion proprtion modifier) assume gear is equally in between bearings Eq. 14-33, p. 752 --> to be calculated
tR = [0.79, 0.79, 0.79, 0.79]; % rim thickness below the tooth (inch), Fig. 14-16, p. 756 --> calculated later
ht = [0.066, 0.066, 0.066, 0.066]; % tooth height (inch), Fig. 14-16, p. 756 --> calculated later
FOS = [1, 1, 1, 1]; % bending factor of safety, Eq. 14-41, p. 757
St = [32125,32125,1,1]; % AGMA bending strength, p. 739 --> should be fed in because they can be very variable depending on material
N_cycles = [1, 1, 1, 1]; % load cycles, changes with position in gear train.
mG = [1, 1, 1, 1]; % gear ratios (never less than 1), Eq. 14-22, p. 746
enduranceStrength = [1, 1, 1, 1]; % bending endurance strength, Eq. 14-17
bendingStress = [0, 0, 0, 0]; % gear bending stress
J = [J1, J2, J3, J4]; % geometry factor (for 16 to 64 teeth), (64 to 16 teeth), (16 to 56 teeth), (56 to 16 teeth)  Fig. 14-6, p. 745
H = [29.75,29.75, 0.9*29.75, 0.9*29.75]; % power, in hp (transmitted from pinion! p. 760)
V = [0, 0, 0, 0]; % pitch line velocity
Wt = [0, 0, 0, 0]; % transmitted load
Kv = [0, 0, 0, 0]; % dynamic factor --> accounts for inaccuracies in manufacture and meshing of gear teeth in action, Eq. 14-27, p.748
A = [0, 0, 0, 0]; % used in Kv calculation, p. 748
B = [0, 0, 0, 0]; % used in Kv calculation, p. 748
Km = [0, 0, 0, 0]; % load distribution factor, Eq. 14-30, p. 751
Cpf = [0, 0, 0, 0]; % pinion proportion factor, p.752 
Cma = [0, 0, 0, 0]; % mesh alignment factor, p. 752
mB = [0, 0, 0, 0]; % backup ratio, Eq. 14-39, p. 756
YN = [1, 1, 1, 1]; % stress cycle factor
Cp = [2300,2300,1,1]; % Elastic coefficient, Eq. 14-13, Table 14-8
poisson = [0.292,0.292,1,1]; % poisson's ratio of pinion, used for calculated of Cp (Table A-5), p. 1015
E = [30*10^6,30*10^6,1,1]; % modulus of elasticity
I = [0,0,0,0]; % geometry factor, Eq. 14-23, p. 747 (external gear)
tPressure = [tPressAngle,tPressAngle,tPressAngle,tPressAngle]; % transverse pressure angle
Sc = [109600,109600,1,1]; % AGMA surface endurance strength, Eq. 14-18
ZN = [1, 1, 1, 1]; % stress-cycle factor, p. 755
contactStress = [1,1,1,1]; % contact stress
contactEnduranceStrength = [1,1,1,1]; % wear endurance strength, Eq. 14-18
cFOS = [1,1,1,1]; % contact or wear factor of safety, Eq. 14-42
materials = [material1,material2,material3,material4]; % holds materials of each pinion and gear
Ks = [1, 1, 1, 1]; % size factor default to 1, Eq. (a), p. 751 --> will be calculated
Y = [Y1,Y2,Y3,Y4]; % Lewis form factor Y, Table 14-2, p. 730

%% Constants for each configuration of 4 gears
Ko = [1.75, 1.75, 1.75, 1.75]; % overload factor. The power source is uniform, however the machine is subject to heavy loads in its heavy duty mining application.
Cmc = [1, 1, 1, 1]; % load correction factor (uncrowned) Eq. 14-31, p. 752
ACma = [0.127, 0.127, 0.127, 0.127]; % constant for Cma, p. 752 --> Commercial enclosed unit
BCma = [0.0158, 0.0158, 0.0158, 0.0158]; % constant for Cma, p. 752 --> Commercial enclosed unit
CCma = [-0.930*10^-4, -0.930*10^-4, -0.930*10^-4, -0.930*10^-4]; % constant for Cma, p. 752 --> Commercial enclosed unit
Ce = [1, 1, 1, 1]; % mesh alignment correction factor, assumed all other conditions, Eq 14-35, p. 752
KR = [1, 1, 1, 1]; % reliability factor of 99% for each (Table 14-10, p. 756)
KT = [1, 1, 1, 1]; % temperature factor = 1 because T < 250 C (p. 756)
initialSpeed = 1145; % starting speed from specifications (rpm x V)
initialLife = 3*10^9;
initialHorsepower = 29.75;
mN = [1,1,1,1]; % load sharing factor (1 for spur gears)
Cf = [1,1,1,1]; % surface condition factor (given as 1)
Ch = [1,1,1,1]; % same material, p. 753
kB = [1, 1, 1, 1]; % rim thickness factor, Eq. 14-40, p. 756 (assume 1)

%% Loop through all gears in configuration
for i = 1:2
    %% Set material properties
    % St1, St2, St3, St4, poisson1, poisson2, poisson3, poisson4, Sc1, Sc2,
    % Sc3, Sc4
    switch materials(i)
        case 1 % grade 1 steel (1020)
            St(i) = 77.3*131 +12800; % Figure 14-2
            poisson(i) = 0.292; % Table A-5
            Sc(i) = 322*131 + 29100; % Figure 14-5
            Cp(i) = 2300; % Table 14-8
        case 2 % cast iron
            St(i) = 8500; % Class 30, Table 14-4
            poisson(i) = 0.211; % Table A-5
            Sc(i) = 65000; % Table 14-7, class 30
            Cp(i) = 1960; % Table 14-8
        case 3 % grade 2 steel (1020)
            St(i) = 102*131 + 16400; % Figure 14-2
            poisson(i) = 0.292; % Table A-5
            Sc(i) = 349*131 + 34300; % Figure 14-5
            Cp(i) = 2300; % Table 14-8
        otherwise
    end
    
    %% Bending stress
    mG(i) = NG(i) / NP(i);
    dP(i) = NP(i) / PD(i);
    % calculate input velocity
    if (i <= 2) % first pinion or gear
        nP(i) = initialSpeed;
        % calculate power (horsepower)
        H(i) = initialHorsepower;
    else % second pinion or gear
        nP(i) = initialSpeed / mG(1); % speed decreased by initial ratio of first gear train
        H(i) = initialHorsepower * 0.9; % efficiency
    end
    % calculate pitch line velocity (V)
    V(i) = (pi*dP(i)*nP(i))/12;
    % calculate transmitted load (Wt)
    Wt(i) = (33000*H(i))/V(i);
    % calculate dynamic factor (Kv), p. 748
    B(i) = 0.25*(12-Qv(i))^(2/3);
    A(i) = 50 + 56*(1-B(i));
    Kv(i) = ((A(i)+sqrt(V(i)))/A(i))^B(i);
    % Ks already set to 1, Eq. (a), p. 751
    % calculate Cpf (pinion proportion factor) Eq. 14-32, p.752
    firstValue = F(i)/(10*dP(i));
    if (firstValue < 0.05) 
        firstValue = 0.05;
    end
    if (F(i) <= 1)
        Cpf(i) = firstValue - 0.025;
    elseif(F(i) > 1 && F(i) <= 17)
        Cpf(i) = firstValue - 0.0375 + 0.0125*F(i);
    elseif(F(i) > 17 && F(i) <= 40)
        Cpf(i) = firstValue - 0.1109 + 0.0207*F - 0.000228*(F(i))^2;
    end
    % calculate Cpm, Eq. 14-33, p. 752
    if (sRatios(i) < 0.175) % gear in middle of bearings
        Cpm(i) = 1;
    else % gear slightly offset
        Cpm(i) = 1.1;
    end
    % calculate Cma Eq. 14-34, p. 752
    Cma(i) = ACma(i) + BCma(i)*F(i) + CCma(i)*F(i)^2;
    %calculate Km, Eq. 14-30, p. 751
    Km(i) = 1 + Cmc(i)*(Cpf(i)*Cpm(i) + Cma(i)*Ce(i));
    % Calculate Ks
    Ks(i) = 1.192*((F(i)*sqrt(Y(i)))/PD(i))^0.0535;
    % finally calculating bending stress! Eq. 14-15
    bendingStress(i) = Wt(i)*Ko(i)*Kv(i)*Ks(i)*(PD(i)/F(i))*((Km(i)*kB(i))/J(i));
    
    %% Factor of safety
    % calculate variables for safety factor!
    % AGMA bending strength, p. 739
    % calculate load cycles
    if (i == 1) % first iteration
        N_cycles(i) = initialLife;
    elseif(mod(i,2) == 0) % i = 2 or i = 4
        N_cycles(i) = N_cycles(i-1) / mG(i);
    else % i = 3
        N_cycles(i) = N_cycles(i-1);
    end
    
    % Calculate YN --> stress-cycle factor for bending strength, Fig 14-14,
    % p. 755
    if (N_cycles(i) > 10^7) % YN = 1 at 10^7 cycles
        YN(i) = 1.6831*N_cycles(i)^-0.0323; % use YN = 1.3558N^-0.0178 because it is more conservative!
    end
    
    % calculate bending factor of safety, Eq. 14-41, p. 757
%     FOS(i) = ((St(i)*YN(i))/(KT(i)*KR(i)))/bendingStress(i);
    
    %% Endurance strength
    % calculate gear bending endurance strength, Eq. 14-17, p.741
    enduranceStrength(i) = (St(i)*YN(i))/(FOS(i)*KT(i)*KR(i));
    
    %% Exclusive to Contact
    % calculate Cp --> elastic coefficient
%     if (mod(i,2) == 1) % on pinion
%         Cp(i) = sqrt(1/(pi*((1-poisson(i)^2)/E(i)+(1-poisson(i+1)^2)/E(i+1))));
%     else % on gear
%         Cp(i) = sqrt(1/(pi*((1-poisson(i-1)^2)/E(i-1)+(1-poisson(i)^2)/E(i))));
%     end
    
    % calculate I --> geometry factor, Eq. 14-23, p. 747
    %Surface-Strength Geometry Factor Eq.(14-23)
    %0 means external gear, 1 means internal gear
    % convert from degrees to radians
    tPressure(i) = tPressure(i)*(pi/180);
    if (I(i) == 0)
        I(i) = ((cos(tPressure(i))*sin(tPressure(i)))/(2*mN(i)))*(mG(i)/(mG(i)+1));
    else 
        I(i) = ((cos(tPressure(i))*sin(tPressure(i)))/(2*mN(i)))*(mG(i)/(mG(i)-1));
    end
    
    % calculate ZN, stress-cycle factor, Fig. 14-15, p. 755
    ZN(i) = 2.466*N_cycles(i)^(-0.056);
    
    % calculate contact stress
    contactStress(i) = Cp(i)*sqrt(Wt(i)*Ko(i)*Ks(i)*((Km(i)*Cf(i))/(dP(i)*F(i)*I(i))));
    
    % calculate contact factor of safety (FOS)
%     cFOS(i) = ((Sc(i)*ZN(i)*Ch(i))/(KT(i)*KR(i)))/contactStress(i);
    
    % calculate contact endurance strength
    contactEnduranceStrength(i) = (Sc(i)*ZN(i)*Ch(i))/(cFOS(i)*KT(i)*KR(i));
    
end
% set return values
bS = bendingStress;
bES = enduranceStrength;
bFOS = FOS;
cS = contactStress;
wES = contactEnduranceStrength;
wFOS = cFOS;
end

