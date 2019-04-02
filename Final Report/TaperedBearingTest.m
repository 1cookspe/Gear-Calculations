%% Tapered Bearing Calculations
% Sean Tron's Mechasonic Wizards: Sean Tron Back in Action
clear;

%% CONSTANTS
life = 5000; % life in hours, Table 11-4
reliability = 0.99; % Assume 99% reliability of tapered rollers set
af = 1; % Assumed application factor = 2, Table 11-5
a = 10/3; % 10/3 for roller bearings (cylindrical and tapered roller)
LR = 90*10^6; % Table 11-6, p. 601
x0 = 0; % Table 11-6, p. 601
theta = 4.48; % Table 11-6, p. 601
b = 1.5; % Table 11-6, p. 601

%% VARIABLES

% Variables from Seany's function
Fra = 2170; % radial force on bearing A
Frb = 2654; % radial force of bearing B
Fae = 1690; % externally applied thrust load from another source --> force of drill
speed = 800; % speed of bearing on shaft

% Variables that must be calculated later
Fia = 1; % thrust reaction on bearing A
Fib = 1; % thrust reaction on bearing B
Ka = 1.5; % Assume K = 1.5 to begin
Kb = 1.5; % Assume K = 1.5 to begin
Fea = 1; % dynamic equivalent load of bearing A
Feb = 1; % dynamic equivalent load of bearing B
XD = 1; % Multiple of rating life
LD = 1; % desired life
R = 1; % reliability
C10a = 1; % C10 value of bearing A
C10b = 1; % C10 value of bearing B
suitableBearing = false;
realizedReliabilityA = 1; % calculate realized reliability--> if less than reliability then new bearings must be chosen
realizedReliabilityB = 1; % calculate realized reliability--> if less than reliability then new bearings must be chosen
totalReliability = 1; % calculate realized reliability--> if less than reliability then new bearings must be chosen
counter = 0; % for counting number of iterations in loop
chosenC10 = 1; % c10 of chosen bearing

%% CALCULATIONS

% Calculate desired life, p. 567
LD = speed*life*60;
% calculate multiple of rating life (XD = LD / LR)
XD = LD / LR;
% Assume 99% reliability on each bearing
R = sqrt(reliability);

% loop until suitable bearing is found
while (~suitableBearing)
    % default values for first iterations
    if (mod(counter,2) == 0) % first iteration
        Ka = 1.5;
        Kb = 1.5;
    end % second iteration, with new K value
    
    % FIRST ITERATION --> Guess value K = 1.5
    Fia = (0.47*Fra)/Ka; % Eq. 11-18, p. 585
    Fib = (0.47*Frb)/Kb; % Eq. 11-18, p. 585
    
    % Determine equivalent load on each bearing, p. 589
    if (Fia <= (Fib + Fae))
        Fea = 0.4*Fra + Ka*(Fib + Fae); % Eq. 11-19a, p. 589
        if (Fea < Fra) % check that equivalent force is not less than original radial load
            Fea = Fra;
        end
        Feb = Frb; % Eq. 11-19b, p. 589
    else
        Feb = 0.4*Frb + Kb*(Fia - Fae); % Eq. 11-20a, p. 589
        if (Feb < Fra) % check that equivalent force is not less than original radial load
            Feb = Fra;
        end
        Fea = Fra; % Eq. 11-20b, p. 589
    end
    
    % Calculate C10, eq. 11-10, p. 570 (print them out)
    C10a = af*Fea*(XD/(x0 + (theta-x0)*(1-R)^(1/b)))^(1/a)
    C10b = af*Feb*(XD/(x0 + (theta-x0)*(1-R)^(1/b)))^(1/a)
    
    if (mod(counter,2) == 0) % get new Kt only on first iteration
        % Get new K from table
        % Ask user for new K
        prompt1 = 'What is the new K value from the table? ';
        Ka = input(prompt1);
        Kb = Ka;
        prompt2 = 'What is the C10 value for the chosen bearing? ';
        chosenC10 = input(prompt2);
    end
    
    % Check that reliability >= 0.99
    % Use Eq. 11-24, p. 594 --> for tapered bearings
    if (mod(counter, 2) == 1) % only check on second iteration
        realizedReliabilityA = 1 - ((XD)/(4.48*(chosenC10/(af*Fea))^(10/3)))^(3/2); % Eq. 11-24, p. 594
        realizedReliabilityB = 1 - ((XD)/(4.48*(chosenC10/(af*Feb))^(10/3)))^(3/2); % Eq. 11-24, p. 594
        totalReliability = realizedReliabilityA*realizedReliabilityB;
        
        % check that totalReliability >= desired reliability of 0.99
        if (totalReliability >= reliability)
            suitableBearing = true;
        else
            "Reliability not enough! Chosen another bearing!"
        end
    end
    
    counter = counter + 1;
end

% has exited loop --> suitable bearing has been found
"Congratulations! Use that bearing!"
totalReliability