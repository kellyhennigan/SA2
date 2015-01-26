% makeRegsSA2_script

% script to make regressors for all SA2 subjects
%
% will save out separate base and stress regressors for each stim
% listed below, a separate regressor time series will be modeled for onsets
% occurring during the baseline and stress contexts.


%
%%

clear all
close all

% stims of interest to create regressor time series for
% stims = {'cuepair1',...         % cuepair1 - cue pair for gain trials
%     'cuepair2',...              % cuepair2 - cue pair for loss trials
%     'gain+1',...                % gain+1 - win outcomes
%     'gain0',...                 % gain0 - nothing outcomes for gain trials
%     'loss-1',...                % loss-1 - loss outcomes
%     'loss0',...                 % loss0 - nothing outcomes for loss trials
%     'contextevent',...          % contextevent - neutral or shock cue depending on context
%     'shock'};                   % shock - shock delivery


stims = {'gain_oc',...          % gain_oc - gain outcome period
    'gain_p_oc'};            % gain_p_oc - " " modulated by win or nothing outcome 
   

[subjs,CB] = getSA2Subjects('all'); % subjects and context order code

runs = 1:6; % scan runs to include in full model
nVols = [326 326 326 326 326 326]; % # of volumes in each included scan run
vol1Idx = [1 327 653 979 1305 1631]; % index of the 1st volume in each scan run

contexts = {'base','stress'};

context_run_idx = [
    1 1 1 2 2 2;
    2 2 2 1 1 1];  % index of the context for each scan run (top row for cb=1 subs, bottom row for cb=2 subs)

TR = 1.5; % scan repetition time

irf = 'fir'; % either 'can' for spm's canonical hrf function or 'fir' for using a finite impulse response function


%% do it

% make sure runs and nVols vectors have the same # of elements
if ~isequal(numel(runs),numel(nVols))
    error('runs and nVols vectors must be equal length');
end


for s=1:numel(subjs)
    
    subj = subjs{s};
    expPaths = getSA2Paths(subj);
    
    % save regs files in directory defined by saPaths.regs
    if (~exist(expPaths.regs, 'dir'))
        mkdir(expPaths.regs);
    end
    
    cb = CB(s);  % counterbalance order (base, stress) or vice versa
    subj_context=contexts(context_run_idx(cb,:));
    
    
    % stim loop
    for k=1:numel(stims)
        
        
        % save out regressors for cuepair and shock stims
        if strcmp(stims{k},'shock') || strcmp(stims{k},'cuepair1') || strcmp(stims{k},'cuepair2')
            
            % run loop
            out_reg = zeros(sum(nVols),1);  % regressor time series for all runs
            for r = runs
                reg = glm_fmri_createRegs_SA2(subj, stims{k}, irf, r, nVols(r),TR);
                out_reg(vol1Idx(r):vol1Idx(r)+nVols(r)-1,1:size(reg,2)) = reg;
            end % runs
            
            outFileName = [stims{k} '_' irf '_runALL'];
            dlmwrite([expPaths.regs, outFileName], out_reg); % save out reg time series
            
            
        else  % save out regressors separately for base and stress contexts for all other stims
            
            for c = 1:numel(contexts)
                
                run_idx = find(strcmp(subj_context,contexts{c})); % idx of the runs that were under this context (base or stress)
                
                % run loop
                out_reg = zeros(sum(nVols),1);  % regressor time series for base or stress runs
                for r = run_idx
                    reg = glm_fmri_createRegs_SA2(subj, stims{k}, irf, r, nVols(r),TR);
                    out_reg(vol1Idx(r):vol1Idx(r)+nVols(r)-1,1:size(reg,2)) = reg;
                end % runs
                
                outFileName = [stims{k} '_' contexts{c} '_' irf '_runALL'];
                dlmwrite([expPaths.regs, outFileName], out_reg); % save out reg time series
                
            end
        end
        
        %     figure;  imagesc(out_reg);  colormap(gray);  title(['subject: ' subj outFileName])
        
        fprintf(['\nSaved regressor time series for ',stims{k},'\n']);
        
    end % stims
    
    
end % subjects



