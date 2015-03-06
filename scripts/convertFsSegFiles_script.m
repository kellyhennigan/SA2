% convertFsSegFiles_script
% -------------------------------------------------------------------------
% usage: this script is designed for converting .mgz files made during 
% freesurfer's recon into nifti files
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

!source $FREESURFER_HOME/SetUpFreeSurfer.sh 

fshome = getenv('FREESURFER_HOME');
% setenv('FREESURFER_HOME',fshome);  % this to tell where FS folder is

subject = 'sa01'; 

% inDir = [fshome '/subjects/' subject '/mri']; % freesurfer subject mri dir
inDir = '/Users/Kelly/dti/sa01/t1/fs'; % dir for out nifti files
outDir = '/Users/Kelly/dti/sa01/t1'; % dir for out nifti files


%% do it 

cd(inDir);

% Convert fs t1 to nifti 
cmd = [fshome '/bin/mri_convert --out_orientation RAS -i T1.mgz -o ' outDir '/t1_fs.nii.gz'];
unix_wrapper(cmd);


% Convert ribbon.mgz to a nifti class file
infile = [inDir '/ribbon.mgz'];
outfile     = [outDir '/t1_class.nii.gz'];
resample_type = 'weighted';
fillWithCSF = true;
cmd = [fshome '/bin/mri_convert --out_orientation RAS -rt ' resample_type ' -i ',...
    infile ' -o ' outfile];
unix_wrapper(cmd);


% Convert aparc+aseg.mgz file
infile = [inDir '/aparc+aseg.mgz'];
outfile2     = [outDir '/aparc+aseg.nii.gz'];
resample_type = 'weighted';
cmd = [fshome '/bin/mri_convert --out_orientation RAS -rt ' resample_type ' -i ',...
    infile ' -o ' outfile2];
unix_wrapper(cmd);





%% Convert freesurfer label values to itkGray label values
% We want to convert
%   Left white:   2 => 3
%   Left gray:    3 => 5
%   Right white: 41 => 4
%   Right gray:  42 => 6
%   unlabeled:    0 => 0 (if fillWithCSF == 0) or 1 (if fillWithCSF == 1)          

% read in the nifti
ni = niftiRead(outfile);

% check that we have the expected values in the ribbon file
vals = sort(unique(ni.data(:)));
if ~isequal(vals, [0 2 3 41 42]')
    warning('The values in the ribbon file - %s - do no match the expected values [2 3 41 42]. Proceeding anyway...') %#ok<WNTAG>
end

% map the replacement values
invals  = [3 2 41 42];
outvals = [5 3  4  6];
labels  = {'L Gray', 'L White', 'R White', 'R Gray'};

fprintf('\n\n****************\nConverting voxels....\n\n');
for ii = 1:4;
    inds = ni.data == invals(ii);
    ni.data(inds) = outvals(ii);
    fprintf('Number of %s voxels \t= %d\n', labels{ii}, sum(inds(:)));
end

if fillWithCSF, 
    ni.data(ni.data == 0) = 1;
end

% write out the nifti
writeFileNifti(ni)

% done.
 
