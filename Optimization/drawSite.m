function[headGrid] =  drawSite(x, y, q)
    figure;   
    % theme light; % 'theme' is not a standard MATLAB function, commented out
    axis equal; % change aspect ratio to equal


    xgrid = [0:10:600];
    ygrid = [-200:10:200];

    headGrid = NaN(41,61);

    for row = 1:41
        for col = 1:61
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