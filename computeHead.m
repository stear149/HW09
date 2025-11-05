%------------------------------------------------------------------------------
% [head] = computeHead(x, y, xwells, ywells, q)
%
% Arguments:
%   x       - x-coordinate of the point where head is computed
%   y       - y-coordinate of the point where head is computed
%   xwells  - array of x-coordinates of wells
%   ywells  - array of y-coordinates of wells
%   q       - array of flow rates from each well
%
% Returns:
%   head    - computed head at the given coordinates
%
% Notes:
%   This function computes the hydraulic head based on the given well data
%   and river height.
% 
% Author:
%   Evan M. Stearns 
%   Owen Haberstroh
%   Lily Wilkerson
%   (Group I)
%   University of Minnesota
%
% Version:
%   4 November 2025
% 
%------------------------------------------------------------------------------
function[head] = computeHead(x, y, xwells, ywells, q)

    k = 2.5; % Given 2.5 m/day
    hr  = 30; % hight of River
    Dw = 0.1; % diamiter of pipe given

    C = .5*k*hr^2;

    Phi = C;
    for i = 1:5
        oldPhi = Phi;
        r = max(sqrt(((xwells(i) - x).^2) + (ywells(i) - y).^2),Dw/2);
        s = sqrt(((xwells(i) + x).^2) + (ywells(i) - y).^2);
        Phi = oldPhi + (q(i)/(2*pi)) * log(r/s);

    end

    head = sqrt((2*max(Phi,0))/k);

end
