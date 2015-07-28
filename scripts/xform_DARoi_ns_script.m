% make DA ROI masks by transforming the mean DA ROI from the Adcock lab
% template from MNI standard sapce to each subjects' native space.



%%

clear all
close all

% define main data directory
dataDir = '/Users/Kelly/SA2/data';


% define subjects to process
subjects=getSA2Subjects; subjects(1) = [];


% define .mat file with xform info. This also specifies the path to the
% template file.
xf_mat = 'sn/sn_info.mat';


% da roi file to transform from standard to native space:
da = readFileNifti('/Users/Kelly/SA2/data/templates/mean_fullMB.nii.gz');



%% do it

s=1
for s=1:numel(subjects)
    
    subject = subjects{s};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % define subject main directory
    subjDir =fullfile(dataDir,subject); cd(subjDir);
    
    
    %% load xform info
    
    load(xf_mat); % sn invDef templateFile inFile outFile
    
    invDef.outMat   = da.qto_ijk;
    
    
    % t1 and template filepaths should be in the loaded xf_info file
    t1 = readFileNifti(sprintf(inFile,subject));
    
    template=readFileNifti(templateFile);
    
    
    % get bounding box and mmPerVox for native space anat
    mm = t1.pixdim;
    bb = mrAnatXformCoords(t1.qto_xyz,[1 1 1; size(t1.data)]);
    
    
    
    %% xform DA roi from standard to subject's native space
    
    
    [outImg,xform] = mrAnatResliceSpm(da.data, invDef, bb, mm,[1 1 1 0 0 0]);
    
    outImg(isnan(outImg))=0; % set nan values to zero
    
    % now turn it into a binary mask
    mask = outImg;
    mask(mask<=.8)=0;
    mask(mask>.8) = 1;
    
    
    %% save it out
    
    cd([subjDir '/ROIs']);
    
    outNii = createNewNii('DA_Adcock_grad',t1,'avg DA ROI xformed from MNI to native space',outImg);
    outNii2 = createNewNii('DA_Adcock_mask',t1,'avg DA ROI xformed from MNI to native space and binarized',mask);
    
    
    writeFileNifti(outNii)
    writeFileNifti(outNii2)
    
    
    
end
    
    
    
    
    