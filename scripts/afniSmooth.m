function nii = afniSmooth(dataFilePath,smooth_kernel_mm,outName,outDir)
% -------------------------------------------------------------------------
% usage: 
% this function calls the afni function 3dmerge to smooth data
% 
% INPUT:
%   dataFilePath - string identifying the filepath to data to be
%               aligned to the reference volume. 
%   smooth_kernel_mm - full-width half-max gaussian smoothing kernel in mm
%   outName - string to name the out file
%   outDir (optional) - string identifying which directory to save out
%               files to (if not specified, files will be saved out to pwd)
% 
% OUTPUT (both are optional):
%   nii  - smoothed data


% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 16-Jan-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% if out directory is defined, cd to it
origDir = pwd;
if ~notDefined('outDir')
    cd(outDir)
end


% call afni's 3dmerge 
cmd = sprintf(['export DYLD_LIBRARY_PATH=""; '...  
    '3dmerge -1blur_fwhm %d -doall -prefix %s %s'],...
    smooth_kernel_mm,outName,dataFilePath);
       
unix_wrapper(cmd);  % system(cmd)
      

% convert data file to nifti format
cmd = sprintf('export DYLD_LIBRARY_PATH=""; 3dAFNItoNIFTI %s+orig; gzip %s.nii',...
    outName, outName);
unix_wrapper(cmd);  % system(cmd)


% delete the data files in afni format
delete([outName '+orig.HEAD']);
delete([outName '+orig.BRIK']);


% if out variable(s) are requested, load corrected data and motion params
if nargout>0
    nii=readFileNifti([outName '.nii.gz']);
    nii.fname = fullfile(pwd,nii.fname); % include filepath in nii.fname
end


% cd to the original dir, in case it was different from outDir
cd(thisDir); 
            
