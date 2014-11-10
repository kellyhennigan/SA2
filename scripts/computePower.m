function power = computePower(D,sd,N,a,nTail,plotFig)
%
% function to compute statistical power for a one sample t-test
%
% INPUTS:
%    D - mean effect (not standardized), based on pilot data or hypothesis
%    sd - standard deviation of the effect D
%    N - sample size for power calculation
%    a - alpha signifcance threshold (P(false positive)); default is .05
%    nTail - 1 or 2 tailed test; default is 2
%    plotFig - set to 1 to plot a figure, otherwise 0
%
% OUTPUT:
%    power - 1 - B, where B = P(false negative)

% note as of now, this is only valid for 1 sample t-tests.
% some background on power analyses is included below.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bg content from here:
% http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0CCwQFjAA&url=http%3A%2F%2Fageconsearch.umn.edu%2Fbitstream%2F116234%2F2%2Fsjart_st0062.pdf&ei=jblFU4iCBMmzyAHSpYAY&usg=AFQjCNE6hUYmTHf6Dju31W_XzX4SUTSOFQ&sig2=DCWzr7tdn-Sj_T3fNVQMIA&bvm=bv.64507335,d.aWc&cad=rja
% and matlabnoncentral t distribution documentation

% BACKGROUND:

% P(Type I error; false positive) = ?
% P(Type II error; false negative) = ?
%
% power = 1 - ?;  P ( reject H0 | H0 is false )
%

% Suppose that we have a single sample, xi, i = 1,...,n, which we assume
% comes from a normal distribution with mean ? and standard deviation ?. We
% wish to test the hypothesis:

%           H0 : ?=?0 versus Ha : ?a?=?0

% for some hypothesized value ?0. The standard parametric test for this
% situation is the one-sample t test. This test is based on the test
% statistic
%
%           T = (x - ?0) / (s/?n)
%
% where x represents the sample mean and s the sample standard
% deviation. Under the null hypothesis, T has a Student?s t-distribution on
% n ? 1 degrees of freedom.

% If the alternative hypothesis ?a is the "true" population mean, then the
% t-stat has a noncentral t distribution with a noncentrality parameter:
%
%           ? = (?a??0) / (?/?n)
%
% The noncentrality parameter is the normalized difference btwn ?0 and ?.
% The noncentral t distribution gives the probability that a t-test will
% correctly reject the false null hypothesis of mean ?0 when the true mean
% is ?a.

% the power increases as:
%     ? - ?0 increases
%     sample size n increases
%
%
% in practice, pilot data can be used to estimate the hypothesized effect
% size (so, the hypothesized mean and sd, ?a and ?)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check variables 

% if no a is given, default is .05
if(~exist('a','var') || isempty(a))
    a = 0.05;
end

% if no nTail is given or if its a value other than 1 or 2, set to 2
if(~exist('nTail','var') || isempty(nTail))
    nTail = 2;
end
if ~ismember(nTail,[1,2])
    nTail = 2;
end

% if plotFig is given, default is 0
if(~exist('plotFig','var') || isempty(plotFig))
    plotFig = 0;
end

%% calculate power 

% noncentrality parameter
ncp = D./(sd./sqrt(N));

% get critical t-value at alpha under the null
if ncp < 0
    tc = tinv(a/nTail,N-1); % critical t-value at alpha under the null
else
    tc = tinv(1-a/nTail,N-1);
end

% determine cumulative prob left of the critical value for the alt hyp
B = nctcdf(tc,N-1,ncp);

% power = 1-B
power = 1-B;


%% plot

if (plotFig)
    
    colors = solarizedColors(8); c0 = colors(1,:); ca = colors(6,:);
    
    % show null and alternative distributions
    x = (-5:0.1:5)';
    t0 = tpdf(x,N-1);  % t-distribution under the null
    ta = nctpdf(x,N-1,ncp); % t-distribution under the alt
    
    figure
    plot(x,t0,'LineWidth',2,'color',c0)
    hold on
    plot(x,ta,'--','LineWidth',2,'color',ca)
    
    xc = [tc,tc,x(x>=tc)']; yc = [0,tpdf(tc,N-1),t0(x>=tc)'];
    patch(xc,yc,c0,'FaceAlpha',.25,'EdgeColor','none')
    xc = [tc,x(x<=tc)',tc]; yc = [0,ta(x<=tc)',nctpdf(tc,N-1,ncp)];
    patch(xc,yc,ca,'FaceAlpha',.25,'EdgeColor','none')
    
    line([tc,tc],ylim,'LineStyle',':','Linewidth',2,'color','k')
    
    leg=legend('H0','Ha','\alpha/2','\beta',['critical t: ',num2str(round(tc.*100)./100)])
    set(leg,'Location','best','FontSize',14); legend(leg,'boxoff')
    title(['N = ',num2str(N), '; power: ',num2str(round(power.*100)),'%'],'FontSize',14)
    
end



