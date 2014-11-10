% script to make a design matrix from MID regressors

% include in outgoing .mat file: 
% X - design matrix 
% regLabels - string to identify regressor

%%%%%%%%%%%%%%%%%%

clear all
close all

runNum = 2; % run number
nTRs = 246; % # of TRs in each run

base_regLabels = {'base1','base2','base3','base4'};
base_regIdx = zeros(1,4);

% baseline model
Xbase = modelBaseline(nTRs,3);


%% add regressors of interest to model

% string names that will correspond to all the regressor time series
regLabels = {'cue_control','cue_gain_0','cue_gain_lo','cue_gain_hi',...
    'cue_loss_0','cue_loss_lo','cue_loss_hi','target','outcome'};

regIdx = 1:length(regLabels);


cd(['/Users/Kelly/SA2/data/pilot100513/regs/run',num2str(runNum)])


for i =1:length(regLabels)
    a=dir(['*',regLabels{i},'*'])
    reg = dlmread(a.name);
    X(:,i) = reg;
end

% combine baseline model w/ task regressors
regLabels = [base_regLabels,regLabels];
regIdx = [base_regIdx,regIdx];
X = [Xbase,X];
% X = spm_orth(X); % orthogonalize it


cd ../../

outName = ['run',num2str(runNum),'_design_mat.mat'];
save(outName,'X','regLabels','regIdx')
% save('run2_design_mat.mat','X','regLabels')
    