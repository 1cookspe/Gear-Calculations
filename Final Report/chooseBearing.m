function [bore,outerDiameter,width,resultingReliability,suitableBore,desiredReliability] = chooseBearing(radialForce,axialForce,type,rpm,desiredBore)
%chooseBearing Returns bearing suitable for application
% Units will be given in imperial as calculated by Sean and Ariel

%% Known values for bearing
% Constants
lifeHours = 30*1000; % life in hours, Table 11-4, p. 575
RD = 0.99; % Desired reliability of bearing, p. 570
af = 1.5; % Application factor, Table 11-5, p. 576. Assumed to be 2 because of "machinery with moderate impact"
V = 1; % inner ring is rotating
K = 1.5; % Assume Timken roller bearings if applicable
a = 3; % 3 for ball and angular bearings, 10/3 for cylindrical and tapered
LR = 10^6; % Table 11-6, p. 601
x0 = 0.02; % Table 11-6, p. 601
theta = 4.459; % Table 11-6, p. 601
b = 1.483; % Table 11-6, p. 601
kNTolbf = 1/0.00445; % convert KN to lbf
mmToIn = 1/25.4; % convert mm to in (for Table 11-2 and 11-3)
% initialSpeed = 10965; % starting speed from Phase 1 

% Tables required
table111 = [[0.014 0.021 0.028 0.042 0.056 0.070 0.084 0.110 0.17 0.28 0.42 0.56]', [0.19 0.21 0.22 0.24 0.26 0.27 0.28 0.30 0.34 0.38 0.42 0.44]', [1 1 1 1 1 1 1 1 1 1 1 1]', [0 0 0 0 0 0 0 0 0 0 0 0]', [0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56]', [2.30 2.15 1.99 1.85 1.71 1.63 1.55 1.45 1.31 1.15 1.04 1.00]']; % Table 11-1
table112 = [mmToIn*[10 12 15 17 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95]', mmToIn*[30 32 35 40 47 52 62 72 80 85 90 100 110 120 125 130 140 150 160 170]', mmToIn*[9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 28 30 32]', mmToIn*[0.6 0.6 0.6 0.6 1 1 1 1 1 1 1 1.5 1.5 1.5 1.5 1.5 2 2 2 2]', mmToIn*[12.5 14.5 17.5 19.5 25 30 35 41 46 52 56 63 70 74 79 86 93 99 104 110]', mmToIn*[27 28 31 34 41 47 55 65 72 77 82 90 99 109 114 119 127 136 146 156]', kNTolbf*[5.07 6.89 7.80 9.56 12.7 14 19.5 25.5 30.7 33.2 35.1 43.6 47.5 55.9 61.8 66.3 70.2 83.2 95.6 108]', kNTolbf*[2.24 3.1 3.55 4.5 6.2 6.95 10 13.7 16.6 18.6 19.6 25 28 34 37.5 40.5 45 53 62 69.5]', kNTolbf*[4.94 7.02 8.06 9.95 13.3 14.8 20.3 27 31.9 35.8 37.7 46.2 55.9 63.7 68.9 71.5 80.6 90.4 106 121]', kNTolbf*[2.12 3.05 3.65 4.75 6.55 7.65 11 15 18.6 21.2 22.8 28.5 35.5 41.5 45.5 49 55 63 73.5 85]'];
table113 = [mmToIn*[25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150]', mmToIn*[52 62 72 80 85 90 100 110 120 125 130 140 150 160 170 180 200 215 230 250 270]', mmToIn*[15 16 17 18 19 20 21 22 23 24 25 26 28 30 32 34 38 40 40 42 45]', kNTolbf*[16.8 22.4 31.9 41.8 44 45.7 56.1 64.4 76.5 79.2 93.1 106 119 142 165 183 229 260 270 319 446]', kNTolbf*[8.8 12 17.6 24 25.5 27.5 34 43.1 51.2 51.2 63.2 69.4 78.3 100 112 125 167 183 193 240 260]', mmToIn*[62 72 80 90 100 110 120 130 140 150 160 170 180 190 200 215 240 260 280 300 320]', mmToIn*[17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 50 55 58 62 65]', kNTolbf*[28.6 36.9 44.6 56.1 72.1 88 102 123 138 151 183 190 212 242 264 303 391 457 539 682 781]', kNTolbf*[15 20 27.1 32.5 45.4 52 67.2 76.5 85 102 125 125 149 160 189 220 304 340 408 454 502]'];
emax = 0.44; % maximum value of e, from Table 11-1
emin = 0.19; % minimum value of e, from Table 11-1

%% Variables

% Variables set through parameter call
speed = rpm; % speed of bearing, p. 567
typeOfBearing = type; % 1 for deep groove ball bearing, 2 for angular contact ball bearing, 3 for series 02 cylindrical bearing, 4 for series 03 cylindrical bearing
Fr = radialForce; % radial force, passed from Sean's function
Fa = axialForce; % axial force, passed from Sean's function (should less than radial force)

% Variables calculated in computations
LD = 1; % life of bearing, p. 567
XD = 1; % multiple of rating life, XD = LD / LR
% C10 = 1; % catalog load rating --> constant radial load that causes 10% of a group of bearings to fail at rated life --> Eq. 11-9, p. 570
Fe = 1; % equivalent force (calculated from radial and axial loads)
Xi = 1; % X factor, not known intially (Table 11-1, p. 572)
C10req = 1; % required C10 needed for each iteration
C10bearing = 1; % C10 value of specific bearing in question
e = emax; % e is initially emax
C0 = 0; % static load rating, used in iteration calculations
loopCount = 0; % used to determine the first iteration of loop in finding bearing
bearingFound = false; % true once bearing C10 exceeds that of the calculated C10
FaVFr = 1; % ratio for comparisons
realizedReliability = 1; % Calculate to compare with specified reliability
bearingBore = 1; % bore of ball bearing
bearingPassed = false; % verifies that realized reliability is greater than original specified reliability
bearingOD = 1; % outer diameter of bearing
bearingWidth = 1; % width of bearing
desiredSuitable = false; % determines if desired bore is suitable
desiredFaC0 = 1; % Fa/C0 of desired bore
desiredE = 1; % e value for desired bore passed in function
desiredFe = 1; % equivalent force (Fe) for desired bore size passed in function
desiredC10 = 1; % C10 value of desired bore size passed in function
desiredBoreReliability = 1; % reliability of the desired bore size

%% Calculations

% Type of bearing specific parameters
if (typeOfBearing == 1 || typeOfBearing == 2) % ball or angular 
    a = 3;
else % cylindrical
    a = 10/3; 
end

% Calculate values for C10
LD = speed*lifeHours*60; % calculates life in revolutions
XD = LD / LR; % calculates multiple of rating life

% iteration to find Fe and Xi
while (~bearingFound) % loop infinitely until correct bearing is found
    % Find equivalent load, Fe
    FaVFr = Fa/(V*Fr);
    if (C0 ~= 0) % has been updated from previous iterations
        FaC0 = Fa/C0;
        % loop through table 11-1 to find e value
        % Loop through first column of table111 to find Fa/Co value
        if (FaC0 > 0.014 && FaC0 < 0.56) % Fa/C0 > 0.014
            for counter = (1:size(table111,1)-1)
                currentFaC0 = table111(counter,1);
                nextFaC0 = table111(counter+1,1);
                if (FaC0 < nextFaC0) % value is below
                    % Found correct range; interpolate for e
                    currentE = table111(counter,2);
                    nextE = table111(counter+1,2);
                    e = currentE + (nextE-currentE)*((FaC0-currentFaC0)/(nextFaC0-currentFaC0));
                    % e has been acquired, compare to FaVFr to determine value of i, X, and Y
                    if (FaVFr <= e)
                        % Check 3rd and 4th columns
                        Xi = 1;
                        Yi = 0;
                    else
                        % Check 5th and 6th columns
                        Xi = 0.56;
                        currentY2 = table111(counter,6);
                        nextY2 = table111(counter+1,6);
                        Yi = currentY2 + (nextY2-currentY2)*((FaC0-currentFaC0)/(nextFaC0-currentFaC0));
                    end
                    % values found; exit loop
                    break;
                elseif (FaC0 == nextFaC0) % value is equal
                    % e taken from table
                    e = table111(counter+1,2);
                    % e has been acquired, compare to FaVFr to determine value of i, X, and Y
                    if (FaVFr <= e)
                        % Check 3rd and 4th columns
                        Xi = 1;
                        Yi = 10;
                    else
                        % Check 5th and 6th columns
                        Xi = 0.56;
                        Yi = table111(counter+1,6);
                    end
                    % values found; exit loop
                    break;
                end
            end
        elseif (FaC0 < 0.014) % Fa/C0 < 0.014
            FaC0 = 0.014;
            e = emin;
            if (FaVFr <= e)
                Xi = 1;
                Yi = 0;
            else
                Xi = 0.56;
                Yi = 2.30;
            end
        elseif (FaC0 > 0.56) % greater than table
            FaC0 = 0.56;
            e = emax;
            if (FaVFr <= e)
                Xi = 1;
                Yi = 0;
            else
                Xi = 0.56;
                Yi = 1;
            end
        end
    else % has not been found yet; first iteration
        if (FaVFr > emax)
            e = emax;
            % Start halfway and work up
            Xi = 0.56;
            Yi = 1.63;
        else
            e = emin;
            % Start from beginning and work up
            Xi = 1;
            Yi = 0;
        end
    end
    % Calculate equivalent load, Fe, Eq. 11-12, p. 572
    Fe = Xi*V*Fr + Yi*Fa;
    % Calculate required C10 value, Eq. 11-9, p. 570
    C10req = af*Fe*(XD/(x0+(theta-x0)*(1-RD)^(1/b)))^(1/a); % calculates C10
    
    if (loopCount ~= 0) % Not the first rodeo, can compare with the previous C10bearing value
        if (C10req < C10bearing)  % Perfect! We have found the correct bearing, and it matches up after!
            bearingFound = true;
        end
    end
    
    % Get data from Table 11-2 to get C0, C10, and test different bearings
    % loop through until a C10 value greater than C10req is found
    if (~bearingFound) % Bearing still not found, need to find it
        if (typeOfBearing == 1 || typeOfBearing == 2) % Use table 11-2
            for iteration = 1:size(table112,1)
                column10 = 0;
                column0 = 0;
                if (typeOfBearing == 1) % deep groove ball bearing
                    column10 = 7;
                    column0 = 8;
                elseif (typeOfBearing == 2) % angular contact ball bearing
                    column10 = 9;
                    column0 = 10;
                end
                currentC10 = table112(iteration,column10);
                if (currentC10 > C10req)
                    % suitable option found
                    % Get C10bearing value from table
                    C10bearing = currentC10;
                    C0 = table112(iteration,column0);
                    bearingBore = table112(iteration,1); % save bore size (in)
                    bearingOD = table112(iteration,2); % save outer diameter (OD) --> in
                    bearingWidth = table112(iteration,3);
                    % exit loop
                    break;
                end
            end
        elseif (typeOfBearing == 3 || typeOfBearing == 4) % Use table 11-3
            for increment = 1:size(table113,1)
                % check both 02 series and 03 series
                % return a bearing for both 02 and 03 --> user can choose their pick
                columnValue = 4; % 4 by default on 02 series
                widthColumn = 3; % 3 by default on 02 series
                if (typeOfBearing == 4) % different columns for 03 series bearing
                    columnValue = 8;
                    widthColumn = 7; 
                end
                
                currentC10 = table113(increment,columnValue); % get current C10 value
                if (currentC10 > C10req)
                    % found suitable bearing
                    C10bearing = currentC10;
                    bearingBore = table113(increment,1);
                    bearingOD = table113(increment,2);
                    bearingWidth = table113(increment,widthColumn);
                    break; % bearing found, exit loop
                end
            end
        end
    else % bearing has been found --> make sure it passes the reliability
        % Imperial units
        realizedReliability = 1 - ((XD*((af*Fe)/C10bearing)^a-x0)/(theta-x0))^b;
        
        if (realizedReliability > RD) % all good!
            "Minimum bearing passes!"
            bearingPassed = true;
        else
            "Minimum bearing fails!"
            bearingPassed = false;
        end
    end
    loopCount = loopCount + 1;
end

% display chosen bearing to user --> bore mm
% if (typeOfBearing == 1 || typeOfBearing == 2) % ball or angular
%     bearingBore
%     realizedReliability
% else % cylindrical
%     cylinderBore2
%     cylinderBore3
%     realizedReliability02
%     realizedReliability03
% end

% check if input desired bore works
% calculate values for the desired bore
% loop to values for specific diameter
% determine columns and tables to fetch
analyzedTable = table112;
if (typeOfBearing == 1)
    C0column = 8;
    C10column = 7;
    analyzedTable = table112;
elseif(typeOfBearing == 2)
    C0column = 10;
    C10column = 9;
    analyzedTable = table112;
elseif(typeOfBearing == 3)
    C0column = 5;
    C10column = 4;
    analyzedTable = table113;
else
    C0column = 9;
    C10column = 8;
    analyzedTable = table113;
end

for toDesired=1:size(table112,1)
    currentDesiredBore = table112(toDesired,1);
    nextDesiredBore = table112(toDesired+1,1);
    if (currentDesiredBore <= desiredBore && nextDesiredBore >= desiredBore) % correct range
        
        currentDesiredC0 = analyzedTable(toDesired,C0column);
        nextDesiredC0 = analyzedTable(toDesired+1,C0column);
        % interpolate for actual C0 value
        C0desired = currentDesiredC0 + ((desiredBore-currentDesiredBore)/(nextDesiredBore-currentDesiredBore))*(nextDesiredC0-currentDesiredC0);
        desiredFaC0 = Fa/C0desired;
        % interpolate for C10
        currentDesiredC10 = analyzedTable(toDesired,C10column);
        nextDesiredC10 = analyzedTable(toDesired+1,C10column);
        interpolatedC10 = currentDesiredC10 + ((desiredBore-currentDesiredBore)/(nextDesiredBore-currentDesiredBore))*(nextDesiredC10-currentDesiredC10);
        break;
    end
end
% once Fa/Co is acquired, interpolate for e by iterating through Table 11-1
for j=1:size(table111,1)
    if (desiredFaC0 >= 0.014 && desiredFaC0 <= 0.56)
        currentFaC0 = table111(j,1);
        nextFaC0 = table111(j+1,1);
        if (currentFaC0 < desiredFaC0 && nextFaC0 > desiredFaC0)
            currentDesiredE = table111(j,2);
            currentNextE = table111(j+1,2);
            desiredE = currentDesiredE + ((desiredFaC0-currentFaC0)/(nextFaC0-currentFaC0))*(currentNextE-currentDesiredE);
            % Also interpolate for the Y2 value (might as well in case you need it)
            currentYValue = table111(j,6);
            nextYValue = table111(j+1,6);
            interpolatedY = currentYValue + ((desiredFaC0-currentFaC0)/(nextFaC0-currentFaC0))*(nextYValue-currentYValue);
            break;
        end
    elseif (desiredFaC0 < 0.014)
        interpolatedY = 2.30;
        desiredFaC0 = 0.014;
        desiredE = emin;
        break;
    elseif (desiredFaC0 > 0.56)
        interpolatedY = 1;
        desiredFaC0 = 0.56;
        desiredE = emax;
        break;
    end
end
% Compare e with Fa/(VFr)
% Fa/VFr is already calculated and constant
desiredX = 0;
desiredY = 0;
if (FaVFr <= desiredE)
    desiredX = 1;
    desiredY = 0;
else
    desiredX = 0.56;
    desiredY = interpolatedY;
end

% calculate resulting Fe of desired bore
desiredFe = desiredX*V*Fr + desiredY*Fa;

% calculate resulting C10 of desired bore
desiredC10 = af*Fe*(XD/(x0+(theta-x0)*(1-RD)^(1/b)))^(1/a);

if (desiredC10 < interpolatedC10) % works!
    desiredSuitable = true;
end

if (typeOfBearing == 1 || typeOfBearing == 2) % deep groove or angular contact
    desiredBoreReliability = 1 - ((XD*((af*desiredFe)/interpolatedC10)^a-x0)/(theta-x0))^b;
else % cylindrical
    desiredBoreReliability = 1 - (XD/(4.48*(interpolatedC10/(af*desiredFe))^(10/3)))^(3/2);
end

if (desiredSuitable)
    "Desired bore works!"
    desiredBoreReliability
else
    "Desired bore does not work!"
    desiredBoreReliability
end

% return values
resultingReliability = realizedReliability;
bore = bearingBore;
outerDiameter = bearingOD;
width = bearingWidth;
suitableBore = desiredSuitable;
desiredReliability = desiredBoreReliability;
end

