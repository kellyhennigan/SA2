
% check out different methods for processing fieldmaps

% note: if multiple fieldmaps are being processed at once, this script
% assumes that they have the same dimensions and scan parameters

clear all
close all

subj = '18';

expPaths=getSA2Paths(subj);


% what directory do the data live in?
inDir = expPaths.raw;

outDir = expPaths.fmap_proc;

figuredir = [expPaths.fmap_proc,'figures'];
if ~exist(figuredir,'dir')
    mkdir(figuredir)
end


fmapMAGFilenames = {'8208_5_1_v1.nii','8208_13_1_v1.nii','8208_17_1_v1.nii','8208_24_1_v1.nii'}; % magnitude data
fmapB0Filenames = {'8208_5_1_B0.nii','8208_13_1_B0.nii','8208_17_1_B0.nii','8208_24_1_B0.nii'}; % wrapped phase data

fieldmapdeltate = [2272]; % what is the difference in TE (in milliseconds) for the two volumes in the fieldmaps?
dformat = 'single';

extratrans = eye(4);
funcRefFilePath = [expPaths.func_proc, 'func_ref_vol.nii'];

funcRefFmapIdx = 1; % which field map scan should be used to undistort the functional reference volume? Leave empty or assign to 0 to not unwarp the reference vol



%% define some basic useful variables

nFMaps = numel(fmapB0Filenames);

% calc fieldmap stuff
fmapsc = 1./(fieldmapdeltate/1000)/2;  % vector of values like 250 (meaning +/- 250 Hz)

fmapdiffrng = [-50 50];  % range for fieldmap difference volumes


