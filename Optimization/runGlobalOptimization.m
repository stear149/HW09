function [AllLayoutResults] = runGlobalOptimization()
% RUNGLOBALOPTIMIZATION runs GA (global) + fmincon (local) for all 8 layouts.
%
% This function uses the Genetic Algorithm (ga) for a robust global
% search, and then automatically uses fmincon as a 'HybridFcn' to
% refine the result to a precise local minimum.
%
% A CRITICAL POST-ROUNDING REFINEMENT STEP is added:
% If the optimal rounded solution is infeasible, fmincon is used to 
% push it back into the compliant region, ensuring the final output passes 
% the compliance check (max head <= 25m).
%
% x = [p1, p2, p3, p4, p5]
%
% OUTPUT:
% AllLayoutResults (8x6 matrix): [Q_total, p1, p2, p3, p4, p5] for all 8 layouts.
% Infeasible solutions will have Q_total = Inf.

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
        'FunctionTolerance', 1e-5,...
        'Display', 'none', ... 
        'MaxFunctionEvaluations', 1000);

    % Options for 'ga' (global search)
    ga_options = optimoptions('ga', ...
        'Display', 'iter', ...     
        'UseParallel', true, ...
        'EliteCount',10,...
        'FunctionTolerance', 1e-5,...
        'MaxStallGenerations',20,...
        'HybridFcn', {@fmincon, fmincon_options}); % Use fmincon to polish
    
    nvars = 5; % Number of variables (p1, p2, p3, p4, p5)
    
    % Initialize the matrix to store results for all 8 layouts: [Q_total, p1, p2, p3, p4, p5]
    AllLayoutResults = NaN(8, 6); 
        
    for layout = 1:8 % Updated loop to run 8 layouts
        fprintf('\n\n--- RUNNING GA FOR LAYOUT %d ---\n', layout);
        
        % --- 2. Define bounds (lb, ub) based on new cases ---
        % x = [p1, p2, p3, p4, p5]
        [lb, ub] = getLayoutBounds(layout); % Use helper function
        
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
    
    % --- 5. Report and Find Best Continuous Solution ---
    
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

    % Find the best continuous solution
    [min_Q, best_row_idx] = min(AllLayoutResults(:, 1));
    best_x = AllLayoutResults(best_row_idx, 2:end); % Parameters p1-p5
    best_layout_idx = best_row_idx; % Layout index is the row index
    
    % Apply the required rounding to the best continuous solution
    best_x_rounded = roundOptimalSolution(best_x);
    
% --- 6. POST-ROUNDING REFINEMENT (The fix for compliance) ---
    
    fprintf('\n\n--- POST-ROUNDING REFINEMENT FOR LAYOUT %d ---\n', best_layout_idx);
    
    % Define function handles for the best layout
    objFun = @objectiveFcn; 
    conFun = @(x) constraintFcn(x, best_layout_idx); 
    
    % Check compliance of the initial rounded solution
    [c_rounded, ~] = conFun(best_x_rounded);
    
    if c_rounded < 1e-3 % Check if the rounded solution is already compliant
        
        % If compliant, use the rounded solution directly
        x_final = best_x_rounded;
        fval_final = objectiveFcn(x_final);
        
        fprintf('Initial rounded solution is compliant (c=%.3f).\n', c_rounded);
    else
        
        % If NOT compliant, use fmincon to push it back into the feasible region
        fprintf('Rounded solution is INCOMPLIANT (c=%.3f). Starting local refinement...\n', c_rounded);

        % Retrieve bounds for fmincon
        [lb, ub] = getLayoutBounds(best_layout_idx);

        % Options for the refinement fmincon call
        fmincon_refine_options = optimoptions('fmincon', ...
            'Algorithm', 'sqp', ...
            'Display', 'final', ... 
            'MaxFunctionEvaluations', 2000); 
            
        % Initial guess is the (infeasible) rounded solution
        x0 = best_x_rounded; 
        
        % Run fmincon to refine the rounded solution to the nearest compliant minimum
        [x_refined, fval_refined] = fmincon(objFun, x0, ...
            [], [], ...     % A, b 
            [], [], ...     % Aeq, beq 
            lb, ub, ...     % Lower and upper bounds
            conFun, ...     % Nonlinear constraint function
            fmincon_refine_options); 
        
        % Check final compliance of the refined solution
        [c_refined, ~] = conFun(x_refined);
        if c_refined > 1e-3
            warning('Refinement FAILED to find a compliant solution. Final result may be infeasible.');
        end
        
        % The critical final step: Re-round the refined solution to enforce precision
        x_final = roundOptimalSolution(x_refined);
        fval_final = objectiveFcn(x_final);
        
        fprintf('Refined parameters were successfully found and re-rounded.\n');
    end
    
    % Final Check and Report
    [c_final_check, ~] = conFun(x_final);
    
    if c_final_check > 1e-3
        fprintf('\n*** WARNING: FINAL ROUNDED SOLUTION IS STILL INFEASIBLE (c=%.3f) ***\n', c_final_check);
    else
        fprintf('\nFINAL ROUNDED SOLUTION IS COMPLIANT (c=%.3f).\n', c_final_check);
    end

    fprintf('\n\n==============================================\n');
    fprintf('        GLOBAL OPTIMIZATION COMPLETE \n');
    fprintf('==============================================\n');
    fprintf('Best Layout: %d\n', best_layout_idx);
    fprintf('Minimum Q_total (Final Rounded, Compliant): %f m^3/day\n', fval_final);
    disp('Optimal Parameters (Final Rounded) [p1 (0.5m), p2 (0.5m), Q (3 dec)]:');
    disp(x_final);
    
    % --- 7. Build the final Wells matrix for the best *rounded* solution ---
    Wells_final = buildWellsMatrix(x_final, best_layout_idx);
    
    % % --- 8. Visualize and check the final solution ---
    % disp('Visualizing the best rounded solution...');
    % headGrid_final = drawSite(Wells_final(:,1), Wells_final(:,2), Wells_final(:,3));
    % 
    % disp('Running final compliance check on the best ROUNDED solution:');
    % complianceChecker(headGrid_final);

end
