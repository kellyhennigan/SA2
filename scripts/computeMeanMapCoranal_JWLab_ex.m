% Computes mean maps and coranal for original scans and for averaged scans
% in the Inplane. Transforms averaged mean map and coranal to gray using
% trilinear interpolation.

% for more info, see here: https://wikis.nyu.edu/pages/viewpage.action?pageId=54830209

% Open the session
cd /Volumes/server/Projects/Gamma_BOLD/wl_subj004;
vw = mrVista;


%% Coherence analysis for original scans
% Set the frames to be limited to a multiple of the cycle length
for scan = 1:8 % 1 to 8 are the gamma bold
    vw = viewSet(vw, 'num cycles', 9, scan);
    vw = viewSet(vw, 'frames to use', 5:148, scan);
end

saveSession;

% Compute a coherence analysis
vw = computeCorAnal(vw, 0, 1); 
updateGlobal(vw)

% View coranal
vw = setDisplayMode(vw, 'co');
vw = viewSet(vw, 'cothresh', .2);
vw = refreshScreen(vw);

%% Compute mean maps for original scans

vw = computeMeanMap(vw, 0);
updateGlobal(vw)

%view meap map
vw = setDisplayMode(vw, 'map');
vw = viewSet(vw, 'cothresh', 0);
vw = refreshScreen(vw);


%% Average 

% if we have just original data, let's make a new dataTYPE of the averages
if numel(dataTYPES) == 1        
    vw = averageTSeries(vw, 1:8, 'Averages', 'Average of Original 1:8');
end

%% Run coherence analysis on averaged scan
vw = viewSet(vw, 'current data type', 'Averages'); 

scanList  = 0; % 0 means all
forceSave = true;
vw = computeCorAnal(vw, scanList, forceSave); 
updateGlobal(vw);

vw = setDisplayMode(vw,'ph'); 
vw = viewSet(vw, 'coherence threshold', .30);
vw = refreshScreen(vw);

%% Compute mean map on averaged scan
vw = computeMeanMap(vw, 0);
updateGlobal(vw)

%view meap map
vw = setDisplayMode(vw, 'map');
vw = viewSet(vw, 'cothresh', 0);
vw = refreshScreen(vw);

%% Xform maps to gray
gr = mrVista('3');
gr = viewSet(gr, 'cur dt', 'Averages');

% Xform coranal
gr = ip2volCorAnal(vw, gr, 0, 1);

gr = setDisplayMode(gr,'ph'); 
gr = viewSet(gr, 'cothresh', .2);
gr = refreshScreen(gr);

% Xform mean map
gr = ip2volParMap(vw, gr, 0, [], 'linear');
gr = viewSet(gr, 'cothresh', 0);
gr = setDisplayMode(gr, 'map');
gr = refreshScreen(gr);















