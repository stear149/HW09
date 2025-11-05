function [Q_total] = objectiveFcn(x)
% OBJECTIVEFCN calculates the total pumping rate (cost).
% x = [p1, p2, p3, p4, p5]
% p3 = Q for pumps 1 & 2
% p4 = Q for pumps 3 & 4
% p5 = Q for pump 5
% This function assumes the *intended* logic, where p3, p4, p5 are
% *rates* and not parameter values that are buggy.
    
    q_p1_p2 = x(3);
    q_p3_p4 = x(4);
    q_p5    = x(5);
    
    % Total flow is the sum of all 5 pumps
    Q_total = 2*q_p1_p2 + 2*q_p3_p4 + q_p5;
end