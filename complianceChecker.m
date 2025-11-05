%------------------------------------------------------------------------------
% [pass] = complianceChecker(headGrid)
%
% Arguments:
%   headGrid : A 2D matrix representing the computed head values over a grid.
%
% Returns:
%   pass     : A boolean indicating whether all head values in the excavation
%               area are below the critical head value (25 m).
% 
% Notes:
%   This function checks compliance of the water table head with respect to
%   excavation requirements.
% 
% Author:
%   Evan M. Stearns 
%   Owen Haberstroh
%   Lily Wilkerson
%   (Group I)
%   University of Minnesota
%
% Version:
%   4 November 2025
% 
%------------------------------------------------------------------------------

function[pass] = complianceChecker(headGrid)
% COMPLIANCECHECKER checks if the computed head grid meets the homework requirements.
%
% The requirement is that the water table head (h) must be drawn BELOW
% the excavation floor throughout the excavation area.
%
% 1. Target Head: The initial water table is 30 m (river height). The
%    excavation floor is 5 m below the initial water table, making the
%    critical head value (h_floor) for compliance 30 - 5 = 25 m.
% 2. Excavation Area: The site is a square spanning x in [300, 500] and y in [-100, 100].
%
% The input 'headGrid' is generated over:
% Xgrid: 0:10:600 (61 columns)
% Ygrid: -200:10:200 (41 rows)

    % --- 1. Define Excavation Grid Indices ---

    % X indices (300 to 500)
    % Index = (X / step) + 1
    x_start_index = 31; % (300 / 10) + 1
    x_end_index = 51;   % (500 / 10) + 1

    % Y indices (-100 to 100)
    % Index = (Y - Y_min) / step + 1
    y_start_index = 11; % (-100 - (-200)) / 10 + 1
    y_end_index = 31;   % (100 - (-200)) / 10 + 1

    % --- 2. Extract and Check Heads ---

    % Extract the head values within the excavation area
    excavationHeads = headGrid(y_start_index:y_end_index, x_start_index:x_end_index);

    % The critical head value (h_floor) for compliance is 25 m
    h_floor = 25;

    % Check if ALL head values in the excavation area are less than or equal to h_floor.
    % The `all(all(...))` ensures all elements in the 2D array satisfy the condition.
    isCompliant = all(all(excavationHeads <= h_floor));

    % --- 3. Set Output and Display Results ---

    pass = isCompliant;

    if pass
        disp(' ');
        disp('*** COMPLIANCE CHECK: PASS ***');
        disp('All head values in the excavation are below 25 m.');
        disp(' ');
    else
        % Find the max head value to report the violation
        max_h = max(max(excavationHeads));
        disp(' ');
        disp('*** COMPLIANCE CHECK: FAIL ***');
        disp(['Maximum head in excavation is ', num2str(max_h, 4), ' m, which exceeds the ', num2str(h_floor), ' m limit.']);
        disp(' ');
    end

end
