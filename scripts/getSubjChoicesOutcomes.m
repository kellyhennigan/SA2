function [choices,outcomes]=getSubjChoicesOutcomes(subjs,cond,context)
% --------------------------------
% usage: this function loads subject choices and the resulting outcomes
%        for further analysis
%
% INPUT:
%   subjects - cell array of strings specifying which subjects to include
%   cond - string or number specifying which condition (gain or loss) to
%          return data for; should be either 'gain' or 1 for gains and
%          'loss' or 2 for loss trials.
%   context (optional) - option to specify returning data from just
%          baseline or just stress context. Should be either 'base' or 1 to
%          specify baseline and 'stress' or 2 to specify stress context. 

% OUTPUT:
%   choices: nT x nSets matrix denoting choice where nT = # of trials
%            choices are either 1 or 2, or 0 if no response was made
%   outcomes: nT x nSets matrix denoting Rewards (trial outcomes)
%             outcomes are 1 for a win or loss and 0 for nothing
%
%
% author: Kelly, kelhennigan@gmail.com, 11-Nov-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~iscell(subjs)
    subjs = {num2str(subjs)};
end

% if condition isn't specified, then just return gains trials
if notDefined('cond')
    cond = 1;
end
if strcmpi(cond, 'gain')
    cond = 1;
elseif strcmpi(cond, 'loss')
    cond = 2;
end

% if context isn't specified, then return data from both contexts 
if notDefined('context')
    context = '*';
end
if strcmpi(context, 'base') 
    context = '1';
elseif strcmpi(context, 'stress') 
    context = '2';
end


choices=[];
outcomes = [];


%% do it

% load subjects' choices and outcomes
for i=1:numel(subjs)
    
    expPaths=getSA2Paths(subjs{i});
    
    f=dir([expPaths.behavior,'run*_c' num2str(context) '*task_trials*']);
    
    for j =1:numel(f)
        
        [~,~,trial_cond,~,~,trial_choice,~,trial_outcome,~] = getSA2BehData(fullfile(expPaths.behavior,f(j).name));
        
        choices(:,end+1) = trial_choice(trial_cond==cond);
        outcomes(:,end+1) = trial_outcome(trial_cond==cond);
        
    end
end




