% preprocess fmri data for the SA2 experiment

% my hope is to document my preprocessing steps here with some light
% explanation of why/how things are done, then add checks at every stage to
% visualize what was done and if there are any problems.

% 1) drop the first few volumes
% 2) slice time correction
% 3) motion correction
% 4) fieldmap correction

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

subj = '11';

p=getSA2Paths(subj);

% what directory do the data live in?
inDir = p.raw;

% where should i save figures to?
figuredir = fullfile(p.func_proc,'figures');

% where should the preprocessed files be saved to?
outDir = p.func_proc;

% what NIFTI files should we interpret as EPI runs?
epifilenames = {'run1.nii.gz',...
    'run2.nii.gz',...
    'run3.nii.gz',...
    'run4.nii.gz',...
    'run5.nii.gz',...
    'run6.nii.gz'};% ***

func_ref_idx = [3 1]; % idx of the run and the vol of the run to align
% other functional volumes and anatomical data to. NOTE: the vol idx refers
% counts AFTER nVolsOmit have been discarded from the run. 
ref_filename = 'mc_func_vol.nii';


anat_filenames = {'t1.nii','t2.nii','pd.nii'}; % anatomical files to coregister w/functional data


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
    nii.data = double(nii.data);
    vox_dim = nii.pixdim(1:3);
    TR = nii.pixdim(4);
    epi_dim = sizefull(nii.data,3);
    nVols = size(nii.data,4);
    eval(nii.descrip); % at cni this gives [te, ti, fa, ec, acq, mt, rp]
    inPlaneMatrixSize = acq;
    nSlices = size(nii.data,3);
    readOutTime = ec*acq(2)/rp; % divide by 2 if you are using 2x acceleration
    phaseDir = bitand(uint8(3),bitshift(uint8(nii.dim(3)),-2)); % ?? don't get whats happening here
    
    
    
    %% drop the first few vols, save out the func vol to align anatomical data to
    
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
    
    
    %% save out a reference volume for coregistering anatomical data
    
     if r==func_ref_idx(1)
        vol = nii;
        vol.fname = fullfile(outDir,ref_filename);
        vol.data = vol.data(:,:,:,func_ref_idx(2));
        writeFileNifti(vol);
     end
    
    clear nii
    
end


% %% MOTION CORRECTION
% 
% cd(outDir)
% 
% for r = 1:nRuns
%     
%     mc_command = ['3dvolreg -prefix rarun' num2str(r) ' -verbose -base ',...     
%         ref_filename ' -dfile run' num2str(r) '_vr a' epifilenames{r}];
%     
%     system(mc_command)
%         
%     
% end
    
    
    

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
    
    
    
