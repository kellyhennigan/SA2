
% define data dir
dataDir = '/Users/Kelly/Dropbox/SA2/expPres/data';

% get subjects
[subs,CBs] = getSA2Subjects();

nTrialsPerSet = 36; % 36 trials per set
nSetsPerRun = 2; % # of sets per scan run
nRuns = 6; % 6 scan runs

%% per-subject chi-squared table of counts of "good" responses 
% by condition (gain,loss) x context (baseline,stress)

i=1;

contextComp = zeros(2,1);

cd(dataDir)

for i=1:19
    
sub = subs{i};

cd(subs{i})

cb = CBs(i);

for r=1:nRuns
    f=dir(['run' num2str(r) '_task_trials*']);
    [run_set_num,set_trial_num,cond,cue_onset,response,...
        cue_choice,rt,outcome,outcome_onset] = getSA2BehData(f(end).name);
    
    nGoodGain(r) = sum(outcome(cond==1));
    nGoodLoss(r) = nTrialsPerSet - sum(outcome(cond==2));
end

    goodRespCounts = [sum(nGoodGain(1:3)),sum(nGoodGain(4:6));...
        sum(nGoodLoss(1:3)),sum(nGoodLoss(4:6))];
    
if cb==2
    goodRespCounts = fliplr(goodRespCounts);
end

base_vs_stress(i,:) = [goodRespCounts(:,1)-goodRespCounts(:,2)]';
%% 
cd ..

end

cN = sum(goodRespCounts);
rN = sum(goodRespCounts');
N = sum(cN);
E = [cN(1).*rN(1)./N,cN(2).*rN(1)./N;cN(1).*rN(2)./N,cN(2).*rN(2)./N];

X2=sum(sum(((goodRespCounts-E).^2)./E))

df = 1;

p = chi2cdf(X2,df,'upper');

[p2,X22]=chisquarecont(goodRespCounts)