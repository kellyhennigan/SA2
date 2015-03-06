% script to practice and check out mesh building commands


% path and name of a class file
fName = '/Users/Kelly/Desktop/mrVistaAnatomy/left/left.Class';

%% 

mrmStart; % command to start mrMesh server

% commands to create and visualize a mesh: 
msh = meshBuildFromClass(fName);
msh = meshSmooth(msh);
msh = meshColor(msh);
meshVisualize(msh);


% commands to add 2 layers of gray matter:
[nodes,edges,classData] = mrgGrowGray(fName,2); 
wm = uint8( (classData.data == classData.type.white) | (classData.data == classData.type.gray));
msh = meshColor(meshSmooth(meshBuildFromClass(wm,[1 1 1])));
meshVisualize(msh,2);


% key mesh parameters are: # of smoothing interations, relaxation &
% sinc_method:
% smooth_iterations  (default 35)
% smooth_relaxation  (default 0.15)
% smooth_sinc_method (default 1)
% these can be changed using by calling meshSet: 
msh = meshSet(msh,'smooth_iterations',30);
msh = meshSet(msh,'smooth_relaxation',0.5);
msh = meshSet(msh,'smooth_sinc_method',0);

msh = meshSet(msh,'smooth_iterations',200);

%% create a montage of a mesh from multiple angles w/ meshMultiAngle
 
% Usage: meshMultiAngle(mesh, settings, savePath, colorbarFlag); 
meshMultiAngle(VOLUME{1}, {'Medial' 'Posterior' 'Lateral'}, 'Images/meshMontage.png', 1);

% To plot the same map / corAnal field from several scans, using the same
% angle, in a montage: meshCompareScans
% Usage: meshCompareScans(view, scans, dts, angles, savePath, leg); 
meshCompareScans(VOLUME{1}, [1:4], 'Original', {'Medial' 'Posterior' 'Lateral'}, 'Images/Comparison.png'), 1);
[edit]



%% now try with my data: 

fName = '/Users/Kelly/SA2/data/23/t1/t1_class.nii.gz';

mrmStart; % command to start mrMesh server

% commands to create and visualize a mesh: 
msh = meshBuildFromNiftiClass(fName)
