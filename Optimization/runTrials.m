% runTrials.m

% --- Configuration ---
N = 100; % Define the total number of times to run the optimization

% Initialize a cell array to store the results from each trial (N trials)
% Each cell will store an 8x6 matrix (8 layouts, 6 columns of data)
all_trial_results = cell(N, 1);

fprintf('Starting %d global optimization trials...\n', N);

% --- Run Loop ---
for trial = 1:N
    fprintf('\n\n===================================================\n');
    fprintf('              STARTING TRIAL %d OF %d\n', trial, N);
    fprintf('===================================================\n');
    
    % Call the modified optimization function
    % This returns the 8x6 matrix [Q_total, p1, p2, p3, p4, p5] for all 8 layouts
    LayoutResults_i = runGlobalOptimization();
    
    % Store the 8x6 matrix for this trial
    all_trial_results{trial} = LayoutResults_i;
    
    fprintf('\n--- TRIAL %d COMPLETE ---\n', trial);
end

% --- Final Data Consolidation and Saving ---

% Concatenate all 8x6 matrices vertically into one large matrix.
% Total size will be (N * 8) x 6
FinalResultsMatrix = vertcat(all_trial_results{:});

% Add a column to identify the trial number and layout
num_successful_rows = size(FinalResultsMatrix, 1);
TrialIndexColumn = repelem(1:N, 8)'; % Repeat trial number 8 times
LayoutIndexColumn = repmat(1:8, 1, N)'; % Repeat 1 to 8, N times

% Final consolidated matrix: [Trial #, Layout #, Q_total, p1, p2, p3, p4, p5]
FinalSaveMatrix = [TrialIndexColumn, LayoutIndexColumn, FinalResultsMatrix];

% Define column headers for clarity
header = {'Trial_N', 'Layout_ID', 'Q_total', 'p1', 'p2', 'p3', 'p4', 'p5'};

% Save the final matrix to a file
outputFileName = sprintf('GlobalOptimization_Results_%d_Trials_%s.mat', N, datestr(now, 'yyyy-mm-dd_HHMM'));
save(outputFileName, 'FinalSaveMatrix', 'header');

fprintf('\n\nAll %d trials complete.\n', N);
fprintf('Final results saved to: **%s**\n', outputFileName);