% preprocess fmri data for the SA2 experiment

% my hope is to document my preprocessing steps here with some light
% explanation of why/how things are done, then add checks at every stage to
% visualize what was done and if there are any problems.

% Assumptions: 
% - all functional data from different runs have the same voxel
%   dimensions and scanning parameters


% here are the pre-processing step options:
% 1) drop the first few volumes of each run add prefix 'o'
% 2) slice time correction                  add prefix 'a'
% 3) motion correction                      add prefix 'r'
% 4) fieldmap correction                    add prefix 'u'
% 5) smooth data                            add prefix 's'
% 6) make a binary brain mask               called func_mask
% 7) convert from raw to % change units     add prefix 'p'
% 8) concatanate runs 
% 9) normalize to a group template




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define directories, files, etc.

clear all
close all

subj = '24';

p=getSA2Paths(subj);

% what directory do the data live in?
inDir = p.raw;

% what NIFTI files should we interpret as EPI runs?
inFiles = {'run1.nii.gz',...
    'run2.nii.gz',...
    'run3.nii.gz',...
    'run4.nii.gz',...
    'run5.nii.gz',...
    'run6.nii.gz'};% ***


% where should the preprocessed files be saved to?
outDir = p.func_proc;

% base string to use for each output file; should correspond to each inFile
outStrs = {'run1','run2','run3','run4','run5','run6'};

% by default, we tend to use double format for computation.  but if memory is an issue,
% you can try setting <dformat> to 'single', and this may reduce memory usage.
dformat = 'single';


%  what should be done? 1 to do, 0 to not do
doQCFigs = 1;  % write out QC figures?

doDiary = 0; % keep a log of everything that happens?

doOmit1stVols = 1; % omit some of the 1st vols of each run?

doComputeTSNR = 1; % compute temporal SNR?

doCorrectSliceTiming = 0; % correct for differences in slice acquisition times?

doCorrectMotion = 0; % correct for head movement?

doCorrectFieldMap = 0; % correct for distortions in the B0 field?

doSmooth = 0; % smooth with gaussian kernel?

doMask = 0; 

doConvertUnits = 0; % convert from raw scanner units to percent BOLD signal change?

doConcatRuns = 0; % concatanate across functional runs?

% add coregistration and normalization steps here


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%%%%%%%%%%%%%%%%%%%%%%%%%% DO QC FIGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if doQCFigs
    
    % where should i save figures to?
%     figuredir = fullfile(outDir,'figures');
%     if ~exist(figuredir,'dir')
%         mkdir(figuredir)
%     end
     
% where should i save figures to?
    figuredir = fullfile(p.data,'QCfigs',subj);
    if ~exist(figuredir,'dir')
        mkdir(figuredir)
    end
    
    
else
    figuredir = [];
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%% DO DIARY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if doDiary
    
    % what .txt file should we keep a diary in?
    diaryfile = [outDir outfileprefix 'diary.txt'];
    
end



%%%%%%%%%%%%%%%%%%%% OMIT FIRST VOLS INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% omit some of the first volumes to allow for t1-magnetization steady
% state?
if doOmit1stVols
    
    omitNVols = 6;    % if yes, how many vols to omit?
    saveOmit1stVols  = 0;  % save after this completing this step?
    
end



%%%%%%%%%%%%%%%%%%%% SLICE TIME CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%

if doCorrectSliceTiming
    
    % what is the slice order for the EPI runs?
    % for MUX sequences, do slice order as if it was mux 1
    sliceOrder = [1:2:19,2:2:19];
    
    % for mux sequences, enter the number of simultaneously acquired slices; if
    % not a mux sequence, set this to 0 or []
    mux = 3;
    
    saveCorrectSliceTiming = 1;  % save after this completing this step?
    
end



%%%%%%%%%%%%%%%%%%%%%% MOTION CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if doCorrectMotion
    
    % which volume to use as a reference for motion correction? save out a
    % single volume nifti to use as reference for motion correction
    % before running this script.
    refFilePath = fullfile(outDir,'func_ref_vol.nii');
    
    mcMethod = 'afni'; % currently, this must be either 'afni' or 'kk_spm'
    
    saveCorrectMotion = 1;  % save after this completing this step?
    
end


%%%%%%%%%%%%%%%%%%%%%% FIELDMAP CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%

if doCorrectFieldMap

    fmapMAGfiles= {'fmap1.nii.gz','fmap4.nii.gz'};
    fmapB0files = {'fmap1_B0.nii.gz','fmap4_B0.nii.gz'};
   
end


%%%%%%%%%%%%%%%%%%%%%% SMOOTHING INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%

if doSmooth
    
    smMethod = 'afni';
    smooth_kernel_mm = 3; % what size kernel to use for smoothing?
 
    
end


%%%%%%%%%%%%%%%%%%%%%% CONVERT TO % BOLD CHANGE UNITS %%%%%%%%%%%%%%%%%%%%%

if doConvertUnits
    
    % define any relevant variables here
   
    
end



%%%%%%%%%%%%%%%%%%%%%% CONVERT TO % BOLD CHANGE UNITS %%%%%%%%%%%%%%%%%%%%%

if doConcatRuns
    
    % define any relevant variables here
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO PREPROCESSING

% add some paths 
path('/Applications/spm8',path);
% setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
% setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % determines fsl output file type


% v = whos;

% diary on
% start diary
% mkdirquiet(stripfile(diaryfile));
% diary(diaryfile);


doPreProcess;

% diary off



