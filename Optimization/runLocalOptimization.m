function [AllLayoutResults] = runLocalOptimization()
% RUNLOCALOPTIMIZATION runs fmincon (local) for all 8 layouts with
% a predefined, fixed starting point.
%
%   This function uses the fmincon solver for a fast, local search.
%   NOTE: The result is highly dependent on the starting point (x0).
%   It is significantly faster than GA but might find a poorer (higher)
%   local minimum or fail to find a solution.
%
%   x = [p1, p2, p3, p4, p5]
%
%   OUTPUT:
%   AllLayoutResults (8x6 matrix): [Q_total, p1, p2, p3, p4, p5] for all 8 layouts.
%   Infeasible solutions will have Q_total = Inf.

    disp('Starting LOCAL optimization (fmincon) for all 8 layouts...');

    % --- 1. Define Options for FMINCON ---
    
    % Options for 'fmincon' (local refinement)
    fmincon_options = optimoptions('fmincon', ...
        'Algorithm', 'sqp', ... % Sequential Quadratic Programming (SQP)
        'Display', 'none', ...  % Show iteration output
        'MaxFunctionEvaluations', 5000); % Increased from 1000

    nvars = 5; % Number of variables (p1, p2, p3, p4, p5)
    
    % Initialize the matrix to store results: [Q_total, p1, p2, p3, p4, p5]
    AllLayoutResults = NaN(8, 6); 
        
    for layout = 1:8
        fprintf('\n\n--- RUNNING FMINCON FOR LAYOUT %d ---\n', layout);
        
        % --- 2. Define bounds (lb, ub) and a starting point (x0) ---
        % x = [p1, p2, p3, p4, p5]
        max_Q = 500; 
        
        % Define bounds (lb, ub) based on the original script
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
        
        % Define the fixed starting point (x0). A central point is a good guess.
        % (p1_mid, p2_mid, Q1=100, Q2=100, Q3=100)
        p1_mid = mean([lb(1), ub(1)]);
        p2_mid = mean([lb(2), ub(2)]);
        x0 = [p1_mid, p2_mid, 100, 100, 100]; 

        % --- 3. Define function handles ---
        objFun = @objectiveFcn; 
        conFun = @(x) constraintFcn(x, layout); 
        
        % --- 4. Run fmincon ---
        try
            % The standard fmincon syntax
            [x_opt, fval, exitflag, output] = fmincon(objFun, x0, ...
                [], [], ...     % A, b (Linear Inequality)
                [], [], ...     % Aeq, beq (Linear Equality)
                lb, ub, ...     % Lower and upper bounds
                conFun, ...     % Nonlinear constraint function
                fmincon_options);% Fmincon options
            
            % Check if the solution is compliant (constraint c <= 0) and successful (exitflag > 0)
            [c_final, ~] = conFun(x_opt);
            
            % Check feasibility (c > 0) or if solver failed (exitflag <= 0)
            if c_final > 1e-3 || exitflag <= 0
                fprintf('--- LAYOUT %d FAILED --- \n', layout);
                disp(['Optimizer returned an infeasible solution (head > 25m) or failed to converge. Exit flag: ', num2str(exitflag)]);
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
    
    % --- 5. Report and Finalize Results (Same as original script) ---
    
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
    fprintf('        LOCAL OPTIMIZATION COMPLETE \n');
    fprintf('==============================================\n');
    fprintf('Best Layout: %d\n', best_layout_idx);
    fprintf('Minimum Q_total (Rounded): %f m^3/day\n', min_Q_rounded);
    disp('Optimal Parameters (Rounded) [p1 (0.5m), p2 (0.5m), Q (3 dec)]:');
    disp(best_x_rounded);
    
    % --- 6. Build the final Wells matrix for the best *rounded* solution ---
    % NOTE: Functions like roundOptimalSolution, objectiveFcn, buildWellsMatrix, 
    %       and complianceChecker are assumed to be available in the workspace.
    Wells_final = buildWellsMatrix(best_x_rounded, best_layout_idx);
    
    % --- 7. Visualize and check the final solution (uncomment as needed) ---
    % disp('Visualizing the best rounded solution...');
    % headGrid_final = drawSite(Wells_final(:,1), Wells_final(:,2), Wells_final(:,3));
    % 
    % disp('Running final compliance check on the best ROUNDED solution:');
    % complianceChecker(headGrid_final);

end