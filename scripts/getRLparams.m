function p = getRLGroupParams(subStr,cond)
% --------------------------------
% usage: return the best fitting parameter estimates
% (learning rate a and inverse temperature B) found using fminsearch
% on the function fitQLearningMod
%
% INPUT:
%   subStr - string identifying which subject subgroup to return best
%   fits for. Possiblities are:
%           'all'
%           'RL'
%           'fmri'
%   * note: see getSA2Subjects about what these subgroups mean
% 
%   subOrGroup - return params for each subject or as a group
%
%   cond - string or number specifying which condition (gain or loss) to
%          return data for; should be either 'gain' or 1 for gains and
%          'loss' or 2 for loss trials.

%
% OUTPUT:
%   p - best fitting parameter estimates (learning rate a and inverse
%   temperature B) found using fminsearch on the function fitQLearningMod
%   and hard-coded in here.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('subStr')
    subStr = 'fmri';
end


if notDefined('subOrGroup')
    subOrGroup = 'group';
end

% return params for gains and/or losses? 
if notDefined('cond')
    cond = [1,2];
end

        
if strcmpi(subStr,'RL')         % give params for 'RL'
    p = [0.2778    4.6715;
        0.3016    4.2917];
    
elseif strcmp(subStr,'fmri')    % give params for 'fmri'
    p = [0.1609    3.3480;
        0.2017    3.1583];
    
else                            % give params for 'all'
    p = [0.1724    3.3236;
        0.2224    3.1259];
    
end



if strcmpi(cond, 'gain')
    cond = 1;
elseif strcmpi(cond, 'loss')
    cond = 2;
end
p = p(cond,:); 

