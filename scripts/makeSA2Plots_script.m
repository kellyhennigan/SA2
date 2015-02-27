% makeSA2Plots_script

% script to make figures for project SA2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up

clear all
close all

% get expPaths
paths=getSA2Paths()


% define subjects
subStr = 'RL'; % 'all', etc.


savePlots = 1;
saveDir = ['/Users/Kelly/SA2/figures']


font = 'Helvetica';
fSize = 16;

Conds=[1,2]; % gain and loss

cols=getSA2Colors(); 

subjs = getSA2Subjects(subStr);

%%  plot of observed and modeled choices

figH = setupFig();
% figH = figure; hold on
% set(gca,'fontName',font,'fontSize',fSize)
% set(gca,'box','off');
% set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');

col_idx = 0; % color index

for cc=1:2                    % context - base or stress

for cond = 1:numel(Conds)      % gains and losses
    
    col_idx = col_idx+1;
    
    p = getRLparams(subStr,cond); % best parameter fits
    
    [choices,outcomes]=getSubjChoicesOutcomes(subjs,cond,cc); % get trial choices and outcomes
    
    [nLL(cond),~,Pc1] = fitQLearningMod(p, choices, outcomes); % get model Pc1
    
    choices(choices==2)=0;  % recode choices as 0 and 1 for plotting
    
    col = getSA2Colors(cond,cc); % get color for plotting 
    
    scatter([1:36]',nanmean(choices,2),40,col,'filled')
    
    plot([1:36]',nanmean(choices,2),'color',col)
    
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




