%% Bearings Calculations
% Sean Tron's Mechasonic Wizards: Sean Tron Back in Action
clear;

%% Known values for bearing
% Constants
lifeHours = 30*1000; % life in hours, Table 11-4, p. 575
RD = 0.99; % Desired reliability of bearing, p. 570
af = 2; % Application factor, Table 11-5, p. 576. Assumed to be 2 because of "machinery with moderate impact"
V = 1; % inner ring is rotating

% Tables required
table111 = [[0.014 0.021 0.028 0.042 0.056 0.070 0.084 0.110 0.17 0.28 0.42 0.56]', [0.19 0.21 0.22 0.24 0.26 0.27 0.28 0.30 0.34 0.38 0.42 0.44]', [1 1 1 1 1 1 1 1 1 1 1 1]', [0 0 0 0 0 0 0 0 0 0 0 0]', [0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56]', [2.30 2.15 1.99 1.85 1.71 1.63 1.55 1.45 1.31 1.15 1.04 1.00]']; % Table 11-1 
table112 = [[10 12 15 17 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95]', [30 32 35 40 47 52 62 72 80 85 90 100 110 120 125 130 140 150 160 170]', [9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 28 30 32]', [0.6 0.6 0.6 0.6 1 1 1 1 1 1 1 1.5 1.5 1.5 1.5 1.5 2 2 2 2]', [12.5 14.5 17.5 19.5 25 30 35 41 46 52 56 63 70 74 79 86 93 99 104 110]', [27 28 31 34 41 47 55 65 72 77 82 90 99 109 114 119 127 136 146 156]', [5.07 6.89 7.80 9.56 12.7 14 19.5 25.5 30.7 33.2 35.1 43.6 47.5 55.9 61.8 66.3 70.2 83.2 95.6 108]', [2.24 3.1 3.55 4.5 6.2 6.95 10 13.7 16.6 18.6 19.6 25 28 34 37.5 40.5 45 53 62 69.5]', [4.94 7.02 8.06 9.95 13.3 14.8 20.3 27 31.9 35.8 37.7 46.2 55.9 63.7 68.9 71.5 80.6 90.4 106 121]', [2.12 3.05 3.65 4.75 6.55 7.65 11 15 18.6 21.2 22.8 28.5 35.5 41.5 45.5 49 55 63 73.5 85]'];
emax = 0.44; % maximum value of e, from Table 11-1
emin = 0.19; % minimum value of e, from Table 11-1

%% Variables

% Variables set through parameter call
speed = 1; % speed of bearing, p. 567
typeOfBearing = 1; % 1 for ball, 2 for tapered-roller
Fr = 1; % radial force, passed from Sean's function
Fa = 0; % axial force, passed from Sean's function (should less than radial force)

% Variables calculated in computations
LD = 1; % life of bearing, p. 567
LR = 1; % Rated life, Table 11-6, p. 601
XD = 1; % multiple of rating life, XD = LD / LR
a = 3; % 3 for ball bearings, 10/3 for roller bearings (cylindrical and tapered roller)
x0 = 0; % minimum value of life of bearing, Table 11-6, p. 601
theta = 1; % characteristic parametric rolling-contact 63.2121 percentile, Table 11-6, p. 601
b = 1; % shape parameter that controls skewness, Table 11-6, p. 601 
% C10 = 1; % catalog load rating --> constant radial load that causes 10% of a group of bearings to fail at rated life --> Eq. 11-9, p. 570
Fe = 1; % equivalent force (calculated from radial and axial loads)
Xi = 1; % X factor, not known intially (Table 11-1, p. 572)
C10req = 1; % required C10 needed for each iteration
C10bearing = 1; % C10 value of specific bearing in question
e = emax; % e is initially
C0 = 0; % static load rating, used in iteration calculations
i = 0; % used in calculation of Fe, Eq. 11-12, p. 572
loopCount = 0; % used to determine the first iteration of loop in finding bearing
bearingFound = false; % true once bearing C10 exceeds that of the calculated C10
FaVFr = 1; % ratio for comparisons

%% Calculations
% define constants based off of type of bearing
if (typeOfBearing == 1) % ball bearing
    a = 3; % 3 for ball bearings
    LR = 10^6; % Table 11-6, p. 601
    x0 = 0.02; % Table 11-6, p. 601
    theta = 4.459; % Table 11-6, p. 601
    b = 1.483; % Table 11-6, p. 601
else % tapered-roller
    a = 10/3; % 10/3 for roller bearings (cylindrical and tapered roller)
    LR = 90*10^6; % Table 11-6, p. 601
    x0 = 0; % Table 11-6, p. 601
    theta = 4.48; % Table 11-6, p. 601
    b = 1.5; % Table 11-6, p. 601
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
    C10req = af*Fe*(XD/(x0+(theta-x0)*(log(1/RD))^(1/b)))^(1/a); % calculates C10
    
    if (loopCount ~= 0) % Not the first rodeo, can compare with the previous C10bearing value
        if (C10req < C10bearing)  % Perfect! We have found the correct bearing, and it matches up after!
            bearingFound = true;
        end
    end
    
    % Get data from Table 11-2 to get C0, C10, and test different bearings
    % loop through until a C10 value greater than C10req is found
    if (~bearingFound) % Bearing still not found, need to find it
        for iteration = 1:size(table112,1)
            currentC10 = table112(iteration,7);
            if (currentC10 > C10req)
                % suitable option found
                % Get C10bearing value from table
                C10bearing = currentC10;
                C0 = table112(iteration,8);
                % exit loop
                break;
            end
        end
    end
    loopCount = loopCount + 1;
end