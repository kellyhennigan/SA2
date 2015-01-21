%%%%%%%%%%%
%%% START HERE
subj = '18';
expPaths=getSA2Paths(subj);
% what directory do the data live in?
datadir = expPaths.raw;
% what NIFTI files should we interpret as EPI runs?
epifilenames = {'run1.nii.gz'}; % ***

% what NIFTI files should we interpret as the fieldmaps?
% (to omit the fieldmap-based undistortion process, just set fieldmapB0files to [].)
fieldmapMAGfiles= {'fmap1.nii.gz'};
fieldmapB0files = {'fmap1_B0.nii.gz'};

% where should i save figures to?
figuredir = fullfile(expPaths.func_proc,'figures');

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
fieldmaptimes = [1];

% what is the difference in TE (in milliseconds) for the two volumes in the fieldmaps?
% (hint: after entering in the value of map_deltaf, check the value of map_delta in
% the CV vars of the spiral fieldmap sequence.)
fieldmapdeltate = [2272];

% should we attempt to unwrap the fieldmaps? (note that 1 defaults to a fast, 2D-based strategy;
% see preprocessfmri.m for details.)  if accuracy is really important to you and the 2D strategy
% does not produce good results, consider switching to a full 3D strategy like
% fieldmapunwrap = '-f -t 0' (however, execution time may be very long).
fieldmapunwrap = 1;

% how much smoothing (in millimeters) along each dimension should we use for the fieldmaps?
% the optimal amount will depend on what part of the brain you care about.
% I have found that 7.5 mm may be a good general setting.
fieldmapsmoothing = [7.5 7.5 7.5];

% what NIFTI files should we interpret as in-plane runs?
% inplanefilenames = matchfiles([datadir '/*inplane*nii*'],'tr');
% inplanefilenames = [];
inplanefilenames = {'t2.nii.gz','pd.nii.gz'}

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
episliceorder = [1:2:19,2:2:19];
episliceorder = repmat(episliceorder,1,3); % ***

% what fieldmap should be used for each EPI run? ([] indicates default behavior, which is to attempt
% to match fieldmaps to EPI runs 1-to-1, or if there is only one fieldmap, apply that fieldmap
% to all EPI runs, or if there is one more fieldmap than EPI runs, interpolate each successive
% pair of fieldmaps; see preprocessfmri.m for details.)
epifieldmapasst = [];

% how many volumes should we ignore at the beginning of each EPI run?
numepiignore = 6;

% what volume should we use as reference in motion correction? ([] indicates default behavior which is
% to use the first volume of the first run; see preprocessfmri.m for details. 
% three options: 
%     1) leave blank (e.g., motionreference = []); will use the 1st vol of the
%     1st run after omitting epinumignorevol vols
%     2) assign the run and vol index (e.g., motionreference = [1 1])
%     3) give the name of a nii file to load to use reference, e.g., 
mcreffile = [expPaths.func_proc, '/ref_r1_v1.nii'];


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
% mcmask = [];
mcmaskfile = [expPaths.func_proc, '/ref_mask.nii'];

% how should we handle voxels that have NaN values after preprocessing?
% if [], we use the default behavior which is to zero out all voxels that have a NaN
% value at any point in the EPI data.  see preprocessfmri.m for other options.
maskoutnans = [];


% savefile:  what .nii files (accepting a 1-indexed integer) should we save the final EPI data to?
% (we automatically make parent directories if necessary, and we also create a mean.nii file
% with the mean volume and a valid.nii file with a binary mask of the valid voxels.)
% outdir = expPaths.func_proc;
% out_prefix = 'pp_';
savefile = [expPaths.func_proc 'pp_run%02d.nii'];
% what .txt file should we keep a diary in?
% diaryfile = [expPaths.func_proc '/preproc.txt'];
%   mkdirquiet(stripfile(diaryfile));
%   diary(diaryfile);
path('/Applications/spm8',path)
% preprocessfmri_CNI;
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% preprocessfmri_CNI


reportmemoryandtime;

cd(datadir);

% load Inplane files
fprintf('loading inplane data...');
inplanes = {}; inplanesizes = {};
for p=1:length(inplanefilenames)
  ni = load_untouch_nii(gunziptemp(inplanefilenames{p}));
  inplanes{p} = double(ni.img);
  inplanesizes{p} = ni.hdr.dime.pixdim(2:4);
  clear ni;
