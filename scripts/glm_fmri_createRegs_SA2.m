function reg_tr = glm_fmri_createRegs_SA2(subj, stim, irf, run, nVols, TR)
%
% creates a separate regressor for each trial
%
% event times are convolved with spm's gamma function hrf
%
% INPUTS:
% subj - string that's the name of the subject's directory (e.g., 'sa01')
% stim - string to find and match in stimfile w/onset times. can be:
            % cuepair1 - cue pair for gain trials
            % cuepair2 - cue pair for loss trials
            % gain+1 - win outcomes
            % gain0 - nothing outcomes for gain trials
            % loss-1 - loss outcomes
            % loss0 - nothing outcomes for loss trials
            % contextevent - neutral or shock cue (base or stress context)
            % shock - shock delivery
% irf - can be either 'can' for spm's canonical hrf or 'fir' for using a
%       finite response function (like AFNI's tent function)
% run - integers specifying which scan runs to include (e.g., [1:6])
% nVols - number of volumes acquired in the scan run
% TR - repetition time of each acquired volume
%
% OUTPUTS:,
% run_regs - regressor time series in units of TRs from the runs
%          requested in columns

%
% NOTE: User should edit first section below to specify desired irf
% parameters, etc.
%
% Kelly, 2014
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%

% if runs argument not given, process all 3 runs
if notDefined('irf')
    irf = 'can'; % spm's canonical hrf function
end


% irf parameters
switch irf
    
    case 'can'  % spm's canonical hrf function 
        
        sample_rate = 0.1;             % sample rate in seconds (upsampled)
        params = [6 16 1 1 6 0 32];         % set parameters for hrf; defaults are: P = [6 16 1 1 6 0 32];
        hrf = spm_hrf(sample_rate,params);  % spm's hrf
        
        % to get spm's hrf function & temporal derivative:
        % TR = .1;
        % [err,bf]=spm_bf(TR);
        % 1st col of bf is the hrf function w/default spm parameters; 2nd col is
        % the temporal derivative
        
        
    case 'fir'  % finite impulse response funtion (like afni's tent function)
        
        b = -2;  %  beginning of time window to model after stim onset
        c = 10;  % end of time window to model after stim onset
        n = 7;   % number of tent functions to model for each event of interest
        params = [b c n];
        % note: timegap btwn regressors = (c-b)./(n-1); this value should be >= TR
        
end


%%%%%%%%%%%
%% do it


reg_tr = [];

onsets = getSA2StimOnsets(subj,stim,run); % get stim onset times

    
    %% convolve stim events with hrf, or interpolate for tent irf
    
    switch irf
        
        case 'can'
            
            onsets = round(onsets ./ sample_rate); % convert to sample_rate units
            
            t = zeros(nVols.*TR./sample_rate,1); % define regressor time series
            t(onsets) = 1; % 1 when stim occurs
            
            reg_ts = conv(t, hrf); % convolve upsampled time series with hrf
            
            if max(reg_ts)>0  % only scale if there are values > 0 
                reg_ts = (reg_ts./max(reg_ts));    % scaled to peak at 1
            end
            
            reg_tr = reg_ts(1:TR/sample_rate:end); % convert time series into units of TRs
            reg_tr = reg_tr(1:nVols); % convolution makes the reg ts longer than nVols
            
            
        case 'fir'
            
            t = 0:TR:nVols*TR-1; % define time series
            reg_tr = createFIRRegs(t, onsets, params);
            
    end
    

% figure
% plot(reg_tr)









