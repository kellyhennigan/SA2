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

subj = '27';

p=getSA2Paths(subj);

% what directory do the data live in?
datadir = p.raw;

% where should i save figures to?
figuredir = fullfile(p.func_proc,'figures');


% where should the preprocessed files be saved to?
outdir = p.func_proc;


% what NIFTI files should we interpret as EPI runs?
epifilenames = {'run1_c1.nii.gz',...
    'run2_c1.nii.gz',...
    'run3_c1.nii.gz',...
    'run4_c2.nii.gz',...
    'run5_c2.nii.gz',...
    'run6_c2.nii.gz'};% ***


% by default, we tend to use double format for computation.  but if memory is an issue,
% you can try setting <dformat> to 'single', and this may reduce memory usage.
dformat = 'single';

% prefix for saved out pre-processed files
outfileprefix = ['pp_'];

numepiignore = 0;

% what .txt file should we keep a diary in?
diaryfile = [outdir outfileprefix 'diary.txt'];


%% drop the first few vols?

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


%% motion correction info

doCorrectMotion = 1; % 1 to correct slice timing, otherwise 0


% what volume should we use as reference in motion correction? ([] indicates default behavior which is
% to use the first volume of the first run
motionRef = [];

% what cut-off frequency should we use for filtering motion parameter estimates? ([] indicates default behavior
% which is to low-pass filter at 1/90 Hz; see preprocessfmri.m for details.)
motionCutoff = [];

% should we use a binary 3D ellipse mask in the motion parameter estimation?
% if [], do nothing special (i.e. do not use a mask).
mcMask = [];

epiignoremcvol = []; % ignore any volumes for mc? (default is no)



%% field map correction

doCorrectFieldMap = 1;

fmapdeltate = 2272; % TE between fieldmap vols (in ms)
fmaptimes = [];

fmapunwrap = 1;

fmapsmoothing = [7.5 7.5 7.5];

fmapMAGfiles= {'fmap1.nii.gz'};
fmapB0files = {'fmap1_B0.nii.gz'};

epifmapasst = {1 1 1 2 2 2};

%% fmri quality checks and figures for inspection

% these are constants that are used in fmriquality.m.  it is probably
% fine to leave this as [], which means to use default values.
% NaN means to skip the fmriquality calculations.
fmriQualityParams = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW:
%
mkdirquiet(stripfile(diaryfile));
diary(diaryfile);



fprintf('loading EPI data...');


nii = readFileNifti(fullfile(datadir,epifilenames{1}));
epis{1} = double(nii.data);
vox_dim = nii.pixdim(1:3);
TR = nii.pixdim(4);
epi_dim = sizefull(nii.data,3);
nVols = size(nii.data,4);
eval(nii.descrip); % at cni this gives [te, ti, fa, ec, acq, mt, rp]
inPlaneMatrixSize = acq;
nSlices = size(nii.data,3);
readOutTime = ec*acq(2)/rp; % divide by 2 if you are using 2x acceleration
phaseDir = bitand(uint8(3),bitshift(uint8(nii.dim(3)),-2)); % ?? don't get whats happening here

for r = 2:numel(epifilenames)
    nii = readFileNifti(fullfile(datadir,epifilenames{r}));
    epis{r} = double(nii.data);
end


fprintf('done (loading EPI data).\n');

reportmemoryandtime;


%% drop the first few vols

% if ~notDefined('nVolsOmit')
%     fprintf(['dropping first ' num2str(nVolsOmit) ' volumes from the epi...']);
%     nii.data(:,:,:,1:nVolsOmit) = []; % drop them
%     nVols = nVols-nVolsOmit;
%     fprintf('done.\n');
%     reportmemoryandtime;
%
% end

%% SLICE TIME CORRECTION

% if (doCorrectSliceTime)
%     fprintf('correcting for differences in slice acquisition times...');
%     nii.data = correctSliceTime(nii.data,sliceOrder,mux);
%     fprintf('done.\n');
%     reportmemoryandtime;
% end


%% FIELDMAP CORRECTION

if doCorrectFieldMap
    
    % load fieldmap data
    fprintf('loading fieldmap data...');
    fmaps = {}; fmapsizes = {}; fmapbrains = {};
    
    for r = 1:numel(fmapB0files)
        % for r=1:numel(fieldmapB0files)
        fmB0 = readFileNifti(fullfile(datadir,fmapB0files{r}));
        fmaps{r} = double(fmB0.data) * pi / (1/(fmapdeltate/1000)/2);  % convert to range [-pi,pi]
        fmapsizes{r} = fmB0.pixdim(1:3);
        
        fmMAG = readFileNifti(fmapMAGfiles{r});
        fmapbrains{r} = double(fmMAG.data(:,:,:,1)); % just use first volume
        
        clear fmB0 fmMAG
        
    end
    
    fprintf('done (loading fieldmap data).\n');
    
end

reportmemoryandtime;
%
% correctDistortion(fieldmaps,fieldmapbrains,fieldmapsizes,fieldmapdeltate,...
%     fieldmaptimes,fieldmapunwrap,fieldmapsmoothing,figuredir)



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

%% COMPUTE TEMPORAL SNR






%%

extratrans = []
targetres = []
sliceshiftband = []
maskoutnans = 1;
fmriqualityparams = []
fmaptimeinterp = []

fprintf('calling preprocessfmri...');
[epis,finalepisize,validvol,meanvol] = preprocessfmri_SA2(figuredir, ...
  fmaps,fmapbrains,fmapsizes,fmapdeltate,fmapunwrap,fmapsmoothing, ...
  epis,mux,vox_dim,inPlaneMatrixSize,TR,sliceOrder,phaseDir,readOutTime,...
  epifmapasst,numepiignore,motionRef,motionCutoff,extratrans,targetres,sliceshiftband, ...
  fmriqualityparams,fmaptimeinterp,mcMask,maskoutnans,epiignoremcvol,dformat);
% fprintf('done (calling preprocessfmri).\n');
%


%%



%%
diary off;