end
if exist('inplanehackfun','var')  % HRM. HACKY.
  inplanes = cellfun(inplanehackfun,inplanes,'UniformOutput',0);
end
fprintf('done (loading inplane data).\n');

reportmemoryandtime;


% load motion correction binary mask?

%load motion reference volume?



% load EPI files
fprintf('loading EPI data...');
epis = {}; episizes = {}; epitr = {};
epiphasedir = [];
for p=1:length(epifilenames)
ni = load_untouch_nii(gunziptemp(epifilenames{p}));
epis{p} = double(ni.img);
episizes{p} = ni.hdr.dime.pixdim(2:4);
epitr{p} = ni.hdr.dime.pixdim(5);
% if this is the first EPI file, then attempt to learn some information based on
% the information in the header.
if p==1
% CNI puts some helpful information in the "descrip" field.  here,
% we simply evaluate it (since it is valid MATLAB code).  the variables
% defined are as follows:
%   ec is the echo spacing (read-out time per PE line) in milliseconds
%   rp is the ASSET/ARC acceleration factor in the phase-encode dimension
%   acq is the acquisition matrix size (freq x phase)
eval(ni.hdr.hist.descrip);  % this should define [ec, rp, acq]
% this should be [A B] where A and B are the in-plane frequency-encode
% and phase-encode matrix sizes, respectively.  can be [] in which case
% we default to the size of the first two dimensions of the EPI data.
epiinplanematrixsize = acq;
fprintf('*** epiinplanematrixsize determined to be %s.\n',mat2str(epiinplanematrixsize));
% what is the total readout time in milliseconds for an EPI slice?
% (note that 'Private_0043_102c' in the dicominfo of the EPI files gives the time per phase-encode line in microseconds.
% I confirmed that this time is correct by checking against the waveforms displayed by plotter.)
epireadouttime = ec*acq(2)/rp;  % divide by 2 if you are using 2x acceleration
fprintf('*** epireadouttime determined to be %.5f ms * %d lines / %d acceleration.\n',ec,acq(2),rp);
end
% what is the phase-encode direction for the EPI runs? (see preprocessfmri.m for details.)
% up-down in the images is 1 or -1 in our convention; left-right in the images is 2 or -2
% in our convention.  you should always check the sanity of the results!
% NOTE: this attempts to learn this information from the NIFTI.
%       if you ever flip the phase-encode direction, you will need to multiply
%       the following by -1.
epiphasedir(p) = bitand(uint8(3),bitshift(uint8(ni.hdr.hk.dim_info),-2));
fprintf('*** epiphasedir for run %d determined to be %d.\n',p,epiphasedir(p));
clear ni;
end
fprintf('done (loading EPI data).\n');
reportmemoryandtime;



% load fieldmap data
fprintf('loading fieldmap data...');
fieldmaps = {}; fieldmapsizes = {}; fieldmapbrains = {};
for p=1:length(fieldmapB0files)
  ni = load_untouch_nii(gunziptemp(fieldmapB0files{p}));
  fieldmaps{p} = double(ni.img) * pi / (1/(fieldmapdeltate/1000)/2) ;  % convert to range [-pi,pi]
  fieldmapsizes{p} = ni.hdr.dime.pixdim(2:4);
  ni = load_untouch_nii(gunziptemp(fieldmapMAGfiles{p}));
  fieldmapbrains{p} = double(ni.img(:,:,:,1));  % JUST USE FIRST VOLUME
  clear ni;
end
fprintf('done (loading fieldmap data).\n');

reportmemoryandtime;

% fieldmaps = {fieldmaps fieldmaptimes};
episize = episizes{1};


fprintf('calling preprocessfmri...');


%%
%% preprocessfmri


% [epis,finalepisize,validvol,meanvol] = preprocessfmri(figuredir,inplanes,inplanesizes, ...
%   fieldmaps,fieldmapbrains,fieldmapsizes,fieldmapdeltate,fieldmapunwrap,fieldmapsmoothing,fieldmaptimes ...
%   epis,episize,epiinplanematrixsize,cell2mat(epitr),episliceorder, ...
%   epiphasedir,epireadouttime,epifieldmapasst, ...
%   numepiignore,motionreference,motioncutoff,extratrans,targetres, ...
%   sliceshiftband,fmriqualityparams,fieldmaptimeinterp,mcmask,maskoutnans,epiignoremcvol,dformat);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INTERNAL CONSTANTS

