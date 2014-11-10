
% script for analyzing mux pilot data

% This is a script that calls preprocessfmri_CNI.m.
% based on Kendrick's preprocess_CNIscript.m 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% run this script to preprocess mux data (slice time & motion correction; 
% also computes temporal SNR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EDIT THIS:
% what directory do the data live in?
datadir = '/home/kelly/SA2/data/pilot100513/mux3_run1';

% where should i save figures to?
figuredir = '/home/kelly/SA2/data/pilot100513/mux3_run1/figures';


% what NIFTI files should we interpret as the fieldmaps?
% (to omit the fieldmap-based undistortion process, just set fieldmapB0files to [].)
fieldmapB0files = [];
fieldmapMAGfiles = [];
 
% if you didn't acquire fieldmaps with the same slice thickness as the 
% functionals, we can work around this problem if your fieldmaps are
% a positive integer multiple of the slice thickness of the functionals,
% and if the total field-of-view in the slice dimension is the same.
% all we do is upsample the fieldmaps using nearest neighbor interpolation.
% this is done immediately and we then act as if the fieldmaps were acquired
% at the correct slice thickness.  (of course, we could be more flexible
% and fix other circumstances, but we'll do this as the need arises.)
% if you want the work around, supply the appropriate positive integer 
% for <fieldmapslicefactor>.  if [], do nothing special.
fieldmapslicefactor = [];
 
% what are the time values to associate with the fieldmaps?
% if [], default to 1:N where N is the number of fieldmaps.
fieldmaptimes = [];
 
% what is the difference in TE (in milliseconds) for the two volumes in the fieldmaps?
% (hint: after entering in the value of map_deltaf, check the value of map_delta in 
% the CV vars of the spiral fieldmap sequence.)
fieldmapdeltate = [];
 
% should we attempt to unwrap the fieldmaps? (note that 1 defaults to a fast, 2D-based strategy; 
% see preprocessfmri.m for details.)  if accuracy is really important to you and the 2D strategy 
% does not produce good results, consider switching to a full 3D strategy like 
% fieldmapunwrap = '-f -t 0' (however, execution time may be very long).
fieldmapunwrap = 0;
 
% how much smoothing (in millimeters) along each dimension should we use for the fieldmaps?
% the optimal amount will depend on what part of the brain you care about.
% I have found that 7.5 mm may be a good general setting.
fieldmapsmoothing = [];
 
% what NIFTI files should we interpret as in-plane runs?
% inplanefilenames = matchfiles([datadir '/*inplane*nii*'],'tr');
inplanefilenames = [];
 
% what NIFTI files should we interpret as EPI runs?
epifilenames{1} = '/home/kelly/SA2/data/pilot100513/mux3_run1/mux3_run1.nii.gz'; % ***

 

% what is the desired in-plane matrix size for the EPI data?
% this is useful for downsampling your data (in order to save memory) 
% in the case that the data were reconstructed at too high a resolution.  
% for example, if your original in-plane matrix size was 70 x 70, the 
% images might be reconstructed at 128 x 128, in which case you could 
% pass in [70 70].  what we do is to immediately downsample each slice
% using lanczos3 interpolation.  if [] or not supplied, we do nothing special.
epidesiredinplanesize = [];
 
% what is the slice order for the EPI runs?
% special case is [] which means to omit slice time correction.
episliceorder = [1:2:26,2:2:26];
episliceorder = repmat(episliceorder,1,3); % ***
 
% what fieldmap should be used for each EPI run? ([] indicates default behavior, which is to attempt
% to match fieldmaps to EPI runs 1-to-1, or if there is only one fieldmap, apply that fieldmap
% to all EPI runs, or if there is one more fieldmap than EPI runs, interpolate each successive
% pair of fieldmaps; see preprocessfmri.m for details.)
epifieldmapasst = [];
 
% how many volumes should we ignore at the beginning of each EPI run?
numepiignore = 2;
 
% what volume should we use as reference in motion correction? ([] indicates default behavior which is
% to use the first volume of the first run; see preprocessfmri.m for details.  set to NaN if you
% want to omit motion correction.)
motionreference = [];
 
% for which volumes should we ignore the motion parameter estimates?  this should be a cell vector
% of the same length as the number of runs.  each element should be a vector of indices, referring
% to the volumes (after dropping volumes according to <numepiignore>).  can also be a single vector
% of indices, in which case we use that for all runs.  for volumes for which we ignore the motion
% parameter estimates, we automatically inherit the motion parameter estimates of the closest
% volumes (if there is a tie, we just take the mean).  [] indicates default behavior which is to 
% do nothing special.
epiignoremcvol = [];
 
% by default, we tend to use double format for computation.  but if memory is an issue,
% you can try setting <dformat> to 'single', and this may reduce memory usage.
dformat = 'single';
 
% what cut-off frequency should we use for filtering motion parameter estimates? ([] indicates default behavior
% which is to low-pass filter at 1/90 Hz; see preprocessfmri.m for details.)
motioncutoff = [];
 
% what extra transformation should we use in the final resampling step? ([] indicates do not perform an extra transformation.)
extratrans = [];
 
% what is the desired resolution for the resampled volumes? ([] indicates to just use the original EPI resolution.)
targetres = []; 

% should we perform slice shifting?  if so, specify band-pass filtering cutoffs in Hz, like [1/360 1/20].
% probably should be left as [] which means to do nothing special.
sliceshiftband = [];

% these are constants that are used in fmriquality.m.  it is probably 
% fine to leave this as [], which means to use default values.
% NaN means to skip the fmriquality calculations.
fmriqualityparams = []; 

% what kind of time interpolation should we use on the fieldmaps (if applicable)?
% ([] indicates to use the default, which is cubic interpolation.)
fieldmaptimeinterp = [];

% should we use a binary 3D ellipse mask in the motion parameter estimation?
% if [], do nothing special (i.e. do not use a mask).
% if {}, then we will prompt the user to interactively determine the
%   3D ellipse mask (see defineellipse3d.m for details).  upon completion,
%   the parameters will be reported to the command window so that you can
%   simply supply those parameters if you run again (so as to avoid user interaction).
% if {MN SD}, then these will be the parameters that determine the mask to be used.
mcmask = [];

% how should we handle voxels that have NaN values after preprocessing?
% if [], we use the default behavior which is to zero out all voxels that have a NaN
% value at any point in the EPI data.  see preprocessfmri.m for other options.
maskoutnans = [];

% savefile:  what .nii files (accepting a 1-indexed integer) should we save the final EPI data to?
% (we automatically make parent directories if necessary, and we also create a mean.nii file
% with the mean volume and a valid.nii file with a binary mask of the valid voxels.)

savefile = [datadir '/pp_mux3_run1.nii.gz']; % ***

% what .txt file should we keep a diary in?
diaryfile = [datadir '/mux3_run1.txt'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW:

  mkdirquiet(stripfile(diaryfile));
  diary(diaryfile);
  
  rp = 2.0; % acceleration factor not in the nifti header for mux sequences
path('/usr/local/spm8',path)
preprocessfmri_CNI;
  diary off;
 

