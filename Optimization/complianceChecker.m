function[pass] = complianceChecker(headGrid)
% COMPLIANCECHECKER checks if the computed head grid meets the homework requirements.

    % --- 1. Define Excavation Grid Indices ---
    x_start_index = 31; % (300 / 10) + 1
    x_end_index = 51;   % (500 / 10) + 1
    y_start_index = 11; % (-100 - (-200)) / 10 + 1
    y_end_index = 31;   % (100 - (-200)) / 10 + 1

    % --- 2. Extract and Check Heads ---
    excavationHeads = headGrid(y_start_index:y_end_index, x_start_index:x_end_index);
    h_floor = 25;
    isCompliant = all(all(excavationHeads <= h_floor));

    % --- 3. Set Output and Display Results ---
    pass = isCompliant;

    if pass
        disp(' ');
        disp('*** COMPLIANCE CHECK: PASS ***');
        disp('All head values in the excavation are below 25 m.');
        disp(' ');
    else
        max_h = max(max(excavationHeads));
        disp(' ');
        disp('*** COMPLIANCE CHECK: FAIL ***');
        disp(['Maximum head in excavation is ', num2str(max_h, 4), ' m, which exceeds the ', num2str(h_floor), ' m limit.']);
        disp(' ');
    end

end