% internal constants
tsnrmx = 5;          % max temporal SNR percentage (used in determining the color range)
numinchunk = 30;     % max images in chunk for movie
fmapdiffrng = [-50 50];  % range for fieldmap difference volumes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DBSTOP

dbstop if error;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREP

setenv('FSLDIR','/usr/local/fsl');  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ'); % this to tell what the output type would be


%%
if notDefined('motionreference')
motionreference=[1 1]; % use the first vol of the 1st run
end
if ~exist('motioncutoff','var') || isempty(motioncutoff)
motioncutoff = 1/90;
end
if ~exist('extratrans','var') || isempty(extratrans)
extratrans = eye(4);
end
if ~exist('targetres','var') || isempty(targetres)
targetres = [];
end
if ~exist('sliceshiftband','var') || isempty(sliceshiftband)
sliceshiftband = [];
end
if ~exist('fmriqualityparams','var') || isempty(fmriqualityparams)
fmriqualityparams = {[] [] []};
end
if ~exist('fieldmaptimeinterp','var') || isempty(fieldmaptimeinterp)
fieldmaptimeinterp = 'cubic';
end
if ~exist('mcmask','var') || isempty(mcmask)
mcmask = [];
end
if ~exist('maskoutnans','var') || isempty(maskoutnans)
maskoutnans = 1;
end
if ~exist('epiignoremcvol','var') || isempty(epiignoremcvol)
epiignoremcvol = [];
end
if ~exist('dformat','var') || isempty(dformat)
dformat = 'double';
end

% make sure fieldmaps and fieldmaptimes are ok...
fieldmaps
fieldmaptimes

% calc
wantundistort = ~isempty(fieldmaps);
wantsliceshift = ~isempty(sliceshiftband);



% convert to special format
% if ~iscell(numepiignore)
%   numepiignore = cellfun(@(x) [x 0],num2cell(numepiignore),'UniformOutput',0);
% end


% calc
wantfigs = ~isempty(figuredir);
wantmotioncorrect = ~isequalwithequalnans(motionreference,NaN);
epidim = sizefull(epis{1},3);     % e.g. [64 64 20]
epifov = epidim .* episize;       % e.g. [128 128 40]

% convert fieldmapunwrap
switch fieldmapunwrap
    case 1
        fieldmapunwrap = '-s -t 0';
end



% deal with massaging epifieldmapasst [after this, epifieldmapasst will either be NaN or a fully specified cell vector]
if wantundistort
  if isempty(epifieldmapasst)
    if length(fieldmaps)==1  % if one fieldmap, use it for all
      epifieldmapasst = ones(1,length(epis));
    elseif length(fieldmaps)==length(epis)  % if equal number, assign 1-to-1
      epifieldmapasst = 1:length(fieldmaps);
    elseif length(fieldmaps)==length(epis)+1  % if one more fieldmap, then interpolate between successive
      epifieldmapasst = splitmatrix(flatten([1:length(fieldmaps)-1; 2:length(fieldmaps)]),2,2*ones(1,length(epis)));
    else
      error('<epifieldmapasst> cannot be [] when the number of fieldmaps is not one NOR the same as the number of EPI runs NOR the same as the number of EPI runs plus one');
    end
  end
  if ~iscell(epifieldmapasst) && ~isequalwithequalnans(epifieldmapasst,NaN)
    epifieldmapasst = num2cell(epifieldmapasst);
  end
  assert(isequalwithequalnans(epifieldmapasst,NaN) || (length(epifieldmapasst)==length(epis)));
end

% deal with targetres
if isempty(targetres)
  targetres = epidim;
end

% make figure dir
if wantfigs
  mkdirquiet(figuredir);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DO IT



  reportmemoryandtime;

