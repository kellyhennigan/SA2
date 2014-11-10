function [results] = expexpModel(path,subjNo)
% model expexp
% include path.data which leads to data folder
% - only 20 iterations per round of estimation because it takes forEVER

global Vall

noBlks = 2;
nIter=20; % actual = 1000
clc

% column identifiers for data files
IDCol = 1; % subject ID
choiceCol = 2; % which option was chosen (1-5)
probCol = 3; % which probability was chosen?
winCol=4; % did subj win on that trial?
tallyCol = 5; % running total
onsetCol = 6; % choice presented
RTCol = 7; % choice made
roundCol =8; % which round are they playing?


try % 2012 and up
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock))); %seed rand
catch % older versions of matlab
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock))); %seed rand
end

% load subj data
cd(path.data)
filename = ['GABA' num2str(subjNo) '_expexp.mat'];
d=load(filename); % data stored in variable 'data'
noTrials = length(d.data);
cd(path.expexp)

Vall=[]; % value of each stim, per trial


%P = orderedProbArr{blk}; % probabilities for that block
c = d.data(:,choiceCol); % choices
r = d.data(:,winCol); % reward


% initial guesses
V = ones(1,5)*1/5; % equal starting value of each stim
a = .23; % learning rate
m = rand(1)*2; % random decision slope

m_init = m;
a_init = a;
ll_best = Inf; % initialize
for i = 1:nIter % iterations
    fprintf('iter: %g\n',i)
    [p, ll_this] = fminsearch(@(p)negloglike(p,d,r,V), [m a]);
    if (ll_this < ll_best)
        m_fit = abs(p(1));
        a_fit = abs(p(2)); 
        ll_best = ll_this;
    end;
end;

results.m_init=m_init;
results.m_fit=m_fit;
results.a_init=a_init;
results.a_fit=a_fit;
results.ll=ll_best;

%plot
subplot(1,2,1);
imagesc(Vall);
subplot(1,2,2);
plot(c);
title(m);

cd(path.main)


function ll = negloglike(p,d,r,V)
global Vall
choiceCol = 2; % which option was chosen (1-5)
winCol=4; % did subj win on that trial?
roundCol =8; % which round are they playing?

% free parameters in the model
m = abs(p(1)); % decision slope
a = abs(p(2)); % learning rate

ll = 0; % initialize loglike


for i = 1 : size(d.data,1)
    % if just switched from round 1 to 2
    if d.data(i,roundCol) - d.data(i,roundCol)>0
       V = ones(1,5)*1/5;
    end
    
    c_this = d.data(i,choiceCol);
    Pc = exp(m * V(c_this)) / sum( exp(m .* V) );
    
    ll = ll + log(Pc);
    
    V(c_this) = a*(r(i) - V(c_this)) + V(c_this);
    Vall=[Vall;V];
end;

ll = -1 * ll;


