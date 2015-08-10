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
[subjects,cb] = getSA2Subjects('fmri');

fitGroup = 0; % 1 for fitting all subjects as a group, 0 to fit each subject individually

% which condition? must be either 1/'gain' or 2/'loss'
cond = 'gain';

% which context? must be either 1/'base' or 2/'stress' or '' for both
% contexts = {'base','stress'};
contexts ={''};

% fix the inverse temp B to the best fit across contexts? 1 for yes, 0 for
% no. if fitEachSub is set to 1, B is fixed to the best fit per sub,
% otherwise its the best for the whole group
fix_best_B = 0;
fix_B_by_subj = 0;

options = optimset('MaxFunEvals',1000,'MaxIter',1000);

doPlot = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% fit learning model


% get parameters and options for fminsearch
[p0, p_min, p_max] = getInitRLParams();


% if fix_best_B, estimate the best B for both contexts & all subjects
if fix_best_B
    [choices,outcomes]=getSubjChoicesOutcomes(subjects,cond);
    p_best = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
    p_min(2) = p_best(2); p_max(2) = p_best(2);
end


if fitGroup
    
    for c=1:numel(contexts)
        
        context = contexts{c};
        
            
        % fit model for all subjects
        [choices,outcomes]=getSubjChoicesOutcomes(subjects,cond,context);
        [p,nll] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
        a(c) = p(1);
        B(c) = p(2);
        
    end % contexts
    
    
    %% or fit for each subject individually
    
else
    
    % now fit model for each individual subject
    for i=1:numel(subjects)
        
        subj = subjects{i};
        
        if fix_best_B && fix_B_by_subj
            [p0, p_min, p_max] = getInitRLParams();
            [choices,outcomes]=getSubjChoicesOutcomes(subj,cond);
            p_best = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
            p_min(2) = p_best(2); p_max(2) = p_best(2);
        end

        
        for c=1:numel(contexts)
            
            context = contexts{c};
            
            [choices,outcomes]=getSubjChoicesOutcomes(subj,cond,context);
            [p,nll] = fminsearchbnd(@(p) fitQLearningMod(p, choices, outcomes), p0, p_min, p_max, options); % bounded search
            a(i,c) = p(1);  B(i,c) = p(2);
        end
        
    end
    
end % subj or group fit


%% plots

if doPlot
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
    print(gcf,'-dpng','-r300',['RL_subj_' cond])
    
end











