% script to save out a single volume from a fmri data set
%
% this script will be used for saving out a reference volume for motion
% correction, but of course there could be other uses, too
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subj = '23';

inNiiFName = 'run3.nii.gz';
outNiiFname = 'mc_ref_vol.nii.gz';

vol_idx = 7; % 7 will be the 1st volume after 1st 6 vols are omitted
expPaths=getSA2Paths(subj);

inDir = expPaths.raw;

outDir = expPaths.func_proc;

fprintf('saving out reference volume for motion correction...');

nii = readFileNifti(inDir, inNiiFName);
vol = nii;
vol.data = vol.data(:,:,:,vol_idx);
vol.fname = fullfile(outDir,outNiiFName);
writeFileNifti(vol);

fprintf('done (saving out reference volume).\n');
