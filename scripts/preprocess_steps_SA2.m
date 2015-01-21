% preprocess fmri data for the SA2 experiment

% my hope is to document my preprocessing steps here with some light
% explanation of why/how things are done, then add checks at every stage to
% visualize what was done and if there are any problems.

% 1) drop the first few volumes
% 2) compute temporal snr
% 3) slice time correction
% 4) fieldmap correction
% 5) motion correction

% fieldmap correction and motion correction will be estimated separately 
% and then resampled in the same step


% 6) smooth the data - use a FWHM kernel that's roughly twice the width of
% the voxel's most lengthy dimension

% 7) normalize to a group template

% 8) do GLMs at the individual and group level


%% define directories, files, etc.


subj = '23';

p=getSA2Paths(subj);

% what directory do the data live in?
datadir = p.raw;

% what NIFTI files should we interpret as EPI runs?
epifilenames = {'run1.nii.gz',...
    'run2.nii.gz',...
    'run3.nii.gz',...
    'run4.nii.gz',...
    'run5.nii.gz',...
    'run6.nii.gz'};% ***


% by default, we tend to use double format for computation.  but if memory is an issue,
% you can try setting <dformat> to 'single', and this may reduce memory usage.
dformat = 'single';

% where should i save figures to?
figuredir = fullfile(p.func_proc,'figures');

% where should the preprocessed files be saved to?
outdir = p.func_proc;

% prefix for saved out pre-processed files
outfileprefix = ['pp_'];

% how many volumes should we omit at the beginning of each EPI run? 
% 0 or '' to not omit any 
omitNVols = 6;

% what .txt file should we keep a diary in?
diaryfile = [outdir outfileprefix 'diary.txt'];

%%%%%%%%%%%%%%%%%%%% SLICE TIME CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%

doComputeTSNR = 1; % 1 to compute temporal SNR, otherwise 0



%%%%%%%%%%%%%%%%%%%% SLICE TIME CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%

doCorrectSliceTime = 1; % 1 to correct slice timing, otherwise 0

% what is the slice order for the EPI runs?
% for MUX sequences, do slice order as if it was mux 1
sliceOrder = [1:2:19,2:2:19];

% for mux sequences, enter the number of simultaneously acquired slices; if
% not a mux sequence, set this to 0 or []
mux = 3;


%%%%%%%%%%%%%%%%%%%%%% FIELDMAP CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%

doCorrectFieldMap = 1;

fmapdeltate = 2272; % TE between fieldmap vols (in ms)
fmaptimes = [];

fmapunwrap = 1;

fmapsmoothing = [];

fmapMAGfiles= {'fmap1.nii.gz'};
fmapB0files = {'fmap1_B0.nii.gz'};

epifmapasst = {};

%%%%%%%%%%%%%%%%%%%%%% MOTION CORRECTION INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

doCorrectMotion = 1; % 1 to correct slice timing, otherwise 0

% save out a single volume nifti to use as reference for motion correction
% before running this script. Specify its filepath/name here
ref_filename = fullfile(outdir,'func_ref_vol.nii.gz');

% what cut-off frequency should we use for filtering motion parameter estimates? ([] indicates default behavior
% which is to low-pass filter at 1/90 Hz; see preprocessfmri.m for details.)
motionCutoff = [];

% should we use a binary 3D ellipse mask in the motion parameter estimation?
% if [], do nothing special (i.e. do not use a mask).
mcMask = [];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO IT

path('/Applications/spm8',path);
% setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
% setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be



nRuns = numel(epifilenames); % # of runs to process

% start diary
mkdirquiet(stripfile(diaryfile));
diary(diaryfile);

if notDefined('nVolsOmit')
    nVolsOmit = 0;
end
  
         
fprintf('loading EPI data...');

r = 1; % which nii file to load

nii = readFileNifti(fullfile(datadir,epifilenames{r}));

% get some info from the first nii file  
if r==1
    vox_dim = nii.pixdim(1:3);
    TR = nii.pixdim(4);
    epi_dim = sizefull(nii.data,3);
    nVols = size(nii.data,4);
    eval(nii.descrip); % at cni this gives [te, ti, fa, ec, acq, mt, rp]
    inPlaneMatrixSize = acq;
    nSlices = size(nii.data,3);
    readOutTime = ec*acq(2)/rp; % divide by 2 if you are using 2x acceleration
    phaseDir = bitand(uint8(3),bitshift(uint8(nii.dim(3)),-2)); % ?? don't get whats happening here
end

