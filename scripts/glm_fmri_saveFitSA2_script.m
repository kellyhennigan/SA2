% script for fitting a glm to subjects' pre-processed fmri data and
% saving the results


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define files etc.

clear all
close all

subj = '23';

irf = 'can';
irf_param_str = '';


matFName = ['glm_' irf '_' irf_param_str 'runALL.mat'];

%
% funcFiles = {'ssrarun1.nii.gz',...
%     'ssrarun2.nii.gz',...
%     'ssrarun3.nii.gz',...
%     'ssrarun4.nii.gz',...
%     'ssrarun5.nii.gz',...
%     'ssrarun6.nii.gz'};

funcFiles = {'ssrarun123_sl1_19.nii.gz',...
    'ssrarun123_sl20_38.nii.gz',...
    'ssrarun123_sl39_57.nii.gz'};

funcFiles2 = {'ssrarun456_sl1_19.nii.gz',...
    'ssrarun456_sl20_38.nii.gz',...
    'ssrarun456_sl39_57.nii.gz'};


%
maskFile = 'func_mask.nii.gz';
sl_idx = [1:19;20:38;39:57];

stims = {'gain+1_base','gain+PE_base','gain0_base','gain-PE_base',...
    'loss-1_base','loss-PE_base','loss0_base','loss+PE_base',...
    'gain+1_stress','gain+PE_stress','gain0_stress','gain-PE_stress',...
    'loss-1_stress','loss-PE_stress','loss0_stress','loss+PE_stress',...
    'contextevent_base','contextevent_stress','shock',...
    'cuepair1','cuepair2'};

outDir = ['/Volumes/Mac OS X Install ESD/SA2/data/' subj '/results'];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it



fprintf('\n\nfitting model for subject %s ...\n', subj);


expPaths = getSA2Paths(subj);


% get design matrix
matPath = fullfile(expPaths.design_mats,matFName);
load(matPath);


% get mask
cd(expPaths.func_proc)
mask=readFileNifti(maskFile);
mask.data=single(mask.data);


% get data
for d = 1:numel(funcFiles)
    
    cd(expPaths.func_proc)

    func1 = readFileNifti(funcFiles{d});
    func2 = readFileNifti(funcFiles2{d});
    
    data = cat(4,func1.data,func2.data);
    
    
    % fit model to data
    stats = glm_fmri_fit_vol(data,X,regIdx,mask.data(:,:,sl_idx(d,:))); % fit model to data
    
    
    % save out model fits
    cd(outDir);
    
    % get a template mask for out files 
    out_mask = mask; out_mask.data=out_mask.data(:,:,sl_idx(d,:));
      
    out_descrip = ['glm file(s): ' matFName];
    sl_str = [num2str(sl_idx(d,1)) '-' num2str(sl_idx(d,end))];
  
    
    outName = ['Rsq_' sl_str];
    outNii = makeGlmNifti(out_mask,outName,out_descrip,stats.Rsq);
    writeFileNifti(outNii);
    
    outName = ['F_' sl_str];
    outNii = makeGlmNifti(out_mask,outName,out_descrip,stats.Fstat);
    writeFileNifti(outNii);
    
    outName = ['B_' sl_str];
    outNii = makeGlmNifti(out_mask,outName,out_descrip,stats.B(:,:,:,regIdx~=0));
    writeFileNifti(outNii);
    
    outName = ['tB_' sl_str];
    outNii = makeGlmNifti(out_mask,outName,out_descrip,stats.tB(:,:,:,regIdx~=0));
    writeFileNifti(outNii);
    
    clear func1 func2 data stats outNii outName
    
end

fprintf(['\n\nfinished subject ', subj,'\n']);



