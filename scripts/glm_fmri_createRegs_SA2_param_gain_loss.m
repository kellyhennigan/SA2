function reg_tr = glm_fmri_createRegs_SA2_param_gain_loss(subj, stim, irf, run, nVols, TR)
%
% this is a mesy hack to make parametric regressors for gains and losses 
% parametrically modulated acording to outcome (for gain condition, +1 for wins and
% -1 for nothing, for loss condition, +1 for nothing and -1 for losses)
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
[~,outcomes]=getSubjChoicesOutcomes(subj,stim(1:4)); % trial outcomes for gain or loss conds
outcomes = outcomes(:,run);
 
% omit any no response trials 
idx=find(isnan(outcomes));
if ~isempty(idx)
    outcomes(idx) = [];
    onsets(idx) = [];
end
assert(isequal(numel(outcomes),numel(onsets)),'# of onsets and PEs arent equal');
  
if strcmp(stim,'gain')
    outcomes(outcomes==0) = -1;
elseif strcmp(stim,'loss')
    outcomes(outcomes==1) = -1;
    outcomes(outcomes==0) = 1;
else
    error('stim string not recognized - first 4 characters must be either gain or loss')
end
    %% convolve stim events with hrf, or interpolate for tent irf
    
    switch irf
        
        case 'can'
            
            onsets = round(onsets ./ sample_rate); % convert to sample_rate units
            
            t = zeros(nVols.*TR./sample_rate,1); % define regressor time series
            
            t(onsets) = outcomes; % 1 when stim occurs
            
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