fprintf('done (loading EPI data).\n');
reportmemoryandtime;

% note: check out kendrick's undistortvolumes script to go the motion
% correction and undistortion correction in one step (maybe)


%% DROP THE FIRST FEW VOLS 

if ~notDefined('nVolsOmit')
    fprintf(['dropping first ' num2str(nVolsOmit) ' volumes from the epi...']);
    nii.data(:,:,:,1:nVolsOmit) = []; % drop them
    nVols = nVols-nVolsOmit;
    fprintf('done.\n');
    reportmemoryandtime;
    
end

%% COMPUTE TEMPORAL SNR 

% compute temporal SNR
  % this is a cell vector of 3D volumes.  values are percentages representing the median frame-to-frame difference
  % in units of percent signal.  (if the mean intensity is negative, the percent signal doesn't make sense, so
  % we set the final result to NaN.)  [if not enough volumes, some warnings will be reported.]
fprintf('computing temporal SNR...');
temporalsnr = cellfun(@computetemporalsnr,epis,'UniformOutput',0);
fprintf('done.\n');

  reportmemoryandtime;

% write out EPI inspections
if wantfigs
  fprintf('writing out various EPI inspections...');

  % first and last of each run
  viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,1)),epis,'UniformOutput',0)),sprintf('%s/EPIoriginal/image%%04da',figuredir));
  viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,end)),epis,'UniformOutput',0)),sprintf('%s/EPIoriginal/image%%04db',figuredir));

  % movie of first run
  viewmovie(double(epis{1}(:,:,:,1:min(30,end))),sprintf('%s/MOVIEoriginal/image%%04d',figuredir));

  % temporal SNR for each run
  for p=1:length(temporalsnr)
    imwrite(uint8(255*makeimagestack(tsnrmx-temporalsnr{p},[0 tsnrmx])),jet(256),sprintf('%s/temporalsnr%02d.png',figuredir,p));
  end

  fprintf('done.\n');
end

  reportmemoryandtime;


%% SLICE TIME CORRECTION

if (doCorrectSliceTime)
    fprintf('correcting for differences in slice acquisition times...');
    nii.data = correctSliceTime(nii.data,sliceOrder,mux);
    fprintf('done.\n');
    reportmemoryandtime;
    
    % save out slice-time corrected nii file
    nii.fname = fullfile(outdir,['a' epifilenames{r}]);
    writeFileNifti(nii);
 
end


%% FIELDMAP CORRECTION

% if doCorrectFieldMap
%     
%     % load fieldmap data
    fprintf('loading fieldmap data...');
    fmaps = {}; fmapsizes = {}; fmapbrains = {};
%     
m=1;

%      
        fmB0 = readFileNifti(fullfile(datadir,fmapB0files{m}));
        fmaps{m} = double(fmB0.data) * pi / (1/(fmapdeltate/1000)/2);  % convert to range [-pi,pi]
        fmapsizes{m} = fmB0.pixdim(1:3);
%         
        fmMAG = readFileNifti(fullfile(datadir,fmapMAGfiles{m}));
        fmapbrains{m} = double(fmMAG.data(:,:,:,1)); % just use first volume
%         
%         clear fmB0 fmMAG
%         
%     end
%     
    fprintf('done (loading fieldmap data).\n');
 reportmemoryandtime;
% %
% correctDistortion(fieldmaps,fieldmapbrains,fieldmapsizes,fieldmapdeltate,...
%     fieldmaptimes,fieldmapunwrap,fieldmapsmoothing,figuredir)


%% make VDM for fieldmap correction, do fieldmap correction 

% pm_defs = [9.1, 11.372, 0, 19.1, -1, 1, 1]];
% 
% VDM=FieldMap_preprocess(indir,epi_dir,[9.1,11.372,0,pm_defs,sessname)

%% MOTION CORRECTION

% skipReslice = 0;
%
% if (doCorrectMotion)
%
%     fprintf('correcting for motion...');
%
%     [vols,paramsB] = motioncorrectvolumes(nii.data,[vox_dim,TR],figuredir,...
%         motionRef,motionCutoff,[],skipReslice);
%
%     fprintf('done.\n');
%     reportmemoryandtime;
% end

cd(outDir)

for r = 1:nRuns
    
    mc_command = ['afni 3dvolreg -prefix rarun' num2str(r) ' -verbose -base ',...     
        ref_filename ' -zpad 4 -dfile vr_run' num2str(r) ' a' epifilenames{r}];
    
    system(mc_command)
        
    
end









%%
diary off;


