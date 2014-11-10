%%% make regressors for MID task

% regressors of interest:

% task cues (7); duration is 500ms:
%   1) gain-big,
%   2) gain-med,
%   3) gain-small,
%   4) neutral,
%   5) loss-big,
%   6) loss-med,
%   7) loss-small

% target/response (1); duration of target is 500ms

% feedback (3); duration is 1.5 sec
%   1) win
%   2) lose
%   3) no change

% actually the way the outcomes are saved makes its difficult to figure out
% what the outcome was for trials in sequential order, so for now I'll just
% modeled the feedback period with a single regressor


%%

% stim file names for each scan run
stimFiles = {'MID_cumulative_arrays1.mat','MID_cumulative_arrays2.mat'};

sample_rate = 0.1; % units of seconds; for upsampled regressor time series

% string names that will correspond to all the regressor time series
reg_names = {'cue_control','cue_gain_0','cue_gain_lo','cue_gain_hi',...
    'cue_loss_0','cue_loss_lo','cue_loss_hi','cue_all','target','outcome'};

n_trial_types = 7; % number of trial types (corresponding to cues)

% duration of stimuli of interest (in seconds), corresponding to reg_names
cue_dur = 1.5; target_dur = .5; outcome_dur = .5;
stim_durations = [repmat(cue_dur,1,n_trial_types),cue_dur,target_dur,outcome_dur];
stim_durations = round(stim_durations./sample_rate); % upsampled to sample_rate
 

irf = 'spm_hrf';

p = [6 16 1 1 6 0 32]; % default parameter's for spm's hrf: [6 16 1 1 6 0 32]
[hrf,p]=spm_hrf(sample_rate,p); % use spm's hrf

param_str = sprintf('_%d', p);
outFileSuffix = ['_',irf,param_str];

TR = 2; % in units of seconds
nTRs = 246; % number of volumes acquired (not including initial calibration TRs)

% define directories containing stim files & where to save out regressors
inDir = '/Users/Kelly/Dropbox/MID/data/5';
outDir = '/Users/Kelly/SA2/data/pilot100513/regs';


%% get stimulus onsets

% for i=1:length(stimFiles)
  i=2
  
    cd(inDir)

    load(stimFiles{i})
    
    for j = 1:n_trial_types
        cue_onsets{j} = trial_starts(trials==j);
    end
    
    % now define a cell array that contains onsets for all regs of interest
    % should correspond in order to reg_names
    onsets = cue_onsets;
    onsets{end+1} = trial_starts;
    onsets{end+1} = target_times;
    onsets{end+1} = feedback_times;
    onsets=cellfun(@(x) ceil(x./sample_rate), onsets,'UniformOutput',false); % now upsample onset times to the sample_rate
       
    %% now make regressor time series
    
    for k = 1:length(reg_names)
        
        nt = nTRs.*TR./sample_rate; % number of upsampled time points 
        t = zeros(nt,1); % define regressor time series of zeros
        
        % 1 when the stim of interest is occurring
        for m = onsets{k}
            t(m:m+stim_durations(k)-1) = 1; % 1 when stim occurs
        end
        
        % convolve upsampled time series with hrf
        reg_ts = conv(t, hrf);
        
        % scaled to peak at 1
        reg_ts = (reg_ts./max(reg_ts));
        
        % downsample time series into TR units
        reg_tr = reg_ts(1:TR/sample_rate:length(reg_ts));
        reg_tr = reg_tr(1:nTRs);
        
        cd(outDir)
        
        outName = ['run',num2str(i),'_',reg_names{k},outFileSuffix];
            
        dlmwrite(outName,reg_tr)
        
    end % regressors
     
% end % stimFiles (runs)
        
        
        
        
        
        
        
        
        
