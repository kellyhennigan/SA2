% x     - the parameters describing the rigid body rotation, such that a
%         mapping from voxels in G to voxels in F is attained by:
%         VF.mat\spm_matrix(x(:)')*VG.mat
%

% Between modality coregistration using information theory
% FORMAT x = spm_coreg(VG,VF,flags)
% VG    - handle for reference image (see spm_vol).
% VF    - handle for source (moved) image.
% flags - a structure containing the following elements:
%          sep      - optimisation sampling steps (mm)
%                     default: [4 2]
%          params   - starting estimates (6 elements)
%                     default: [0 0 0  0 0 0]
%          cost_fun - cost function string:
%                       'mi'  - Mutual Information
%                       'nmi' - Normalised Mutual Information
%                       'ecc' - Entropy Correlation Coefficient
%                       'ncc' - Normalised Cross Correlation
%                     default: 'nmi'
%          tol      - tolerences for accuracy of each param
%                     default: [0.02 0.02 0.02 0.001 0.001 0.001]
%          fwhm     - smoothing to apply to 256x256 joint histogram
%                     default: [7 7]
%          graphics - display coregistration outputs
%                     default: ~spm('CmdLine')
%
% x     - the parameters describing the rigid body rotation, such that a
%         mapping from voxels in G to voxels in F is attained by:
%         VF.mat\spm_matrix(x(:)')*VG.mat



clear all
close all


% get experiment-specific paths & cd to main data dir
p = getSA2Paths; cd(p.data);


% define subjects to process
subjects = getSA2Subjects('dti');


%%

for i =9:numel(subjects)
    
    subj = subjects{i};
    subjDir = fullfile(p.data,subj);
    
    % get filepaths for temporarily unzipped pd and anat files
    pdFile = gunziptemp(fullfile(subjDir,'raw','pd.nii.gz'));
    t1File = gunziptemp(fullfile(subjDir,'t1_fs.nii.gz'));
    
    
    % Rescale pd image values to get better gary/white/CSF contrast
    pd = niftiRead(pdFile);
    pd.data = mrAnatHistogramClip(double(pd.data),0.3,0.99);
    writeFileNifti(pd)
    
    
    % load pd and t1 spm style
    VG = spm_vol(t1File);
    VF = spm_vol(pdFile);
    
    % estimate coregistration
    flags = struct('sep',[4 2],'cost_fun','nmi','fwhm',[7 7],...
        'tol',[0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001]);
    x = spm_coreg(VG,VF,flags);
    
    M = inv(spm_matrix(x)); % multiply this matrix by the current xform to get the xform that aligns the volumes
    
    newXform = M*VF.mat;
    
    % this is clunky but I prefer it to using spm_get_space because I know
    % what's happening this way
    pd = niftiRead(pdFile);
    pd.sto_xyz = newXform;
    writeFileNifti(pd);
    VF = spm_vol(VF.fname); % reload nifti w/new xform in sto_xyz field
    
    
    % reslice pd to match t1
    clear flags
    flags = struct('interp', 1, 'mask', 0,'wrap',[0 0 0]',...
        'prefix','r','which',1,'mean',0);
    spm_reslice([VG,VF], flags);
    
    % move resliced pd to subject's main dir
    movefile([fileparts(VF.fname),'/rpd.nii'],subjDir)
    
    cd(subjDir)
    spm_check_registration([VG,spm_vol('rpd.nii')]);
    
end

%%

