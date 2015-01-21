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

  disp('3 - coregistration');
    
  subj = '23';
  expPaths = getSA2Paths(subj);
  
  
  refDir = expPaths.func_proc;
  refFName = 'func_ref_vol.nii';
  VG = fullfile(refDir,refFName);
  VG = spm_vol(VG);
    
    % % Use anatomy as source
    sourceDir = expPaths.raw;
    sourceFName = 't1_ns2.nii';
   VF = fullfile(sourceDir,sourceFName);
   VF = spm_vol(VF);
    
    % % estimate coregistration
    flags = struct('sep',[4 2],'cost_fun','nmi','fwhm',[7 7],...
        'tol',[0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001]);
    x=spm_coreg(VG,VF,flags);
    
    clear flags
    P = char(VG.fname, VF.fname);
    
    % % Perform coregistration
    flags = struct('interp', 1, 'mask', 0,'wrap',[0 0 0]',...
        'prefix','r');
    spm_reslice(P, flags);
    
    clear P VF VG
    cd ..