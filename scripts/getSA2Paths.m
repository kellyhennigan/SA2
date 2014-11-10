function expPaths = getSA2Paths(subject)
% --------------------------------
% usage: get a structural array containing all relevant paths for project
% SA2
% 
% INPUT:
%   subject - subject id string (optional)

% 
% OUTPUT:
%   expPaths - structural array containing relevant paths
% 
% 
% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cName=getComputerName; 

if strcmp(cName,'dn0a221879.sunet')     % laptop
    baseDir = '/Users/Kelly/SA2/data';
elseif strcmp(cName,'psy-jal-ml.stanford.edu') % lab desktop
    baseDir = '/Users/kelly/SA2/data';
else 
expPaths = struct();

expPaths.baseDir = baseDir;
expPaths.subj        = fullfile(baseDir, subject);  % subject directory

% subject directories
% expPaths.afni        = fullfile(expPaths.subj, 'afni/');
expPaths.design_mats = fullfile(expPaths.subj, 'design_mats/');
% expPaths.dti96trilin = fullfile(expPaths.subj, 'dti96trilin/');
% expPaths.fibers      = fullfile(expPaths.subj, 'fibers/');
% expPaths.raw         = fullfile(expPaths.subj, 'raw/');
% expPaths.raw_func    = fullfile(expPaths.subj, 'raw_func/');
% expPaths.raw_dti     = fullfile(expPaths.subj, 'raw_dti/');
expPaths.regs        = fullfile(expPaths.subj, 'regs/');
expPaths.results     = fullfile(expPaths.subj, 'results/');
% expPaths.results_hab = fullfile(expPaths.subj, 'results_hab/');
expPaths.ROIs        = fullfile(expPaths.subj, 'ROIs/');
expPaths.stimtimes   = fullfile(expPaths.subj, 'stimtimes/');
expPaths.slicetimes  = fullfile(expPaths.subj, 'slicetimes/');
% expPaths.funcROIs    = fullfile(expPaths.subj, 'funcROIs/');
expPaths.t1          = fullfile(expPaths.subj, 't1/');

end


