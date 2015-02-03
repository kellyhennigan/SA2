function [nll,d,Pc1] = fitQLearningMod(p,choice,reward)
% --------------------------------
% usage: action value Q-learning RL model
%
% INPUT:
%   p: model parameters: p(1) = learning rate and p(2)=inverse temperature
%   choice: nT x nSets matrix denoting choice where nT = # of trials
%   Reward: nT x nSets matrix denoting Rewards (trial outcomes)

% OUTPUT:
%   nll: negative log-likelihood of the observed choices given the Q values
%        this is defined as -log( ? P(c(t) | Q(t,1), Q(t,2)) ) 
%        where P(c(t)) is calculated using a softmax function w/inverse temperature parameter B
%   d: nT x nSets matrix of trial prediction errors
%   Pc1: probability of choosing cue 1 using soft max


% NOTES: this is for modeling trials when 2 options are available to the
% subject, but it could be easily adapted to handle any # of options.
%
% author: Kelly, kelhennigan@gmail.com, 10-Nov-2014
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP

a = p(1); % learning rate parameter

B = p(2); % inverse temperature parameter for softmax 

nC = 2; % # of cue options 
[nT,nS]=size(choice); % nT = # of trials per set; nS = # of sets

d = nan(nT,nS); % define a matrix for trial prediction errors
ll = 0; % initialize log-likelihood
Pc1 = nan(nT,nS); % define matrix for model's prob estimates of choosing cue 1


%% do it 

for s = 1:nS    % set loop
       
    c = choice(:,s); % choices for this set
    
    r = reward(:,s); % reward outcomes for this set
    
    Q = zeros(1,nC); % initialize Q-values for choosing cue 1 or 2 to 0
    
    
    for t=1:nT  % trial loop       
          
        if c(t)==1 || c(t)==2 % only analyze trials w/recognizable responses
                 
            Pc1(t,s) = exp(B*Q(1))/sum(exp(B*Q));  % softmax probability of the choosing cue 1
               
            Pc = exp(B*Q(c(t)))/sum(exp(B*Q));  % softmax probability of the observed choice, given Q-values
            
            ll = ll + log(Pc); % log-likelihood 
       
            d(t,s) = r(t) - Q(c(t));  % prediction error
            
            Q(c(t)) = Q(c(t)) + a * d(t,s); % update Q-value for the chosen option
            
        end 
        
    end % trials 
     
end % sets 

nll = -ll;  % negative log-likelihood




