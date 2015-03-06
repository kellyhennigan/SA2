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
msh = meshBuildFromClass(fName,[],'both'); 

% unsmoothed (0 iterations)
msh = meshSet(msh,'smooth_iterations',0);
msh = meshSet(msh,'smooth_relaxation',0.5);
msh = meshVisualize(meshColor(meshSmooth(msh)));


% also save as smoothed (200 iterations at .5) and 
% super-smoothed (400 iterations at .5)


% If you would like to add two layers of gray matter to this visualization,
% you can use the following sequence of commands.
 [nodes,edges,classData] = mrgGrowGray(fName,3); 
wm = uint8( (classData.data == classData.type.white) | (classData.data == classData.type.gray));
msh = meshColor(meshSmooth(meshBuildFromClass(wm,[1 1 1])));
meshVisualize(msh,2);
% This changes the mesh appearance so that it has a more full appearance.
% Mesh with gray matter, also colored by curvature


%% save a mesh 

msh.path = pwd;
msh=mrmWriteMeshFile(msh,'mesh_supersmoothed')



%% RETRIEVING MESH SETTINGS

% Other useful command line options: 

% meshStoreSettings: saves the view angle, zoom level, and lighting
% settings for a mesh, in order to retrieve the same view settings later.
% (E.g., if you want to view several different maps on the brain using the
% same angle.)
msh = meshStoreSettings(msh, 'ventral_view');
% meshRetrieveSettings: retrieves the stored settings.

% meshMultiAngle: accepts a list of view settings for a given mesh,
% sequentially sets each view settings and takes a snapshot of the mesh
% from that angle, then returns a montage image of the mesh from the
% different view angles. Useful for examining a map from different angles.
% Usage: meshMultiAngle(mesh, settings, savePath, colorbarFlag); 

% Example: meshMultiAngle(VOLUME{1}, {'Medial' 'Posterior' 'Lateral'},
% 'Images/meshMontage.png', 1);

% To plot the same map / corAnal field from several scans, using the same
% angle, in a montage: meshCompareScans e
% Usage: meshCompareScans(view, scans, dts, angles, savePath, leg);
% Example: meshCompareScans(VOLUME{1}, [1:4], 'Original', {'Medial'
% 'Posterior' 'Lateral'}, 'Images/Comparison.png'), 1);




%% ROI SELECTION 



meshPublicationPictures i
