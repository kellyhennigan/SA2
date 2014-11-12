% plotNLLxParamEstimates

% this script plots the negative-log likelihood for model fits using
% a variety of values for parameters a and B. 

% Q-learning model is fit by calling fitQLearningMod

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up

clear all
close all

% define parameter values to estimate
a = 0.05:.05:1; % learning rate parameter
B = .2:.2:6;  % inverse temperature parameter


% define subjects
subjs = getSA2Subjects();


% get trial choices and outcomes
[choices,outcomes]=getSubjChoicesOutcomes(subjs,'loss');



%% loop over different parameter values and plot the resulting NLLs
% % % define variables and initialize parameters
% 
%
for i=1:numel(a)
    for j = 1:numel(B)
        [nll(i,j),~] = fitQLearningMod([a(i),B(j)],choice,outcomes);
    end
end

[~,mi]=min(min(nll,[],2)); [~,mj]=min(min(nll));
best_a = a(mi) 
best_B = B(mj)


%% plot a 2-D map showing  NLL for the various parameter values 

imagesc(nll)
colormap(gray)
colorbar
xT = get(gca,'XTick');
yT = get(gca,'YTick')
set(gca,'XTickLabel',B(xT))
set(gca,'YTickLabel',a(yT))
ylabel('a learning rate')
xlabel('B inverse temperature')


