% makePRegsSA2_script

% script to make parametric regressors for all SA2 subjects

% for each pstim listed below, will save out 4 separate regressors:
%   for positive and negative PEs in baseline and stress contexts
%
%
%  for now at least, parametric regressors will be modeled using spm's
%  canonical hrf
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

pstims = {'gainPE',...          % parametric PE regressors 
    'lossPE'};

separatePosNeg = 0; % 1 to write out separate positive and negative p regs, otherwise 0

out_suffix = '_runALL';
% out_suffix = ['_run' sprintf('%d',runs)];


%% do it

% make sure runs and vol1Idx vectors have the same # of elements
if ~isequal(numel(runs),numel(vol1Idx))
    error('runs and vol1Idxs vectors must be equal length');
end


for s=1:numel(subjs)
    
    subj = subjs{s};
    expPaths = getSA2Paths(subj);
    
    fprintf(['\n\nSaving parametric regressor time series for subject ' subj '...']);
    
    % save regs files in directory defined by saPaths.regs
    if (~exist(expPaths.regs, 'dir'))
        mkdir(expPaths.regs);
    end
    
    cb = CB(s);  % counterbalance order (base, stress) or vice versa
    subj_context=contexts(context_run_idx(cb,runs));
    
    
    % parametric regressor stim loop
    for k=1:numel(pstims)
        
        this_pstim = pstims{k};
        
        for c = 1:numel(contexts)
            
            run_idx = find(strcmp(subj_context,contexts{c})); % idx of the runs to model that were under this context (base or stress)
            
            % run loop
            if separatePosNeg % save out separate positive and negative PE regs? 
                out_preg1 = zeros(nVols.*numel(runs),1);  % positive PEs
                out_preg2 = out_preg1;            % negative PEs
                for r = run_idx
                    [preg1,preg2] = glm_fmri_createParametricRegs_SA2(subj, this_pstim, runs(r), nVols,TR);
                    out_preg1(vol1Idx(r):vol1Idx(r)+nVols-1,1) = preg1;
                    out_preg2(vol1Idx(r):vol1Idx(r)+nVols-1,1) = preg2;
                end % runs
                
                outFName1 = [this_pstim(1:4) '+PE_' contexts{c} '_can' out_suffix]; % out filenames
                outFName2 = [this_pstim(1:4) '-PE_' contexts{c} '_can' out_suffix];
                dlmwrite([expPaths.regs, outFName1], out_preg1); % save out reg time series
                dlmwrite([expPaths.regs, outFName2], out_preg2);
                
            else % save out pos/neg PEs as 1 parametric regressor
                
                % run loop
                
                out_preg = zeros(nVols.*numel(runs),1);  % PEs
                for r = run_idx
                    preg = glm_fmri_createParametricRegs_SA2(subj, this_pstim, runs(r), nVols,TR);
                    out_preg(vol1Idx(r):vol1Idx(r)+nVols-1,1) = preg;
                end % runs
                
                outFName = [this_pstim '_' contexts{c} '_can' out_suffix]; % out filenames
                
                dlmwrite([expPaths.regs, outFName], out_preg); % save out reg time series
                
                
            end
            
            %     figure;
            %     subplot(1,2,1); imagesc(out_preg1);  colormap(gray);  title(['subject: ' subj outFName1  ])
            %     subplot(1,2,2);  imagesc(out_preg2);  colormap(gray); title(['subject: ' subj outFName2 ])
            
        end
        
        fprintf(['\nSaved parametric regressor time series for ',pstims{k},'\n']);
        
        
    end % pstims
    
end % subjects



