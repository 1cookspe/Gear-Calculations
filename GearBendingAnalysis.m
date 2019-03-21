clear;
%% Information
% SPUR GEAR Bending Analysis!
% Spur Gear

% arrays of values are arranged such that value = [pinion 1 (16), gear 1 (64), pinion 2 (16), gear 2 (56)]
% chosen gear on p. 37 of manual

%% Initial Values
% Properties
% All angles in degrees
NP = [16, 16, 16, 16]; % number of teeth on pinion
NG = [64, 64, 56, 56]; % number of teeth on gear
PD = [64, 64, 64, 64]; % transverse diametral pitch
% d = 0; % pitch diameter
nP = [45000, 45000, 45000/4, 45000/4]; %% pinion speed, in rev/min
H = [29.75, 29.75, 0.9*29.75, 0.9*29.75]; % power, in hp (transmitted from pinion! p. 760)
Ko = [1.75, 1.75, 1.75, 1.75]; % overload factor. The power source is uniform, however the machine is subject to heavy loads in its heavy duty mining application.
Qv = [10, 10, 10, 10]; % gear quality number. (Change this!!!!!)
Ks = [1, 1, 1, 1]; % size factor default to 1, Eq. (a), p. 751
Cmc = [1, 1, 1, 1]; % load correction factor (uncrowned) Eq. 14-31, p. 752
F = [0.125, 0.125, 0.125, 0.125]; % width size of gear (from Boston datasheet)
Cpm = [1, 1, 1, 1]; % (pinion proprtion modifier) assume gear is equally in between bearings Eq. 14-33, p. 752
ACma = [0.127, 0.127, 0.127, 0.127]; % constant for Cma, p. 752 --> Commercial enclosed unit
BCma = [0.0158, 0.0158, 0.0158, 0.0158]; % constant for Cma, p. 752 --> Commercial enclosed unit
CCma = [-0.930*10^-4, -0.930*10^-4, -0.930*10^-4, -0.930*10^-4]; % constant for Cma, p. 752 --> Commercial enclosed unit
Ce = [1, 1, 1, 1]; % mesh alignment correction factor, assumed all other conditions, Eq 14-35, p. 752
tR = [0.79, 0.79, 0.79, 0.79]; % rim thickness below the tooth (inch)
ht = [0.066, 0.066, 0.066, 0.066]; % tooth height (inch)
J = [0.27, 0.41, 0.27, 0.40]; % geometry factor (for 16 to 64 teeth), (64 to 16 teeth), (16 to 56 teeth), (56 to 16 teeth)  Fig. 14-6, p. 745
KR = [1, 1, 1, 1]; % reliability factor of 99% for each (Table 14-10, p. 756)
KT = [1, 1, 1, 1]; % temperature factor = 1 because T < 250 C (p. 756)
HB = [100, 100, 100, 100]; % core hardness of material, calculates St (p. 739)
St = [0,0,0,0]; % AGMA bending strength, p. 739
slope = [102, 102, 102, 102]; % for calculating St, p. 739
offset = [16400, 16400, 16400, 16400]; % for calculating St, p. 739
mG = [1, 1, 1, 1]; % gear ratios (never less than 1), Eq. 14-22, p. 746
initialSpeed = 1125*40; % starting speed from specifications (rpm x V)
initialLife = initialSpeed*240000;

% To be calculated
dP = [0, 0, 0, 0]; % pitch diameter of pinion
V = [0, 0, 0, 0]; % pitch line velocity
Wt = [0, 0, 0, 0]; % transmitted load
bendingStress = [0, 0, 0, 0]; % gear bending stress
Kv = [0, 0, 0, 0]; % dynamic factor --> accounts for inaccuracies in manufacture and meshing of gear teeth in action
A = [0, 0, 0, 0]; % used in Kv calculation
B = [0, 0, 0, 0]; % used in Kv calculation
Km = [0, 0, 0, 0]; % load distribution factor
Cpf = [0, 0, 0, 0]; % pinion proportion factor, p.752 
Cma = [0, 0, 0, 0]; % mesh alignment factor, p. 752
mB = [0, 0, 0, 0]; % backup ratio, Eq. 14-39, p. 756
kB = [0, 0, 0, 0]; % rim thickness factor, Eq. 14-40, p. 756
N_cycles = [1, 1, 1, 1]; % load cycles, changes with position in gear train.
YN = [1, 1, 1, 1]; % stress cycle factor
enduranceStrength = [1, 1, 1, 1]; % bending endurance strength, Eq. 14-17
FOS = [1, 1, 1, 1]; % bending factor of safety, Eq. 14-41, p. 757

%% Calculations
% calculate pitch diameter of pinion (dP)
for i = 1:4
    %% Bending stress
    mG(i) = NG(i) / NP(i);
    dP(i) = NP(i) / PD(i);
    % calculate pitch line velocity (V)
    V(i) = (pi*dP(i)*nP(i))/12;
    % calculate transmitted load (Wt)
    Wt(i) = (33000*H(i))/V(i);
    % calculate dynamic factor (Kv)
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
    % calculate Cma Eq. 14-34, p. 752
    Cma(i) = ACma(i) + BCma(i)*F(i) + CCma(i)*F(i)^2;
    %calculate Km, Eq. 14-30, p. 751
    Km(i) = 1 + Cmc(i)*(Cpf(i)*Cpm(i) + Cma(i)*Ce(i));
    % calculate mB, Eq. 14-39, p. 756
    mB(i) = tR(i) / ht(i);
    % calculate kB, Eq. 14-40, p. 756
    if (mB(i) < 1.2)
        kB(i) = 1.6*log(2.242/mB(i));
    else
        kB(i) = 1;
    end
    % finally calculating bending stress! Eq. 14-15
    bendingStress(i) = Wt(i)*Ko(i)*Kv(i)*Ks(i)*(PD(i)/F(i))*((Km(i)*kB(i))/J(i));
    
    %% Factor of safety
    % calculate variables for safety factor!
    % AGMA bending strength, p. 739
    St(i) = slope(i)*HB(i) + offset(i);
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
        YN(i) = 1.3558*N_cycles(i)^-0.0178; % use YN = 1.3558N^-0.0178 because it is more conservative!
    end
    
    % calculate bending factor of safety, Eq. 14-41, p. 757
    FOS(i) = ((St(i)*YN(i))/(KT(i)*KR(i)))/bendingStress(i);
    
    %% Endurance strength
    % calculate gear bending endurance strength, Eq. 14-17, p.741
    enduranceStrength(i) = (St(i)*YN(i))/(FOS(i)*KT(i)*KR(i));
end
FOS