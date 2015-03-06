function [p0, p_min, p_max] = getInitRLParams()
% --------------------------------
% usage: get initial starting parameters for fitting an RL model for experiment SA2
% 
% OUTPUT:
%   p0, p_min, p_max
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 19-Feb-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get parameters and options for fminsearch

% % p0 = [rand(1) rand(1).*10];      % initial parameter values
p0=[.2 3];
p_min = [0 0];    % min param vals
p_max = [1 10];    % max param vals
