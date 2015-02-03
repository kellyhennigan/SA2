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

if strcmp(cName,'psy-jal-ml.stanford.edu') % lab desktop
    baseDir = '/Users/kelly/SA2';
elseif strcmp(cName,'mt-tamalpais')        % mt-tam server
    baseDir = '/home/kelly/SA2';
else                                       % assume it's laptop Pluck
    
    if exist('/Volumes/blackbox/SA2','dir') % if the XHD black is connected
        baseDir = '/Volumes/blackbox/SA2';
    else
        baseDir = '/Users/Kelly/SA2';
    end
end


p = struct();

p.baseDir = baseDir;
p.data = fullfile(p.baseDir, 'data/');
p.figures = fullfile(p.baseDir, 'figures/');

% subject directories
if ~notDefined('subject')
    p.subj = fullfile(p.data, subject);  % subject directory
    p.behavior    = fullfile(p.subj, 'behavior/');
    p.design_mats = fullfile(p.subj, 'design_mats/');
    p.fmap_proc       = fullfile(p.subj, 'fmap_proc/');
    p.func_proc   = fullfile(p.subj, 'func_proc/');
    p.raw         = fullfile(p.subj, 'raw/');
    p.regs        = fullfile(p.subj, 'regs/');
    p.ROIs        = fullfile(p.subj, 'ROIs/');
    p.results        = fullfile(p.subj, 'results/');
    p.t1          = fullfile(p.subj, 't1/');
end

end


