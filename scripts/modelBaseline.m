function Xbase = modelBaseline(nt,nP)

% this function creates a design matrix for modeling the baseline of an
% fMRI time series with polynomial baseline regressors.
% 
% INPUTS: 
%      nt - 1 x n or n x 1 vector specifying the # of TRs in each scan run
%           to model. So n is the number of scan runs, which will be modeled
%           separately. 
%      nP - specifies the order of polynomial expansion, where nP = 0 will
%           return a single constant regressor to model for each scan run,
%           nP=1 will return a constant and linear term, nP= will also
%           include a quadratic term, etc.
% 
% 
% OUTPUTS:
%      Xbase - design matrix with m rows x n columns. # of rows m will
%           equal sum(nt) and # of columns n will equal (nP+1)*numel(nt)
%     
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nRuns = numel(nt); % number of scan runs to individually model
Nt = sum(nt);      % total number of time points across scan runs

% Xbase = zeros(sum(nt),nRuns*(nP+1));
Xbase = [];

for i = 1:nRuns
    for j = 0:nP
        Xbase_run{i}(:,j+1) = linspace(-1,1,nt(i))'.^j;
    end
%     Xbase_run{i}( = spm_orth(Xbase_run{i}); % orthogonalize regressors
    Xbase(end+1:end+nt(i),end+1:end+nP+1) = Xbase_run{i};
end
  Xbase = spm_orth(Xbase);  
    
% figure
% imagesc(Xbase)

end