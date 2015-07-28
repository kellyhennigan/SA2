% Set session and anatomy paths
%  Modify: sess_path, subj_id

% Set session path
sess_path = '/Volumes/server/Projects/Gamma_BOLD/wl_subj002';
cd(sess_path)
 
% Make symbolic link to anatomy directory if it doesn't already exist
if ~exist(fullfile(sess_path, '3DAnatomy'), 'file'),
    str = sprintf('ln -s %s %s',  '../../Anatomy/wl_subj002', fullfile(sess_path, '3DAnatomy'));
    system(str)
end

% Set paths to scan files
% Modify: name_of_inplane

% Specify EPI files (should be 10)
tmp = dir(fullfile('raw','run*.nii'));
for ii = 1:numel(tmp)
    epi_file{ii} = fullfile('raw', tmp(ii).name); 
    assert(exist(epi_file{ii}, 'file')>0)
end
 
% Specify INPLANE file
inplane_file = fullfile('raw','05+cbi_tfl_T1inplane_2mm', 'fieldMap+05+cbi_tfl_T1inplane_2mm_std.nii.gz'); 
assert(exist(inplane_file, 'file')>0)
 
% Specify 3DAnatomy file
anat_file = fullfile('3DAnatomy', 'nifti', 't1.nii.gz');
assert(exist(anat_file, 'file')>0)

% Create params structure
% Generate the expected generic params structure
params = mrInitDefaultParams;
 
% And insert the required parameters: 
params.inplane      = inplane_file; 
params.functionals  = epi_file; 
params.sessionDir   = sess_path;

% Set optional parameters (specific to experiment)
% Modify: params.subject, params.annotations (e.g. 'FacesHouses' 'Words' 'Bars' 'Bars' 'OnOff'), params.coParams.nCycles (for each scan, can be determined from par files)
params.subject = 'wl_002';
params.annotations = {'GammaBOLD_01', 'GammaBOLD_02','GammaBOLD_03',...
    'GammaBOLD_04','GammaBOLD_05','GammaBOLD_06','GammaBOLD_07', ...
    'GammaBOLD_08', 'pRF_BARS_01', 'pRF_BARS_02'};

% Specify some optional parameters
params.vAnatomy     = anat_file;
params.keepFrames   = []; %We dropped frames in pre-processing
params.coParams{1}  = coParamsDefault; %may be different for each scan
params.coParams{1}.nCycles = [9 9 9 9 9 9 9 9 8 8];
params.coParams{1}.framesToUse = 5:148;

% Go!
ok = mrInit(params);