% write out inplane volumes
if wantfigs
  fprintf('writing out inplane volumes for inspection...');
  for p=1:length(inplanes)
    imwrite(uint8(255*makeimagestack(inplanes{p},1)),sprintf('%s/inplane%02d.png',figuredir,p));
    imwrite(uint8(255*makeimagestack( ...
      processmulti(@imresizedifferentfov,inplanes{p},inplanesizes{p}(1:2),epidim(1:2),episize(1:2)), ...
      1)),sprintf('%s/inplaneMATCH%02d.png',figuredir,p));
  end
  fprintf('done.\n');
end

  reportmemoryandtime;
  
  
  % drop the first few EPI volumes
fprintf('dropping EPI volumes (if requested).\n');
% epis = cellfun(@(x,y) x(:,:,:,y(1)+1:end-y(2)),epis,{numepiignore},'UniformOutput',0);
for p=1:numel(epis)
    epis{p}(:,:,:,1:numepiignore)=[];
end

  % slice time correct [NOTE: we may have to do in a for loop to minimize memory usage]
  if ~isempty(episliceorder)
      %   fprintf('correcting for differences in slice acquisition times...');
      %   epis = cellfun(@(x,y) sincshift(x,repmat(reshape((1-y)/max(y),1,1,[]),[size(x,1) size(x,2)]),4), ...
      %                  epis,repmat({calcposition(episliceorder,1:max(episliceorder))},[1 length(epis)]),'UniformOutput',0);
      
      %              %% try this instead for mux3
      
      % fprintf('correcting for differences in slice acquisition times for MUX sequence...');
                   mux3_sl_seq = repmat(calcposition(episliceorder,1:max(episliceorder)),1,3);
                   epis = cellfun(@(x,y) sincshift(x,repmat(reshape((1-y)/max(y),1,1,[]),[size(x,1) size(x,2)]),4), ...
                       epis,repmat({mux3_sl_seq},[1 length(epis)]),'UniformOutput',0);
      
      
      % the non-cell version
%       fprintf('correcting for differences in slice acquisition times for MUX sequence...');
%       epis = epis{1};
%       mux3_sl_seq = repmat(calcposition(episliceorder,1:max(episliceorder)),1,3);
%       epis = sincshift(epis,repmat(reshape((1-mux3_sl_seq)/max(mux3_sl_seq),1,1,[]),[size(epis,1) size(epis,2)]),4);
      
      
      fprintf('done.\n');
  end
  reportmemoryandtime;


  
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

% calc fieldmap stuff
fmapsc = 1./(fieldmapdeltate/1000)/2;  % vector of values like 250 (meaning +/- 250 Hz)

% write out fieldmap inspections
if wantfigs && wantundistort
  fprintf('writing out various fieldmap inspections...');

  % write out fieldmaps, fieldmaps brains, and histogram of fieldmap
  for p=1:length(fieldmaps)
  
    % write out fieldmap
    imwrite(uint8(255*makeimagestack(fieldmaps{p}/pi*fmapsc(p),[-1 1]*fmapsc(p))),jet(256),sprintf('%s/fieldmap%02d.png',figuredir,p));

    % write out fieldmap diff
    if p ~= length(fieldmaps)
      imwrite(uint8(255*makeimagestack(circulardiff(fieldmaps{p+1},fieldmaps{p},2*pi)/pi*fmapsc(p), ...
        fmapdiffrng)),jet(256),sprintf('%s/fieldmapdiff%02d.png',figuredir,p));
    end
  
    % write out fieldmap brain
    imwrite(uint8(255*makeimagestack(fieldmapbrains{p},1)),gray(256),sprintf('%s/fieldmapbrain%02d.png',figuredir,p));
    
    % write out fieldmap brain cropped to EPI FOV
    imwrite(uint8(255*makeimagestack(processmulti(@imresizedifferentfov,fieldmapbrains{p},fieldmapsizes{p}(1:2), ...
      epidim(1:2),episize(1:2)),1)),gray(256),sprintf('%s/fieldmapbraincropped%02d.png',figuredir,p));

    % write out fieldmap histogram
    figureprep; hold on;
    vals = prctile(fieldmaps{p}(:)/pi*fmapsc(p),[25 75]);
    hist(fieldmaps{p}(:)/pi*fmapsc(p),100);
    straightline(vals,'v','r-');
    xlabel('Fieldmap value (Hz)'); ylabel('Frequency');
    title(sprintf('Histogram of fieldmap %d; 25th and 75th percentile are %.1f Hz and %.1f Hz',p,vals(1),vals(2)));
    figurewrite('fieldmaphistogram%02d',p,[],figuredir);
  
  end

  fprintf('done.\n');
