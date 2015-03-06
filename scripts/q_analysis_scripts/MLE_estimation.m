% MLE_estimation 
% --------------------------------
% usage: this is a function to estimate an individual's temporal
% discounting rate based on a series of choices between a smaller sooner
% and larger later reward offering. I think I got this script from Sam. 
% 
% INPUT:
%   data - an Nx4 matrix with trial information in each row. The columns
%   contain the following:
%     1 - magnitude of the smaller sooner reward
%     2 - magnitude of the larger later reward
%     3 - delay between the SS and LL 
%     4 - subjects choice 1=SS, 2=LL
% 
% OUTPUT:
%    [k,m.nll] - hyperbolic discounting rate k, variance m, and the neg log
%    likelihood of the model fit
% 
% NOTES:
% 
% author: Sam? 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = MLE_estimation(data)

%This code estimate the implicit discount rate of each subjects
choice    =data(:,4);  %% c = 1 for immadiate choice, 0 for delayed choice
ss        =data(:,1);
ll        =data(:,2);
d         =data(:,3);
N=size(data);
N=N(1);

%Data for one given subject-condition
data_mle=[ss ll d choice];

%Simulated Annealing MLE estimation:

%Initial guess for the parameters that we want to estimate
mu_o=1.1;
r_o=0.1;

vP_0    = [r_o; mu_o];
%Lower and Upper Bounds
vL      = [0.0001,0]';
vU      = [0.999 ,20]';

dsize_param = length(vP_0);

check=multi_logit2(vP_0,data_mle);


% I.    Set SA parameters

% Temperature reduction factor. The value suggested by Corana et al. is .85. See Goffe et al. for more advice.
dRt     = 0.85;
% No. iterations in which only step size changes
%iN_S    = 20;
iN_S    = 20;
% No. iterations before temperature decreases
%iN_T    = 20;
iN_T    = 20;
% Step length vector used in initial step. Algorithm adjusts vM automatically, such that an incorrect initial value gets adapted.
vM      = ones(dsize_param,1);
% Step length adjustment. The suggested value for all elements is 2.
vC      = 2*ones(dsize_param,1);
% Initial temperature
dT      = 1;

% II.   Optimization:Minimization (replace function)

% Initialize
vX_init         = vP_0;
vX              = vX_init;
df              = multi_logit2(vX,data_mle);
vX_opt          = vX;
df_opt          = multi_logit2(vX_opt,data_mle);
dN              = length(vX_opt);
mX(1,1:dN)      = vX_opt';
vf(1)           = df_opt;

for z = 1 : 50,
    for t = 1 : iN_T,
        vnAcp = zeros(dN,1);
        for s = 1 : iN_S,
            for i = 1 : dN,
                vX_test     = vX;
                vX_test(i)  = vX_test(i) + 2*(unifrnd(0,1) - 0.5) * vM(i);
                
                if vX_test(i)>vU(i) || vX_test(i)<vL(i),
                    vX_test(i) = vL(i) + (vU(i) - vL(i))*unifrnd(0,1);
                end
                  
                df_test     = multi_logit2(vX_test,data_mle);
                if df_test <= df && isreal(df_test)==1,
                    vX      = vX_test;
                    df      = df_test;
                    vnAcp(i)= vnAcp(i)+1;
                    if df_test <= df_opt,
                        vX_opt  = vX_test;
                        df_opt  = df_test;
                    end
                elseif isreal(df_test)==1,
                    dp  = exp((df-df_test)/dT);
                    if dp > unifrnd(0,1),
                        vnAcp(i)    = vnAcp(i)+1;
                        vX          = vX_test;
                        df          = df_test;
                    end
                end
            end
        end
        
        % Adjust step length (vM)
        vRatio  = vnAcp / iN_S;
        for i = 1 : dN,
            if vRatio(i) > 0.6,
                vM(i) =  vM(i)*(1 + vC(i) * (vRatio(i)-.6) ./ .4);
            elseif vRatio(i) < 0.4,
                vM(i) =  vM(i)/(1 + vC(i) * (.4-vRatio(i)) ./ .4);
            end
        end
        vselect = vM > 5;
        vM      = vM .* (1-vselect) + 5 * vselect;
    end
    
    % Adjust temperature
    dT  = dRt * dT;
    
    % Start from the best point thus far
    vX      = vX_opt;
    df      = df_opt;
    disp(z)
    vf(z+1)         = df;
    mX(z+1,1:dN)    = vX';
    mM(z,1:dN)      = vM';
end

% % figure
% subplot(3,1,1),plot(vf);
% subplot(3,1,2),plot(mX);
% subplot(3,1,3),plot(mM);

vX_opt;
temp = multi_logit2(vX_opt,data_mle);
output = [vX_opt(1) vX_opt(2) temp];


%plot the results of the model
data_mle=[ss ll d choice];
% figure;
for i = 1:size(data,1)
    if (i == 2)
        hold on;
    end;
    v1 = data_mle(i,1);
    v2 = data_mle(i,2);
    d = data_mle(i,1);
    c = data_mle(i,4)
    
    V1 = v1;
    V2 = v2* 1 /( 1 + vX_opt(1) * d );
    
    opt = 'o-';
    
    if (c == 1)
        opt = [opt 'r'];
    else
        opt = [opt 'b'];
    end;
    
%     plot([0 100], [V1 V2], opt);
end;
% hold off;
% set(gcf, 'Color', [1 1 1]);



end %func


function LLE=multi_logit2(params,data)
k = params(1);
m = params(2);

P = 0;
for i = 1:size(data,1)
    v1 = data(i,1);  %% value of the immediate choice
    v2 = data(i,2);  %% value of the delayed choice
    t = data(i,3);   %% delay in days
    c = data(i,4);   %% c = 1 for immadiate choice, 0 for delayed choice
    
    V1 = v1;  %%no discounting for immediate option
    V2 = v2 * 1/(1+ k * t);
    
    
    P1 = 1 / (1 + exp(-1*m*(V1-V2)) ); %%softmax decision rule.  P1 = probability of choosing SS
    if (c == 1)
        if (P1 == 0)
            LLE = Inf;
            return;
        end;
        P = P + log(P1);
    else
        if (P1 == 1)
            LLE = Inf;
            return;
        end;
        P = P + log(1-P1);
    end;
end;

LLE = -1*P;
end