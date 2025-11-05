function [x_rounded] = roundOptimalSolution(x)
% ROUNDOPTIMALSOLUTION enforces the user-specified precision for parameters.
% x = [p1 (location), p2 (location), p3 (Q), p4 (Q), p5 (Q)]

    x_rounded = zeros(1, 5);

    % p1 (Index 1) and p2 (Index 2): Round to the nearest 0.5 m (half meter)
    % This is achieved by rounding 2x the value, then dividing by 2.
    x_rounded(1) = round(x(1) * 2) / 2;
    x_rounded(2) = round(x(2) * 2) / 2;

    % p3, p4, p5 (Indices 3, 4, 5): Round to three decimal places
    % This is achieved by rounding 1000x the value, then dividing by 1000.
    x_rounded(3) = round(x(3) * 1000) / 1000;
    x_rounded(4) = round(x(4) * 1000) / 1000;
    x_rounded(5) = round(x(5) * 1000) / 1000;
end