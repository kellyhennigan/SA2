% preprocess fmri data for the SA2 experiment

% my hope is to document my preprocessing steps here with some light
% explanation of why/how things are done, then add checks at every stage to
% visualize what was done and if there are any problems.

% Assumptions: 
% - all functional data from different runs have the same voxel
%   dimensions and scanning parameters


% here are the pre-processing step options:

% 1) doDiary - record every step that occurs? 
% 2) doQAFigs - save out quality assurance figures? 
% 3) doOmit1stVols - drop the first few volumes of eachrun? add prefix 'o'
% 4) doCorrectSliceTiming - do slice time correction        add prefix 'a'
% 5) doCorrectFieldMap - correct for distorted field map    add prefix 'u'
% 6) doCorrectMotion - correct for head movement            add prefix 'r'
% 7) doSmooth - smooth data                                 add prefix 's'
% 8) doMask - make a binary brain mask (doMask)             called func_mask
% 9) doConvertUnits - convert from raw to % change units    add prefix 'p'
% 10) doConcatRuns - concatanate runs                        called __

% the options that add a prefix are the ones that actually effect the data





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

saveIntSteps = 1; % save out intermediate steps? 0 means only the final pre-processed data will be saved out 

%  what should be done? 1 to do, 0 to not do
doDiary = 1; % keep a log of everything that happens?

doQAFigs = 1;  % write out QA figures?

doOmit1stVols = 1; % omit some of the 1st vols of each run?

doCorrectSliceTiming = 1; % correct for differences in slice acquisition times?

doCorrectFieldMap = 1; % correct for distortions in the B0 field?

doCorrectMotion = 1; % correct for head movement?

doSmooth = 1; % smooth with gaussian kernel?

doMask = 1; 

doConvertUnits = 1; % convert from raw scanner units to percent BOLD signal change?

doConcatRuns = 1; % concatanate across functional runs?

% add coregistration and normalization steps here



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%% DO DIARY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if doDiary
    
    % what .txt file should we keep a diary in?
    diaryfile = [outDir 'diary.txt'];
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%% DO QA FIGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if doQAFigs
    
    % where should i save figures to?
%     figuredir = fullfile(outDir,'figures');
%     if ~exist(figuredir,'dir')
%         mkdir(figuredir)
%     end
     
% where should i save figures to?
    figuredir = fullfile(p.data,subj,'QAfigs');
    if ~exist(figuredir,'dir')
        mkdir(figuredir)
    end
    
    
else
    figuredir = [];
    
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
    
    
end


%%%%%%%%%%%%%%%%%%%%%% FIELDMAP CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%

if doCorrectFieldMap

    fmapMAGfiles= {'fmap1.nii.gz','fmap3.nii.gz'};
    fmapB0files = {'fmap1_B0.nii.gz','fmap3_B0.nii.gz'};
    fmap_epi_idx = [1 1 1 2 2 2]; % for each functional run, indicate which fieldmap should be used to undistort it
end


%%%%%%%%%%%%%%%%%%%%%% MOTION CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if doCorrectMotion
    
    % which volume to use as a reference for motion correction? save out a
    % single volume nifti to use as reference for motion correction
    % before running this script.
    refFilePath = fullfile(outDir,'ref1.nii.gz');
    
     % currently, this must be either 'afni' or 'kk_spm'; note: in order to
     % do FieldMap correction in the same interpolated step as motion
     % correction, 'kk_spm' method must be used.
    mcMethod = 'afni';
    mcMethod = 'kk_spm'; 
    
    saveCorrectMotion = 1;  % save after this completing this step?
    
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


doPreProcess;




