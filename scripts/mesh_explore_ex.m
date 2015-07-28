% You can use a sample anatomical data set to experiment with building
% meshes. After downloading and extracting the data, find one of the white
% matter class files (left.Class or right.Class). Currently these files are
% created using ITKGray; previously we used mrGray. To display a mesh, the
% mesh server must be running (with the command mrmStart). Also, on
% Windows, you must have several libraries installed. To create and
% visualize a mesh, use the following sequence of Matlab commands:

cd '/Users/Kelly/dti/sa01/t1'  % go to directory with segmentation file

fName = 't1_class.nii.gz';

 mrmStart
msh = meshBuildFromClass(fName,[],'left'); 
msh = meshSmooth(msh);
msh = meshColor(msh);
meshVisualize(msh);

% If you would like to add two layers of gray matter to this visualization,
% you can use the following sequence of commands.
 [nodes,edges,classData] = mrgGrowGray(fName,2); 
wm = uint8( (classData.data == classData.type.white) | (classData.data == classData.type.gray));
msh = meshColor(meshSmooth(meshBuildFromClass(wm,[1 1 1])));
meshVisualize(msh,2);
% This changes the mesh appearance so that it has a more full appearance.
% Mesh with gray matter, also colored by curvature

% To visualize the right hemisphere, you can run
msh = meshBuildFromClass(fName,[],'right');
msh = meshSmooth(msh);
msh = meshColor(msh);
meshVisualize(msh);

% You can also visualize 'both' hemispheres.
msh = meshBuildFromClass(fName,[],'both');
msh = meshSmooth(msh);
msh = meshColor(msh);
meshVisualize(msh);


%% Modifying meshes

%%%%%% key smoothing parameters are: 
% smooth_iterations  (default 35)
% smooth_relaxation  (default 0.15)
% smooth_sinc_method (default 1)


%%%% These are set using the meshSet method as:
msh = meshSet(msh,'smooth_iterations',30);
msh = meshSet(msh,'smooth_relaxation',0.5);
msh = meshSet(msh,'smooth_sinc_method',0);
meshVisualize(msh);


%%%%%% Jon's lab's wiki recommends having 3 meshes/hemisphere with the
%%%%%% following smoothing params: 

% unsmoothed (0 iterations)
msh = meshBuildFromClass(fName); % if no hemisphere is given, it defaults to the left hemisphere
msh = meshSet(msh,'smooth_iterations',0);
msh = meshSmooth(msh);
msh = meshColor(msh);
meshVisualize(msh);

% smoothed (200 iterations at .5)
msh = meshBuildFromClass(fName); % if no hemisphere is given, it defaults to the left hemisphere
msh = meshSet(msh,'smooth_iterations',200);
msh = meshSet(msh,'smooth_relaxation',0.5);
msh = meshSmooth(msh);
msh = meshColor(msh);
meshVisualize(msh);

% super-smoothed (400 iterations at .5)
msh = meshBuildFromClass(fName); % if no hemisphere is given, it defaults to the left hemisphere
msh = meshSet(msh,'smooth_iterations',400);
msh = meshSet(msh,'smooth_relaxation',0.5);
msh = meshSmooth(msh);
msh = meshColor(msh);
meshVisualize(msh);

msh = meshSet(msh,'smooth_iterations',30);

msh = meshColor(msh);
meshVisualize(msh);



%% RETRIEVING MESH SETTINGS

Other useful command line options:
To create a montage of a mesh from multiple angles, w/ color bar, use meshMultiAngle
Usage: meshMultiAngle(mesh, settings, savePath, colorbarFlag); 
Example: meshMultiAngle(VOLUME{1}, {'Medial' 'Posterior' 'Lateral'}, 'Images/meshMontage.png', 1);
To plot the same map / corAnal field from several scans, using the same angle, in a montage: meshCompareScans
Usage: meshCompareScans(view, scans, dts, angles, savePath, leg); 
Example: meshCompareScans(VOLUME{1}, [1:4], 'Original', {'Medial' 'Posterior' 'Lateral'}, 'Images/Comparison.png'), 1);
[edit]



%% ROI SELECTION 


