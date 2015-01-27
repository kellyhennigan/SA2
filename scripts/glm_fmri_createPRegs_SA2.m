function reg_tr = glm_fmri_createPRegs_SA2(subj, stim, pstr, run, nVols, TR)
%
% function to create parametric regressors for experiment SA2
%
% event times are convolved with spm's gamma function hrf
%
% INPUTS:
%         subj - string that's the name of the subject's directory (e.g.,
%                'sa01')
%         stim - string to find and match in stimfile w/onset times. must
%                be one of these strings as of this time:
%                     - gain
%                     - loss
%         pstr - string identifying the type of parametric modulation. As
%                of now this can be 'PE', '+PE', '-PE','sPE',or 'outc' to signify
%               parametric modulation with prediction error (PE) values, only
%               positive PE values, only negative PE values, salience PE values
%               (so the absolute value of PEs), or outcome, which for gains is +1
%               for wins and -1 for nothing outcomes and for losses its +1 for
%               nothing and -1 for loss outcomes.
%               run - integers specifying which scan runs to include (e.g., [1:3])
%               nVols - number of volumes acquired in the scan run
%               TR - repetition time of each acquired volume

%
% OUTPUTS:
%         reg_tr - desired parametric regressor
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% irf parameters
sample_rate = 0.1;                  % sample rate in seconds (upsampled)
params = [6 16 1 1 6 0 32];         % set parameters for hrf; defaults are: P = [6 16 1 1 6 0 32];
hrf = spm_hrf(sample_rate,params);  % spm's hrf


%%%%%%%%%%%
%% do it

reg_tr = [];

onsets = getSA2StimOnsets(subj,stim,run); % get stim onset times

[choices,outcomes]=getSubjChoicesOutcomes(subj,stim); % trial choices and outcomes

choices = choices(:,run); outcomes = outcomes(:,run);

% omit any no-response trials
idx=find(isnan(choices));
if ~isempty(idx)
    choices(idx) = []; onsets(idx) = []; outcomes(idx) = [];
end


% assert that the number of choices, outcomes, and onsets are equal
assert(isequal(numel(onsets),numel(choices),numel(outcomes)),'# of onsets, choices, and outcomes arent equal');


switch pstr
    
    case 'outc'  % trial outcome (win/nothing or loss/nothing)
        
        if strcmp(stim,'gain')
            outcomes(outcomes==0) = -1;
        elseif strcmp(stim,'loss')
            outcomes(outcomes==1) = -1;
            outcomes(outcomes==0) = 1;
        else
            error('stim string not recognized - first 4 characters must be either gain or loss')
        end
        
        pmod = outcomes; % parametrically modulate regressor by outcome values
        
        
    otherwise % must be a PE parametric mod
        
        ab = getRLparams('all',stim); % get best fitting RL params for gains
        [~,PE,~] = fitQLearningMod(ab, choices, outcomes);
        
        switch pstr
            
            case 'PE'   % reward prediction errors
                
                pmod = PE - mean(PE);  % center mean at 0
                
            case '+PE' % positive prediction errors
                
                pmod=PE(PE>0)-mean(PE(PE>0));
                onsets = onsets(PE>0);
                
            case '-PE'  % negative prediction errors
                
                pmod=PE(PE<0)-mean(PE(PE<0));
                onsets = onsets(PE<0);
                
                
            case 'sPE'  % salience prediction errors (abs val of PE)
                
                pmod = abs(PE)-mean(abs(PE));
                
            otherwise
                
                error(['pstr: ' pstr ' not recognized']);
        end
end


pmod

%% make regressor time series


% make sure there's the same # of onsets and pmod values
assert(isequal(numel(onsets),numel(pmod)),'# of onsets and parametric mod values arent equal');

onsets = round(onsets ./ sample_rate); % convert to sample_rate units

t = zeros(nVols.*TR./sample_rate,1); % define regressor time series

t(onsets) = pmod; % reg is parametrically modulated

reg_ts = conv(t, hrf); % convolve upsampled time series with hrf

reg_ts = (reg_ts./max(reg_ts));    % scaled to peak at 1

reg_tr = reg_ts(1:TR/sample_rate:end); % convert time series into units of TRs

reg_tr = reg_tr(1:nVols); % convolution makes the reg ts longer than nVols



