function p = getSA2Paths(subject)
% --------------------------------
% usage: get a structural array containing all relevant paths for project
% SA2
% 
% INPUT:
%   subject (optional) - subject id string

% 
% OUTPUT:
%   p - structural array containing relevant paths
% 
% 
% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cName=getComputerName; 

if strcmp(cName,'dn0a221879.sunet')     % laptop
    baseDir = '/Users/Kelly/SA2/data';
elseif strcmp(cName,'psy-jal-ml.stanford.edu') % lab desktop
    baseDir = '/Users/kelly/SA2/data';
elseif strcmp(cName,'mt-tamalpais') % mt-tam server
    baseDir = '/home/kelly/SA2/data';
end

p = struct();

p.baseDir = baseDir;

% subject directories
if ~notDefined(subject)
    p.subj = fullfile(baseDir, subject);  % subject directory
    p.design_mats = fullfile(p.subj, 'design_mats/');
    p.raw         = fullfile(p.subj, 'raw/');
    p.regs        = fullfile(p.subj, 'regs/');
    p.ROIs        = fullfile(p.subj, 'ROIs/');
    p.stimtimes   = fullfile(p.subj, 'stimtimes/');
    p.t1          = fullfile(p.subj, 't1/');
end
    
end


