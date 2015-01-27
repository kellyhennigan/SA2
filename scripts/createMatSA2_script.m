% make a glm design matrix and save it out as a mat file along with
% regressor labels and an index

% for experiment SA2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define files, params, etc

clear all
close all

subjs=getSA2Subjects('all');

runs = 1:6; % scan runs to include

nVols = 326; % vector w/corresponding # of vols/run, or one scalar to use the same value for all runs


%%%%% Regressors of interest %%%%%
% NOTE: each of these will be modeled as one regressor across runs, rather
% than a new regressor for each run
% regStrs = {'gain+1_base','gain+PE_base','gain0_base','gain-PE_base',...
%     'loss-1_base','loss-PE_base','loss0_base','loss+PE_base',...
%     'gain+1_stress','gain+PE_stress','gain0_stress','gain-PE_stress',...
%     'loss-1_stress','loss-PE_stress','loss0_stress','loss+PE_stress',...
%     'contextevent_base','contextevent_stress','shock',...
%     'cuepair1','cuepair2'};

regStrs = {'gain_base',...
    'gain_param_base',...
    'gainPE_base',...
    'loss_base',...
    'loss_param_base',...
    'lossPE_base',...
    'gain_stress',...
    'gain_param_stress',...
    'gainPE_stress',...
    'loss_stress',...
    'loss_param_stress',...
    'lossPE_stress',...
    'contextevent_base',...
    'contextevent_stress',...
    'shock',...
    'cuepair1',...
    'cuepair2'};



%%%%% Baseline/Nuisance regressors %%%%%
% NOTE: each of these will be modeled as a separate regressor for each run
base_regStrs = {'motion'}; % regressors not of interest

irfStr = '_can'; % string in regFile Name distinguishing the irf & maybe irf params

regSuffixStr = '_runALL'; % suffix string of reg text files

% degree of the polynomial to include in the baseline model (0 to include
% only a constant term, 1 for a constant + linear drift, 2 for constant,
% linear, and quadratic drift, etc.)
nPolyRegs = 3; % should be at least 1, +1 more for every 2.5 min of continuous scanning

censor_trs = []; % idx of vols to censor bc of bad movement or otherwise

outFName = ['glm2' irfStr regSuffixStr '.mat']; % save name

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it


% get # of vols for each run if its given as a scalar
if numel(nVols)==1
    nVols = repmat(nVols,1,numel(runs));
end


% subject loop
for s=1:numel(subjs)

% s=13
    
    subj = subjs{s};
    
    fprintf('\n\nMaking design matrix for subject %s ...\n', subj);
    
    expPaths=getSA2Paths(subj);
    
    [X,regLabels,regIdx] = glm_fmri_mat_SA2(subj, nVols, regStrs, ...
        base_regStrs,irfStr,regSuffixStr,nPolyRegs,censor_trs,1);
    
    
    %% save out full model
    
    cd(expPaths.design_mats);
    save(outFName, 'X','regLabels','regIdx');
    
    fprintf('\ndone.\n\n');
    
end % subject


