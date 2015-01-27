function onsets = getSA2StimOnsets(subj, stim, run)

%
% INPUTS:
%   subj - subject id string
%   stim - string id of stim to get onsets for; can be: 
        % cuepair1 - cue pair for gain trials
        % cuepair2 - cue pair for loss trials
        % gain+1 - win outcomes 
        % gain0 - nothing outcomes for gain trials
        % loss-1 - loss outcomes 
        % loss0 - nothing outcomes for loss trials
        % contextevent - neutral or shock cue (base or stress context)
        % shock - shock delivery 
  
%   run - scan run number

% OUTPUT:
%   onsets 

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


adjustTime0s = 6; % omitted the first 4 volumes, so subtract 4*TR from onset times (6s)

p = getSA2Paths(subj);

onsets = [];


switch stim
    
    case {'contextevent','shock'}
        
        % then load context events file
        [~,~,context,~,event_onset,...
            shock,shock_onset]= getSA2ContextEventData([p.behavior 'run' num2str(run) '_context_events']);
        
        % adjust onset times for omitted first 4 vols
        event_onset = event_onset - adjustTime0s;
        shock_onset = shock_onset - adjustTime0s;
        
        if strcmp(stim,'contextevent')  % either neutral or shock cues
            onsets = event_onset;
            
        elseif strcmp(stim,'shock') && all(context==2)
            onsets = shock_onset(~isnan(shock_onset));
            
        end
        
        
    otherwise   % assume its a task trial regressor
        
        
        %         load task trials stim file
        f=dir([p.behavior 'run' num2str(run) '*task_trials']);
        [run_set_num,set_trial_num,cond,cue_onset,response,...
            cue_choice,rt,outcome,outcome_onset]= getSA2BehData([p.behavior f(end).name]);
        
        % adjust onset times for omitted first 4 vols
        cue_onset = cue_onset - adjustTime0s;
        outcome_onset = outcome_onset - adjustTime0s;
        
        
        if strcmp(stim,'cuepair1')
            onsets = cue_onset(cond==1);
            
        elseif strcmp(stim,'cuepair2')
            onsets = cue_onset(cond==2);
            
        elseif strcmp(stim,'gain')
            onsets = outcome_onset(cond==1);    
     
        elseif strcmp(stim,'gain+1')
            onsets = outcome_onset(cond==1 & outcome==1);    
                  
        elseif strcmp(stim,'gain0')
            onsets = outcome_onset(cond==1 & outcome==0);
    
        elseif strcmp(stim,'loss')
            onsets = outcome_onset(cond==2);
            
        elseif strcmp(stim,'loss-1')
            onsets = outcome_onset(cond==2 & outcome==1);
            
        elseif strcmp(stim,'loss0')
            onsets = outcome_onset(cond==2 & outcome==0);
            
        else
            error('dont recognize the stimStr given');
        end
        
end