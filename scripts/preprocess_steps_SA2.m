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


maindir = '/Volumes/Ruca/14/';

% what directory do the data live in?
datadir = [maindir 'raw/'];


% where should i save figures to?
figuredir = [maindir 'preproc_figs']; % ***


% what NIFTI files should we interpret as EPI runs?
epifilenames{1} = [datadir 'run1.nii.gz']; % ***


% by default, we tend to use double format for computation.  but if memory is an issue,
% you can try setting <dformat> to 'single', and this may reduce memory usage.
dformat = 'single';

savefile = [maindir 'pp_run1.nii.gz']; % ***

% what .txt file should we keep a diary in?
diaryfile = [maindir 'diary_pp_run1.txt'];


%% drop the first few vols?

% how many volumes should we ignore at the beginning of each EPI run?
nVolsOmit = 5;


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
% if {}, then we will prompt the user to interactively determine the
%   3D ellipse mask (see defineellipse3d.m for details).  upon completion,
%   the parameters will be reported to the command window so that you can
%   simply supply those parameters if you run again (so as to avoid user interaction).
% if {MN SD}, then these will be the parameters that determine the mask to be used.
mcMask = [];


%% field map correction

doCorrectFieldMap = 1; 

fieldmapdeltate = 2272; % TE between fieldmap vols (in ms)
fieldmaptimes = [];

fieldmapunwrap = 0;

fieldmapsmoothing = [7.5 7.5 7.5];


fieldmapMAGfiles= {'fmap_1.nii.gz'};
fieldmapB0files = {'fmap_B0_1.nii.gz'};


%% fmri quality checks and figures for inspection

% these are constants that are used in fmriquality.m.  it is probably
% fine to leave this as [], which means to use default values.
% NaN means to skip the fmriquality calculations.
fmriQualityParams = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW:
%%
% mkdirquiet(stripfile(diaryfile));
% diary(diaryfile);



fprintf('loading EPI data...');

p = 1
nii = readFileNifti(epifilenames{p});
nii.data = double(nii.data);
vox_dim = nii.pixdim(1:3);
TR = nii.pixdim(4);
epi_dim = sizefull(nii.data,3);
nVols = size(nii.data,4);
eval(nii.descrip); % at cni this gives [te, ti, fa, ec, acq, mt, rp]
inPlaneDim = acq;
nSlices = size(nii.data,3);
readOutTime = ec*acq(2)/rp; % divide by 2 if you are using 2x acceleration
phaseDir = bitand(uint8(3),bitshift(uint8(nii.dim(3)),-2)); % ?? don't get whats happening here

% epis = {}; episizes = {}; TR = {};
% phaseDir = [];

% for p=1:length(epifilenames)
% p = 1
%     ni = load_untouch_nii(gunziptemp(epifilenames{p}));
%     epis{p} = double(ni.img);
%     episizes{p} = ni.hdr.dime.pixdim(2:4);
%     TR{p} = ni.hdr.dime.pixdim(5);
    
    
    
%     if p == 1
%         eval(ni.hdr.hist.descrip);  % this should define [ec, rp, acq]
%         % this should be [A B] where A and B are the in-plane frequency-encode
%         % and phase-encode matrix sizes, respectively.  can be [] in which case
%         % we default to the size of the first two dimensions of the EPI data.
%         epiinplanematrixsize = acq;
%         fprintf('*** epiinplanematrixsize determined to be %s.\n',mat2str(epiinplanematrixsize));
%         
%         epireadouttime = ec*acq(2)/rp;  % divide by 2 if you are using 2x acceleration
%         fprintf('*** epireadouttime determined to be %.5f ms * %d lines / %d acceleration.\n',ec,acq(2),rp);
        
%     end
%     
%     phaseDir(p) = bitand(uint8(3),bitshift(uint8(ni.hdr.hk.dim_info),-2));
%     fprintf('*** phaseDir for run %d determined to be %d.\n',p,phaseDir(p));
%     
%     clear ni;
    
% end % for epifilenames

fprintf('done (loading EPI data).\n');

reportmemoryandtime;


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
    slice_time_corrected_epi = correctSliceTime(nii.data,sliceOrder,mux);
    fprintf('done.\n');
    reportmemoryandtime;
end


%% FIELDMAP CORRECTION

fieldmapdeltate = 2272;
fieldmaptimes = [];

fieldmapunwrap = 1;

fieldmapsmoothing = [7.5 7.5 7.5];


fieldmapMAGfiles= {[datadir 'fmap_1.nii.gz'],[datadir 'fmap_2.nii.gz']};
fieldmapB0files = {[datadir 'fmap_B0_1.nii.gz'],[datadir 'fmap_B0_2.nii.gz']};


% load fieldmap data
fprintf('loading fieldmap data...');
fieldmaps = {}; fieldmapsizes = {}; fieldmapbrains = {};

% p = 1
for p=1:length(fieldmapB0files)
%   ni = load_untouch_nii(gunziptemp(fieldmapB0files{p}));
%   fieldmaps{p} = double(ni.img) * pi / (1/(fieldmapdeltate/1000)/2) ;  % convert to range [-pi,pi]
%   fieldmapsizes{p} = ni.hdr.dime.pixdim(2:4);
%   ni = load_untouch_nii(gunziptemp(fieldmapMAGfiles{p}));
%   fieldmapbrains{p} = double(ni.img(:,:,:,1));  % JUST USE FIRST VOLUME
%   clear ni;
%   
  niiB0 = readFileNifti(fieldmapB0files{p});
  fieldmaps{p} = double(niiB0.data) * pi / (1/(fieldmapdeltate/1000)/2);  % convert to range [-pi,pi]
  fieldmapsizes{p} = niiB0.pixdim(1:3);
  
  nii = readFileNifti(fieldmapMAGfiles{p});
  fieldmapbrains{p} = double(nii.data(:,:,:,1)); % just use first volume
  
  clear niiB0 nii
  
 end
fprintf('done (loading fieldmap data).\n');

reportmemoryandtime;

correctDistortion(fieldmaps,fieldmapbrains,fieldmapsizes,fieldmapdeltate,...
    fieldmaptimes,fieldmapunwrap,fieldmapsmoothing,figuredir)


    
    %% MOTION CORRECTION 

skipReslice = 0;

if (doCorrectMotion)
    
    fprintf('correcting for motion...');
    
    [vols,paramsB] = motioncorrectvolumes(nii.data,[vox_dim,TR],figuredir,...
        motionRef,motionCutoff,[],skipReslice);

    fprintf('done.\n');
    reportmemoryandtime;
end

    %% 
% fprintf('calling preprocessfmri...');
% [epis,finalepisize,validvol,meanvol] = preprocessfmri(figuredir,inplanes,inplanesizes, ...
%     {fieldmaps fieldmaptimes},fieldmapbrains,fieldmapsizes,fieldmapdeltate,fieldmapunwrap,fieldmapsmoothing, ...
%     epis,episizes{1},epiinplanematrixsize,cell2mat(TR),sliceOrder, ...
%     phaseDir,epireadouttime,epifieldmapasst, ...
%     nVolsOmit,motionRef,motionCutoff,extratrans,targetres, ...
%     sliceshiftband,fmriQualityParams,fieldmaptimeinterp,mcMask,maskoutnans,epiignoremcvol,dformat);
% fprintf('done (calling preprocessfmri).\n');
% 


%%



%%
diary off;


