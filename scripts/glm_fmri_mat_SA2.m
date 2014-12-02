function [X,regLabels,regIdx] = glm_fmri_mat_SA2(subj, nVols, regStrs, ...
    base_regStrs,irfStr,regSuffixStr,nPolyRegs,censor_trs,plotMat)

% creates a design matrix for specified regressors of interest and baseline
% regressors


%%%%%%% INPUTS:

% subject - subject id string
% nVols - vector corresponding to the # of volumes in each run
% regStrs - cell array of stim labels corresponding to regFiles
% base_regStrs - cell array of stim labels corresponding to control
%       regFiles (e.g., motion, etc.)
% irfStr - string distinguishing the irf and maybe irf params in the
%       filename of the regs of interest.
% regSuffixStr - last string in the name of all reg files to load
% nPolyRegs - # of regressors for modeling the baseline of each scan run.
%       1 is a constant, 2 for a linear trend, 3 is quadratic, etc.
% censor_trs - 1 x numel(runs) cell array w/vectors or scalars specifying
%       the volumes to censor, if desired (bc of bad motion, etc.)
% plotMat - 1 to plot design matrix, 0 to not plot (default is 1)

%%%%%%% OUTPUTS:

% X - glm design matrix with a column for each regressor and nScans rows
% regLabels - cell array of string labels corresponding to each reg column
% regIdx - vector w/ 1,2, etc. for each stim specified by stims and 0 for
%       all other (baseline) regs



% kelly May 2012; edited for SA2 in Nov 2014

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% the number of volumes for each scan run
if notDefined('subj')
    error('must define a subject')
end

% the number of volumes for each scan run
if notDefined('censor_trs')
    censor_trs = [];
end


% plot design matrix?
if notDefined('plotMat')
    plotMat = 1;
end


X = [];             % design matrix
regLabels = {};     % labels of regressors
regIdx = [];        % index of regressors; 0 denotes part of the baseline model, otherwise 1,2, etc.


%% do it

expPaths = getSA2Paths(subj);

cd(expPaths.regs)


% baseline regs first 
this_reg = modelBaseline(nVols,nPolyRegs);
X = [X,this_reg];
regLabels = [regLabels,repmat({'baseline'},1, size(this_reg,2))];
regIdx = [regIdx,zeros(1,size(this_reg,2))];


% regs of interest
for n=1:numel(regStrs)
    this_reg = dlmread([regStrs{n} irfStr regSuffixStr]);
    X = [X,this_reg];
    regLabels = [regLabels,repmat(regStrs(n),1, size(this_reg,2))];
    regIdx = [regIdx,ones(1,size(this_reg,2)).*n];
    
end

% additional nuisance regs
base_regs = [];
for n=1:numel(base_regStrs)
    this_reg = dlmread([base_regStrs{n} regSuffixStr]);
    X = [X,this_reg];
    regLabels = [regLabels,repmat(base_regStrs(n),1, size(this_reg,2))];
    regIdx = [regIdx,zeros(1,size(this_reg,2))];
    
end


% censor trs? 
if ~isempty(censor_trs) && censor_trs~=0
    X(censor_trs,:) = zeros;
end


%% plot design matrix? 

if plotMat
    plotDesignMat(X,regLabels,regIdx);
end





