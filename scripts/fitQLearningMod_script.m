% fitQLearningMod_script

% this script calls the function fitQLearningMod for 2 different purposes: 
% 1) to find the parameter values that minimize the negative log likelihood
% of subjects' choices and 
% 2) once the best parameter values are found, use them to calculate
% trial-by-trial prediction error estimates to be used as parametric
% regressors. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up

clear all
close all

rand_seed=rng('shuffle'); % initialize random seed generator

% define subjects
subjs = getSA2Subjects('all');

cond = 'loss';

%% now find best parameter values 

% get trial choices and outcomes
[choices,outcomes]=getSubjChoicesOutcomes(subjs,cond,'base');


% define parameters and options for fminsearch
p0 = [rand(1) rand(1).*10];      % initial parameter values
% p0=[.2 3];
p_min = [0 0];    % min param vals 
p_max = [1 10];    % max param vals
options = optimset('MaxFunEvals',1000,'MaxIter',1000);

% find param values p that minimize nll as calculated in fitQLearningMod
[p,nll] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options);   
% [p,nll] = fminsearch(@(p) fitQLearningMod(p, choices, outcomes), p0, options);   


%% 

[nll,d,Pc] = fitQLearningMod(p, choices, outcomes);







