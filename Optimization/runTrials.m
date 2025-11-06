% runTrials_v2.m
%
% This script runs the optimization function multiple times (N trials),
% choosing between the Global (GA + fmincon) or Local (fmincon only) solver.
% It consolidates results, saves them to a .mat file, and generates a
% comparative plot of Q_total performance across the 8 layouts.

% --- Configuration ---
N = 10; % Define the total number of times to run the optimization (Adjust as needed)

% --- NEW: Optimization Type Selector ---
% Set to 'Global' to run GA + fmincon (slower, more robust)
% Set to 'Local' to run fmincon only (faster, dependent on starting point)
OptimizationType = 'Global'; % **<-- SET OPTIMIZATION TYPE HERE**

% --- Function Handle Setup ---
if strcmpi(OptimizationType, 'Global')
    % Assumes 'runGlobalOptimization.m' is in the path
    optim_function = @runGlobalOptimization;
    optim_name = 'Global (GA + fmincon)';
elseif strcmpi(OptimizationType, 'Local')
    % Assumes 'runLocalOptimization.m' is in the path
    optim_function = @runLocalOptimization;
    optim_name = 'Local (fmincon only)';
else
    error('Invalid OptimizationType. Please use ''Global'' or ''Local''.');
end


% Initialize a cell array to store the results from each trial (N trials)
all_trial_results = cell(N, 1);

fprintf('Starting %d **%s** optimization trials...\n', N, optim_name);
fprintf('Optimization function: %s\n', func2str(optim_function));

% --- Run Loop ---
for trial = 1:N
    fprintf('\n\n===================================================\n');
    fprintf('           STARTING TRIAL %d OF %d (%s)\n', trial, N, OptimizationType);
    fprintf('===================================================\n');
    
    % Call the selected optimization function
    % [Q_total, p1, p2, p3, p4, p5] for all 8 layouts
    LayoutResults_i = optim_function();
    
    % Store the 8x6 matrix for this trial
    all_trial_results{trial} = LayoutResults_i;
    
    fprintf('\n--- TRIAL %d COMPLETE ---\n', trial);
end

% --- 1. Data Consolidation and Saving ---

% Filter out any empty results in case a trial failed completely 
valid_results_cells = all_trial_results(~cellfun('isempty', all_trial_results));

if isempty(valid_results_cells)
    error('All %d optimization trials failed to return results. Cannot proceed with plotting or saving.', N);
end

% Concatenate all 8x6 matrices vertically into one large matrix.
FinalResultsMatrix = vertcat(valid_results_cells{:});

% Determine the actual number of full trials successfully run
num_successful_trials = size(FinalResultsMatrix, 1) / 8;

% Create index columns for the consolidated data
TrialIndexColumn = repelem(1:num_successful_trials, 8)'; 
LayoutIndexColumn = repmat(1:8, 1, num_successful_trials)'; 

% Final consolidated matrix: [Trial #, Layout #, Q_total, p1, p2, p3, p4, p5]
FinalSaveMatrix = [TrialIndexColumn, LayoutIndexColumn, FinalResultsMatrix];

% Define column headers for clarity
header = {'Trial_N', 'Layout_ID', 'Q_total', 'p1', 'p2', 'p3', 'p4', 'p5'};

% Save the final matrix to a file
% Include optimization type in the filename
outputFileName = sprintf('%s_Optimization_Results_%d_Trials_%s.mat', OptimizationType, num_successful_trials, datestr(now, 'yyyy-mm-dd_HHMM'));
save(outputFileName, 'FinalSaveMatrix', 'header', 'OptimizationType');

fprintf('\n\nAll %d trials complete.\n', N);
fprintf('Total successful layouts: %d\n', size(FinalResultsMatrix, 1));
fprintf('Final results saved to: **%s**\n', outputFileName);

% --- 2. Plotting and Statistical Analysis ---

% Isolate relevant data: [Layout ID, Q_total]
PlotData = FinalSaveMatrix(:, [2, 3]); 

% Filter out failed runs (where Q_total is Inf or NaN)
PlotData = PlotData(~isinf(PlotData(:, 2)) & ~isnan(PlotData(:, 2)), :);

if isempty(PlotData)
    warning('No successful runs to plot after filtering infeasible solutions.');
    return;
end

% Preallocate arrays for statistics
num_layouts = 8;
mean_Q = NaN(1, num_layouts);
min_Q = NaN(1, num_layouts);

% Calculate mean and min Q_total for each layout
for i = 1:num_layouts
    Q_for_layout = PlotData(PlotData(:, 1) == i, 2);
    
    if ~isempty(Q_for_layout)
        mean_Q(i) = mean(Q_for_layout);
        min_Q(i) = min(Q_for_layout);
    end
end

% --- Find the Single Global Minimum ---
[global_min_Q, global_min_idx_in_plotdata] = min(PlotData(:, 2));
global_min_Layout = PlotData(global_min_idx_in_plotdata, 1);

% --- Create the Plot ---
figure;
hold on;
grid on;

% 1. Scatter Plot of all individual runs (Layout vs. Q_total)
h_scatter = scatter(PlotData(:, 1), PlotData(:, 2), 50, 'b', 'filled', 'MarkerFaceAlpha', 0.2, 'DisplayName', 'Individual Trial Results'); 

% 2. Plot the Mean Q_total for each layout
h_mean = plot(1:num_layouts, mean_Q, 'k--', 'LineWidth', 2, 'DisplayName', 'Mean Q_{total}');

% 3. Plot the Minimum Q_total (best performance) for each layout - using a large marker
h_min = plot(1:num_layouts, min_Q, 'r^', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'r', 'DisplayName', 'Min Q_{total} (Layout)');

% 4. Plot the ABSOLUTE Lowest Q_total across all layouts
h_global_min = scatter(global_min_Layout, global_min_Q, 150, 'g', 'o', 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'DisplayName', 'Global Minimum Q_{total}');


% --- Plot Customization ---
title(sprintf('%s Optimization Results: Q_{total} vs. Layout (N=%d Trials)', optim_name, N));
xlabel('Layout ID');
ylabel('Q_{total} (m^3/day)');

% Set X-axis ticks to show discrete layout IDs
xticks(1:num_layouts); 
xlim([0.5 num_layouts + 0.5]);

% Add a legend
legend([h_scatter, h_mean, h_min, h_global_min], 'Location', 'Best');

hold off;