end

  reportmemoryandtime;

  % unwrap fieldmaps
fieldmapunwraps = {};
if wantundistort
  fprintf('unwrapping fieldmaps if requested...');
%   parfor p=1:length(fieldmaps)
% for p=1:length(fieldmaps)
 
p=1
  
    if ~isequal(fieldmapunwrap,0)
  
      % get temporary filenames
      tmp1 = tempname; tmp2 = tempname;
      
      % make a complex fieldmap and save to tmp1
      save_untouch_nii(make_ana(fieldmapbrains{p} .* exp(j*fieldmaps{p}),fieldmapsizes{p},[],32),tmp1);
      
      % use prelude to unwrap, saving to tmp2
      unix_wrapper(sprintf('prelude -c %s -o %s %s; gunzip %s.nii.gz',tmp1,tmp2,fieldmapunwrap,tmp2));
      
      % load in the unwrapped fieldmap
      temp = load_nii(sprintf('%s.nii',tmp2));  % OLD: temp = readFileNifti(tmp2);
      
      % convert from radians centered on 0 to actual Hz
      fieldmapunwraps{p} = double(temp.img)/pi*fmapsc(p);
    
    else
  
      % convert from [-pi,pi] to actual Hz
      fieldmapunwraps{p} = fieldmaps{p}/pi*fmapsc(p);
  
    end

  fprintf('done.\n');
end

  reportmemoryandtime;

  
  
  % write out inspections of the unwrapping and additional fieldmap inspections
