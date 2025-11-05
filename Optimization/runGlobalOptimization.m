function [] = runGlobalOptimization()
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
        'FunctionTolerance', 1e-6,...
        'MaxStallGenerations',50,...
        'HybridFcn', {@fmincon, fmincon_options}); % Use fmincon to polish
    
    nvars = 5; % Number of variables (p1, p2, p3, p4, p5)
        
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
                results{layout}.x_opt = [];
                results{layout}.fval = Inf;
                optimal_fvals(layout) = Inf;
            else
                results{layout}.x_opt = x_opt;
                results{layout}.fval = fval;
                optimal_fvals(layout) = fval;
                
                fprintf('--- LAYOUT %d COMPLETE --- \n', layout);
                fprintf('Continuous Q_total: %f m^3/day\n', fval);
            end
            
        catch ME
            fprintf('--- LAYOUT %d FAILED TO SOLVE --- \n', layout);
            disp(ME.message);
            results{layout}.x_opt = [];
            results{layout}.fval = Inf;
            optimal_fvals(layout) = Inf;
        end
    end
    
    % --- 5. Find Best Solution, Apply Rounding, and Report ---
    [min_Q, best_layout_idx] = min(optimal_fvals);
    
    if isinf(min_Q)
        disp(' ');
        disp('*** ALL OPTIMIZATIONS FAILED ***');
        disp('Could not find a compliant solution for any layout.');
        return;
    end
    
    best_x = results{best_layout_idx}.x_opt;
    
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
    
    % --- 7. Visualize and check the final solution ---
    disp('Visualizing the best rounded solution...');
    headGrid_final = drawSite(Wells_final(:,1), Wells_final(:,2), Wells_final(:,3));
    
    disp('Running final compliance check on the best ROUNDED solution:');
    complianceChecker(headGrid_final);

end