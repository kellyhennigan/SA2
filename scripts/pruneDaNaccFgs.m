function [fgOut,fgBad] = pruneDaNaccFgs(fgIn,subject,LorR,roi1,roi2,pruneAboveAC,doPlot)
% fgOut = pruneDaNaccPathways(fgIn)
% -------------------------------------------------------------------------
% usage: use this function to specify fiber pruning that is unique to
% DA-Nacc pathways
%
% INPUT:
%   fgIn - .pdb format pathways
%   roi1 - .mat roi file for a subject's da roi
%   roi2 - " " nacc roi
%   subject - subject string (e.g., 'sa01')
%   doPlot - plot fgs
%
% OUTPUT:
%   fgOut - kept nacc-DA pathways
%   fgBad - eliminated fibers
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 01-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% default is not
if notDefined('pruneAboveAC')
    pruneAboveAC = 0;
end

% default is not to plot
if notDefined('doPlot')
    doPlot = 0;
end


fprintf(['\n\n# of fibers before pruneDANaccFgs(): ' num2str(numel(fgIn.fibers)) '\n']);



%% get index for fibers that go more posterior than most posterior DA coord
% more anterior than most anterior nacc coord


o_idx=cellfun(@(x) any(x(2,:)<min(roi1.coords(:,2))), fgIn.fibers);
% o_idx = vertcat(o_idx{:});


%% get index for fibers that go more anterior than most anterior nacc coord

o_idx2=cellfun(@(x) any(x(2,:)>max(roi2.coords(:,2))), fgIn.fibers);
% o_idx = vertcat(o_idx{:});

o_idx(o_idx2==1)=1;


%% get index for fibers that go more than 4 voxels lateral of nacc ROI


o_idx3=cellfun(@(x) any(abs(x(1,:))>max(abs(roi2.coords(:,1)))+4), fgIn.fibers);
% o_idx = vertcat(o_idx{:});

o_idx(o_idx3==1)=1;


%% exclude fibers based on the above criteria

fgOut = getSubFG(fgIn,find(o_idx==0));
fgBad = getSubFG(fgIn,find(o_idx==1));



%% exclude above the AC?

if pruneAboveAC
    fprintf('\n\n omitting fibers that go above the AC...\n\n');
    
    if strcmp(subject,'10') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh = .5;
    elseif strcmp(subject,'11') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh =1;
    elseif strcmp(subject,'16') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh = 1;
    elseif strcmp(subject,'17') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh = 6;
    elseif strcmp(subject,'19') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh = 2;
    elseif strcmp(subject,'20') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh = 10;
    elseif strcmp(subject,'21') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh = 2;
    elseif strcmp(subject,'24') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh = 2;
    elseif strcmp(subject,'29') && strcmp(LorR,'R')
        y_eval=0;
        z_thresh = 2;
%     elseif strcmp(subject,'30') && strcmp(LorR,'R')
%         y_eval=-8;
%         z_thresh = 0;
        
    elseif strcmp(subject,'11') && strcmp(LorR,'L')
        y_eval=0;
        z_thresh = 5;
    elseif strcmp(subject,'12') && strcmp(LorR,'L')
        y_eval=3;
        z_thresh = 0;
    elseif strcmp(subject,'13') && strcmp(LorR,'L')
        y_eval=0;
        z_thresh = 5;
    elseif strcmp(subject,'15') && strcmp(LorR,'L')
        y_eval=0;
        z_thresh = 10;
    elseif strcmp(subject,'17') && strcmp(LorR,'L')
        y_eval=0;
        z_thresh = 5;
    elseif strcmp(subject,'21') && strcmp(LorR,'L')
        y_eval=0;
        z_thresh = 3;
        
    elseif strcmp(subject,'25') && strcmp(LorR,'L')
        y_eval=0;
        z_thresh = 5;
    elseif strcmp(subject,'28') && strcmp(LorR,'L')
        y_eval=0;
        z_thresh = 3;
    elseif strcmp(subject,'29') && strcmp(LorR,'L')
        y_eval=0;
        z_thresh = 7;
 
        
        
    else
        y_eval = 0;  % y-coord of the AC
        z_thresh = 0; % fibers that are above this at the y-coord y-eval will be excluded
    end
    
    
    
    
    
    % temporarily clip all pathways in the coronal plane at the AC
    fg_clipped=dtiClipFiberGroup(fgOut,[],[y_eval 80],[]);
    
    
    % get the z-coord of where the clipped fibers hit the coronal plane where the AC is
    zc=cellfun(@(x) x(3,end), fg_clipped.fibers);
    
    
    % idx of fibers that go above the AC
    aboveAC_idx = zc>z_thresh;
    
    % % fibers below the AC
    fgAboveAC = getSubFG(fgOut,aboveAC_idx==1);
    fgOut = getSubFG(fgOut,aboveAC_idx==0);
    
    
end

%% If desired, render kept fibers in blue and omitted fibers in red

if doPlot
    %     AFQ_RenderFibers(fgIn,'tubes',0,'rois',roi1,roi2); % all input fgs
    %     title('all input fibers')
    AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'rois',roi1,roi2);
    AFQ_RenderFibers(fgBad,'tubes',0,'color',[1 0 0],'newfig',0);
    if exist('fgAboveAC','var')
        AFQ_RenderFibers(fgAboveAC,'tubes',0,'color',[0 1 1],'newfig',0);
    end
    
end


fprintf(['# of fibers after pruneDANaccFgs(): ' num2str(numel(fgOut.fibers)) '\n\n']);


