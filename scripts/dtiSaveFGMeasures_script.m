% resample a fiber group into N nodes for a set of subjects and calculate
% diffusion properties for each node (e.g., md, fa, etc.) and save out a
% .mat file with these measures.

clear all
close all



dataDir = '/Users/Kelly/SA2/data';
subjects=getSA2Subjects('dti'); 


% filepaths relative to each subject's directory
dt6file = 'dti80trilin/dt6.mat';


nNodes = 20; % number of nodes for fiber tract

fgMLabels = {'FA','MD','RD','AD'};

% define fiber group to load
% method = 'conTrack';
method = 'mrtrix';


% roi strings; rois will be in subjDir/ROIs directory
seed = 'DA'; % seed roi string

% targets = {'caudateL','caudateR',...
%     'naccL','naccR',...
%     'putamenL','putamenR'}; % target roi strings
% targets = {'naccR','naccL'}; % target roi strings
targets = {'naccR'};


% string to identify fiber group files?
fgNameStr = '_autoclean_afq_params'; % [targets{j} fgNameStr '.pdb'] should be fgName


% string to include on outfile?
outNameStr = ['_n' num2str(nNodes) '_afq_params'];

%     outName = [target outNameStr]; % name of saved out .mat file


%% do it


for j=1:numel(targets)
    
    target = targets{j};    % this target roi
    fgName = [target fgNameStr '.pdb']; % this fg
    
    fprintf(['\n\nworking on ' target ' fiber group...\n\n']);
    
    
    for i = 1:numel(subjects)
        
        
        fprintf(['\n\nworking on subject ',subjects{i},'\n\n']);
        
        subjDir = fullfile(dataDir,subjects{i});
        cd(subjDir);
        
        
        % load dt6 file
        dt = dtiLoadDt6(dt6file);
        %     [fa,md] = dtiComputeFA(dt.dt6);
        
        
        % load ROIs
        roi1 = roiNiftiToMat(['ROIs/' seed '.nii.gz']);
        roi2 = roiNiftiToMat(['ROIs/' target '.nii.gz']);
        
        
        % load fibers
        fg = mtrImportFibers(fullfile('fibers',method,fgName));
        
        
        % reorient to start in DA ROI and clip to DA and target ROIs
        %     (this may be already done but do it again just in case)
        fg = AFQ_ReorientFibers(fg,roi1,roi2);
        
        
        %  get fa and md measures for correlation test
            [fa, md, rd, ad, cl, SuperFibers(i),fgClipped,~,~,fgResampled,subjEigVals]=...
                dtiComputeDiffusionPropertiesAlongFG_with_eigs(fg,dt,roi1,roi2,nNodes,[]);
      
%         [fa, md, rd, ad, cl, fgvol{i}, TractProfiles(i)] = AFQ_ComputeTractProperties(fg, dt,nNodes, 0);
  
        
        fgMeasures{1}(i,:) = fa;
        fgMeasures{2}(i,:) = md;
        fgMeasures{3}(i,:) = rd;
        fgMeasures{4}(i,:) = ad;
        eigVals(i,:,:) = permute(subjEigVals,[3 1 2]);
        
        clear fa md rd ad cl dt t1 roi1 roi2
        
        
    end % subjects
    
    
    
    %% save out fg measures
    
    outName = [target outNameStr]; % name of saved out .mat file
    
    cd(fullfile(dataDir,'fgMeasures'));
    
    save(outName,'subjects','seed','target',...
        'fgName','nNodes','fgMeasures','fgMLabels','SuperFibers','eigVals');
    
%     save(outName,'subjects','seed',...
%         'target','fgNameStr','nNodes','fgMeasures','fgMLabels','fgvol','TractProfiles');
%     
    fprintf(['\nsaved out file ' outName '\n\n']);
    
    
end % targets loop