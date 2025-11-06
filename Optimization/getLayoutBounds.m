function [lb, ub] = getLayoutBounds(layout)
% Helper function to retrieve the bounds (lb, ub) for fmincon refinement.
    max_Q = 500; 
    switch layout
        case 1
            lb = [0,   300, 0, 0, 0];
            ub = [100, 500, max_Q, max_Q, max_Q];
        case 2
            lb = [300, 0,   0, 0, 0];
            ub = [500, 100, max_Q, max_Q, max_Q];
        case 3
            lb = [0,   300, 0, 0, 0];
            ub = [100, 500, max_Q, max_Q, max_Q];
        case 4
            lb = [0,   0,   0, 0, 0];
            ub = [100, 100, max_Q, max_Q, max_Q];
        case 5
            lb = [0,   0,   0, 0, 0];
            ub = [100, 100, max_Q, max_Q, max_Q];
        case 6
            lb = [300, 0,   0, 0, 0];
            ub = [500, 100, max_Q, max_Q, max_Q];
        case 7
            lb = [300, 300, 0, 0, 0];
            ub = [500, 500, max_Q, max_Q, max_Q];
        case 8
            lb = [300, 300, 0, 0, 0];
            ub = [500, 500, max_Q, max_Q, max_Q];
        otherwise
            error('Invalid layout index in getLayoutBounds: %d', layout);
    end
end