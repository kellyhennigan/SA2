% presumbaly, the view structure should be open?

vw = initHiddenInplane;

% install segmentation
query = 0;
keepAllNodes = false;
filePaths = {'t1/t1_class.nii.gz'};
numGrayLayers = 3;
installSegmentation(query, keepAllNodes, filePaths, numGrayLayers)


% Check
ip = mrVista('inplane');
gr = mrVista('3View');
vo = open3ViewWindow('volume');

