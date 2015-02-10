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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% internal constants

nRuns = numel(inFiles); % # of runs to process
tsnrmx = 12;          % max temporal SNR percentage (used in determining the color range)
numinchunk = 30;      % max images in chunk for movie
% etc.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  doDIARY 
    
    
    if doDiary 
        
        fprintf(['\n\nstarting diary file ' diaryfile '...']);
        mkdirquiet(stripfile(diaryfile));
        diary(diaryfile);
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% process data

for r = 1:numel(inFiles); % which nii file to load

    fprintf(['\n\n\nPROCESSING RUN ' num2str(r) ' FOR SUBJECT ' subj '\n\n']);
        
    fprintf('load EPI data...');
    
    nii = readFileNifti(fullfile(inDir,inFiles{r}));
    
    % get some info from the first nii file
    if r==1
        printNiiInfo(nii,'epi')
    end
    
    % filename to reflect pre-processing performed
    thisStr = outStrs{r};  % base string for outname (e.g., 'run1')
    nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
    
    
    fprintf('done (loading EPI data).\n');
    reportmemoryandtime;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% OMIT 1st VOLS
    
    
    if doOmit1stVols
        
        out_prefix = 'o'; % add this to outfile to indicate this step performed
        
        fprintf(['omitting 1st ' num2str(omitNVols) ' vols...']);
       
        % do it
        nii.data(:,:,:,1:omitNVols) = [];
        
        % update filename to reflect pre-processing performed
        thisStr = [out_prefix thisStr];
        nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
        if saveIntSteps % save out intermediate processing steps?
            writeFileNifti(nii); 
        end
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  QA FIGS
    
    
    if doQAFigs
        
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
        
       out_prefix = 'a'; % add this to outfile to indicate this step performed
        
        fprintf('correcting for differences in slice acquisition times...');
        
        % do it
        nii.data = correctSliceTiming(nii.data,sliceOrder,mux);
        
         % update filename to reflect pre-processing performed
        thisStr = [out_prefix thisStr];
        nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
        if saveIntSteps % save out intermediate processing steps?
            writeFileNifti(nii); 
        end
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FIELDMAP CORRECTION


if doCorrectFieldMap
    
    out_prefix = 'u'; % add this to outfile to indicate this step performed
        
        fprintf('correcting fieldmap distortions...');
        
        % do it
       nii.data = correctFieldMap();
       
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
        
         % update filename to reflect pre-processing performed
        thisStr = [out_prefix thisStr];
        nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
        if saveIntSteps % save out intermediate processing steps?
            writeFileNifti(nii); 
        end
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    
end

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MOTION CORRECTION
    
    
    if doCorrectMotion
        
         out_prefix = 'r'; % add this to outfile to indicate this step performed
     
        fprintf('correcting for motion...');
        
        switch lower(mcMethod)
            
            case 'afni'
                
                % make sure the input data has been written out as a file
                if ~exist(nii.fname,'file')
                    writeFileNifti(nii)
                end
                
                thisStr = [out_prefix thisStr];   % define file string that describes the stage of preprocessing
                [nii,mparams]=afniMotionCorrect(refFilePath,nii.fname,thisStr,['vr_run' num2str(r) '.1D'],outDir);
                
            case 'spm'
                
               
                % do it
                % write function here
                
                
                % update filename to reflect pre-processing performed
                thisStr = [out_prefix thisStr];
                nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
                if saveIntSteps % save out intermediate processing steps?
                    writeFileNifti(nii);
                end
                
                
        end
        
        
        fprintf('done.\n');
        reportmemoryandtime;
        
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UNDISTORT & MOTION CORRECT IN ONE INTERPOLATION STEP
    
    
    if doFieldMap && doCorrectMotion
        
        fprintf('undistorting and motion correcting in one interpolation step...');
                
                % do it
                % write function here
                
                
                % update filename to reflect pre-processing performed
%                 thisStr = [out_prefix thisStr];
%                 nii.fname = fullfile(outDir,[thisStr '.nii.gz']);
                if saveIntSteps % save out intermediate processing steps?
                    writeFileNifti(nii);
                end
                
                 fprintf('done.\n');
        reportmemoryandtime;
                
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

   
   
   
%%
   if doDiary
       diary off
   end
   




