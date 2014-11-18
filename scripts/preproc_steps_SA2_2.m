% preprocess fmri data for the SA2 experiment

% my hope is to document my preprocessing steps here with some light
% explanation of why/how things are done, then add checks at every stage to
% visualize what was done and if there are any problems.

% 1) drop the first few volumes
% 2) slice time correction
% 3) motion correction
% 4) fieldmap correction
% 5) 

% eventually, these first three steps should be done at the same time

% *** compute temporal SNR after these steps
% ***sc

% 4) smooth the data - use a FWHM kernel that's roughly twice the width of
% the voxel's most lengthy dimension

% 5) normalize to a group template

% 6) do GLMs at the individual and group level


%% define directories, files, etc.

clear all
close all

subj = '18';

p=getSA2Paths(subj);


% what directory do the data live in?
inDir = p.raw;


% where should the preprocessed files be saved to?
outDir = p.func_proc;



% where should i save figures to?
figureDir = fullfile(outDir,'figures');


% % what NIFTI files should we interpret as EPI runs?
epifilenames = {'run1.nii.gz',...
    'run2.nii.gz',...
    'run3.nii.gz',...
    'run4.nii.gz',...
    'run5.nii.gz',...
    'run6.nii.gz'};% ***

% fmapMAGfilenames = {'fmap1.nii.gz','fmap4.nii.gz'};
% fmapB0filenames = {'fmap1_B0.nii.gz','fmap4_B0.nii.gz'};

func_ref_idx = [3 1]; % idx of the run and the vol of the run to align
% other functional volumes and anatomical data to. NOTE: the vol idx refers
% counts AFTER nVolsOmit have been discarded from the run. 
ref_filename = 'mc_func_vol.nii';

tlrcTempPath = '/Users/Kelly/afni';


t1_filename = 't1.nii.gz'; % anatomical files to coregister w/functional data


nRuns = numel(epifilenames);

% by default, we tend to use double format for computation.  but if memory is an issue,
% you can try setting <dformat> to 'single', and this may reduce memory usage.
dformat = 'single';


% how many volumes should we ignore at the beginning of each EPI run?
nVolsOmit = 6;


%% slice time correction info

doCorrectSliceTime = 1; % 1 to correct slice timing, otherwise 0

% what is the slice order for the EPI runs?
% for MUX sequences, do slice order as if it was mux 1
sliceOrder = [1:2:19,2:2:19];

% for mux sequences, enter the number of simultaneously acquired slices; if
% not a mux sequence, set this to 0 or []
mux = 3;




%%


fprintf('loading EPI data...');

for r=1:nRuns
    
    nii = readFileNifti(fullfile(inDir,epifilenames{r}));
%     nii.data = double(nii.data);
    vox_dim = nii.pixdim(1:3);
    TR = nii.pixdim(4);
    epi_dim = sizefull(nii.data,3);
    nVols = size(nii.data,4);
    eval(nii.descrip); % at cni this gives [te, ti, fa, ec, acq, mt, rp]
    inPlaneMatrixSize = acq;
    nSlices = size(nii.data,3);
    readOutTime = ec*acq(2)/rp; % divide by 2 if you are using 2x acceleration
    phaseDir = bitand(uint8(3),bitshift(uint8(nii.dim(3)),-2)); % ?? don't get whats happening here
    
    
    
    %% drop the first few vols
    
    if ~notDefined('nVolsOmit')
        fprintf(['dropping first ' num2str(nVolsOmit) ' volumes from the epi...']);
        nii.data(:,:,:,1:nVolsOmit) = []; % drop them
        nVols = nVols-nVolsOmit;
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
   
    
    
    %% SLICE TIME CORRECTION
    
    if (doCorrectSliceTime)
        fprintf('correcting for differences in slice acquisition times...');
        nii.data = correctSliceTime(nii.data,sliceOrder,mux);
        fprintf('done.\n');
        reportmemoryandtime;
    end
    
    
    nii.fname = fullfile(outDir,['a' epifilenames{r}]);
    writeFileNifti(nii);
    
    
    %% SAVE A FUNC REF VOL for realignment (motion correction) 
%     and for coregistration of anatomcal data
    
     if r==func_ref_idx(1)
        vol = nii;
        vol.fname = fullfile(outDir,ref_filename);
        vol.data = vol.data(:,:,:,func_ref_idx(2));
        writeFileNifti(vol);
     end
    
     clear nii
   
    
end

%% make VDM for fieldmap correction, do fieldmap correction 

% pm_defs = [9.1, 11.372, 0, 19.1, -1, 1, 1]];
% 
% VDM=FieldMap_preprocess(indir,epi_dir,[9.1,11.372,0,pm_defs,sessname)


%% MOTION CORRECTION

cd(outDir)

for r = 1:nRuns
    
    mc_command = ['afni 3dvolreg -prefix rarun' num2str(r) ' -verbose -base ',...     
        ref_filename ' -zpad 4 -dfile vr_run' num2str(r) ' a' epifilenames{r}];
    
    system(mc_command)
        
    
end
    

%% SMOOTH 

for r = 1:nRuns
    sm_command = ['3dmerge -1blur_fwhm 3.2 -doall -prefix srarun' num2str(r) 'rarun' num2str(r) '+orig']; ];
