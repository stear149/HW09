function[headGrid] =  drawSite(x, y, q)
    figure;   
    theme light;
    axis equal; % change aspect ratio to equal

    % --- 1. Define Grid and Calculate Dynamic Size ---

    % Set the desired step size (e.g., 0.5 for high accuracy)
    step_size = 5;

    xgrid = [0:step_size:600];
    ygrid = [-200:step_size:200];
    
    % Dynamically calculate the dimensions of the head grid
    num_x_points = length(xgrid); % Number of columns (e.g., 1201 for 0.5 step)
    num_y_points = length(ygrid); % Number of rows (e.g., 801 for 0.5 step)

    % Initialize headGrid with the calculated dimensions
    headGrid = NaN(num_y_points, num_x_points);

    % --- 2. Compute Head Values ---

    for row = 1:num_y_points
        for col = 1:num_x_points
            headGrid(row, col) = computeHead(xgrid(col), ygrid(row), x, y, q); 
        end
    end
    
        hold on;
        axis equal; % change aspect ratio to equal
        % Visualize the head grid as a topographical map
        contourf(xgrid, ygrid, headGrid, 50, 'LineColor', 'none'); % Use contour3 for a topographical effect
        colorbar; % Add a color bar to indicate values
    
        contour(xgrid, ygrid, headGrid, [25, 25], 'LineColor', 'k', 'LineWidth', 2);
    
    
        
        plot([0,0],[-200,200],'-b',LineWidth=5) % plot river
    
        plot([300,500,500,300,300],[-100,-100,100,100,-100],Color='k', LineWidth=2) % plot dig site
    
        %ploting wells
        well_labels = {'Well 1', 'Well 2', 'Well 3', 'Well 4', 'Well 5'};
        for i = 1:5
            plot(x(i), y(i), 'o', MarkerEdgeColor='black', MarkerFaceColor='r'); % plot points at (x(i), y(i))
            text(x(i), y(i) + 10, well_labels(i), 'Color', 'k', 'FontWeight', 'bold')
    
        end
        xlabel('Easting [m]');
        ylabel('Northing [m]');
        title('Site Visualization (Optimal Solution)');
        
        % Set axis limits for clarity
        xlim([-50 650]);
        ylim([-250 250]);
        
        % Add a colorbar label
        h = colorbar;
        ylabel(h, 'Water Table Head (m)')

        hold off;

        
end