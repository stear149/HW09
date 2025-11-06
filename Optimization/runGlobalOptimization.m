function [AllLayoutResults] = runGlobalOptimization()
% RUNGLOBALOPTIMIZATION runs GA (global) + fmincon (local) for all 8 layouts.
%
%   This function uses the Genetic Algorithm (ga) for a robust global
%   search, and then automatically uses fmincon as a 'HybridFcn' to
%   refine the result to a precise local minimum.
%
%   A final rounding step is applied to the optimal parameters before 
%   the compliance check and visualization.
%
%   x = [p1, p2, p3, p4, p5]
%
%   OUTPUT:
%   AllLayoutResults (8x6 matrix): [Q_total, p1, p2, p3, p4, p5] for all 8 layouts.
%   Infeasible solutions will have Q_total = Inf.

    disp('Starting GLOBAL optimization (GA + fmincon) for all 8 layouts...');
    
    % --- Start Parallel Pool (if you have the Parallel Toolbox) ---
    if isempty(gcp('nocreate')) % If no pool exists
        try
            parpool; % Start a new parallel pool
        catch ME
            disp('Could not start parallel pool. GA will run in serial.');
            disp(ME.message);
        end
    end
    
    % Store results
    results = cell(8, 1); % Updated to 8 results
    optimal_fvals = NaN(8, 1); % Updated to 8 results
    
    % --- 1. Define Options for GA and FMINCON ---
    
    % Options for the 'fmincon' hybrid function (fast local refinement)
    fmincon_options = optimoptions('fmincon', ...
        'Algorithm', 'sqp', ...
        'Display', 'none', ... 
        'MaxFunctionEvaluations', 1000);

    % Options for 'ga' (global search)
    ga_options = optimoptions('ga', ...
        'Display', 'iter', ...     
        'UseParallel', true, ...
        'EliteCount',20,...
        'FunctionTolerance', 1e-7,...
        'MaxStallGenerations',50,...
        'HybridFcn', {@fmincon, fmincon_options}); % Use fmincon to polish
    
    nvars = 5; % Number of variables (p1, p2, p3, p4, p5)
    
    % Initialize the matrix to store results for all 8 layouts: [Q_total, p1, p2, p3, p4, p5]
    AllLayoutResults = NaN(8, 6); 
        
    for layout = 1:8 % Updated loop to run 8 layouts
        fprintf('\n\n--- RUNNING GA FOR LAYOUT %d ---\n', layout);
        
        % --- 2. Define bounds (lb, ub) based on new cases ---
        % x = [p1, p2, p3, p4, p5]
        % Bounds for Q rates (p3, p4, p5) are assumed to be [0, 500]
        max_Q = 500; 

        switch layout
            case 1 % 2-2-1: p1=[0,100], p2=[300,500]
                lb = [0,   300, 0, 0, 0];
                ub = [100, 500, max_Q, max_Q, max_Q];
                
            case 2 % 1-2-2: p1=[300,500], p2=[0,100]
                lb = [300, 0,   0, 0, 0];
                ub = [500, 100, max_Q, max_Q, max_Q];
                
            case 3 % 3-2-0: p1=[0,100], p2=[300,500]
                lb = [0,   300, 0, 0, 0];
                ub = [100, 500, max_Q, max_Q, max_Q];
                
            case 4 % 3-0-2: p1=[0,100], p2=[0,100]
                lb = [0,   0,   0, 0, 0];
                ub = [100, 100, max_Q, max_Q, max_Q];

            case 5 % 2-0-3: p1=[0,100], p2=[0,100]
                lb = [0,   0,   0, 0, 0];
                ub = [100, 100, max_Q, max_Q, max_Q];

            case 6 % 0-2-3: p1=[300,500], p2=[0,100]
                lb = [300, 0,   0, 0, 0];
                ub = [500, 100, max_Q, max_Q, max_Q];

            case 7 % 1-4-0: p1=[300,500], p2=[300,500]
                lb = [300, 300, 0, 0, 0];
                ub = [500, 500, max_Q, max_Q, max_Q];

            case 8 % 0-4-1: p1=[300,500], p2=[300,500]
                lb = [300, 300, 0, 0, 0];
                ub = [500, 500, max_Q, max_Q, max_Q];

            otherwise
                error('Invalid layout index: %d', layout);
        end
        
        % --- 3. Define function handles ---
        objFun = @objectiveFcn; 
        conFun = @(x) constraintFcn(x, layout); 
        
        % --- 4. Run ga ---
        try
            [x_opt, fval] = ga(objFun, nvars, ...
                [], [], ...     % A, b 
                [], [], ...     % Aeq, beq 
                lb, ub, ...     % Lower and upper bounds
                conFun, ...     % Nonlinear constraint function
                ga_options);    % GA options
            
            % Check if the solution is compliant (constraint c <= 0)
            [c_final, ~] = conFun(x_opt);
            if c_final > 1e-3 
                fprintf('--- LAYOUT %d FAILED --- \n', layout);
                disp('Optimizer returned an infeasible solution (head > 25m).');
                fval_final = Inf;
                x_opt_final = NaN(1, 5); % Use NaN for parameters
            else
                fval_final = fval;
                x_opt_final = x_opt;
                
                fprintf('--- LAYOUT %d COMPLETE --- \n', layout);
                fprintf('Continuous Q_total: %f m^3/day\n', fval_final);
            end
            
        catch ME
            fprintf('--- LAYOUT %d FAILED TO SOLVE --- \n', layout);
            disp(ME.message);
            fval_final = Inf;
            x_opt_final = NaN(1, 5); % Use NaN for parameters
        end

        % Store results for returning
        AllLayoutResults(layout, :) = [fval_final, x_opt_final];
    end
    
    % --- 5. Report and Finalize Results ---
    
    fprintf('\n\n--- SUMMARY OF CONTINUOUS OPTIMIZATION RESULTS ---\n');
    valid_results = AllLayoutResults(~isinf(AllLayoutResults(:,1)), :);
    
    if isempty(valid_results)
        disp(' ');
        disp('*** ALL OPTIMIZATIONS FAILED ***');
        disp('Could not find a compliant solution for any layout. Returning NaN/Inf matrix.');
        return;
    end

    % Report results for each layout run
    for layout_idx = 1:8
        fval = AllLayoutResults(layout_idx, 1);
        
        if isinf(fval)
            fprintf('Layout %d: FAILED (Infeasible). Results set to Inf/NaN.\n', layout_idx);
        else
            x_opt = AllLayoutResults(layout_idx, 2:end);
            % Format the p-values for clear display
            p_values_str = sprintf('[%5.1f, %5.1f, %5.3f, %5.3f, %5.3f]', x_opt);
            
            fprintf('Layout %d: Q_total = %f m^3/day, x_opt = %s\n', ...
                    layout_idx, fval, p_values_str);
        end
    end

    % Find the best continuous solution for visualization
    [min_Q, best_row_idx] = min(AllLayoutResults(:, 1));
    
    best_x = AllLayoutResults(best_row_idx, 2:end); % Parameters p1-p5
    best_layout_idx = best_row_idx; % Layout index is the row index
    
    % Apply the required rounding to the best continuous solution
    best_x_rounded = roundOptimalSolution(best_x);
    
    % Recalculate Q_total with the rounded values for reporting
    min_Q_rounded = objectiveFcn(best_x_rounded);

    fprintf('\n\n==============================================\n');
    fprintf('        GLOBAL OPTIMIZATION COMPLETE \n');
    fprintf('==============================================\n');
    fprintf('Best Layout: %d\n', best_layout_idx);
    fprintf('Minimum Q_total (Rounded): %f m^3/day\n', min_Q_rounded);
    disp('Optimal Parameters (Rounded) [p1 (0.5m), p2 (0.5m), Q (3 dec)]:');
    disp(best_x_rounded);
    
    % --- 6. Build the final Wells matrix for the best *rounded* solution ---
    Wells_final = buildWellsMatrix(best_x_rounded, best_layout_idx);
    
    % % --- 7. Visualize and check the final solution ---
    % disp('Visualizing the best rounded solution...');
    % headGrid_final = drawSite(Wells_final(:,1), Wells_final(:,2), Wells_final(:,3));
    % 
    % disp('Running final compliance check on the best ROUNDED solution:');
    % complianceChecker(headGrid_final);

end