end


%% COREGISTER T1 to functional data

    coreg_command = ['align_epi_anat.py -anat ../raw/t1.nii.gz -epi mc_func_vol.nii ',...
        '-epi_base 0 -anat2epi -tshift off -partial_coverage -AddEdge'];
    system(coreg_command)

    
    % change file names 
    movefile('t1.nii.gz_al_mat.aff12.1D','t12func_xform');
    movefile('t1.nii.gz_al_e2a_only_mat.aff12.1D','func2t1_xform')
    movefile('t1.nii.gz_al.nii.gz','c_t1.nii.gz');

    
    

%% NORMALIZE DATA TO TLRC SPACE

% normalize func-aligned t1 to the tlrc template
t12tlrc_cmd = ['@auto_tlrc -base ' tlrcTempPath '-input c_t1.nii.gz -no_ss'];
system(t12tlrc_cmd);

  % change file names 
% movefile('t1.nii.gz_al_mat.aff12.1D','t12func_xform');
%     movefile('t1.nii.gz_al_e2a_only_mat.aff12.1D','func2t1_xform')
%     movefile('t1.nii.gz_al.nii.gz','c_t1.nii.gz');

    
% transform mc_func_vol to tlrc space     
func2tlrc_cmd = ['@auto_tlrc -apar c_t1_at.nii -input mc_func_vol.nii -dxyz 1.6'];
system(func2tlrc_cmd)

% transform all func runs to tlrc space
for r=1:nRuns
    func2tlrc_cmd = ['@auto_tlrc -apar c_t1_at.nii -input srarun' num2str(r) '+orig -dxyz 1.6'];
    system(func2tlrc_cmd)
end


%% MAKE A BINARY MASK 

% make a binary mask for each run
for r=1:nRuns
    mask_cmd = ['3dAutomask -prefix mask' num2str(r) ' srarun' num2str(r) '_at.nii'];
    system(mask_cmd)
end

% take the mean of all run masks 
mask_cmd = ['3dMean -datum float -prefix mean_mask mask*'];
system(mask_cmd);

% create one mask from the mean including all voxels w/a value of .2 or
% higher (so present in masks from at least 2 runs)
mask_cmd = ['3dcalc -datum byte -prefix s' subj 'mask -a mean_mask+tlrc -expr ''step(a-0.2)'''];
system(mask_cmd);

% delte all mask files except main subject one
delete('mask*','mean_mask*');


%% SCALE EACH FUNC RUN 

for r=1:nRuns
    
    % get the mean of each run
    scale_cmd = ['3dTstat -mean -prefix mean srarun' num2str(r) '+tlrc'];
    system(scale_cmd)
    
    % scale each run by dividing by the run mean then x 100
    scale_cmd = ['3dcalc -a srarun' num2str(r) '+tlrc -b mean+tlrc -expr ''(a/b)*100'' -prefix srarun' num2str(r) '_scaled'];
    system(scale_cmd)
    
    % delete the mean file for each run
    delete('mean+*');
    
end


%% 



% calculate a group mask





%% 
%    %% Coregister anatomy with reference functional volume
%    
% %     function coReg( studyDirectory, subjFolder, exp )
%     
%     disp('coregistration');
%     
%     VG = fullfile(outDir, ref_filename);
% 
%     VG = spm_vol(VG);
%     
%     % % Use anatomy as source
%     
%     VF = fullfile(inDir,anat_filenames{1});
%      VF = spm_vol(strvcat(VF));
     
     
%     anatomyDir = sprintf('%s/%s/anat',studyDirectory, subjFolder);
%     cd(anatomyDir);
%     sourceFolder = pwd;
%     source = dir('anat*');
%     sourceFile = source.name;
%     VF = fullfile(sourceFolder, sourceFile);
%     if ischar(VF) || iscellstr(VF), VF = spm_vol(strvcat(VF)); end;
    
    % % estimate coregistration
%     flags = struct('sep',[4 2],'cost_fun','nmi','fwhm',[7 7],...
%         'tol',[0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001]);
%     spm_coreg(VG,VF,flags);
%     
%     clear flags
%     P = char(VG.fname, VF.fname);
%     
%     % % Perform coregistration
%     flags = struct('interp', 1, 'mask', 0,'wrap',[0 0 0]',...
%         'prefix','r');
%     spm_reslice(P, flags);
%     
%     clear P VF VG
%     cd ..
%     %% move step avol* to /steps
%  
%     disp('--> moving avol* to to steps/');
% 
%     for run = 1:exp.noRuns
%         runFolder = ['run_000' num2str(run)];
%         cd(runFolder);  % cd to the appropriate run folder
%         vols = dir('avol*');
%         mkdir steps;
%             for file = 1:length(vols)
%             movefile(vols(file).name, 'steps'); 
%             end
% 	 cd ..
%     end
%     
%     


% a) Slice timing correction
% r) Realignment of functionals to first image
% u) Realign & Unwrap (requires FieldMap steps first!see SPM manual not yet in here)
% c) Coregistration of T1 to realigned functional mean
% z) Segmentation of corregistered T1
% w) Normalization of functionals onto EPI template using segmentations
% s) Smoothing of functionals
% v) Artrepair

    
    
    
