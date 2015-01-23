function [pos_preg,neg_preg] = glm_fmri_createParametricRegs_SA2(subj, stim, run, nVols, TR)
%
% function to create parametric regressors for experiment SA2
%
% event times are convolved with spm's gamma function hrf
%
% INPUTS:
%         subj - string that's the name of the subject's directory (e.g.,
%                'sa01') 
%         stim - string to find and match in stimfile w/onset times. must
%                be one of these strings:
        %             - gainPE
        %             - lossPE
%         run - integers specifying which scan runs to include (e.g., [1:3])
%         nVols - number of volumes acquired in the scan run
%         TR - repetition time of each acquired volume

%
% OUTPUTS:
%         pregs - if 1 output is desired, then one parametric regressor for
%           both pos and neg PEs will be returned. If 2 outputs are desired,
%           then positive and negative p_regs will be given as separete
%           0-centered regressors pos_preg,neg_preg - parametric regressor
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


switch stim
    
    case 'gainPE'
        
        ab = getRLparams('all',1); % get best fitting RL params for gains
        [choices,outcomes]=getSubjChoicesOutcomes(subj,1); % gain trial choices and outcomes
        choices = choices(:,run); outcomes = outcomes(:,run);
        posPEmod = 'gain+1'; 
        negPEmod = 'gain0';  
        
    case 'lossPE'
        
        ab = getRLparams('all',2); % get best fitting RL params for losses
        [choices,outcomes]=getSubjChoicesOutcomes(subj,2); % loss trial choices and outcomes
        choices = choices(:,run); outcomes = outcomes(:,run);
        posPEmod = 'loss0';  
        negPEmod = 'loss-1'; 
        
        
    otherwise
        error('stim string not recognized');
        
end


[~,PE,~] = fitQLearningMod(ab, choices, outcomes);


if nargout<2

    fprintf('\ncomputing 1 parametric regressor for positive and negative PEs\n\n');
    
    onsets = [];   reg_tr = [];
    
    % first do positive PE, then negative PEs
    if k==1
        thisPE =  PE(PE>0);  % positive PEs
        thisCond = posPEmod; % which condition is this modulating?
    else
        thisPE = PE(PE<=0);
        thisCond = negPEmod;
    end
    
    % center mean at 0
    thisPE = thisPE - mean(thisPE);
    
    
    % get PE onset times
    onsets = getSA2StimOnsets(subj,thisCond,run);
    
    
    % make sure the # of onsets matches the number of positive PE values
    assert(isequal(numel(thisPE),numel(onsets)),'# of onsets and PEs arent equal');
          
        onsets = round(onsets ./ sample_rate); % convert to sample_rate units
        
        t = zeros(nVols.*TR./sample_rate,1); % define regressor time series
        
        t(onsets) = thisPE; % reg is parametrically modulated by PE value
        
        reg_ts = conv(t, hrf); % convolve upsampled time series with hrf
        
        reg_ts = (reg_ts./max(reg_ts));    % scaled to peak at 1
        
        reg_tr = reg_ts(1:TR/sample_rate:end); % convert time series into units of TRs
        
        reg_tr = reg_tr(1:nVols); % convolution makes the reg ts longer than nVols
        
    
    % assign to pos/neg out variables 
    if k==1
        pos_preg = reg_tr;
    else
        neg_preg = reg_tr;
    end
    

end % k = 1:2 (pos/neg)

    
    if nargout==2
        
          fprintf('\ncomputing parametric regressors separately for positive and negative PEs\n\n');
  
for k = 1:2 % do both positive and negative PEs (for either gains or losses)
    
    onsets = [];   reg_tr = [];
    
    % first do positive PE, then negative PEs
    if k==1
        thisPE =  PE(PE>0);  % positive PEs
        thisCond = posPEmod; % which condition is this modulating?
    else
        thisPE = PE(PE<=0);
        thisCond = negPEmod;
    end
    
    % center mean at 0
    thisPE = thisPE - mean(thisPE);
    
    
    % get PE onset times
    onsets = getSA2StimOnsets(subj,thisCond,run);
    
    
    % make sure the # of onsets matches the number of positive PE values
    assert(isequal(numel(thisPE),numel(onsets)),'# of onsets and PEs arent equal');
          
        onsets = round(onsets ./ sample_rate); % convert to sample_rate units
        
        t = zeros(nVols.*TR./sample_rate,1); % define regressor time series
        
        t(onsets) = thisPE; % reg is parametrically modulated by PE value
        
        reg_ts = conv(t, hrf); % convolve upsampled time series with hrf
        
        reg_ts = (reg_ts./max(reg_ts));    % scaled to peak at 1
        
        reg_tr = reg_ts(1:TR/sample_rate:end); % convert time series into units of TRs
        
        reg_tr = reg_tr(1:nVols); % convolution makes the reg ts longer than nVols
        
    
    % assign to pos/neg out variables 
    if k==1
        pos_preg = reg_tr;
    else
        neg_preg = reg_tr;
    end
    

end % k = 1:2 (pos/neg)








