% script for fitting a glm to subjects' pre-processed fmri data and
% saving the results


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define files etc.

clear all
close all


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
    'ssrarun456_sl1_19.nii.gz',...
    'ssrarun123_sl20_38.nii.gz',...
    'ssrarun456_sl20_38.nii.gz',...
    'ssrarun123_sl39_57.nii.gz',...
    'ssrarun456_sl39_57.nii.gz'};


%
maskFile = 'func_mask.nii.gz';


stims = {'gain+1_base','gain+PE_base','gain0_base','gain-PE_base',...
    'loss-1_base','loss-PE_base','loss0_base','loss+PE_base',...
    'gain+1_stress','gain+PE_stress','gain0_stress','gain-PE_stress',...
    'loss-1_stress','loss-PE_stress','loss0_stress','loss+PE_stress',...
    'contextevent_base','contextevent_stress','shock',...
    'cuepair1','cuepair2'};

outDir = ['/Volumes/Mac OS X Install ESD/SA2/results'];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% subject loop


% for s =1:numel(subjs)

subj = '23';
% subj = subjs{s};

fprintf('\n\nfitting model for subject %s ...\n', subj);


expPaths = getSA2Paths(subj);

cd(expPaths.func_proc)


% get mask
mask=readFileNifti(maskFile);
mask.data=double(mask.data);

% get design matrix
matPath = fullfile(expPaths.design_mats,matFName);
load(matPath);


% get data
cd(expPaths.func_proc)

% func = readFileNifti(funcFiles{1});
% data = func.data;
% for r=2:numel(funcFiles)
%     nextNii = readFileNifti(funcFiles{r});
%     data = cat(4,data,nextNii.data);
%     clear nextNii
% end

func1 = readFileNifti(funcFiles{1});
func2 = readFileNifti(funcFiles{2});
data = cat(4,func1.data,func2.data);

stats1 = glm_fmri_fit_vol(data,X,regIdx,mask.data(:,:,1:19)); % fit model to data



func1 = readFileNifti(funcFiles{3});
func2 = readFileNifti(funcFiles{4});
data = cat(4,func1.data,func2.data);

stats2 = glm_fmri_fit_vol(data,X,regIdx,mask.data(:,:,20:38)); % fit model to data


func1 = readFileNifti(funcFiles{5});
func2 = readFileNifti(funcFiles{6});
data = cat(4,func1.data,func2.data);

stats3 = glm_fmri_fit_vol(data,X,regIdx,mask.data(:,:,39:57)); % fit model to data



% save out model fits 
cd(outDir);

B = 
tB =
Rsq =

out_descrip = ['glm file(s): ' matNames{1:3}];

outName = [subj '_' context '_Rsq'];
outNii = makeGlmNifti(mask,outName,out_descrip,Rsq);
writeFileNifti(outNii);


for c = 1:length(stims)
    
    outName = [subj '_' stims{c} '_' context '_betas'];
    outNii = makeGlmNifti(mask,outName,out_descrip,B(:,:,:,[strmatch(stims{c},regLabels)]));
    writeFileNifti(outNii);
    
    outName = [subj '_' stims{c} '_' context '_T'];
    outNii = makeGlmNifti(mask,outName,out_descrip,B(:,:,:,[strmatch(stims{c},regLabels)]));
    writeFileNifti(outNii);
    
end

clear X stats func

%% runs 4-6

if cb==1
    context = 'stress';
else
    context = 'base';
end

for r=4:6
    
    % get design matrix
    matFile = dir([expPaths.design_mats matNames{r}]);
    if numel(matFile) ~=1
        error(['found ' num2str(numel(matFile)) ' matFiles for run ' num2str(r)])
    end
    matPath = fullfile(expPaths.design_mats,matFile(1).name);
    load(matPath);
    
    
    % get data
    cd(expPaths.func_proc)
    func = readFileNifti(funcFiles{r});
    
    
    % fit model to data
    stats(r-3) = glm_fmri_fit_vol(func.data,X,regIdx,mask.data);
    
end

B = cat(5,stats(1).B,stats(2).B,stats(3).B); B = mean(B,5);
tB = cat(5,stats(1).tB,stats(2).tB,stats(3).tB); tB = mean(tB,5);
Rsq = cat(4,stats(1).Rsq,stats(2).Rsq,stats(3).Rsq); Rsq = mean(Rsq,4);

cd(outDir);

out_descrip = ['glm file(s): ' matNames{4:6}];

outName = [subj '_' context '_Rsq'];
outNii = makeGlmNifti(mask,outName,out_descrip,Rsq);
writeFileNifti(outNii);


for c = 1:length(stims)
    
    outName = [subj '_' stims{c} '_' context '_betas'];
    outNii = makeGlmNifti(mask,outName,out_descrip,B(:,:,:,[strmatch(stims{c},regLabels)]));
    writeFileNifti(outNii);
    
    outName = [subj '_' stims{c} '_' context '_T'];
    outNii = makeGlmNifti(mask,outName,out_descrip,B(:,:,:,[strmatch(stims{c},regLabels)]));
    writeFileNifti(outNii);
    
end


clear expPaths func X

fprintf(['\n\nfinished subject ', subject,'\n']);


% end % subjects
