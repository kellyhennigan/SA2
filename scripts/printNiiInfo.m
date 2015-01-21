function printNiiInfo(nii,dataTypeStr)
% -------------------------------------------------------------------------
% usage: this function will print out some info about an input nifti file
% in the command window. The main purpose of this function is to store what
% all these fields mean and how to get info about nii files. The hope is
% that I'll keep adding to this function as necessary.
%
% INPUT:
%   nii - nii file acquired from CNI. CNI puts some extra info in the
%       headers of niftis that this function looks for, so it will have limited
%       use for other nifti files and will most likely require editing to run.
%   dataTypeStr - string identifying the type of data in nifti file. As of
%       now, this only takes 'epi'
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 19-Jan-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ischar(nii)
    nii = readFileNifti(nii);
end

fprintf(['\nhere''s some info about nifti file ' nii.fname ': \n'])

switch lower(dataTypeStr)
    
    case 'epi'
        
        % volume dimensions
        fprintf(['dimensions (# of voxels):  ' num2str(sizefull(nii.data,3)) '\n']);
        
        % # of volumes
        fprintf(['# of volumes:  ' num2str(size(nii.data,4)) '\n']);
        
        % voxel dimensions in mm
        fprintf(['voxel dimensions (mm):  ' num2str(nii.pixdim(1:3)) '\n']);
        
        % TR
        fprintf(['TR:  ' num2str(nii.pixdim(4)) '\n']);
        
        eval(nii.descrip); % at cni this gives [te, ti, fa, ec, acq, mt, rp]
        
        % acquisition matrix size (freq x phase)
        fprintf(['in plane matrix size:  ' num2str(acq) '\n']);
        
        % in-plane FOV in mm
        fprintf(['field-of-view (FOV) (in mm):  ' num2str(acq.*nii.pixdim(1:2)) '\n']);
        
        % # of slices
        fprintf(['number of slices:  ' num2str(size(nii.data,3)) '\n']);
        
        %   ec is the echo spacing (read-out time per PE line) in milliseconds
        fprintf(['echo spacing:  ' num2str(ec) '\n']);
        
        % echo time(?) not sure about this
        fprintf(['echo time:  ' num2str(te) '\n']);
        
        % flip-angle
        fprintf(['flip angle:  ' num2str(fa) '\n']);
        
        % rp is the ASSET/ARC acceleration factor in the phase-encode dimension
        fprintf(['acceleration factor:  ' num2str(rp) '\n']);
        
        % mt (not sure what this is)
        fprintf(['mt:  ' num2str(mt) '\n']);
        
        % from Kendrick's preprocess_CNI script: phase-encoding direction -
        % up-down in the images is 1 or -1 in our convention; left-right in the
        % images is 2 or -2 in our convention.  you should always check the sanity
        % of the results! NOTE: if you ever flip the phase-encode direction, you will need to
        % multiply the following by -1.
        %   epiphasedir = bitand(uint8(3),bitshift(uint8(ni.hdr.hk.dim_info),-2));
        fprintf(['epi phase encoding direction:  ' num2str(bitand(uint8(3),bitshift(uint8(size(nii.data,3)),-2))) '\n']);
        
         % total epi read-out time (necessary for fieldmap correction)
        fprintf(['total epi readout time:  ' num2str(ec*acq(2)/rp) '\n']);
       
       
    case 'dti'
        
        % add stuff here for dwi files 
        
    case 't1'
        
        % add stuff here for t1-weighted files
    
end
