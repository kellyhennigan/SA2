% doPreProcess
% --------------------------------
% usage: say a little about the function's purpose and use here
%

% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 09-Jan-2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %  what preprocessing steps should be done?
% % 1 to do, 0 to not do
%
% here are the pre-processing step options:
% 1) drop the first few volumes of each run (doOmit1stVols) add prefix 'o'
% 2) slice time correction (doCorrectSliceTiming)           add prefix 'a'
% 3) motion correction (doCorrectMotion)                    add prefix 'r'
% 4) fieldmap correction (doCorrectFieldMap)                add prefix 'u'
% 5) smooth data (doSmooth)                                 add prefix 's'
% 6) make a binary brain mask (doMask)                      called func_mask
% 7) convert from raw to % change units (doConvertUnits)    add prefix 'p'
% 8) concatanate runs (doConcatRuns)                        called __
% 9) add coreg/normalization option



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% internal constants

nRuns = numel(inFiles); % # of runs to process
tsnrmx = 12;          % max temporal SNR percentage (used in determining the color range)
numinchunk = 30;      % max images in chunk for movie
% etc.


%% process data

% for r = 1:numel(inFiles); % which nii file to load
    for r=1
        
    fprintf('load EPI data...');
    
    nii = readFileNifti(fullfile(inDir,inFiles{r}));
    
    % get some info from the first nii file
    if r==1
        printNiiInfo(nii,'epi')
    end
    
    % filename to reflect pre-processing performed
    thisStr = outStrs{r};
    nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
    
    
    fprintf('done (loading EPI data).\n');
    reportmemoryandtime;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% OMIT 1st VOLS
    
    
    if doOmit1stVols
        
        fprintf(['omitting 1st ' num2str(omitNVols) ' vols...']);
        nii.data(:,:,:,1:omitNVols) = [];
        
        % update filename to reflect pre-processing performed
        thisStr = ['o' thisStr];
        nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
        %     writeFileNifti(nii); % save out this stage of processing
        
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  QC FIGS
    
    
    if doQCFigs
        
        fprintf('computing & writing out temporal SNR estimates...');
        
        % compute temporal SNR
        % values are percentages representing the median frame-to-frame difference
        % in units of percent signal.  (if the mean intensity is negative, the percent signal doesn't make sense, so
        % we set the final result to NaN.)  [if not enough volumes, some warnings will be reported.]
        temporalsnr = computetemporalsnr(nii.data);
        
        imwrite(uint8(255*makeimagestack(tsnrmx-temporalsnr,[0 tsnrmx])),jet(256),sprintf('%s/temporalsnr%02d.png',figuredir,r));
        
        fprintf('done.\n');
        reportmemoryandtime;
        
        
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% SLICE TIMING CORRECTION
    
    
    if doCorrectSliceTiming
        
        fprintf('correcting for differences in slice acquisition times...');
        
        nii.data = correctSliceTiming(nii.data,sliceOrder,mux);
        
        % update filename to reflect pre-processing performed
        thisStr = ['a' thisStr];
        nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
        writeFileNifti(nii); % save out this stage of processing
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MOTION CORRECTION
    
    
    if doCorrectMotion
        
        fprintf('correcting for motion...');
        
        switch lower(mcMethod)
            
            case 'afni'
                
                % make sure the input data has been written out as a file
                if ~exist(nii.fname,'file')
                    writeFileNifti(nii)
                end
                
                thisStr = ['r' thisStr];   % define file string that describes the stage of preprocessing
                [nii,mparams]=afniMotionCorrect(refFilePath,nii.fname,thisStr,['vr_run' num2str(r) '.1D'],outDir);
                
        end
        
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIELDMAP CORRECTION


