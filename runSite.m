%------------------------------------------------------------------------------
% [] = runSite(p1, p2, p3, p4, p5, layout, Graphs, Compliance)
%
% Arguments:
% p1 - controls the x or y position of pump 1 & 2
% p2 - controls the x or y position of pump 3 & 4
% p3 - controls the flow rate (Q) of pump 1 & 2
% p4 - controls the flow rate (Q) of pump 3 & 4
% p5 - controls the flow rate (Q) of pump 5
%
% layout - determines the configuration of the pumps:
%       1: 2-2-1
%       2: 1-2-2
%       3: 3-2-0
%       4: 3-0-2
%       5: 2-0-3
%       6: 0-2-3
%       7: 1-4-0
%       8: 0-4-1
%        
% Graphs - boolean to indicate if graphs should be drawn
% Compliance - boolean to indicate if compliance should be checked
%
% Returns:
% None
%
% Notes:
% This function configures the layout of pumps based on specified parameters.
% 
% Author:
%   Evan M. Stearns 
%   Owen Haberstroh
%   Lily Wilkerson
%   (Group I)
%   University of Minnesota
%
%   Current Best:
%       runSite(84, 441.5, 204.5, 353.909, 99.2, 3, true, true)
%       Amax = [1216]
%
% Version:
%   4 November 2025
% 
%------------------------------------------------------------------------------
function [] = runSite(p1, p2, p3, p4, p5, layout, Graphs, Compliance)

    

    % X in col 1, Y in col 2, Q in col 3
    Wells = NaN(5,3);

    switch layout
        case 1 % 2-2-1
            assert(p1 >= 0);
            assert(p1 <= 100);
            assert(p2 >= 300);
            assert(p2 <= 500);
            assert(p3 >= 0);
            assert(p4 >= 0);
            assert(p5 >= 0);

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
            % Q Vals
            Wells(1:2,3) = p3;  % Q rate pump 1 & 2
            Wells(3:4,3) = p4;  % Q rate pump 3 & 4
            Wells(5,3) = p5;    % Q rate pump 5
           
        case 2 % 1-2-2
            assert(p1 >= 300);
            assert(p1 <= 500);
            assert(p2 >= 0);
            assert(p2 <= 100);
            assert(p3 >= 0);
            assert(p4 >= 0);
            assert(p5 >= 0);

            % X Vals
            Wells(1:2,1) = p1; % pump 1 & 2
            Wells(3:4,1) = 500;  % pump 3 & 4
            Wells(5,1) = 300;   % pump 5
            % Y Vals
            Wells(1,2) = 100;    % y val pump 1 
            Wells(2,2) = -100;   % y val pump 2
            Wells(3,2) = p2;   % y val pump 3
            Wells(4,2) = -p2;  % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
            % Q Vals
            Wells(1:2,3) = p3;  % Q rate pump 1 & 2
            Wells(3:4,3) = p4;  % Q rate pump 3 & 4
            Wells(5,3) = p5;    % Q rate pump 5

        case 3 %3-2-0
            assert(p1 >= 0);
            assert(p1 <= 100);
            assert(p2 >= 300);
            assert(p2 <= 500);
            assert(p3 >= 0);
            assert(p4 >= 0);
            assert(p5 >= 0);

            % X Vals
            Wells(1:2,1) = 300; % pump 1 & 2
            Wells(3:4,1) = p2;  % pump 3 & 4
            Wells(5,1) = 300;   % pump 5
            % Y Vals
            Wells(1,2) = p1;    % y val pump 1 
            Wells(2,2) = -p1;   % y val pump 2
            Wells(3,2) = 100;    % y val pump 3
            Wells(4,2) = -100;   % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
            % Q Vals
            Wells(1:3,3) = p3;  % Q rate pump 1 & 2 
            Wells(3:4,3) = p4;  % Q rate pump 3 & 4
            Wells(5,3) = p5;    % Q rate pump 5

        case 4 % 3-0-2
            assert(p1 >= 0);
            assert(p1 <= 100);
            assert(p2 >= 0);
            assert(p2 <= 100);
            assert(p3 >= 0);
            assert(p4 >= 0);
            assert(p5 >= 0);

            % X Vals
            Wells(1:2,1) = 300; % pump 1 & 2
            Wells(3:4,1) = 500;  % pump 3 & 4
            Wells(5,1) = 300;   % pump 5
            % Y Vals
            Wells(1,2) = p1;    % y val pump 1 
            Wells(2,2) = -p1;   % y val pump 2
            Wells(3,2) = p2;    % y val pump 3
            Wells(4,2) = -p2;   % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
            % Q Vals
            Wells(1:3,3) = p3;  % Q rate pump 1 & 2 
            Wells(3:4,3) = p4;  % Q rate pump 3 & 4
            Wells(5,3) = p5;    % Q rate pump 5

        case 5 % 2-0-3
            assert(p1 >= 0);
            assert(p1 <= 100);
            assert(p2 >= 0);
            assert(p2 <= 100);
            assert(p3 >= 0);
            assert(p4 >= 0);
            assert(p5 >= 0);

            % X Vals
            Wells(1:2,1) = 300; % pump 1 & 2
            Wells(3:4,1) = 500;  % pump 3 & 4
            Wells(5,1) = 500;   % pump 5
            % Y Vals
            Wells(1,2) = p1;    % y val pump 1 
            Wells(2,2) = -p1;   % y val pump 2
            Wells(3,2) = p2;    % y val pump 3
            Wells(4,2) = -p2;   % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
            % Q Vals
            Wells(1:2,3) = p3;  % Q rate pump 1 & 2 
            Wells(3:4,3) = p4;  % Q rate pump 3 & 4
            Wells(5,3) = p5;    % Q rate pump 5

        case 6 % 0-2-3
            assert(p1 >= 300);
            assert(p1 <= 500);
            assert(p2 >= 0);
            assert(p2 <= 100);
            assert(p3 >= 0);
            assert(p4 >= 0);
            assert(p5 >= 0);

            % X Vals    
            Wells(1:2,1) = p1; % pump 1 & 2
            Wells(3:4,1) = 500;  % pump 3 & 4
            Wells(5,1) = 500;   % pump 5
            % Y Vals
            Wells(1,2) = 100;    % y val pump 1 
            Wells(2,2) = -100;   % y val pump 2
            Wells(3,2) = p2;    % y val pump 3
            Wells(4,2) = -p2;   % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
            % Q Vals
            Wells(1:2,3) = p3;  % Q rate pump 1 & 2 
            Wells(3:4,3) = p4;  % Q rate pump 3 & 4
            Wells(5,3) = p5;    % Q rate pump 5

        case 7 % 1-4-0
            assert(p1 >= 300);
            assert(p1 <= 500);
            assert(p2 >= 300);
            assert(p2 <= 500);
            assert(p3 >= 0);
            assert(p4 >= 0);
            assert(p5 >= 0);

            % X Vals
            Wells(1:2,1) = p1; % pump 1 & 2
            Wells(3:4,1) = p2;  % pump 3 & 4
            Wells(5,1) = 300;   % pump 5
            % Y Vals
            Wells(1,2) = 100;    % y val pump 1 
            Wells(2,2) = -100;   % y val pump 2
            Wells(3,2) = 100;    % y val pump 3
            Wells(4,2) = -100;   % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
            % Q Vals
            Wells(1:3,3) = p3;  % Q rate pump 1 & 2 
            Wells(3:4,3) = p4;  % Q rate pump 3 & 4
            Wells(5,3) = p5;    % Q rate pump 5

        case 8 % 0-4-1
            assert(p1 >= 300);
            assert(p1 <= 500);
            assert(p2 >= 300);
            assert(p2 <= 500);
            assert(p3 >= 0);
            assert(p4 >= 0);
            assert(p5 >= 0);

            % X Vals
            Wells(1:2,1) = p1; % pump 1 & 2
            Wells(3:4,1) = p2;  % pump 3 & 4
            Wells(5,1) = 500;   % pump 5
            % Y Vals
            Wells(1,2) = 100;    % y val pump 1 
            Wells(2,2) = -100;   % y val pump 2
            Wells(3,2) = 100;    % y val pump 3
            Wells(4,2) = -100;   % y val pump 4
            Wells(5,2) = 0;     % y val pump 5
            % Q Vals
            Wells(1:3,3) = p3;  % Q rate pump 1 & 2 
            Wells(3:4,3) = p4;  % Q rate pump 3 & 4
            Wells(5,3) = p5;    % Q rate pump 5
        
        % ommited cases
        % 1-0-4
        % 4-0-1
        otherwise

            error('Invalid layout specified');
    end

    Qtotal = sum(Wells(:,3));
    fprintf("Total Q: %.3f \n", Qtotal)


    if Graphs
    headGrid = drawSite(Wells(:,1), Wells(:,2),Wells(:,3));
    end
    if Compliance
    complianceChecker(headGrid);
    end

    

end