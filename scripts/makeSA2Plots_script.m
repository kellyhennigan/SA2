% makeSA2Plots_script

% script to make figures for project SA2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up

clear all
close all

% get expPaths
paths=getSA2Paths()


% define subjects
subStr = 'all';
subjs = getSA2Subjects('all');


savePlots = 1;
saveDir = ['/Users/Kelly/SA2/figures']


font = 'Helvetica';
fSize = 16;

Conds=[1,2]; % gain and loss

cols=getSA2Colors; 
% cols = [cols(2,:);cols(1,:);cols(3,:);cols(4,:)];

%%  plot of observed and modeled choices

figH = figure; hold on
set(gca,'fontName',font,'fontSize',fSize)
set(gca,'box','off');
set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');

col_idx = 0; % color index

for cc=1:2                    % context - base or stress

for cond = 1:numel(Conds)      % gains and losses
    
    col_idx = col_idx+1;
    
    p = getRLparams(subStr,cond); % best parameter fits
    
    [choices,outcomes]=getSubjChoicesOutcomes(subjs,cond,cc); % get trial choices and outcomes
    
    [nLL(cond),~,Pc1] = fitQLearningMod(p, choices, outcomes); % get model Pc1
    
    choices(choices==2)=0;  % recode choices as 0 and 1 for plotting
    
    scatter([1:36]',nanmean(choices,2),40,cols(col_idx,:),'filled')
    
    plot([1:36]',nanmean(choices,2),'color',cols(col_idx,:))
    
    plot([1:36]',nanmean(Pc1,2),'color',[.5 .5 .5])
    
end


yT = get(gca,'YTick')
set(gca,'YTickLabel',yT.*100)
xlabel('trial number')
ylabel('Observed and Modeled Choices (%)')


end

if savePlots
    outFPath = fullfile(saveDir,'Pchoices.pdf');
    saveas(gcf,outFPath,'pdf');
     saveas(gcf,outFPath,'epsc');
end




