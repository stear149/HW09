function [c, ceq] = constraintFcn(x, layout)
% CONSTRAINTFCN runs the simulation and returns the constraint value.
% fmincon tries to make c <= 0.
% We define c = max_head_in_excavation - 25.
%
% x = [p1, p2, p3, p4, p5]

    % --- 1. Build the Wells matrix based on layout ---
    Wells = buildWellsMatrix(x, layout);
    
    % --- 2. Define Grids ---
    xgrid = 0:10:600;  % 61 columns
    ygrid = -200:10:200; % 41 rows
    headGrid = NaN(41, 61);

    % --- 3. Compute Head Grid ---
    % This is the core simulation part
    for row = 1:41
        for col = 1:61
            headGrid(row, col) = computeHead(xgrid(col), ygrid(row), ...
                Wells(:,1), Wells(:,2), Wells(:,3));
        end
    end
    
    % --- 4. Extract Excavation Heads ---
    % These indices are from your complianceChecker
    x_start_index = 31; % (300 / 10) + 1
    x_end_index = 51;   % (500 / 10) + 1
    y_start_index = 11; % (-100 - (-200)) / 10 + 1
    y_end_index = 31;   % (100 - (-200)) / 10 + 1
    
    excavationHeads = headGrid(y_start_index:y_end_index, x_start_index:x_end_index);
    
    % --- 5. Calculate Constraint Violation ---
    h_floor = 25;
    max_h = max(excavationHeads(:)); % Find the single max value
    
    % fmincon wants c <= 0.
    % Our requirement is max_h <= h_floor.
    % So, we set c = max_h - h_floor.
    c = max_h - h_floor;
    
    % We have no equality constraints
    ceq = []; 
end