te1 = 9.1; % te1 - short echo time (in ms)
te2= 11.372; % te2 - long echo time (in ms)
epifm = 0; % epifm - epi-based fieldmap - yes or no (1/0)
tert = 25.988; % tert - total echo readout time (in ms)
kdir = -1; % kdir - blip direction (1/-1)
mask = 1; % mask ? do brain segmentation to mask field map (1/0)
match = 1; % match ? match vdm file to first EPI in run (1/0).
writeunwarped = 0; % write out unwarped epi or not (keep as 0, then change to 1 according to the funcRefFMapIdx
pm_defs = [te1 te2 epifm tert kdir mask match writeunwarped];


%% do it

cd(inDir);

% load epi reference files
fprintf('\nloading EPI reference volume...');

epi = readFileNifti(funcRefFilePath);
epi.data = double(epi.data);
% epidim = epi.dim;
% episize = epi.pixdim;
    eval(epi.descrip);  % this should define [te, ti, fa, ec, acq, mt, rp, pe]
    %     te - echo time (in ms)
    %     ti - ?
    %     fa - flip angle (in degrees)
    %     ec - echo spacing (read-out time per PE line), in ms
    %     acq - acquisition matrix (freq x phase); if slices were acquired in axial/oblique orientation, this will be epi.dim(1:2), etc.
    %     mt - ?
    %     rp - the ASSET/ARC acceleration factor in the phase-encode dimension
    %     pe - ?
     
    
    % what is the total readout time in milliseconds for an EPI slice?
% (note that 'Private_0043_102c' in the dicominfo of the EPI files gives the time per phase-encode line in microseconds.
% I confirmed that this time is correct by checking against the waveforms displayed by plotter.)
    epireadouttime = ec*acq(2)/rp;  % divide by 2 if you are using 2x acceleration
 
  % this should be [A B] where A and B are the in-plane frequency-encode
% and phase-encode matrix sizes, respectively.  can be [] in which case
% we default to the size of the first two dimensions of the EPI data.
  epiinplanematrixsize = acq;
 
% what is the phase-encode direction for the EPI runs? 
% up-down in the images is 1 or -1 in our convention; left-right in the images is 2 or -2
% in our convention.  you should always check the sanity of the results!
% NOTE: this attempts to learn this information from the NIFTI.
%       if you ever flip the phase-encode direction, you will need to multiply
%       the following by -1.
% ni=load_untouch_nii(funcRefFilePath);
% epiphasedir = bitand(uint8(3),bitshift(uint8(ni.hdr.hk.dim_info),-2));
% clear ni
% epiphasedir = 2;
epiphasedir = -2;
fprintf('done (loading epi reference volume).\n');


% load fieldmap data
fprintf('\nloading fieldmap data...');
fmapsB0 = {}; fmapsMAG = {};
for p=1:nFMaps
    
    nii = readFileNifti(fmapB0Filenames{p}); % phase data
    fmapsB0{p} = double(nii.data) * pi / (fmapsc) ;  % convert to range [-pi,pi]
    
    nii = readFileNifti(fmapMAGFilenames{p}); % magnitude data
    fmapsMAG{p} = double(nii.data(:,:,:,1)); % just use the first volume
    
end
fmapsize = nii.pixdim(1:3);
clear nii;

fprintf('done (loading fieldmap data).\n');



%% unwrap field maps using spm and load

% unwrap fieldmaps
for p=1:nFMaps
    
    % unwarp the functional ref vol using the appropriate fieldmap
    if funcRefFmapIdx==p
        pm_defs(8) = 1;
    else
        pm_defs(8) = 0;
    end
    
    VDM = FieldMap_preprocess_SA2(fullfile(inDir,fmapB0Filenames{p}),fullfile(inDir,fmapMAGFilenames{p}),funcRefFilePath, pm_defs );
    
    % this saves out the following files:
    %   scfmap1_B0.nii - scaled phase fieldmap (in radians)
    %   bmaskfmap1_v1 - brain mask
    %   fpm_scfmap1_B0.nii - unwrapped field map (in Hz)
    %   mfmap1_v1.nii - not sure...
    %   vdm5_scfmap1_B0 - voxel displacement map
    %   ufunc_ref_vol.nii - unwarped epi reference volume
    %   wfmag_func_ref_vol.nii - forward warped magnitude image matched to the
    %       epi reference volume
    
end

% move files into fmap_proc directory
movefile('sc*.nii',outDir);
movefile('bmask*.nii',outDir);
movefile('fpm*.nii',outDir);
movefile('vdm*.nii',outDir);
movefile('m*.nii',outDir);

cd(outDir)

% load in unwrapped fieldmaps in units of Hz & resample to match epi res
for p = 1:nFMaps
    nii = readFileNifti(['fpm_sc' fmapB0Filenames{p}]); % smoothed and unwrapped phase map
    fmapunwraps{p} = double(nii.data); 
    % resample fieldmaps to have same voxel dimensions as epi data
    fmaps_res{p} = processmulti(@imresizedifferentfov,fmapunwraps{p},fmapsize(1:2),epi.dim(1:2),epi.pixdim(1:2));
    
     nii = readFileNifti(['vdm5_sc' fmapB0Filenames{p}]);
     vdms{p} = double(nii.data);
    % resample fieldmaps to have same voxel dimensions as epi data
    vdms_res{p} = processmulti(@imresizedifferentfov,vdms{p},fmapsize(1:2),epi.dim(1:2),epi.pixdim(1:2));
   
end

reportmemoryandtime;


% write out inspections of the unwrapping and additional fieldmap inspections
fprintf('writing out inspections of the unwrapping and additional inspections...');

% write inspections of unwraps
for p=1:nFMaps
    imwrite(uint8(255*makeimagestack(fmapunwraps{p},[-1 1]*fmapsc)),jet(256),sprintf('%s/fieldmapunwrapped%02d.png',figuredir,p));
end

fprintf('done writing out additional inspections.\n');

    
  
    %% I'm here
   
    
% using kendrick's scripts, the pixelshifts seem to be the reverse
% direction. Changing epiphasedir from 2 to -2 makes the undistortions
% occur in the right direction (also more comparable to the spm fieldmap
% toolbox undistortions)
    
    
  p=1; 
  epiphasedir = -2;
  
 % try undistorting funcRefVol (epi) using Kendrick's undistortvolumes
  % script but using spm's processed and unwrapped fieldmap as input
vols=epi.data;
volsize=epi.pixdim;  
mcparams = [];
pixelshifts =  fmaps_res{p}*(epireadouttime/1000)*(epi.dim(abs(epiphasedir))/epiinplanematrixsize(2)); 

outD = undistortvolumes(vols,volsize,pixelshifts,epiphasedir,mcparams);
      
outEpi = epi;
outEpi.data = double(outD);
outEpi.fname='unw_func_ref_vol.nii';
 
 cd(expPaths.func_proc);
 writeFileNifti(outEpi);
 
  
  
  
  
  
    % write out EPI undistort inspections
    fprintf('writing out inspections of what the undistortion is like...');
    
    % undistort a volume
      pixelshifts =  fmaps_res{p}*(epireadouttime/1000)*(epi.dim(abs(epiphasedir))/epiinplanematrixsize(2)); 
      temp = undistortvolumes(epi.data,epi.pixdim,pixelshifts, epiphasedir,[]);
  
    
    % undistort the first and last volume [NOTE: temp is int16]
%     temp = cellfun(@(x,y,z) undistortvolumes(x(:,:,:,[1 end]),epi.pixdim, ...
%         y(:,:,:,[1 end])*(epireadouttime/1000)*(epi.dim(abs(z))/epiinplanematrixsize(2)), ...
%         z,[]),epis,finalfmaps,num2cell(epiphasedir),'UniformOutput',0);
    
    % inspect first and last of each run
    viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,1)),temp,'UniformOutput',0)),sprintf('%s/EPIundistort/image%%04da',figuredir));
    viewmovie(catcell(4,cellfun(@(x) double(x(:,:,:,2)),temp,'UniformOutput',0)),sprintf('%s/EPIundistort/image%%04db',figuredir));
    
    fprintf('done.\n');
    
    
    reportmemoryandtime;
    
    
    
    pixelshifts = fmaps_res{1}*(epireadouttime/1000)*(epi.dim(abs(epiphasedir))/epiinplanematrixsize(2));
  
    
    [outEpis,voloffset,validvolrun]=undistortvolumes(epis{1},epi.pixdim,pixelshifts,epiphasedir,[]
    
     
    
    % if we are doing motion correction, then do something different here
    %   fprintf('time to do motion correction...');
    
    
%          [epis,voloffset,validvolrun] = cellfun(@(x,y,z) undistortvolumes(x,epi.pixdim, ...
%                          y*(epireadouttime/1000)*(epi.dim(abs(z))/epiinplanematrixsize(2)),z,[],extratrans,targetres(1:3)), ...
%                          epis,finalfieldmaps,num2cell(epiphasedir),'UniformOutput',0);
%     
    
    pixelshifts =  finalfmaps{1}*(epireadouttime/1000)*(epi.dim(abs(epiphasedir))/epiinplanematrixsize(2));
    
    [epis,voloffset,validvolrun] = undistortvolumes(epis{1},epi.pixdim,pixelshifts,epiphasedir,[],extratrans,targetres(1:3));
    
    
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
    
  
    
  
    
    
    
    

    
    %% after loading fmap data and before doing the unwrap, do this: 
    
    %% write out fieldmap inspections

% fprintf('\nwriting out various fieldmap inspections...');
% 
% % write out fieldmaps, fieldmaps brains, and histogram of fieldmap
% for p=1:nFMaps
%     
%     % write out fieldmap phase
%     imwrite(uint8(255*makeimagestack(fmapsB0{p}/pi*fmapsc,[-1 1]*fmapsc)),jet(256),sprintf('%s/fieldmap%02d.png',figuredir,p));
%     
%     % write out fieldmap diff
%     if p ~= nFMaps
%         imwrite(uint8(255*makeimagestack(circulardiff(fmapsB0{p+1},fmapsB0{p},2*pi)/pi*fmapsc, ...
%             fmapdiffrng)),jet(256),sprintf('%s/fieldmapdiff%02d.png',figuredir,p));
%     end
%     
%     % write out fieldmap magnitude imagesc
%     imwrite(uint8(255*makeimagestack(fmapsMAG{p},1)),gray(256),sprintf('%s/fieldmapMAG%02d.png',figuredir,p));
%     
%     % write out fieldmap brain cropped to EPI FOV
%     imwrite(uint8(255*makeimagestack(processmulti(@imresizedifferentfov,fmapsMAG{p},fmapsize(1:2), ...
%         epi.dim(1:2),epi.pixdim(1:2)),1)),gray(256),sprintf('%s/fieldmapMAG_EPIcropped%02d.png',figuredir,p));
%     
%     % write out fieldmap histogram
%     figureprep; hold on;
%     vals = prctile(fmapsB0{p}(:)/pi*fmapsc,[25 75]);
%     hist(fmapsB0{p}(:)/pi*fmapsc,100);
%     straightline(vals,'v','r-');
%     xlabel('Fieldmap value (Hz)'); ylabel('Frequency');
%     title(sprintf('Histogram of fieldmap %d; 25th and 75th percentile are %.1f Hz and %.1f Hz',p,vals(1),vals(2)));
%     figurewrite('fieldmaphistogram%02d',p,[],figuredir);
%     
% end
% 
% fprintf('done (writing out fieldmap inspections).\n');
% 
% reportmemoryandtime;
% 
% 
%     
%     
    
%% unwrap field maps using FSL's prelude - can't get this to work!

% 
% fmapunwraps = {};
% 
% 
% % for p=1:nFMaps
% 
% cd(inDir)
% p=1
% 
% prelude_str = '-s -t 0'; % s means do some fast method; t is for mask threshold
% 
% mask_str = ['bet_fm' num2str(p)];
% unix_wrapper(sprintf('bet %s %s -m -f .3', fmapMAGFilenames{1},tmp3))
%  maskFPath = [inDir mask_str '.nii.gz'];
%  
%       % get temporary filenames
%       tmp1 = tempname; tmp2 = tempname; tmp3 = tempname;
% 
%       % make a mask of the magnitude image
%       unix_wrapper(sprintf('bet %s %s -m -f .3', fmapMAGFilenames{1},tmp3))
% 
%       % make a complex fieldmap and save to tmp1
%       save_untouch_nii(make_ana(fmapsMAG{p} .* exp(j*fmapsB0{p}),fmapsize,[],32),tmp1);
%       
%       % use prelude to unwrap, saving to tmp2
%       unix_wrapper(sprintf('prelude -c %s -o %s -m %s %s; gunzip %s.nii.gz',tmp1,tmp2,[tmp3 '_mask'],prelude_str,tmp2));
%       
%       % load in the unwrapped fieldmap
%       temp = load_nii(sprintf('%s.nii',tmp2));  % OLD: temp = readFileNifti(tmp2);
%       
%       % convert from radians centered on 0 to actual Hz
%       fieldmapunwraps{p} = double(temp.img)/pi*fmapsc(p);
    
   
%   reportmemoryandtime;

    
