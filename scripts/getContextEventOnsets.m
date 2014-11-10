  function [run_set_num,event_num,context,set_trial_idx,event_onset,...
      shock,shock_onset]= getContextEventOnsets(filePath)

% filePath - full file path to the txt file w/context event info (e.g.,
% 'run1_context_events')

% the file header should be this:
% 'RUN_SET_NUM EVENT_NUM CONTEXT SET_TRIAL_IDX EVENT_ONSET SHOCK SHOCK_ONSET';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
        
       
fid1=fopen(filePath);

dFormat = '%d %d %d %d %.4f %d %.4f';

d = textscan(fid1,dFormat,'HeaderLines',1);

fclose(fid1);

% info by trial 
run_set_num=d{1}; % set number of the run (1 or 2)
event_num = d{2};
context = d{3};
set_trial_idx = d{4};
event_onset = d{5};
shock = d{6};
shock_onset= d{7};



