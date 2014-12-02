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

[subjs,CB] = getSA2Subjects('all'); % subjects and context order code

contexts = {'base','stress'};

context_run_idx = [
    1 1 1 2 2 2;
    2 2 2 1 1 1];  % index of the context for each scan run (top row for cb=1 subs, bottom row for cb=2 subs)


runs = [1:6]; % scan runs to model (if not using all scan runs for some reason, 
% this should be the only line necessary to edit, eg, runs = [1 2 3 5]

nVols = 326; % # of volumes in each included scan run

vol1Idx = 1:nVols:nVols*numel(runs); % index of the 1st volume in each scan run

TR = 1.5; % scan repetition time

irf = 'can'; % either 'can' for spm's canonical hrf function or 'fir' for using a finite impulse response function

% stims of interest to create regressor time series for
stims = {'cuepair1',...         % cuepair1 - cue pair for gain trials
    'cuepair2',...              % cuepair2 - cue pair for loss trials
    'gain+1',...                % gain+1 - win outcomes
    'gain0',...                 % gain0 - nothing outcomes for gain trials
    'loss-1',...                % loss-1 - loss outcomes
    'loss0',...                 % loss0 - nothing outcomes for loss trials
    'contextevent',...          % contextevent - neutral or shock cue depending on context
    'shock'};                   % shock - shock delivery


% stims = {'gain+1',...                % gain+1 - win outcomes
%     'gain0',...                 % gain0 - nothing outcomes for gain trials
%     'loss-1',...                % loss-1 - loss outcomes
%     'loss0',...                 % loss0 - nothing outcomes for loss trials
%     'contextevent',...          % contextevent - neutral or shock cue depending on context
%     'shock'};                   % shock - shock delivery


out_suffix = '_runALL';
% out_suffix = ['_run' sprintf('%d',runs)];



%% do it

% make sure runs and vol1Idx vectors have the same # of elements
if ~isequal(numel(runs),numel(vol1Idx))
    error('runs and vol1Idx vectors must be equal length');
end


for s=1:numel(subjs)
    
    subj = subjs{s};
    expPaths = getSA2Paths(subj);
    
    fprintf(['\n\nSaving regressor time series for subject ' subj '...']);
    
    % save regs files in directory defined by expPaths.regs
    if (~exist(expPaths.regs, 'dir'))
        mkdir(expPaths.regs);
    end
    
    cb = CB(s);  % counterbalance order (base, stress or stress, base)
    subj_context=contexts(context_run_idx(cb,runs));
    
    
    % stim loop
    for k=1:numel(stims)
        
        this_stim = stims{k};
        
        
        % make reg time series slightly differently depending on the stim
        switch this_stim
            
            case 'shock' % create 1 shock regressor across contexts
                
%                 % run loop
                out_reg = zeros(nVols.*numel(runs),1);
                for r = 1:numel(runs)
                    reg = glm_fmri_createRegs_SA2(subj, this_stim, irf, runs(r), nVols,TR);
                    out_reg(vol1Idx(r):vol1Idx(r)+nVols-1,size(reg,2)) = reg;
                end % runs
                
                outFName = [this_stim '_' irf out_suffix];
                dlmwrite([expPaths.regs, outFName], out_reg); % save out reg time series
                
                
            case {'cuepair1','cuepair2'}  % create separate regressor time series for each cue pair set
                
                if strcmp(irf,'fir')
                    error('making fir regressor time series for cue pairs is ill advised - too much collinearity');
                end
                
                % run loop
                out_reg = zeros(nVols.*numel(runs),numel(runs));
                for r = 1:numel(runs)
                    reg = glm_fmri_createRegs_SA2(subj, this_stim, irf, runs(r), nVols,TR);
                    out_reg(vol1Idx(r):vol1Idx(r)+nVols-1,r) = reg;
                end % runs
                
                outFName = [this_stim '_' irf out_suffix];
                dlmwrite([expPaths.regs, outFName], out_reg); % save out reg time series
                
                
            otherwise   % create a separate regressor for base and stress contexts
                
                
                for c = 1:numel(contexts)
                    
                    run_idx = find(strcmp(subj_context,contexts{c})); % idx of the runs to model that were under this context (base or stress)
                    
                    % run loop
                    out_reg = zeros(nVols.*numel(runs),1);  % regressor time series for base or stress runs
                    for r = run_idx
                        reg = glm_fmri_createRegs_SA2(subj, this_stim, irf, runs(r), nVols,TR);
                        out_reg(vol1Idx(r):vol1Idx(r)+nVols-1,1:size(reg,2)) = reg;
                    end % runs
             
                    outFName = [this_stim '_' contexts{c} '_' irf out_suffix];
                    dlmwrite([expPaths.regs, outFName], out_reg); % save out reg time series
                    
                end % contexts
                
                
        end % case this_stim
        %     figure;  imagesc(out_reg);  colormap(gray);  title(['subject: ' subj outFName])
    
    end % stims
    
    fprintf('done.\n');
    
end % subjects



