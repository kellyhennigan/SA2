% script for conducting power analyses 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all


%% EDIT AS NEEDED 

a = .001;    % alpha; P(False Positive)
nTail = 2;  % one or two tailed comparison

D = .4405;      % mean condition difference based on group data or hypothesis
sd = .4354;    % st dev of the effect based on pilot data or hypothesis


%% 

N = 10; % starting sample size
power = computePower(D,sd,N,a,nTail);

while power(end)<.9
    
    N(end+1) = N(end)+1;
    power(end+1) = computePower(D,sd,N(end),a,nTail);

end
   
% get index for number of subjects needed for ~80% power
i = find(power>.8); i = i(1);
fprintf(['\n\nestimated subjects needed for 80%% power: ',num2str(N(i)),'\n\n'])

% run computePower once more to plot distributions for >80% power 
computePower(D,sd,N(i),a,nTail,1);

%% plots

% power as a function of number of subjects 
figure
title(['estimated effect (mean, sd): ',num2str(D), ', ',num2str(sd),'; \alpha = ',num2str(a),'; ',num2str(nTail),'-tailed'],'FontSize',18)
hold on
plot(N,power.*100,'b-','linewidth',2)
plot(xlim,[80, 80],'k--')
xlabel('number of subjects')
ylabel('Power (%)')
hold off







    




