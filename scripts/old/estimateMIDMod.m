% fit glm to MID data

datadir = '/Users/kelly/SA2/data/pilot100513';

runNum = 2;

% pre-processed data
niiFile = ['pp_mux1_run',num2str(runNum),'.nii.gz'];

% 3d mask nifti
maskFile = ['mask.nii.gz'];

% .mat file that contains the model 
matFile = ['run',num2str(runNum),'_design_mat.mat'];

%% get to it

% load data & mask
func = readFileNifti(niiFile);
mask = readFileNifti(maskFile);

% load design matrix
load(matFile);

[B, ~, ~, ~, Rsq,err_ts] = glm_fmri_fit(func.data,X,regIndx,mask);
