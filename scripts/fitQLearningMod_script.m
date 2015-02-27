% fitQLearningMod_script

% this script calls the function fitQLearningMod to find the parameter
% values that minimize the negative log likelihood of subjects' choices and
% plots them.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up

clear all
close all

rand_seed=rng('shuffle'); % initialize random seed generator


% get subject subset
[subjects,cb] = getSA2Subjects('RL');


% which condition? must be either 1/'gain' or 2/'loss'
cond = 'gain';

% which context? must be either 1/'base' or 2/'stress' or '' for both
contexts = {'base','stress'};

% fix the inverse temp B to the best fit across contexts? 1 for yes, 0 for
% no. if fitEachSub is set to 1, B is fixed to the best fit per sub,
% otherwise its the best for the whole group
fix_best_B = 1;

% get parameters and options for fminsearch
[p0, p_min, p_max] = getInitRLParams();
options = optimset('MaxFunEvals',1000,'MaxIter',1000);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% fit learning model for all subs together 



%%% call to fit model without using cell fun:
%  [p,nll] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
%  [p,nll] = fminsearch(@(p) fitQLearningMod(p, choices, outcomes), p0, options); % unbound method


% if fix_best_B, estimate the best B for both contexts
if fix_best_B
    [choices,outcomes]=getSubjChoicesOutcomes(subjects,cond);
    p_best = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
    p_min(2) = p_best(2); p_max(2) = p_best(2);
end
    
for c=1:numel(contexts)
    
    context = contexts{c};

    % fit model for all subjects
    [choices,outcomes]=getSubjChoicesOutcomes(subjects,cond,context);
    [p_all,nll_all] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
    a_all(c) = p_all(1); B_all(c) = p_all(2);
   
end % contexts 


%% fit for each subject individually 

    
% now fit model for each individual subject
for i=1:numel(subjects)
    
    [p0, p_min, p_max] = getInitRLParams(); % reinitialize rl params
    
    if fix_best_B
        [choices,outcomes]=getSubjChoicesOutcomes(subjects{i},cond);
        p_best = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
        p_min(2) = p_best(2); p_max(2) = p_best(2);
    end
    
    for c=1:numel(contexts)
        
        context = contexts{c};
        
        [choices,outcomes]=getSubjChoicesOutcomes(subjects{i},cond,context);
        [p,nll] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
        a(i,c) = p(1);  B(i,c) = p(2);
    end
    
end

%% plots

fh = setupFig

cols = getSA2Colors(cond);
for c=1:numel(contexts)
    context = contexts{c};
    h = histogram(a(:,c),numel(subjects))
    set(h,'FaceColor',cols(c,:),'EdgeColor','w')
end
tStr = ['subject learning rates for ' cond ' trials'];
if fix_best_B
    tStr = [tStr ' w/fixed B across contexts']
end
title(tStr)
legend(contexts); legend('location','best'); legend('boxoff')

pa=getSA2Paths();
cd(pa.figures); cd behavior;
saveas(gcf,['RL_subj_' cond '.pdf'],'pdf')

    
 
    
    
    
    
    
    
    
    
    
    %
    % % for each subject individually:
    % if fitEachSub
    %
    %     if fix_best_B  % if fit best B, first get the best fitting B across contexts
    %         for i=1:numel(subjects)
    %             [choices{i},outcomes{i}]=getSubjChoicesOutcomes(subjects{i},cond);
    %         end
    %
    %         p_min = [
    %
    %
    % [choices,outcomes]=cellfun(@(x) getSubjChoicesOutcomes(x,cond), subjects,'UniformOutput',0);
    %
    % p = catcell(1,cellfun(@(x,y) fminsearchbnd(@(p) fitQLearningMod(p, x, y), p0, p_min, p_max, options), choices, outcomes, 'UniformOutput',0)');
    % B=mat2cell(p(:,2),[ones(1,size(p,1))])';
    % p = catcell(1,cellfun(@(x,y,z) fminsearchbnd(@(a) fitQLearningMod2(a, z, x, y), p0, p_min, p_max, options), choices, outcomes, B,'UniformOutput',0)');
    % p_min = [
    %
    %
    % if ~fitEachSub  % fit across subjects
    %
    %     % if fix_best_B, get the estimate for the best fitting B across conds
    %     if fix_best_B
    %          [choices,outcomes]=getSubjChoicesOutcomes(subjects,cond);
    %         catcell(1,cellfun(@(x,y) sum(squish(x.*abs(y),2),1) ./ sum(squish(abs(y),2),1),fieldmapunwraps,fieldmapbrains,'UniformOutput',0));
    %          cellfun(@(x,y) fminsearchbnd(@(p) fitQLearningMod(p, x, y), p0, p_min, p_max, options), choices, outcomes, 'UniformOutput',0)
    %
    %          [p,nll] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
    %          p0(2)=p(2); p_min(2)=p(2); p_max(2)=p(2);
    %     end
    %
    %      % fit for all given subjects:
    %     [choices,outcomes]=getSubjChoicesOutcomes(subjects,cond,context);
    %     [p,nll] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
    %     %  [p,nll] = fminsearch(@(p) fitQLearningMod(p, choices, outcomes), p0, options); % unbound method
    %
    %
    % else   % fit for subjects individually:
    %
    %     for i = 1:numel(subjects)
    %
    %         % if fix_best_B, get the estimate for the best fitting B across conds
    %          if fix_best_B
    %              [choices,outcomes]=getSubjChoicesOutcomes(subjects,cond);
    %              [p,nll] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
    %              p0(2)=p(2); p_min(2)=p(2); p_max(2)=p(2);
    %          end
    %
    %         [choices,outcomes]=getSubjChoicesOutcomes(subjects{i},cond,context);
    %
    %         % find param values p that minimize nll as calculated in fitQLearningMod
    %         [p(i,:),nll(i,1)] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options);
    %         % [p,nll] = fminsearch(@(p) fitQLearningMod(p, choices, outcomes), p0, options);
    %     end
    %
    % end
    %
    % %%
    % % to get probability of choosing the chosen cue:
    % % [nll,d,Pc] = fitQLearningMod(p, choices, outcomes);
    %
    %
    %
    %
    %
