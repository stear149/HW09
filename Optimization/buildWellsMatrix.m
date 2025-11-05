function [Wells] = buildWellsMatrix(x, layout)
% BUILDWELLSMATRIX creates the 5x3 well matrix from parameters x and layout
% x = [p1, p2, p3, p4, p5]
    
    Wells = NaN(5,3);

    % Unpack parameters from x
    p1 = x(1); p2 = x(2); p3 = x(3); p4 = x(4); p5 = x(5);

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
            
        otherwise
            error('Invalid layout specified');
    end
    
    % Q Vals (Pumping Rates)
    Wells(1:2,3) = p3;  % Q rate pump 1 & 2
    Wells(3:4,3) = p4;  % Q rate pump 3 & 4
    Wells(5,3) = p5;    % Q rate pump 5
end