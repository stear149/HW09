function [Wells] = buildWellsMatrix(x, layout)
% BUILDWELLSMATRIX creates the 5x3 well matrix from parameters x and layout
% x = [p1, p2, p3, p4, p5]
    
    Wells = NaN(5,3);

    % Unpack parameters from x
    p1 = x(1); p2 = x(2); p3 = x(3); p4 = x(4); p5 = x(5);

    switch layout
        case 1 % 2-2-1
            % X Vals
            Wells(1:2,1) = 300; % pump 1 & 2
            Wells(3:4,1) = p2;  % pump 3 & 4
            Wells(5,1) = 500;   % pump 5
            % Y Vals
            Wells(1,2) = p1;    % y val pump 1 
            Wells(2,2) = -p1;   % y val pump 2
            Wells(3,2) = 100;   % y val pump 3
            Wells(4,2) = -100;  % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
           
        case 2 % 3-2-0 (Original code had bug)
            % X Vals
            Wells(1:2,1) = 300; % pump 1 & 2
            Wells(3:4,1) = p2;  % pump 3 & 4
            Wells(5,1) = 300;   % pump 5
            % Y Vals
            Wells(1,2) = p1;    % y val pump 1 
            Wells(2,2) = -p1;   % y val pump 2
            Wells(3,2) = 100;   % y val pump 3
            Wells(4,2) = -100;  % y val pump 4
            Wells(5,2) = 0;     % y val pump 5

        case 3 % 1-4-0 (Original code had bug)
            % X Vals
            Wells(1:2,1) = p1;  % pump 1 & 2
            Wells(3:4,1) = p2;  % pump 3 & 4
            Wells(5,1) = 300;   % pump 5
            % Y Vals
            Wells(1,2) = 100;   % y val pump 1 
            Wells(2,2) = -100;  % y val pump 2
            Wells(3,2) = 100;   % y val pump 3
            Wells(4,2) = -100;  % y val pump 4
            Wells(5,2) = 0;     % y val pump 5

        case 4 % 1-2-2
            % X Vals
            Wells(1:2,1) = p1;  % pump 1 & 2
            Wells(3:4,1) = 500; % pump 3 & 4
            Wells(5,1) = 300;   % pump 5
            % Y Vals
            Wells(1,2) = 100;   % y val pump 1 
            Wells(2,2) = -100;  % y val pump 2
            Wells(3,2) = p2;    % y val pump 3
            Wells(4,2) = -p2;   % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
            
        otherwise
            error('Invalid layout specified');
    end
    
    % Q Vals (Pumping Rates)
    % This is the *correct* assignment, fixing the bug.
    Wells(1:2,3) = p3;  % Q rate pump 1 & 2
    Wells(3:4,3) = p4;  % Q rate pump 3 & 4
    Wells(5,3) = p5;    % Q rate pump 5
end