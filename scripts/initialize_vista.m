% Set session and anatomy paths
%  Modify: sess_path, subj_id

% Set session path
subject = '23';

p=getSA2Paths(subject);

sess_path = p.subj;
cd(sess_path)
 

% Set paths to scan files
% Modify: name_of_inplane

% Specify EPI files (should be 6)
tmp = dir(fullfile('raw','run*.nii*'));
nRuns = numel(tmp);
for ii = 1:nRuns
    epi_file{ii} = fullfile('raw', tmp(ii).name); 
    assert(exist(epi_file{ii}, 'file')>0)
end
 
% % Specify INPLANE files
inplane_file = fullfile('raw', 'pd.nii.gz'); 
assert(exist(inplane_file, 'file')>0)

 
% Specify Acpc-aligned t1 file
anat_file = fullfile('t1', 't1_fs.nii.gz');
assert(exist(anat_file, 'file')>0)

% Create params structure
% Generate the expected generic params structure
params = mrInitDefaultParams;
 
% And insert the required parameters: 
params.sessionDir   = sess_path;
params.subject = subject;

params.inplane      = inplane_file;
params.functionals  = epi_file; 
params.vAnatomy     = anat_file;

% Go!
ok = mrInit(params);


