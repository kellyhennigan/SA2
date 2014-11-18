function [run_set_num,set_trial_num,cond,cue_onset,response,...
    cue_choice,rt,outcome,outcome_onset]= getSA2BehData(filePath)

% filePath - full file path to the txt file w/task info (e.g.,
% 'run1_task_trials')

% the file header should be this:
% 'RUN_SET_NUM SET_TRIAL_NUM COND CUE_ONSET RESPONSE CUE_CHOICE RT OUTCOME OUTCOME_ONSET';

% NOTE: edit this function to take in strings as an input that will
% determine what is output (use varargin and varargout)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

fid1=fopen(filePath);

dFormat = '%d %d %d %.4f %d %d %.4f %d %.4f';

d = textscan(fid1,dFormat,'HeaderLines',1);

fclose(fid1);

% info by trial 
run_set_num=d{1}; % set number of the run (1 or 2)
set_trial_num = d{2}; % trial number for the current set (1-36)
cond = d{3}; % gain or loss trial
cue_onset = d{4}; 
response = d{5};
cue_choice = d{6};
rt = d{7};
outcome = d{8};
outcome_onset = d{9};

% recode no-response trials w/NaN for cue choice and outcome
outcome = double(outcome); outcome(cue_choice==0)=nan;
cue_choice = double(cue_choice); cue_choice(cue_choice==0)=nan;

   
            