if wantfigs && wantundistort
  fprintf('writing out inspections of the unwrapping and additional inspections...');
  
  % write inspections of unwraps
  for p=1:length(fieldmaps)
    imwrite(uint8(255*makeimagestack(fieldmapunwraps{p},[-1 1]*fmapsc(p))),jet(256),sprintf('%s/fieldmapunwrapped%02d.png',figuredir,p));
  end

  % write slice-mean inspections
    % this is fieldmaps x slice-mean with the (weighted) mean of each slice in the fieldmaps:
  fmapdcs = catcell(1,cellfun(@(x,y) sum(squish(x.*abs(y),2),1) ./ sum(squish(abs(y),2),1),fieldmapunwraps,fieldmapbrains,'UniformOutput',0));
  figureprep; hold all;
  set(gca,'ColorOrder',jet(length(fieldmaps)));
  h = plot(fmapdcs');
  legend(h,mat2cellstr(1:length(fieldmaps)),'Location','NorthEastOutside');
  xlabel('Slice number'); ylabel('Weighted mean fieldmap value (Hz)');
  title('Inspection of fieldmap slice means');
  figurewrite('fieldmapslicemean',[],[],figuredir);

  fprintf('done.\n');
end

  reportmemoryandtime;

% use local linear regression to smooth the fieldmaps
smoothfieldmaps = cell(1,length(fieldmapunwraps));
if wantundistort && ~isequalwithequalnans(epifieldmapasst,NaN)
  fprintf('smooth the fieldmaps...');
  for p=1:length(fieldmapunwraps)
    if isnan(fieldmapsmoothing)
      smoothfieldmaps{p} = processmulti(@imresizedifferentfov,fieldmapunwraps{p},fieldmapsizes{p}(1:2),epidim(1:2),episize(1:2));
    else
      fsz = sizefull(fieldmaps{p},3);
      [xx,yy,zz] = ndgrid(1:fsz(1),1:fsz(2),1:fsz(3));
      [xi,yi] = calcpositiondifferentfov(fsz(1:2),fieldmapsizes{p}(1:2),epidim(1:2),episize(1:2));
      [xxB,yyB,zzB] = ndgrid(yi,xi,1:fsz(3));
      smoothfieldmaps{p} = nanreplace(localregression3d(xx,yy,zz,fieldmapunwraps{p},xxB,yyB,zzB,[],[],fieldmapsmoothing ./ fieldmapsizes{p},fieldmapbrains{p},1),0,3);
    end
  end
  fprintf('done.\n');
end

  reportmemoryandtime;

  % write out smoothed fieldmap inspections
if wantfigs && wantundistort
  fprintf('writing out smoothed fieldmaps...');

  % write out fieldmap and fieldmap resampled to match the original fieldmap
  for p=1:length(smoothfieldmaps)
    if ~isempty(smoothfieldmaps{p})
      todo = {{1 ''} {1/3 'ALT'}};
      for qqq=1:length(todo)
        imwrite(uint8(255*makeimagestack(smoothfieldmaps{p},todo{qqq}{1}*[-1 1]*fmapsc(p))),jet(256),sprintf('%s/fieldmapsmoothed%s%02d.png',figuredir,todo{qqq}{2},p));
        imwrite(uint8(255*makeimagestack(processmulti(@imresizedifferentfov,smoothfieldmaps{p},episize(1:2), ...
          sizefull(fieldmaps{p},2),fieldmapsizes{p}(1:2)),todo{qqq}{1}*[-1 1]*fmapsc(p))),jet(256), ...
          sprintf('%s/fieldmapsmoothedbacksampled%s%02d.png',figuredir,todo{qqq}{2},p));
      end
    end
  end

  fprintf('done.\n');
end

  reportmemoryandtime;

% deal with epifieldmapasst
finalfieldmaps = cell(1,length(epis));  % we need this to exist in all epi cases
if wantundistort
  fprintf('deal with epi fieldmap assignment and time interpolation...');

  % calculate the final fieldmaps [we use single to save on memory]
  if ~isequalwithequalnans(epifieldmapasst,NaN)
    for p=1:length(epifieldmapasst)
      if epifieldmapasst{p} ~= 0
        fn = epifieldmapasst{p};
        
        % if scalar, just use as-is, resulting in X x Y x Z
        if isscalar(fn)
          finalfieldmaps{p} = single(smoothfieldmaps{fn});
        
        % if two-element vector, do the interpolation, resulting in X x Y x Z x T     [[OUCH. THIS DOUBLES THE MEMORY USAGE]]
        else
          finalfieldmaps{p} = single(permute(interp1(fieldmaptimes,permute(catcell(4,smoothfieldmaps),[4 1 2 3]), ...
                                                     linspace(fn(1),fn(2),size(epis{p},4)),fieldmaptimeinterp,'extrap'),[2 3 4 1]));
        end
        
      end
    end
  end

  fprintf('done.\n');
end

  reportmemoryandtime;

% write out EPI undistort inspections
if wantfigs && wantundistort
  fprintf('writing out inspections of what the undistortion is like...');

  % undistort the first and last volume [NOTE: temp is int16]
  temp = cellfun(@(x,y,z) undistortvolumes(x(:,:,:,[1 end]),episize, ...
                 y(:,:,:,[1 end])*(epireadouttime/1000)*(epidim(abs(z))/epiinplanematrixsize(2)), ...
                 z,[]),epis,finalfieldmaps,num2cell(epiphasedir),'UniformOutput',0);

  % inspect first and last of each run
  viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,1)),temp,'UniformOutput',0)),sprintf('%s/EPIundistort/image%%04da',figuredir));
  viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,2)),temp,'UniformOutput',0)),sprintf('%s/EPIundistort/image%%04db',figuredir));

  fprintf('done.\n');
end

  reportmemoryandtime;

  
  % for now, don't use a mask for mc corrections
  mcmaskvol = [];
  
%   % calc mcmaskvol and write out inspections
% if wantmotioncorrect
%   fprintf('writing out inspections of mcmaskvol (if applicable)...');
% 
%   % calculate mcmaskvol
%   if isempty(mcmask)
%     mcmaskvol = [];
%   else
%       
%     mcmaskvol = double(makegaussian3d(epidim,mcmask{:}) > 0.5);
%   end
% 
%   % inspect it
%   if wantfigs && ~isempty(mcmask)
%     imwrite(uint8(255*makeimagestack(mcmaskvol,[0 1])),gray(256),sprintf('%s/mcmaskvol.png',figuredir));
%   end
% 
%   fprintf('done.\n');
% end

  reportmemoryandtime;

  
  
  % if we are doing motion correction, then...