if doCorrectFieldMap
    
    %
    % %     % load fieldmap data
    % fprintf('loading fieldmap data...');
    %
    % fmaps = {}; fmapsizes = {}; fmapbrains = {};
    % fmB0 = readFileNifti(fullfile(inDir,fmapB0files{m}));
    % fmaps{m} = double(fmB0.data) * pi / (1/(fmapdeltate/1000)/2);  % convert to range [-pi,pi]
    % fmapsizes{m} = fmB0.pixdim(1:3);
    % fmMAG = readFileNifti(fullfile(inDir,fmapMAGfiles{m}));
    % fmapbrains{m} = double(fmMAG.data(:,:,:,1)); % just use first volume
    % %         clear fmB0 fmMAG
    % %
    % %     end
    % %
    % fprintf('done (loading fieldmap data).\n');
    % reportmemoryandtime;
    % %
    % correctDistortion(fieldmaps,fieldmapbrains,fieldmapsizes,fieldmapdeltate,...
    %     fieldmaptimes,fieldmapunwrap,fieldmapsmoothing,figuredir)
    
    
    % make VDM for fieldmap correction, do fieldmap correction
    
    % pm_defs = [9.1, 11.372, 0, 19.1, -1, 1, 1]];
    %
    % VDM=FieldMap_preprocess(inDir,epi_dir,[9.1,11.372,0,pm_defs,sessname)
    
end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SMOOTH
    
    if doSmooth
        
        fprintf('smoothing data...');
        
        switch lower(smMethod)
            
            case 'afni'
                
                % make sure the input data has been written out as a file
                if ~exist(nii.fname,'file')
                    writeFileNifti(nii)
                end
                
                thisStr = ['s' thisStr];  % define file string that describes the stage of preprocessing
                nii = afniSmooth(nii.fname,smooth_kernel_mm,thisStr,outDir);
                
        end
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BINARY MASK

if doMask && r==1
    
    
% ## for now just do:
% 3dAutomask -prefix func_mask srarun3+orig
% 3dAFNItoNIFTI func_mask+orig
% gzip func_mask.nii

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONVERT TO % BOLD CHANGE UNITS
    
    if doConvertUnits
        
        fprintf('converting to percent signal change units...');
        
        nii.data=bsxfun(@rdivide,nii.data,mean(nii.data,4));
        
        % update filename to reflect pre-processing performed
        thisStr = ['p' thisStr];
        nii.fname = fullfile(outDir,thisStr);
        writeFileNifti(nii)
        
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
    
end % RUN LOOP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONCATENATE RUNS

   if doConcatRuns
        
        fprintf('concatenating runs...');
 
% in afni:
% 3dTcat -prefix all corr_1_cv.nii.gz corr_2_cv.nii.gz corr_3_cv.nii.gz
   end




%% coregister functional and anatomical

% # align T1 to mc_func_vol
% align_epi_anat.py -anat ../raw/t1.nii.gz -epi mc_func_vol.nii -epi_base 0 -anat2epi -tshift off -partial_coverage -AddEdge
%
% mv t1.nii.gz_al_mat.aff12.1D t12func_xform
% mv t1.nii.gz_al_e2a_only_mat.aff12.1D func2t1_xform
% mv t1.nii.gz_al.nii.gz c_t1.nii.gz


%% 6) normalize anatomical to tlrc

% # normalize coregistered-t1 to tlrc
% @auto_tlrc -base /Users/Kelly/SA2/template_brains/TT_icbm452+tlrc. -input c_t1.nii.gz -no_ss
%
% produces:
% c_t1_at.nii file  # t1 in tlrc space
% c_t1_at.nii_WarpDrive.log  # log file
% c_t1_at.nii.Xaff12.1D      # xform
% c_t1_at.Xat.1D		   # another xform
%
% %
% # transform mc_func_vol into tlrc space and check out alignment
% @auto_tlrc -apar c_t1_at.nii -input mc_func_vol.nii -dxyz 1.6
%
%
% # if alignment looks good, normalize all func data
% @auto_tlrc -apar c_t1_at.nii -input srarun1+orig -dxyz 1.6

% ______





%% make a group mask
%
% 3dMean -datum float -prefix mean_mask *mask+tlrc.HEAD
% 3dcalc -datum byte -prefix group_mask -a mean_mask+tlrc -expr 'step(a-0.75)'





