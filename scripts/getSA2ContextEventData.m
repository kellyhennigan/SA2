function [run_set_num,event_num,context,set_trial_idx,event_onset,...
    shock,shock_onset]= getSA2ContextEventData(filePath)

% filePath - full file path to the txt file w/task info (e.g.,
% 'run1_task_trials')

% the file header should be this:
% RUN_SET_NUM EVENT_NUM CONTEXT SET_TRIAL_IDX EVENT_ONSET SHOCK SHOCK_ONSET

% NOTE: edit this function to take in strings as an input that will
% determine what is output (use varargin and varargout)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

fid1=fopen(filePath);

dFormat = '%d %d %d %d %.4f %d %.4f';

d = textscan(fid1,dFormat,'HeaderLines',1);

fclose(fid1);

% info by trial 
run_set_num=d{1}; % set number of the run (1 or 2)
event_num = d{2};   % context event number 
context = d{3}; % neutral or stress context 
set_trial_idx = d{4};  % index for the task trial number
event_onset = d{5};  % onset time of cue 
shock = d{6};           % 1=shock, 0 otherwise
shock_onset = d{7};    % if a shock was delivered, this is the onset time 


   
            