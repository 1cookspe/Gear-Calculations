function [e,Xi,Yi] = interpolate(FaC0)
table111 = [[0.014 0.021 0.028 0.042 0.056 0.070 0.084 0.110 0.17 0.28 0.42 0.56]', [0.19 0.21 0.22 0.24 0.26 0.27 0.28 0.30 0.34 0.38 0.42 0.44]', [1 1 1 1 1 1 1 1 1 1 1 1]', [0 0 0 0 0 0 0 0 0 0 0 0]', [0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56 0.56]', [2.30 2.15 1.99 1.85 1.71 1.63 1.55 1.45 1.31 1.15 1.04 1.00]']; % Table 11-1 
table112 = [[10 12 15 17 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95]', [30 32 35 40 47 52 62 72 80 85 90 100 110 120 125 130 140 150 160 170]', [9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 28 30 32]', [0.6 0.6 0.6 0.6 1 1 1 1 1 1 1 1.5 1.5 1.5 1.5 1.5 2 2 2 2]', [12.5 14.5 17.5 19.5 25 30 35 41 46 52 56 63 70 74 79 86 93 99 104 110]', [27 28 31 34 41 47 55 65 72 77 82 90 99 109 114 119 127 136 146 156]', [5.07 6.89 7.80 9.56 12.7 14 19.5 25.5 30.7 33.2 35.1 43.6 47.5 55.9 61.8 66.3 70.2 83.2 95.6 108]', [2.24 3.1 3.55 4.5 6.2 6.95 10 13.7 16.6 18.6 19.6 25 28 34 37.5 40.5 45 53 62 69.5]', [4.94 7.02 8.06 9.95 13.3 14.8 20.3 27 31.9 35.8 37.7 46.2 55.9 63.7 68.9 71.5 80.6 90.4 106 121]', [2.12 3.05 3.65 4.75 6.55 7.65 11 15 18.6 21.2 22.8 28.5 35.5 41.5 45.5 49 55 63 73.5 85]']
emax = 0.44; % maximum value of e, from Table 11-1
emin = 0.19; % minimum value of e, from Table 11-1

%interpolate Interpolates for e, Xi, Yi
% loop through table 11-1 to find e value
% Loop through first column of table111 to find Fa/Co value
if (FaC0 > 0.014 && FaC0 < 0.56) % Fa/C0 > 0.014
    for counter = (1:size(table111,1)-1)
        if (FaC0 < table111(1,counter+1)) % value is below
            % Found correct range; interpolate for e
            e = (table111(2,counter+1)-table111(2,counter))*((FaC0-table111(1,counter))/(table111(1,counter+1)-table111(1,counter)))
            % e has been acquired, compare to FaVFr to determine value of i, X, and Y
            if (FaVFr <= e)
                % Check 3rd and 4th columns
                Xi = 1;
                Yi = 1;
            else
                % Check 5th and 6th columns
                Xi = 2;
                Yi = (table111(6,counter+1)-table111(6,counter))*((FaC0-table111(1,counter))/(table111(1,counter+1)-table111(1,counter)))
            end
            % values found; exit loop
            break;
        elseif (FaC0 == table111(1,counter+1)) % value is equal
            % e taken from table
            e = table111(2,counter+1)
            % e has been acquired, compare to FaVFr to determine value of i, X, and Y
            if (FaVFr <= e)
                % Check 3rd and 4th columns
                Xi = 1;
                Yi = 1;
            else
                % Check 5th and 6th columns
                Xi = 2;
                Yi = table111(6,counter+1)
            end
            % values found; exit loop
            break;
        end
    end
elseif (FaC0 < 0.014) % Fa/C0 < 0.014
    FaC0 = 0.014;
    e = emin;
elseif (FaC0 > 0.56) % greater than table
    e = emax;
end
end

