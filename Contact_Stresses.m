%%Constants: Cp, Ko, F, Cf, Ch, Qv, n, H, TNP (teeth #), TNG, DP (diamteral pitch), T(temp), R (reliability),
%%LP, LG, YP, YG, HbP, HbG (brineel hardness), Cmc, Cpm, Ce, theta, I,mN(just 1)

%%Calculated:
%%Wt, Kv, PD, V, Ksp/Ksg (or 1), Kt, Kr, ZnP/ZnG, ScP/ScG, Km, Cpf, Cma, I, mG
function [CSP,CSG,SFP,SFG] = Contact_Stresses(n, Cp, Qv, YP, YG, H, P, Cmc, Cpm, Ce, TNP, DP, TNG, theta, mN, F, Cf, I, T, R, HbP, HbG, LP, LG, Ch);

Ko=1.75;
%%%%%%%%%%%Calculations%%%%%%%%%%%%%%%%%%%

%Supplemtary Equation for V: Calculate PD (pitch diamter) Figure 14-17
PD = TNP/DP; %pinion pitch diameter

%Supplemtary Equation for Kv: Calculate V (Figure 14-17)
V = pi*PD*n/12; %pitch line velocity

%For Wt Figure 14-17
Wt = 33000*H/V; %%account for efficiency in main!!!!!!!

%For Kv: Calculate A and B first Eq.(14-27)
B = 0.25*(12-Qv)^(2/3);
A = 50+56*(1-B);
%Dynamic Factor
Kv = ((A+sqrt(V))/A)^B; %ft/min unit equation


%Supplemtary Equation for KsP/KsG: Calculate Y (Example 14-1)
%%%%%%%%%%%%   CALCULATE Y %%%%%%%%%%%%%%%%

% Size factor for pinion and gear Section 14-10
KsP = 1.192*(F*sqrt(YP)/DP)^0.0535;
if (KsP < 1)
    KsP = 1;
end
KsG = 1.192*(F*sqrt(YG)/DP)^0.0535;
if (KsG < 1)
    KsG = 1;
end

Kr = 1; % default
%Reliabiltiy Factor Eq.(14-38)
if(R > 0.5 && R < 0.99)
    Kr = 0.658 - 0.0759*log(1-R);
elseif(R >= 0.99 && R <= 0.9999) 
    Kr = 0.5 - 0.109*log(1-R);
end

%Repeatedly Applied Contact Strength, Steel Gears, Through Hardened Steel,
%Figure 14-5 Equation on Graph
ScP = 349*HbP + 34300;
ScG = 349*HbG + 34300;

%Pitting Stress-Cycle Factor for Pinion and Gear Figure 14-15
ZnP = 1.4488*LP^(-0.023);
ZnG = 1.4488*LG^(-0.023);

%Supplemntary Equation to Calculate Km: Need Cpf
if(F <= 1)
    Cpf = F/(10*PD) - 0.025;
elseif( F > 1 && F <=17)
    Cpf = F/(10*PD) - 0.0375 + 0.0125*F;
elseif(F > 17 && F <= 40)
    Cpf = F/(10*PD) - 0.1109 + 0.0207*F - 0.000228*F^2;
end

%Supplemntary Equation to Calculate Km: Need Cma
%Commercial, Enclosed units Table 14-9
A = 0.127;
B = 0.0158;
C = -0.930*10^(-4);
%Eq.(14-32)
Cma = A + B*F + C*F^2;

%Load Distribtion Factor Eq.(14-30)
Km = 1 + Cmc*(Cpf*Cpm+Cma*Ce);

%Temperature factor 
if(T < 250)
    Kt = 1;
end

%Calculate Speed Ratio to Calculate I Eq.(14-22)
mG = TNG/TNP;
%Convert Pressure Angle from degree to rad
thetaRad = theta*pi/180; 
%Surface-Strength Geometry Factor Eq.(14-23)
%0 means external gear, 1 means internal gear
if (I == 0)
    I = ((cos(thetaRad)*sin(thetaRad))/(2*mN))*(mG/(mG+1));
else 
    I = ((cos(thetaRad)*sin(thetaRad))/(2*mN))*(mG/(mG-1));
end

%Pinion contact stress Eq.(14-16)
CSP = Cp*sqrt(Wt*Ko*Kv*KsP*Km*Cf/(PD*F*I))

%Gear contact stress Eq.(14-16)
CSG = Cp*sqrt(Wt*Ko*Kv*KsG*Km*Cf/(PD*F*I))

%Pinion Wear factor of safety Eq.(14-42)
SFP = ((ScP*ZnP*Ch)/(Kt*Kr))/CSP

%Gear Wear factor of safety Eq.(14-42)
SFG = ((ScG*ZnG*Ch)/(Kt*Kr))/CSG
