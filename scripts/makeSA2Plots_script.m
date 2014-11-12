% makeSA2Plots_script

% script to make figures for project SA2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set up

clear all
close all


% define subjects
subjs = getSA2Subjects('all');


%%  plot of model fits

% best parameter fits 
p1 =  [0.1724    3.3236]
p2 =  [0.2224    3.1259]

% get trial choices and outcomes
[choices1,outcomes1]=getSubjChoicesOutcomes(subjs,'gain');
[choices2,outcomes2]=getSubjChoicesOutcomes(subjs,'loss');
outcomes2 = (outcomes2.*-1)+1;

%

[nLL1,~,Pc1] = fitQLearningMod(p1, choices1, outcomes1);
[nLL2,~,Pc2] = fitQLearningMod(p2, choices2, outcomes2);

choices1(choices1==0)=nan; choices1(choices1==2)=0;
choices2(choices2==0)=nan; choices2(choices2==2)=0;

cols=solarizedColors(8); % cols=[cols(2,:);cols(7,:)]
figure
hold on
plot([1:36]',nanmean(choices1,2),'.','color',cols(2,:))
plot([1:36]',nanmean(choices2,2),'.','color',cols(7,:))
plot([1:36]',nanmean(choices1,2),'color',cols(2,:))
plot([1:36]',nanmean(choices2,2),'color',cols(7,:))

plot([1:36]',nanmean(Pc1,2),'color',cols(3,:))
plot([1:36]',nanmean(1-Pc2,2),'color',cols(6,:))



