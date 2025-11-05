function [] = runGlobalOptimization()
% RUNGLOBALOPTIMIZATION runs GA (global) + fmincon (local) for all 4 layouts.
%
%   This function uses the Genetic Algorithm (ga) for a robust global
%   search, and then automatically uses fmincon as a 'HybridFcn' to
%   refine the result to a precise local minimum.
%
%   This is the most robust way to find the true optimal solution.
%
%   x = [p1, p2, p3, p4, p5]
%

    disp('Starting GLOBAL optimization (GA + fmincon) for all 4 layouts...');
    
    % --- Start Parallel Pool (if you have the Parallel Toolbox) ---
    % GA runs much faster in parallel.
    if isempty(gcp('nocreate')) % If no pool exists
        try
            parpool; % Start a new parallel pool
        catch ME
            disp('Could not start parallel pool. GA will run in serial.');
            disp(ME.message);
        end
    end
    
    % Store results
    results = cell(4, 1);
    optimal_fvals = NaN(4, 1);
    
    % --- 1. Define Options for GA and FMINCON ---
    
    % First, create options for the 'fmincon' hybrid function
    % We want it to be quiet, since GA will be reporting progress.
    fmincon_options = optimoptions('fmincon', ...
        'Algorithm', 'sqp', ...
        'Display', 'none', ... % 'fmincon' itself will be silent
        'MaxFunctionEvaluations', 1000);

    % Now, create options for 'ga'
    ga_options = optimoptions('ga', ...
        'Display', 'iter', ...     % Show GA's progress
        'UseParallel', true, ...   % CRITICAL for speed
        'HybridFcn', {@fmincon, fmincon_options}); % Use fmincon to polish
    
    nvars = 5; % Number of variables (p1, p2, p3, p4, p5)
        
    for layout = 1:4
        fprintf('\n\n--- RUNNING GA FOR LAYOUT %d ---\n', layout);
        
        % --- 2. Define bounds (lb, ub) ---
        % x = [p1, p2, p3, p4, p5]
        switch layout
            case 1 % 2-2-1
                lb = [0,   300, 0, 0, 0];
                ub = [100, 500, 500, 500, 500];
                
            case 2 % 3-2-0
                lb = [0,   300, 0, 0, 0];
                ub = [100, 500, 500, 500, 500];
                
            case 3 % 1-4-0
                lb = [300, 300, 0, 0, 0];
                ub = [500, 500, 500, 500, 500];
                
            case 4 % 1-2-2
                lb = [300, 0,   0, 0, 0];
                ub = [500, 100, 500, 500, 500];
        end
        
        % --- 3. Define function handles ---
        objFun = @objectiveFcn; % Objective is the same for all
        conFun = @(x) constraintFcn(x, layout); % Pass layout
        
        % --- 4. Run ga ---
        % GA does not require an initial guess (x0)
        try
            [x_opt, fval] = ga(objFun, nvars, ...
                [], [], ...     % A, b (no linear inequality constraints)
                [], [], ...     % Aeq, beq (no linear equality constraints)
                lb, ub, ...     % Lower and upper bounds
                conFun, ...     % Nonlinear constraint function
                ga_options);    % GA options
            
            % Check if solution is actually valid
            [c_final, ~] = conFun(x_opt);
            if c_final > 1e-3 % Check if constraint is violated
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
                disp('Optimal parameters [p1, p2, p3, p4, p5]:');
                disp(x_opt);
                fprintf('Minimum Q_total: %f m^3/day\n', fval);
            end
            
        catch ME
            fprintf('--- LAYOUT %d FAILED TO SOLVE --- \n', layout);
            disp(ME.message);
            results{layout}.x_opt = [];
            results{layout}.fval = Inf;
            optimal_fvals(layout) = Inf;
        end
    end
    
    % --- 5. Find and report the best layout ---
    [min_Q, best_layout_idx] = min(optimal_fvals);
    
    if isinf(min_Q)
        disp(' ');
        disp('*** ALL OPTIMIZATIONS FAILED ***');
        disp('Could not find a compliant solution for any layout.');
        return;
    end
    
    best_x = results{best_layout_idx}.x_opt;
    
    fprintf('\n\n==============================================\n');
    fprintf('        GLOBAL OPTIMIZATION COMPLETE \n');
    fprintf('==============================================\n');
    fprintf('Best Layout: %d\n', best_layout_idx);
    fprintf('Minimum Q_total: %f m^3/day\n', min_Q);
    disp('Optimal Parameters [p1, p2, p3, p4, p5]:');
    disp(best_x);
    
    % --- 6. Build the final Wells matrix for the best solution ---
    Wells_final = buildWellsMatrix(best_x, best_layout_idx);
    
    % --- 7. Visualize and check the final solution ---
    disp('Visualizing the best solution...');
    headGrid_final = drawSite(Wells_final(:,1), Wells_final(:,2), Wells_final(:,3));
    
    disp('Running final compliance check on the best solution:');
    complianceChecker(headGrid_final);

end