fprintf('performing motion correction (if requested) and undistortion (if requested)...');
if wantmotioncorrect

 
    epistemp = epis;
 
  % undistort temporarily [NOTE: epistemp is int16 but gets converted to double/single]
  if wantundistort
    [epistemp,d,validvoltemp] = cellfun(@(x,y,z) undistortvolumes(x,episize, ...
      y*(epireadouttime/1000)*(epidim(abs(z))/epiinplanematrixsize(2)),z,[]),epistemp,finalfieldmaps,num2cell(epiphasedir),'UniformOutput',0);
    % yuck..  we have to explicitly convert to double/single and then set nan voxels to NaN
    for p=1:length(epistemp)
      epistemp{p} = squish(cast(epistemp{p},dformat),3);
      epistemp{p}(find(~validvoltemp{p}),:) = NaN;
      epistemp{p} = reshape(epistemp{p},sizefull(epis{p},4));
    end
  end

  % estimate motion parameters from the  undistorted
%   [epistemp,mparams] = motioncorrectvolumes(epistemp,cellfun(@(x,y) [x y],repmat({episize},[1 length(epis)]),num2cell(epitr),'UniformOutput',0), ...
%     figuredir,motionreference,motioncutoff,[],1,[],[],mcmaskvol,epiignoremcvol,dformat);
  [epistemp,mparams] = motioncorrectvolumes(epistemp,[episize epitr{1}],...
    figuredir,motionreference,motioncutoff,[],1,[],[],mcmaskvol,epiignoremcvol,dformat);

clear epistemp;
          %[epistemp,homogenizemask] = homogenizevolumes(epistemp,[99 1/4 2 2]);  % [],1
  
  % finally, resample once (dealing with extratrans and targetres) [NOTE: epis is int16]
  if wantundistort
    
      [epis,voloffset,validvolrun] = cellfun(@(x,y,z,w) undistortvolumes(x,episize, ...
                     y*(epireadouttime/1000)*(epidim(abs(z))/epiinplanematrixsize(2)),z,w(2:end,:),extratrans,targetres(1:3)), ...
                     epis,finalfieldmaps,num2cell(epiphasedir),mparams,'UniformOutput',0);
  else
   
      [epis,voloffset,validvolrun] = cellfun(@(x,w) undistortvolumes(x, ...
                     episize,[],[],w(2:end,:),extratrans,targetres(1:3)), ...
                     epis,mparams,'UniformOutput',0);
   
  end

% if we're not doing motion correction then...
else

  % just slice-shift, undistort, and resample (dealing with extratrans and targetres) [NOTE: epis is int16]
  if wantundistort
    
       [epis,voloffset,validvolrun] = cellfun(@(x,y,z) undistortvolumes(x,episize, ...
                     y*(epireadouttime/1000)*(epidim(abs(z))/epiinplanematrixsize(2)),z,[],extratrans,targetres(1:3)), ...
                     epis,finalfieldmaps,num2cell(epiphasedir),'UniformOutput',0);
    
  end

end
fprintf('done.\n');

  reportmemoryandtime;

  
  %% 
% deal with preparing the <voloffset> variable for final output
  
  assert(all(cellfun(@(x) isequal(x,[0 0 0]),voloffset)));
  voloffset = [0 0 0];
  
  reportmemoryandtime;

% write out EPI final inspections
if wantfigs && (wantmotioncorrect || wantundistort )
  fprintf('writing out inspections of final EPI results...');

  % inspect first and last of each run
  viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,1)),epis,'UniformOutput',0)),sprintf('%s/EPIfinal/image%%04da',figuredir),[],[],1);
  viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,end)),epis,'UniformOutput',0)),sprintf('%s/EPIfinal/image%%04db',figuredir),[],[],1);

  % inspect movie of first run
  viewmovie(double(epis{1}(:,:,:,1:min(30,end))),sprintf('%s/MOVIEfinal/image%%04d',figuredir),[],[],1);

  fprintf('done.\n');
end

  reportmemoryandtime;

% final EPI calculations  [note: mean of int16 produces double! this is good, except for the NaN issue]
fprintf('performing final EPI calculations...');
meanvolrun = cellfun(@(x) int16(mean(x,4)),epis,'UniformOutput',0);          % mean of each run
meanvol = int16(mean(catcell(4,epis),4));                                    % mean over all runs
validvolrun = validvolrun;                                                   % logical of which voxels have no nans (in each run)
validvol = all(catcell(4,validvolrun),4);                                    % logical of which voxels have no nans (over all runs)
if iscell(targetres)
  finalepisize = targetres{2};
