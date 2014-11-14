function preprocS(steps)
%% SPM Preprocessing Script
% Runs SPM's functions without using the GUI

% Requires study folders organized in the following format
% STUDYNAME/STUDYNAMESUBJNO/runX  for functionals, where x = number of run.
% STUDYNAME/STUDYNAMESUBJNO/anat/  for anatomicals

%functional runs start with vol
%anatomical is called anatomical.nii

% Processing performed:
% a) Slice timming correction
% r) Realignment of functionals to first image
% c) Coregistration of T1 to realigned functional mean
% z) Segmentation of corregistered T1
% w) Normalization of functionals onto EPI template using segmentations
% s) Smoothing of functionals
% v) Artrepair

% Q) Clean up (delete intermediate steps)
 
% This script can be adapted to any study with minor changes to the lines
% dealing with directories. The parameters are set favoring quality to
% speed of processing. Any subjects with poor registration into MNI space
% probably have an odd position in the scanner. The problem can be fixed by
% manually realigning the center of the first functional image, using the
% "Display" module in the GUI. The anterior commisure should be made as
% close to zero as possible by pointing the crosshairs over it and entering
% the negative of the mm values in the right, forward and up fields
% respectively.


% work to be done.. now it still needs order as above.. make it possible to
% leave steps out (change the vols = (*)  and the move file command should
% do the trick
% the check reg and remove intermediate should still be done

%% run this batch script on server calling "matlab -nodisplay -nosplash -r preproc_steps"
%% (yes without .m)
addpath ('/usr/local/spm8/toolbox/Artrepair/');


%% determine steps
allsteps = 'arczwsv';

if ~exist( 'steps', 'var' ), 
    steps = allsteps; disp('No steps specified.  Running full sequence.'); 
else
     str = sprintf('Running preproc step(s): %s', steps);disp(str);
end

%% Parameter specification - to be moved to a more general file!!

subjArr = [4008]; % enter the subject numbers of the subjects you are running the script on
studyName = 'DD';
studyDirectory = ('/home/woutervdbos/Data/DD');
exp.noRuns = 2;

%scanner info
exp.nSlices = 44;
exp.TR = 2;

%prerpoc variables
exp.kn = 8; % isometric kernel size for smoothing, mm
exp.sliceorder = [1:2:exp.nSlices 2:2:exp.nSlices]; % Interleaved ascending
exp.refslice = 1;
%%%%%%%%

%% init 
exp.TA = exp.TR - exp.TR/exp.nSlices;
exp.timing(2) = exp.TR - exp.TA;
exp.timing(1) = exp.TA / (exp.nSlices -1);


% Move to study directory
cd(studyDirectory);
thePath.main = pwd;


% Loop through subjects
for subj = 1:length(subjArr)
    
    subjNo = subjArr(subj);
    str = sprintf('subject nr %s%d is being preprocessed.', studyName, subjNo);
    disp(str);
    %move to subject folder
    subjFolder = sprintf('%s%d', studyName, subjNo);
    cd(studyDirectory);
    cd(subjFolder);
    
    
    for s = 1:length(steps)
        
       	if ~strfind( allsteps, steps(s) ) error( ['Invalid step ' steps(s) ' for preproc_steps.'] );end
   
        switch steps(s)   
            case 'a' % Slice-timing correction  
                sliceTiming( studyDirectory, subjFolder, exp );
                
            case 'r' % Realignment 
                realignMent( studyDirectory, subjFolder, exp  ); 
	    
            case 'c' % Coregistration 
                coReg( studyDirectory, subjFolder, exp  );            
                                   
            case 'z' % Segmentation
                segMent( studyDirectory, subjFolder, exp  );

            case 'w' % Normalization
                normaliZe( studyDirectory, subjFolder, exp  );
                
            case 's' % Smoothing
                smOOth( studyDirectory, subjFolder, exp  );
                
            case 'v' % ArtRepair 
               artRepair( studyDirectory, subjFolder, exp  );             
                               
            case 'C'  % Check registration
               checkPreproc( studyDirectory, subjFolder, exp  ); disp( 'Created preproc check files.');

            case 'Q' % Delete intermediate preprocessing files          
               deletePreprocFiles( studyDirectory, subjFolder, exp  ); 
                              
        end  % switch       
            
    end % for each step

end % for each subject

%exit;

    %% Slice Timming
    function sliceTiming( studyDirectory, subjFolder, exp )
    	str = sprintf('1 - slicetiming, refslice is %d', exp.refslice);disp(str);
    	prefix = 'a';
    for run = 1:exp.noRuns % Loop through runs and generate file names for this subject
        	runFolder = ['run_000' num2str(run)];
        	cd(runFolder);  % cd to the appropriate run folder
        	vols = dir('vol*');
        	PP =[];
        	for i = 1:length(vols)
            		PP = [PP; fullfile(studyDirectory, subjFolder, runFolder, vols(i).name)];
        	end
	P{run} = PP;
	cd .. % Move one level up to subject folder        
    end
    	spm_slice_timing(P, exp.sliceorder, exp.refslice, exp.timing, prefix);
    	clear P
    	clear vol    
    	%% move origfiles 
    	disp('1b - moving orig volumes to orig/');
    	for run = 1:exp.noRuns
        	runFolder = ['run_000' num2str(run)];
        	cd(runFolder);  % cd to the appropriate run folder
        	vols = dir('vol*');
        	mkdir orig;
            	for file = 1:length(vols)
            	movefile(vols(file).name, 'orig'); 
                %cd('orig');
                %zip('orig.zip',{'*.nii'});% zip orig files  
                %cd ..
                end
        cd .. % back to subjfolder
    end

    %% Realign to first image and then to mean
    function realignMent( studyDirectory, subjFolder, exp )
    disp('2 - Realign & Reslice');
    % % Set estimate options
    flags = struct('quality', 1, 'fwhm', 5, 'sep', 2, 'interp', 2,'wrap',[0 0 0]);
    P={}; % clear filenames array
    for run = 1:exp.noRuns
        runFolder = ['run_000' num2str(run)];
        cd(runFolder); % cd to the appropriate run folder
        vols = dir('avol*');
        PP =[];
        
        for i = 1:length(vols)
            PP = [PP; fullfile(studyDirectory, subjFolder, runFolder, vols(i).name)];
        end
  
        P{run} = PP;
        cd ..% cd back to subject folder
    end
    
    % Estimate
    spm_realign(P,flags);
    
    clear flags
    clear vols
    
    % Realignment write options
    flags = struct('interp', 4, 'which', 2, 'wrap', [0 0 0]', 'prefix', 'r');
    
    % Perform the realignment
    spm_reslice(P,flags);
    
    clear P
    clear flags
    
    % cd back to subject folder
     cd ..
    
    %% Coregister T1 to meanravol
    function coReg( studyDirectory, subjFolder, exp )
    
    disp('3 - coregistration');
    
    % % Use mean as reference
    refDir = sprintf('%s/%s/run_0001', studyDirectory, subjFolder); %% NOTE depends on right dir structure
    cd(refDir);
    refFolder = pwd;
    ref = dir('mean*');
    refFile = ref.name;
    VG = fullfile(refFolder, refFile);
    if ischar(VG), VG = spm_vol(VG); end;
    
    % % Use anatomy as source
    anatomyDir = sprintf('%s/%s/anat',studyDirectory, subjFolder);
    cd(anatomyDir);
    sourceFolder = pwd;
    source = dir('anat*');
    sourceFile = source.name;
    VF = fullfile(sourceFolder, sourceFile);
    if ischar(VF) || iscellstr(VF), VF = spm_vol(strvcat(VF)); end;
    
    % % estimate coregistration
    flags = struct('sep',[4 2],'cost_fun','nmi','fwhm',[7 7],...
        'tol',[0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001]);
    spm_coreg(VG,VF,flags);
    
    clear flags
    P = char(VG.fname, VF.fname);
    
    % % Perform coregistration
    flags = struct('interp', 1, 'mask', 0,'wrap',[0 0 0]',...
        'prefix','r');
    spm_reslice(P, flags);
    
    clear P VF VG
    cd ..
    %% move step avol* to /steps
 
    disp('--> moving avol* to to steps/');

    for run = 1:exp.noRuns
        runFolder = ['run_000' num2str(run)];
        cd(runFolder);  % cd to the appropriate run folder
        vols = dir('avol*');
        mkdir steps;
            for file = 1:length(vols)
            movefile(vols(file).name, 'steps'); 
            end
	 cd ..
    end
    
    
    %% Segment the corregistered anatomical
    function segMent( studyDirectory, subjFolder, exp )
    disp('4 - segmentation (do not forget to set origin for best results VBM');
    % % Get the T1 corregistered image
    anatomyDir = sprintf('%s/%s/anat',studyDirectory, subjFolder);
    
    cd(anatomyDir);
    segFolder = pwd;
    seg = dir('ranat*');
    segFile = seg.name;
    VF = fullfile(segFolder, segFile);
    if ischar(VF) || iscellstr(VF), VF = spm_vol(strvcat(VF)); end;
    
    % Estimate segmentation
    % Set options
    flags_seg = struct('regtype', 'mni', 'warpreg', 1,...
        'warpco', 25, 'biasreg', 0.0001, 'biasfwhm', 60, 'samp', 3,...
        'ngaus', [2 2 2 4]);
    
    % % Segment
    results = spm_preproc(VF, flags_seg);
    
    % Reformat generated spatial normalization parameters
    [po,pin] = spm_prep2sn(results);
    
    % Save normalization parameters to file
    spm_prep2sn(results);
    
    
    % Write out segmented data
    % Set options
    flags_wrtseg = struct('GM', [0 0 1],'WM', [0 0 1], 'CSF', [0 0 1],...
        'biascor', 1, 'cleanup', 0);
    % Write
    spm_preproc_write(po, flags_wrtseg);
    
    % cd to main subject folder
    cd ..
    
    
    
    %%  Normalize using the normalization parameters from segmentation
    function normaliZe( studyDirectory, subjFolder, exp )
    disp('5 - Normalization');
    % Move to subject folder with high res scan
    anatFolder = sprintf('%s/%s/anat',studyDirectory, subjFolder);    
    % Normalize functional images
    
    % Specify normalization options
    flags = struct('interp',1,'vox', [2, 2, 2],...
        'bb',[-78 -112 -70; 78 76 85],'wrap',[0 0 0],'preserve',0,'prefix','w');
    
    % Load the parameters
    prm = fullfile(anatFolder, 'ranatomical_seg_sn.mat');
    
    % Loop through functional volumes
    for run = 1:exp.noRuns
        runFolder = ['run_000' num2str(run)];
        cd(runFolder); % cd to the appropriate run folder
        vols = dir('ravol*');
        fprintf('writing run %g ... \n', run);
        for i = 1:length(vols)
            Q = fullfile(studyDirectory, subjFolder, runFolder, vols(i).name);
            spm_write_sn(Q,prm,flags);
        end
        cd ..
    end

%% move step ravol* to /steps
 
    disp('--> moving ravol* to to steps/');

    for run = 1:exp.noRuns
        runFolder = ['run_000' num2str(run)];
        cd(runFolder);  % cd to the appropriate run folder
        vols = dir('ravol*');
            for file = 1:length(vols)
            movefile(vols(file).name, 'steps'); 
            end
	cd ..
    end
    
	%%Normalize the anatomicals
    anatFolder = sprintf('%s/%s/anat',studyDirectory, subjFolder); 
    cd (anatFolder);
    t1 = dir('ranatomical.nii');    
    c1 = dir('c1r*');
    c2 = dir('c2r*');
	a = fullfile(anatFolder, t1.name);
	b = fullfile(anatFolder, c1.name);
	c = fullfile(anatFolder, c2.name);
    flags.vox = [2 2 2];
    spm_write_sn(a, prm, flags );
	spm_write_sn(b, prm, flags );
	spm_write_sn(c, prm, flags );
    cd ..
    


    %% Smooth
    function smOOth( studyDirectory, subjFolder, exp )
    disp('6 - Smoothing');
    clear P Q prefixed;
    % load matrix of filenames
    for run = 1:exp.noRuns
        runFolder = ['run_000' num2str(run)];
        cd(runFolder); % cd to the appropriate folder
        vols = dir('wravol*');
        fprintf('smoothing run %g ...\n', run);
        for i = 1:length(vols)
            P = fullfile(studyDirectory, subjFolder, runFolder, vols(i).name);
            prefixed = ['s' vols(i).name];
            Q = fullfile(studyDirectory, subjFolder, runFolder, prefixed);
            
            spm_smooth(P,Q,[exp.kn exp.kn exp.kn]);
            
            clear P Q prefixed
        end
        
        % cd back to subj folder
        cd ..
    end
    
%% move step wravol* to /steps and zip'm all
 
    disp('--> moving wravol* to to steps/');

    for run = 1:exp.noRuns
        runFolder = ['run_000' num2str(run)];
        cd(runFolder);  % cd to the appropriate run folder
        vols = dir('wravol*');
            for file = 1:length(vols)
            movefile(vols(file).name, 'steps'); 
            end
	cd('steps');
	zip('steps.zip',{'*.nii'});
	cd ..
	cd ..
    end

    %% run Artrepair
   function artRepair( studyDirectory, subjFolder, exp )
    disp('--> zipped it up and now repairing.../');
    for run = 1:exp.noRuns
        runFolder = ['run_000' num2str(run)];
        cd(runFolder);  % cd to the appropriate run folder
        vols = dir('swravol*');
        RR =[];
        for i = 1:length(vols)
            RR = [RR; fullfile(studyDirectory, subjFolder, runFolder, vols(i).name)];
        end
        real = dir('rp*');
        
        art_global(RR, real.name, 4, 1)
        
        
        % Move one level up to subject folder
        clear vols
        cd ..
    end
