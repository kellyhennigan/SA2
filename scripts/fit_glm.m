% make a design matrix, fit the model to data and save out the results

% handy if the same model/fit are being used a lot to avoid having to
% re-estimate the model every time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% define files etc.

runNum = 2;

matName = ['run',num2str(runNum),'_design_mat.mat'];

%fStrs = {'mux3_run1_sl1-26','mux3_run1_sl27-52','mux3_run1_sl53-78'};
fStr = 'mux1_run2';

stim = {'cue_control','cue_gain_0','cue_gain_lo','cue_gain_hi',...
    'cue_loss_0','cue_loss_lo','cue_loss_hi','target','outcome'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd('/Users/Kelly/SA2/data/pilot100513')

% get design matrix
load(matName);

%for i = 1:3
    
 %   fStr = fStrs{i};
    
    funcFile = ['pp_',fStr,'.nii.gz'];
% funcFile = [fStr,'.nii.gz'];
   % maskFile = ['mask_',fStr,'.nii.gz'];
    maskFile = 'mask_mux1.nii.gz';

    % get data
%     cd(fStr)
% cd('mux3_run1')
 
   func = readFileNifti(funcFile);
    mask=readFileNifti(maskFile);
    
    
    % fit model to data
    stats = glm_fmri_fit_vol(func.data,X,regIdx,mask.data);
    
  
%end

cd results/

for c = 1:length(stim)
     outName = ['mux3_',stim{c},'_beta'];
     outNii = makeGlmNifti(mask,outName,stats.B(:,:,:,[strmatch(stim{c},regLabels)]));
     writeFileNifti(outNii);
 end
outNii = makeGlmNifti(mask,'mux3_Rsq',stats.Rsq);
writeFileNifti(outNii);