else
  finalepisize = epifov ./ targetres;                                        % size in mm of a voxel in the final EPI version
end
  % some final adjustments to ensure that the mean of values that should be NaN is 0
meanvolrun = cellfun(@(x,y) copymatrix(x,~y,0),meanvolrun,validvolrun,'UniformOutput',0);
meanvol(~validvol) = 0;
fprintf('done.\n');

  reportmemoryandtime;

% zero out data
fprintf('zeroing out data for bad voxels...');
switch maskoutnans
case 0
case 1
  epis = cellfun(@(x) copymatrix(x,repmat(~validvol,[1 1 1 size(x,4)]),0),epis,'UniformOutput',0);
case 2
  epis = cellfun(@(x,y) copymatrix(x,~y,0),epis,validvolrun,'UniformOutput',0);
end
fprintf('done.\n');

  reportmemoryandtime;

% clear out some variables!!!
clear xx yy zz xxB yyB zzB temp;
clear fieldmaps fieldmapbrains fieldmapunwraps;
clear sliceshifts finalfieldmaps;
  
% do fMRI quality
if wantfigs && ~iscell(targetres) && ~isequalwithequalnans(fmriqualityparams,NaN)
  fprintf('calling fmriquality.m on the epis...');
  if ~isempty(inplanes)
    inplaneextra = {sizefull(inplanes{1},2) inplanesizes{1}(1:2)};
  else
    inplaneextra = [];
  end
  fmriquality(epis,episize,[figuredir '/fmriquality'],fmriqualityparams{:},inplaneextra);  % note that NaNs are present and may be in weird places...
  fprintf('done with fmriquality.m.\n');
end

  reportmemoryandtime;

% save record
if ~isempty(figuredir)
  fprintf('saving record.mat...');
  clear inplanes;
  saveexcept([figuredir '/record.mat'],'epis');  % ignore this big variable, but we need it upon function completion
  fprintf('done.\n');
end

  reportmemoryandtime;

% prepare epis in the special flattening case
if iscell(targetres) && targetres{4}==1
  fprintf('preparing epis for special flattening...');
  for p=1:length(epis)
    epis{p} = reshape(epis{p},[prod(sizefull(epis{p},3)) 1 1 size(epis{p},4)]);
    epis{p} = epis{p}(find(validvol),:,:,:);
  end
  fprintf('done.\n');
end

  reportmemoryandtime;

% prepare output
if exist('episissingle','var') && episissingle
  epis = epis{1};
end

  reportmemoryandtime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DBSTOP

dbclear if error;




%% back to preprocess_CNI
% fprintf('done (calling preprocessfmri).\n');

% save it
fprintf('saving data...');
mkdirquiet(stripfile(savefile));
for p=1:length(epis)
  if iscell(targetres) && length(targetres) >= 4 && targetres{4}==1
    fprintf('for EPI run %d, we have %d time points and %d valid voxels.\n',p,size(epis{p},4),size(epis{p},1));
    savebinary(sprintf(savefile,p),'int16',squish(int16(epis{p}),3)');  % special flattened format: time x voxels
  else
    ni = load_untouch_nii(gunziptemp(epifilenames{p}));
    assert(isequal(sizefull(ni.img,3),sizefull(epis{p},3)));
    ni.img = cast(epis{p},class(ni.img));
    ni.hdr.dime.dim(5) = size(ni.img,4);  % since the number of volumes may have changed
    save_untouch_nii(ni,sprintf(savefile,p));
    
    % save special files
    if p==1
      ni.img = cast(validvol,class(ni.img));
      ni.hdr.dime.dim(5) = 1;
      save_untouch_nii(ni,sprintf([stripfile(savefile) '/valid.nii']));

      ni.img = cast(meanvol,class(ni.img));
      ni.hdr.dime.dim(5) = 1;
      save_untouch_nii(ni,sprintf([stripfile(savefile) '/mean.nii']));
    end

    clear ni;
  end
end
fprintf('done (saving data).\n');

reportmemoryandtime;

%% back to preprocess_script_SA2
%   diary off;

