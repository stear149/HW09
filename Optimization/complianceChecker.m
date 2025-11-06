function[pass] = complianceChecker(headGrid)
% COMPLIANCECHECKER checks if the computed head grid meets the homework requirements.

    % --- 1. Define Fixed Site Parameters ---
    
    % Dimensions of the *entire* computed grid (from drawSite.m)
    x_min = 0;
    x_max = 600;
    y_min = -200;
    y_max = 200;

    % Dimensions of the *excavation* area
    x_dig_start = 300;
    x_dig_end = 500;
    y_dig_start = -100;
    y_dig_end = 100;

    % Critical Head Value
    h_floor = 25; % 30 m (initial head) - 5 m (excavation depth)

    % --- 2. Calculate Dynamic Grid Parameters ---

    % Get the size of the headGrid
    [num_y_points, num_x_points] = size(headGrid);

    % Calculate the step size based on the grid dimensions
    % Note: num_points = (max - min) / step + 1  =>  step = (max - min) / (num_points - 1)
    step_x = (x_max - x_min) / (num_x_points - 1);
    step_y = (y_max - y_min) / (num_y_points - 1);

    % --- 3. Determine Excavation Grid Indices ---

    % Index = (Coordinate - Min_Coordinate) / Step + 1
    
    % X indices
    x_start_index = round((x_dig_start - x_min) / step_x) + 1;
    x_end_index   = round((x_dig_end - x_min) / step_x) + 1;
    
    % Y indices
    y_start_index = round((y_dig_start - y_min) / step_y) + 1;
    y_end_index   = round((y_dig_end - y_min) / step_y) + 1;

    % --- 4. Extract and Check Heads ---

    % Extract the head values within the excavation area
    excavationHeads = headGrid(y_start_index:y_end_index, x_start_index:x_end_index);

    % Check if ALL head values in the excavation area are less than or equal to h_floor.
    isCompliant = all(all(excavationHeads <= h_floor));

    % --- 5. Set Output and Display Results ---

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