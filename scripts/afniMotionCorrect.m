function [nii,mparams] = afniMotionCorrect(refFilePath,dataFilePath,outName,outPName,outDir)
% -------------------------------------------------------------------------
% usage: 
% this function calls the afni function 3dVolReg to correct for head
% movement. Does a 6-parameter rigid body transformation using  _?_ cost
% function.
% 
% INPUT:
%   refFilePath - string identifying the filepath to the 3d volume
%               to use as a reference 
%   dataFilePath - string identifying the filepath to data to be
%               aligned to the reference volume. 
%   outName - string to name the motion corrected file. 
%   outPName (optional) - string to name the saved out motion parameters.
%   outDir (optional) - string identifying which directory to save out
%               files to (if not specified, files will be saved out to pwd)
% 
% OUTPUT (both are optional):
%   vols  - motion corrected volumes
%   mparams - parameters for motion correction. Will be a N x 6 matrix,
%       with N= the number of 3d volumes in the corrected dataset and the
%       columns indicating for each volume: 
%                   roll  = rotation about the I-S axis }
%                   pitch = rotation about the R-L axis } degrees CCW
%                   yaw   = rotation about the A-P axis }
%                   dS  = displacement in the Superior direction  }
%                   dL  = displacement in the Left direction      } mm
%                   dP  = displacement in the Posterior direction }


% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 16-Jan-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if out directory is defined, cd to it
origDir = pwd;
if ~notDefined('outDir')
    cd(outDir)
end


% if not given, define a name for the saved out motion parameters file 
if notDefined('outPName')
    outPName = [outName '.1D'];
end

% call afni's 3dvolreg
cmd = sprintf(['export DYLD_LIBRARY_PATH=""; '...  
    '3dvolreg -prefix %s '...
    '-verbose -base %s -zpad 4 '...
    '-1Dfile %s -1Dmatrix_save %s %s'],...
    outName, refFilePath, outPName, ['aff_' outPName], dataFilePath);
       
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
    mparams=dlmread(outPName);
end


% cd to the original dir, in case it was different from outDir
cd(thisDir); 
            
            
%   verbose - means write out everything that's happening 
%   base - reference volume to align all other volumes to
%   zpad - pad the borders of the volume with zeros 
%   1Dfile - filename for saving out motion correction parameters. Saves out: 
%                   roll  = rotation about the I-S axis }
%                   pitch = rotation about the R-L axis } degrees CCW
%                   yaw   = rotation about the A-P axis }
%                   dS  = displacement in the Superior direction  }
%                   dL  = displacement in the Left direction      } mm
%                   dP  = displacement in the Posterior direction }
