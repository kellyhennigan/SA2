%% compare the SNR of some ROIs between sequences 

clear all
close all

cd '/Users/kelly/SA2/data/old/pilot/'

% nifti files to compare
niiFiles = {'mux1_MID2.nii.gz','mux3_MID1.nii.gz','mux3_rest_state.nii.gz'};

% corresponding ROI directory names for each scan
roiDirs = {'mux1_ROIs','mux3_ROIs','mux3_rest_state_ROIs'};

% right and left ventral striatum and VTA sphere rois
roiFiles = {'vsL_rad4.mat','vsR_rad4.mat','vtaL_rad2.mat','vtaR_rad2.mat'};



for i = 1:3
    
    nii = readFileNifti(niiFiles{i});
    
    cd(roiDirs{i})
    
    for j = 1:4
        
        load(roiFiles{j});
        
        imgCoords = round(mrAnatXformCoords(nii.qto_ijk,roi.coords));
        
        idx=unique(sub2ind(size(nii.data),imgCoords(:,1),imgCoords(:,2),imgCoords(:,3)));
        
        d = reshape(nii.data,prod(nii.dim(1:3)),[]);
        d = d(idx,3:end);
        
        d4 = reshape(d,size(d,1),1,1,[]);
        
        snr(i,j) = mean(computetemporalsnr(d4));
     
        clear imgCoords idx d d4
        
    end % rois
    
    clear nii
    
    cd ../
    
end % scans


% remember, the higher the snr metric, the worse the snr :(



